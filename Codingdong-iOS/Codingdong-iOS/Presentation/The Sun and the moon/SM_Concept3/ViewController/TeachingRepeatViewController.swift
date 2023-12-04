//
//  TeachingRepeatViewController.swift
//  Codingdong-iOS
//
//  Created by Joy on 11/14/23.
//

import UIKit
import Log

final class TeachingRepeatViewController: UIViewController, ConfigUI {

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
         You have shaken it 10 times so far.

         Is it hard?
         
         If you use a 'Repeat', you can complete more comfortably.
         """
        label.textColor = .gs10
        label.font = FontManager.footnote()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let repeatImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "sm_repeat1")
        imageView.isAccessibilityElement = true
        return imageView
    }()
    
    private let tenTimesImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "sm_repeat3")
        return imageView
    }()
    
    private var tenTimesImageRightConstraints: NSLayoutConstraint?
    
    private let nextButton = CommonButton()
    
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "Next", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2) {[weak self] in
        self?.navigationController?.pushViewController(SunMoonOnuiiViewController(), animated: false)
    }

    // MARK: View init
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
        [contentLabel, repeatImage, tenTimesImage, nextButton].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(Constants.Button.buttonPadding)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        repeatImage.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(60)
            $0.left.equalToSuperview().offset(40)
        }
        
        tenTimesImageRightConstraints = tenTimesImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 252)
        guard let tenTimeImageRightConstraints = tenTimesImageRightConstraints else { return }
        tenTimeImageRightConstraints.isActive = true
        
        tenTimesImage.snp.makeConstraints {
            $0.centerY.equalTo(repeatImage)
        }
        
        nextButton.setup(model: nextButtonViewModel)
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(Constants.Button.buttonPadding)
            $0.bottom.equalToSuperview().inset(Constants.Button.buttonPadding * 2)
        }

    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        view.accessibilityElements = [contentLabel, repeatImage, nextButton, leftBarButtonElement]
        repeatImage.accessibilityLabel = "Then, you can shake 100 times quickly. right?"
        repeatImage.accessibilityTraits = .none
    }
    
    @objc func popThisView() {
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
    
    func playAnimationWithVoiceOver() {
        if UIAccessibility.isVoiceOverRunning {
            NotificationCenter.default.addObserver(self, selector: #selector(voiceOverFocusChanged), name: UIAccessibility.elementFocusedNotification, object: nil)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                self.multiTenTimesSpringAnimation()
            }
        }
    }
    
    @objc
    private func voiceOverFocusChanged(_ notification: Notification) {
        if let focusedElement = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? NSObject, focusedElement === repeatImage {
            self.multiTenTimesSpringAnimation()
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
            Log.i("focus changed")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func multiTenTimesSpringAnimation() {
        UIView.animate(withDuration: 2,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4,
                       options: []) { [weak self] in
            guard let self = self else { return }
            self.tenTimesImageRightConstraints?.constant = -52
            self.view.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
}
