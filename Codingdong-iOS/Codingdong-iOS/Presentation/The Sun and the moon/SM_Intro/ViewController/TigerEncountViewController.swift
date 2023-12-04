//
//  TigerEncountViewController.swift
//  Codingdong-iOS
//
//  Created by BAE on 2023/11/10.
//

import UIKit
import Combine
import Log

final class TigerEncountViewController: UIViewController, ConfigUI {
    var viewModel = TigerEncounterViewModel()
    private var cancellable = Set<AnyCancellable>()
    
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
    
    var allyBarTitle: UIBarButtonItem?
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = """
                    Mother went to work early morning. While crossing the hill, she met a tiger.

                    Tiger said.
                    “I won’t hurt you if you give me one piece of rice cake.”

                    Let’s make rice cake skewer for mother’s safety!
                    """
        label.font = FontManager.body()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let nextButton = CommonButton()
    
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "Make Rice Cake Skewer", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .primary2, height: 72) {[weak self] in
        self?.viewModel.moveOn()
    }
    
    private let basicPadding = Constants.Button.buttonPadding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        binding()
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
        [contentLabel, nextButton].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        nextButton.setup(model: nextButtonViewModel)
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(basicPadding)
            $0.left.right.equalToSuperview().inset(basicPadding)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(basicPadding)
            $0.bottom.equalToSuperview().offset(-basicPadding * 2)
        }
    }
    
    func setupAccessibility() {
        let naviTitleElement = setupNavigationTitleAccessibility(label: navigationTitle.text ?? "No Title")
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        view.accessibilityElements = [naviTitleElement, contentLabel, nextButton, leftBarButtonElement]
    }
    
    func binding() {
        self.viewModel.route
            .sink { [weak self] nextView in
                self?.navigationController?.pushViewController(nextView, animated: false)
            }
            .store(in: &cancellable)
    }
        
    @objc
    func popThisView() {
        navigationController?.pushViewController(CustomAlert(), animated: false)
    }
}
