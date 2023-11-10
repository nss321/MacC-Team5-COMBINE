//
//  TigerAnimationViewController.swift
//  Codingdong-iOS
//
//  Created by BAE on 2023/10/23.
//

import UIKit
import SnapKit

final class TigerAnimationViewController: UIViewController, ConfigUI {
    
    private let naviLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "떡을 모두 빼앗긴 엄마는 호랑이에게 잡아먹히고 말았어요."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.body()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        
        return label
    }()
    
    private let animationView = TigerLottieAnimationView()
    
    private var btnBottomConstraints: NSLayoutConstraint?
    
    private let nextButton = CommonButton()
    
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "다음", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2, height: 72, didTouchUpInside: didClickNextButton)
    
    private let leftBarButtonItem: UIBarButtonItem = {
        let leftBarButton = UIBarButtonItem(
            image: UIImage(systemName: "books.vertical"),
            style: .plain,
            target: TigerAnimationViewController.self,
            // TODO: StorySelectView 작업 후 연결하기
            action: .none
        )
        
        return leftBarButton
    }()
    
    private let navigationTitle: UILabel = {
        let label = UILabel()
        label.text = "호랑이를 마주친 엄마"
        label.font = FontManager.navigationtitle()
        label.textColor = .gs20
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        
        setupAccessibility()
        setupNavigationBar()
        addComponents()
        setConstraints()
        nextButton.setup(model: nextButtonViewModel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverFocusChanged), name: UIAccessibility.elementFocusedNotification, object: nil)
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
        [titleLabel, animationView, nextButton].forEach {
            view.addSubview($0)
        }
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(122)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        
        animationView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        btnBottomConstraints = nextButton.bottomAnchor.constraint(equalTo: super.view.bottomAnchor, constant: 72)
        guard let bottomConstraints = btnBottomConstraints else { return }
        bottomConstraints.isActive = true
        
        nextButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(Constants.Button.buttonPadding)
            $0.right.equalToSuperview().offset(-Constants.Button.buttonPadding)
        }
    }
    
    func setupAccessibility() {
        navigationItem.accessibilityElements = [leftBarButtonItem, navigationTitle]
        view.accessibilityElements = [titleLabel, nextButton]
        
        leftBarButtonItem.accessibilityLabel = "내 책장"
        leftBarButtonItem.accessibilityTraits = .button
        
        titleLabel.accessibilityLabel = "본문"
        titleLabel.accessibilityValue = "떡을 모두 빼앗긴 엄마는 호랑이에게 잡아먹히고 말았어요."
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension TigerAnimationViewController {
    
    private func bottomBtnSpringAnimation() {
        UIView.animate(withDuration: 0.5,
                       delay: 2.5,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: []) { [weak self] in
            guard let self = self else { return }
            self.btnBottomConstraints?.constant = -Constants.Button.buttonPadding * 2
            self.view.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    @objc
    func didClickNextButton() {
        // TODO: 다음 화면으로 내비게이션 연결 추가해야함.
        // TODO: 버튼에 액션 연결되지 않은 상태.
        print("너무 아름다운 다운 다운 다운 View")
        self.navigationController?.pushViewController(IfConceptViewController(), animated: false)
    }
    
    @objc
    func voiceOverFocusChanged(_ notification: Notification) {
        if UIAccessibility.isVoiceOverRunning {
            if let focusedElement = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? NSObject, focusedElement === titleLabel {
                LottieManager.shared.playAnimation(inView: animationView.lottieView, completion: nil)
                LottieManager.shared.removeAnimation(inView: animationView.lottieView)
                self.bottomBtnSpringAnimation()
                UIAccessibility.post(notification: .layoutChanged, argument: nil)
            }
        }
    }
    
}
