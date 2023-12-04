//
//  TtekkkochiViewController.swift
//  Codingdong-iOS
//
//  Created by Joy on 10/20/23.
//

import UIKit
import Combine
import Log
import CoreMotion

final class TtekkkochiViewController: UIViewController, ConfigUI {
    var viewModel = TtekkkochiViewModel()
    private var cancellable = Set<AnyCancellable>()
    private var hapticManager: HapticManager?
    private let motionManager = CMMotionManager()
    
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
        You can make rice cake skewers by swinging the phone quickly from right to left.
        
        Let's make it and give it to the tiger!
        """
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.footnote()
        label.textColor = .gs10
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
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
    
    private let ttekkkochiCollectionViewElement: UIAccessibilityElement = {
        let element = UIAccessibilityElement(accessibilityContainer: TtekkkochiViewController.self)
        element.accessibilityLabel = "This is a skewer. Let's hurry up and swing the phone and put the rice cake in!"
        return element
    }()
    
    // MARK: - View init
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gs90
        setupNavigationBar()
        addComponents()
        setConstraints()
        startRecordingDeviceMotion()
        initializeView()
    }
    
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
        [titleLabel, ttekkkochiCollectionView, stickView].forEach { view.addSubview($0) }
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(naviLine.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        ttekkkochiCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(95)
            $0.bottom.equalToSuperview().offset(-120)
        }
        
        stickView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(191)
            $0.bottom.equalToSuperview().offset(-90)
        }
        
        self.view.sendSubviewToBack(stickView)
    }
    
    func setupAccessibility() {
        let leftBarButtonElement = setupLeftBackButtonItemAccessibility(label: "My Bookshelf")
        ttekkkochiCollectionViewElement.accessibilityFrameInContainerSpace = ttekkkochiCollectionView.frame
        view.accessibilityElements = [titleLabel, ttekkkochiCollectionViewElement, leftBarButtonElement]
    }
    
    func initializeView() {
        (0...4).forEach {
            answerBlocks[$0].isShowing = false
            selectBlocks[$0].isAccessible = true
            selectBlocks[$0].isShowing = true
            ttekkkochiCollectionView.reloadData()
        }
    }
    
    @objc
    func popThisView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.ttekkkochiCollectionView.reloadData()
        }
        
        self.navigationController?.pushViewController(CustomAlert(), animated: false)
    }
}

// MARK: - Extension
extension TtekkkochiViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answerBlocks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TtekkkochiCollectionViewCell.identifier, for: indexPath) as? TtekkkochiCollectionViewCell else { fatalError() }
        cell.block = answerBlocks[indexPath.row]
        return cell
    }
}

extension TtekkkochiViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width
        return CGSize(width: cellWidth, height: cellWidth/3.2)
    }
}

extension TtekkkochiViewController {
    
    func startRecordingDeviceMotion() {
        
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

            if (abs(acceleration.x).toDegrees() > 90 && abs(acceleration.y).toDegrees() > 0 && abs(acceleration.z).toDegrees() > 45) {
//                print("===========")
//                Log.d(abs(acceleration.x).toDegrees())
//                Log.d(abs(acceleration.y.toDegrees()))
//                Log.d(abs(acceleration.z.toDegrees()))
//                print("===========")
//
                (0...2).forEach { answerBlocks[$0].isShowing = true }
                DispatchQueue.global().async { SoundManager.shared.playSound(sound: .bell) }
                self?.ttekkkochiCollectionView.reloadData()
                
                self?.motionManager.stopDeviceMotionUpdates()
                self?.navigationController?.pushViewController(TtekkkochiCompleteViewController(), animated: false)
            }
        }
    }
}
