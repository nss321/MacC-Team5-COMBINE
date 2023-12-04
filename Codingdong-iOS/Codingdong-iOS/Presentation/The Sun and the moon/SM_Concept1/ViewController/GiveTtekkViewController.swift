//
//  Quiz1ViewController.swift
//  Codingdong-iOS
//
//  Created by 이승용 on 10/20/23.
//

import UIKit
import CoreMotion

final class GiveTtekkViewController: UIViewController, ConfigUI {

    private let padding = Constants.View.padding
    
    private let hapticManager = HapticManager()
    
    private let motionManager = CMMotionManager()
    
    private let naviLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    private let navigationTitle: UILabel = {
        let label = UILabel()
        label.text = "Mother met the tiger"
        label.font = FontManager.navigationtitle()
        label.textColor = .gs20
        return label
    }()
    
    private lazy var leftBarButtonItem: UIBarButtonItem = {
        let leftBarButton = UIBarButtonItem(
            image: UIImage(systemName: "books.vertical"),
            style: .plain,
            target: self,
            action: #selector(popThisView)
        )
        return leftBarButton
    }()
//    
    private let storyLabel: UILabel = {
        let label = UILabel()
        label.text = """
            Oh! The tiger is asking for rice cake again!
            Shake the device and give rice cake!
            """
        label.font = FontManager.body()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let ttekkStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fillEqually
        stack.isAccessibilityElement = true
        return stack
    }()
    
    private let nextButton = CommonButton()
    
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "Next", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2) { [weak self] in
        self?.navigationController?.pushViewController(TigerAnimationViewController(), animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        countShake()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAccessibility()
        navigationController?.navigationBar.accessibilityElementsHidden = true
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        view.accessibilityElements = [storyLabel, ttekkStackView, nextButton, leftBarButtonElement]
        ttekkStackView.accessibilityLabel = "There are five rice cakes left. Let's give them to the tiger!"
    }
    
    func setupNavigationBar() {
        view.addSubview(naviLine)
        naviLine.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.33)
        }
        
        self.navigationController?.navigationBar.tintColor = .gs20
        self.navigationItem.titleView = self.navigationTitle
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
    }
    
    func addComponents() {
        
        [storyLabel, ttekkStackView, nextButton].forEach(view.addSubview)
        nextButton.isHidden = true
        let ttekks = (1...5).map { _ in
            return self.createTtekkViews(height: 112, cornerRadius: 56)
        }
        ttekks.forEach(ttekkStackView.addArrangedSubview)
    }
    
    func setConstraints() {
        storyLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(padding)
            $0.left.right.equalToSuperview().inset(padding)
        }
        
        ttekkStackView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview().inset(4)
        }
        
        nextButton.setup(model: nextButtonViewModel)
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(padding)
            $0.bottom.equalToSuperview().inset(padding * 2)
        }
    }
}

extension GiveTtekkViewController {
    
    @objc
    func popThisView() {
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
    
    @objc
    private func didClickNextButton() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func createTtekkViews(height: CGFloat, cornerRadius: CGFloat) -> UIView {
        let ttekkView = UIView()
        ttekkView.backgroundColor = .white
        ttekkView.layer.cornerRadius = cornerRadius
        ttekkView.snp.makeConstraints { $0.height.equalTo(height) }
        return ttekkView
    }
    
    func handleShake() {
        let ttekks = ttekkStackView.arrangedSubviews
        
        if ttekks.count > 1 {
            guard let poppedView = ttekks.last else { return }
            ttekkStackView.removeArrangedSubview(poppedView)
            poppedView.removeFromSuperview()
            hapticManager?.playNomNom()
            ttekkStackView.accessibilityLabel = "There are \(ttekks.count - 1) rice cakes left. Let's give them to the tiger!"
        } else {
            // 다음 뷰
            ttekkStackView.isHidden = true
            ttekkStackView.isAccessibilityElement = false
            hapticManager?.playSplash()
            motionManager.stopAccelerometerUpdates()
            nextButton.isHidden = false
            storyLabel.text = """
                        The greedy tiger must still be hungry.

                        We don't have any more rice cakes. What should we do?

                        The tiger is staring at the mother in fear,,,
                        """
            UIAccessibility.post(notification: .layoutChanged, argument: self.storyLabel)
        }
        //        TTS는 iOS 17 이슈로 동작하지 않음.
//        SoundManager.shared.playTTS("\(ttekks.count)개 남았어")
    }
    
    func countShake() {
        // CoreMotion을 사용한 방법
        // Threshold를 조절해서 인식 강도 조절 가능
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, _) in
                if let acceleration = data?.acceleration {
                    let shakeThreshold = 0.7  // 흔들기 인식 강도
                    // 흔들기 감지
                    if acceleration.x >= shakeThreshold || acceleration.y >= shakeThreshold || acceleration.z >= shakeThreshold {
                        self.handleShake()
                    }
                }
            }
        }
    }
    
}
