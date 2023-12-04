//
//  SunAndMoonIntroViewController.swift
//  Codingdong-iOS
//
//  Created by BAE on 2023/11/08.
//

import UIKit
import Combine
import Log

final class SunAndMoonIntroViewController: UIViewController, ConfigUI {
    var viewModel = SunAndMoonIntroViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private let naviLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    private let navigationTitle: UILabel = {
        let label = UILabel()
        label.text = "The Sun and The Moon"
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
    
    // 지우기
    // private let labelComponents = SunAndMoonIntroView()
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "Let's learn three coding concepts below!"
        label.isAccessibilityElement = true
        label.font = FontManager.body()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let firstConceptLabel: UILabel = {
        let label = UILabel()
        label.text = "Concept 1. Conditional"
        label.font = FontManager.title3()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let firstDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Mother met the tiger"
        label.font = FontManager.caption2()
        label.textColor = .gs30
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let secondConceptLabel: UILabel = {
        let label = UILabel()
        label.text = "Concept 2. Operator"
        label.font = FontManager.title3()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let secondDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "At the sibling's house"
        label.font = FontManager.caption2()
        label.textColor = .gs30
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let thirdConceptLabel: UILabel = {
        let label = UILabel()
        label.text = "Concept 3. Loops"
        label.font = FontManager.title3()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let thirdDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Climb the rope!"
        label.font = FontManager.caption2()
        label.textColor = .gs30
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let nextButton = CommonButton()
    
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "Start", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .gs10, height: 72) {
        self.viewModel.moveOn()
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
    
    // Used viewDidLayoutSubView to read the frame of each label
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAccessibility()
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
        [introLabel, firstConceptLabel, firstDescriptionLabel, secondConceptLabel, secondDescriptionLabel, thirdConceptLabel, thirdDescriptionLabel, nextButton].forEach {
            view.addSubview($0)
        }
    }
    
    func setConstraints() {
        introLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        firstConceptLabel.snp.makeConstraints {
            $0.top.equalTo(introLabel.snp.bottom).offset(32)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        firstDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(firstConceptLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        secondConceptLabel.snp.makeConstraints {
            $0.top.equalTo(firstDescriptionLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        secondDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(secondConceptLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        thirdConceptLabel.snp.makeConstraints {
            $0.top.equalTo(secondDescriptionLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        thirdDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(thirdConceptLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(basicPadding)
            $0.right.equalToSuperview().offset(-basicPadding)
            $0.bottom.equalToSuperview().offset(-basicPadding * 2)
        }
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        
        view.accessibilityElements = [introLabel]
        [[firstConceptLabel, firstDescriptionLabel], [secondConceptLabel, secondDescriptionLabel], [thirdConceptLabel, thirdDescriptionLabel]].forEach {
            let groupedElement = UIAccessibilityElement(accessibilityContainer: self.view!)
            groupedElement.accessibilityLabel = "\($0[0].text ?? "")\n\($0[1].text ?? "")"
            groupedElement.accessibilityFrameInContainerSpace = $0[0].frame.union($0[1].frame)
            view.accessibilityElements?.append(groupedElement)
        }
        view.accessibilityElements?.append(contentsOf: [nextButton, leftBarButtonElement])
    }

    func binding() {
        nextButton.setup(model: nextButtonViewModel)
        
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
