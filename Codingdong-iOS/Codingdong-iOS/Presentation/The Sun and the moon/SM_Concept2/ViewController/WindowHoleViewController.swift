//
//  WindowHoleViewController.swift
//  Codingdong-iOS
//
//  Created by 이승용 on 11/6/23.
//

import UIKit

final class WindowHoleViewController: UIViewController, ConfigUI {
    // MARK: - Components
    private let naviLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
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
    
    private let navigationTitle: UILabel = {
       let label = UILabel()
        label.text = "At the siblings’ house"
        label.font = FontManager.navigationtitle()
        label.textColor = .gs20
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = """
                    Tap holes and find out who's outside the door.
                    """
        label.font = FontManager.footnote()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private let windowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "initialDoor")
        imageView.isAccessibilityElement = false
        return imageView
    }()
    
    private let tigerHandHoleAnimationView: TigerHandHoleAnimationView = {
        let view = TigerHandHoleAnimationView()
        view.tag = AnimationType.hand.rawValue
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let tigerNoseHoleAnimationView: TigerNoseHoleAnimationView = {
        let view = TigerNoseHoleAnimationView()
        view.tag = AnimationType.nose.rawValue
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let tigerTailHoleAnimationView: TigerTailHoleAnimationView = {
        let view = TigerTailHoleAnimationView()
        view.tag = AnimationType.tail.rawValue
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let nextButton = CommonButton()
    
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "Next",font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2, height: 72) { [weak self] in
        self?.navigationController?.pushViewController(WindowVoiceViewController(), animated: false)
    }
    
    // MARK: - View init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        setGestureRecognizer()
        nextButton.isHidden = true
        nextButton.setup(model: nextButtonViewModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAccessibility()
        navigationController?.navigationBar.accessibilityElementsHidden = true
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
    }
    
    func addComponents() {
        [titleLabel, windowImageView, tigerHandHoleAnimationView, tigerNoseHoleAnimationView, tigerTailHoleAnimationView, nextButton].forEach {
            view.addSubview($0)
        }
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(Constants.View.padding)
            $0.left.right.equalToSuperview().inset(Constants.View.padding)
        }
        
        windowImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(256)
            $0.left.right.equalToSuperview().inset(51)
            $0.bottom.equalToSuperview().inset(118)
        }
        
        tigerHandHoleAnimationView.snp.makeConstraints {
            $0.top.equalTo(windowImageView.snp.top).offset(180)
            $0.left.equalTo(windowImageView.snp.left).offset(52)
            $0.right.equalTo(windowImageView.snp.right).inset(186)
            $0.bottom.equalTo(windowImageView.snp.bottom).inset(230)
            
        }
        
        tigerNoseHoleAnimationView.snp.makeConstraints {
            $0.top.equalTo(windowImageView.snp.top).offset(84)
            $0.left.equalTo(windowImageView.snp.left).offset(176)
            $0.right.equalTo(windowImageView.snp.right).inset(48)
            $0.bottom.equalTo(windowImageView.snp.bottom).inset(332)
        }
        
        tigerTailHoleAnimationView.snp.makeConstraints {
            $0.top.equalTo(windowImageView.snp.top).offset(316)
            $0.left.equalTo(windowImageView.snp.left).offset(153)
            $0.right.equalTo(windowImageView.snp.right).inset(75)
            $0.bottom.equalTo(windowImageView.snp.bottom).inset(88)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.Button.buttonPadding)
            $0.bottom.equalToSuperview().inset(Constants.Button.buttonPadding * 2)
        }
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        
        view.accessibilityElements = [titleLabel, tigerNoseHoleAnimationView, tigerHandHoleAnimationView, tigerTailHoleAnimationView, nextButton, leftBarButtonElement]
    }
    
}

extension WindowHoleViewController {
    enum AnimationType: Int {
        case hand = 1
        case nose = 2
        case tail = 3
    }
    
    @objc func popThisView() {
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
    
    func setGestureRecognizer() {
        [tigerHandHoleAnimationView, tigerNoseHoleAnimationView, tigerTailHoleAnimationView].forEach {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        }
    }
    
    @objc 
    func viewTapped(_ sender: UITapGestureRecognizer) {
        self.nextButton.isHidden = false
        if let type = AnimationType(rawValue: sender.view?.tag ?? 1) {
            switch type {
            case .hand:
                tigerHandHoleAnimationView.lottieView.accessibilityLabel = "a tiger's hand with sharp claws"
                HapticManager.shared?.playSplash()
                SoundManager.shared.playSound(sound: .tiger)
                LottieManager.shared.playAnimation(inView: tigerHandHoleAnimationView.lottieView, completion: nil)
                LottieManager.shared.removeAnimation(inView: tigerHandHoleAnimationView.lottieView)
            case .nose:
                tigerNoseHoleAnimationView.lottieView.accessibilityLabel = "a sniffing tiger's nose"
                HapticManager.shared?.playSplash()
                SoundManager.shared.playSound(sound: .tiger)
                LottieManager.shared.playAnimation(inView: tigerNoseHoleAnimationView.lottieView, completion: nil)
                LottieManager.shared.removeAnimation(inView: tigerNoseHoleAnimationView.lottieView)
            case .tail:
                tigerTailHoleAnimationView.lottieView.accessibilityLabel = "a wobbly tiger's tail"
                HapticManager.shared?.playSplash()
                SoundManager.shared.playSound(sound: .tiger)
                LottieManager.shared.playAnimation(inView: tigerTailHoleAnimationView.lottieView, completion: nil)
                LottieManager.shared.removeAnimation(inView: tigerTailHoleAnimationView.lottieView)
            }
        }
    }
}
