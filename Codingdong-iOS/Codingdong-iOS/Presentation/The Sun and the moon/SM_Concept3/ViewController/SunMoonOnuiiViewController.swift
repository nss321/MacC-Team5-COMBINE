//
//  SunMoonOnuiiViewController.swift
//  Codingdong-iOS
//
//  Created by Joy on 11/13/23.
//

import UIKit
import Combine

final class SunMoonOnuiiViewController: UIViewController, ConfigUI {

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
        label.text = "Climb the rope!"
        label.font = FontManager.navigationtitle()
        label.textColor = .gs20
        return label
    }()
    
    private let contentLabel: UILabel = {
       let label = UILabel()
        label.text = """
        The siblings could climb up the rope,
        
        and they became the sun and the moon.
        """
        label.textColor = .gs10
        label.font = FontManager.footnote()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let nextButton = CommonButton()
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "Next", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2) {[weak self] in
        CddDBService().updateFood(Food(image: "img_yugwa1", concept: "Loop"))
        self?.navigationController?.pushViewController(RepeatConceptViewController(), animated: false)
    }
    
    lazy var lottieView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        LottieManager.shared.setAnimationForOnui(named: "OnuiAnimation_Fixed", inView: view)
        return view
    }()
    
    // MARK: - View Init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        playAnimationWithVoiceOver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAccessibility()
        navigationController?.navigationBar.accessibilityElementsHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        [contentLabel, lottieView, nextButton].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        lottieView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        nextButton.setup(model: nextButtonViewModel)
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.Button.buttonPadding)
            $0.bottom.equalToSuperview().inset(Constants.Button.buttonPadding*2)
        }
        
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My bookshelf")
        view.accessibilityElements = [contentLabel, nextButton, leftBarButtonElement]
    }
    
}

extension SunMoonOnuiiViewController {
    
    @objc private func popThisView() {
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
    
    func playAnimationWithVoiceOver() {
        if UIAccessibility.isVoiceOverRunning {
            NotificationCenter.default.addObserver(self, selector: #selector(voiceOverFocusChanged), name: UIAccessibility.elementFocusedNotification, object: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                LottieManager.shared.playAnimation(inView: self.lottieView, completion: nil)
            }
        }
    }
    
    @objc
    private func voiceOverFocusChanged(_ notification: Notification) {
        if let focusedElement = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? NSObject, focusedElement === contentLabel {
            LottieManager.shared.playAnimation(inView: self.lottieView, completion: nil)
            LottieManager.shared.removeAnimation(inView: self.lottieView)
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }
    
}
