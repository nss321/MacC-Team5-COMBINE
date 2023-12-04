//
//  ReviewViewController.swift
//  Codingdong-iOS
//
//  Created by Joy on 11/12/23.
//

import UIKit
import Log

final class ReviewViewController: UIViewController, ConfigUI {
    
    // 뷰 전체 model, cellModel
    // MARK: - ViewModel
    private var viewModel = ReviewViewModel()
    private var cellModels: [CardViewModel] = [.init(title: "If : Conditional", content: "'If' corresponds to 'Conditional' in codes. It can cause different actions depending on the situation.", cardImage: "sm_review1"),
        .init(title: "And : Operator", content: "'And' corresponds to 'Operator' in codes. Operator judges the 'true' and 'false' of the condition.", cardImage: "sm_review2"),
        .init(title: "Repeat : Loops", content: "'Repeat' corresponds to 'Loops' in codes. Loops can make the same action repeat.", cardImage: "sm_review3")]
    
    // MARK: - Components
    private let naviLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.15)
        return view
    }()
    
    private let navigationTitle: UILabel = {
        let label = UILabel()
        label.text = "Review"
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
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "Three coding concepts from 'The Sun and The Moon'"
        label.textColor = .gs10
        label.numberOfLines = 0
        label.font = FontManager.footnote()
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var reviewCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.register(ReviewCollectionViewCell.self, forCellWithReuseIdentifier: ReviewCollectionViewCell.identifier)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .gs90
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let pageControlContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .gs40
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let pageControl = UIPageControl()
    private let nextButton = CommonButton()
    private lazy var nextButtonViewModel = CommonbuttonModel(title: "End the story", font: FontManager.textbutton(), titleColor: .primary1, backgroundColor: .gs10) {[weak self] in
        self?.viewModel.endStory()
        self?.navigationController?.popToRootViewController(animated: false)
    }
    
    private let padding = Constants.View.padding

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        setupPageControl()
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
        self.navigationItem.titleView = navigationTitle
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func addComponents() {
        [contentLabel, reviewCollectionView, nextButton].forEach { view.addSubview($0) }
        
        let collectionViewFlowLayout: UICollectionViewFlowLayout = {
            let layout = CustomCollectionViewFlowLayout()
            layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height - 348)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            return layout
        }()
        
        reviewCollectionView.collectionViewLayout = collectionViewFlowLayout
        reviewCollectionView.decelerationRate = .fast
        reviewCollectionView.isPagingEnabled = false
    }
    
    func setupPageControl() {
        view.addSubview(pageControlContainer)
        pageControlContainer.addSubview(pageControl)
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .white.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .white
        
        pageControlContainer.snp.makeConstraints {
            $0.top.equalTo(reviewCollectionView.snp.bottom).offset(-44)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 64, height: 24))
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    func setConstraints() {
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(padding)
            $0.left.right.equalToSuperview().inset(padding)
        }
        
        reviewCollectionView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(padding)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().inset(142)
        }
        nextButton.setup(model: nextButtonViewModel)
        nextButton.snp.makeConstraints {
            $0.top.equalTo(reviewCollectionView.snp.bottom).offset(38)
            $0.left.right.equalToSuperview().inset(padding)
            $0.bottom.equalToSuperview().inset(padding * 2)
        }
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My bookshelf")
        let naviTitleElement = setupNavigationTitleAccessibility(label: navigationTitle.text ?? "타이틀 없음")
        view.accessibilityElements = [naviTitleElement, contentLabel, reviewCollectionView, nextButton, leftBarButtonElement]
    }
    
    @objc private func popThisView() {
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
}

// MARK: - Extension
extension ReviewViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.identifier, for: indexPath) as? ReviewCollectionViewCell else { fatalError() }
        cell.cardViewModel = cellModels[indexPath.row]
        return cell
    }
}

extension ReviewViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width

        // 화면 가로 길이: 스크롤뷰에서 얼만큼 움직였는지
        let x = scrollView.contentOffset.x + (width/2)
        let newPage = Int(x/width)
        if pageControl.currentPage != newPage {
            pageControl.currentPage = newPage
        }
    }
}
