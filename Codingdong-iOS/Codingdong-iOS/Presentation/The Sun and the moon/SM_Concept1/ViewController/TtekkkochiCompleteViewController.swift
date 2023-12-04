//
//  TtekkkochiCompleteViewController.swift
//  Codingdong-iOS
//
//  Created by Joy on 12/3/23.
//

import UIKit
import CoreMotion
import Log
import Combine

final class TtekkkochiCompleteViewController: UIViewController {
    private let motionManager = CMMotionManager()
    var viewModel = TtekkkochiViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Components
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
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = """
        Good job! The Fllowing rice cakes were stuck. 'If you', 'give me the rice cake', 'I won't eat you.'
        
        This time, shall we shake our phone up and down?
        """
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.footnote()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let stickView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var ttekkkochiCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(TtekkkochiCollectionViewCell.self, forCellWithReuseIdentifier: TtekkkochiCollectionViewCell.identifier)
        view.isAccessibilityElement = false
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    private let nextButton = CommonButton()
    private lazy var settingButtonViewModel = CommonbuttonModel(title: "Next", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2) {[weak self] in
       self?.viewModel.selectItem()
    }

    private let ttekkkochiCollectionViewElement: UIAccessibilityElement = {
        let element = UIAccessibilityElement(accessibilityContainer: TtekkkochiCompleteViewController.self)
        element.accessibilityLabel = "If you \n give me the rice cake, \n I won't eat you!"
        return element
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        //initializeView()
        setupNavigationBar()
        addComponents()
        setConstraints()
        detectMotion()
        binding()
        nextButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
       // binding()
    }
    
    func setupNavigationBar() {
        view.addSubview(naviLine)
        naviLine.snp.makeConstraints {
            $0.top.equalToSuperview().offset(106)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(0.33)
        }
        self.navigationController?.navigationBar.tintColor = .gs20
        self.navigationItem.titleView = self.navigationTitle
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
        navigationController?.navigationBar.accessibilityElementsHidden = true
    }
    
    func addComponents() {
        [titleLabel, ttekkkochiCollectionView, nextButton, stickView].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        ttekkkochiCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(95)
            $0.bottom.equalToSuperview().offset(-115)
        }
        
        stickView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(191)
            $0.bottom.equalToSuperview().offset(-115)
        }
        
        self.view.sendSubviewToBack(stickView)
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.Button.buttonPadding)
            $0.bottom.equalToSuperview().inset(Constants.Button.buttonPadding * 2)
            $0.height.equalTo(72)
        }
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        ttekkkochiCollectionViewElement.accessibilityFrameInContainerSpace = ttekkkochiCollectionView.frame
        view.accessibilityElements = [titleLabel, ttekkkochiCollectionViewElement, nextButton, leftBarButtonElement]
    }
    
    func binding() {
        self.viewModel.route
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] nextView in
                self?.navigationController?.pushViewController(nextView, animated: false)
            })
            .store(in: &cancellable)
    }
    
    @objc
    func popThisView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.ttekkkochiCollectionView.reloadData()
        }
//
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
}

// MARK: - Extension
extension TtekkkochiCompleteViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answerBlocks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TtekkkochiCollectionViewCell.identifier, for: indexPath) as? TtekkkochiCollectionViewCell else { fatalError() }
        cell.block = answerBlocks[indexPath.row]
        return cell
    }
}

extension TtekkkochiCompleteViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width
        return CGSize(width: cellWidth, height: cellWidth/3.2)
    }
}

extension TtekkkochiCompleteViewController {
    func detectMotion() {
        
        // Device motion을 수집 가능한지 확인
        guard motionManager.isDeviceMotionAvailable else {
            Log.e("Device motion data is not available")
            return
        }
        // 모션 갱신 주기 설정 (10Hz)
        motionManager.deviceMotionUpdateInterval = 0.1
        // Device motion 업데이트 받기 시작
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, error == nil else {return}
            // 필요한 센서값 불러오기
            let acceleration = data.userAcceleration
            let shakeThreshold = 0.5  // 흔들기 인식 강도

            if acceleration.x >= shakeThreshold || acceleration.y >= shakeThreshold || acceleration.z >= shakeThreshold {
                if abs(acceleration.x) < 0.5 && abs(acceleration.y) > 0 && abs(acceleration.z) < 0.5 {
                    (3...4).forEach { answerBlocks[$0].isShowing = true }
                    DispatchQueue.global().async { SoundManager.shared.playSound(sound: .bell) }
                    self?.ttekkkochiCollectionView.reloadData()
                    self?.titleLabel.text = """
                                            Fantastic!
                                            
                                            Let's check if it's well made!
                                            
                                            """
                    self?.ttekkkochiCollectionViewElement.accessibilityLabel = "If you \n give me the rice cake \n I won't eat you \n If else, \n I'll eat you \n Wow. It's perfect. Let's move on. "
                    UIAccessibility.post(notification: .layoutChanged, argument: self?.titleLabel)
                    
                    self?.motionManager.stopDeviceMotionUpdates()
                    self?.nextButton.isHidden = false
                    self?.nextButton.setup(model: self!.settingButtonViewModel)

                }
            }
        }
    }
}
