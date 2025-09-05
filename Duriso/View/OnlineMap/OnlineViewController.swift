//
//  OnlineViewController.swift
//  Duriso
//
//  Created by 이주희 on 8/26/24.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import KakaoMapsSDK
import RxCocoa
import RxSwift
import SnapKit

class OnlineViewController: UIViewController, PoiViewModelDelegate {
  
  // MARK: - Properties
  
  private let poiViewModel = PoiViewModel.shared
  private let disposeBag = DisposeBag()
  private let onlineMapViewController = KakaoMapViewController()
  private let offlineMapViewController = OfflineMapViewController()
  private let viewModel = OnlineViewModel()
  private let emergencyWrittingViewController = EmergencyWrittingViewController()
  private var mapBottomSheetViewController: MapBottomSheetViewController?
  private let firestore = Firestore.firestore()
  
  var mapContainer: KMViewContainer?
  public var si: String = ""
  public var gu: String = ""
  public var dong: String = ""
  
  // UI 요소
  private let addressView = UIStackView().then {
    $0.backgroundColor = .CWhite
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.layer.cornerRadius = 20
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.15
    $0.layer.shadowColor = UIColor.CBlack.cgColor
    $0.layer.shadowRadius = 4
    $0.layer.masksToBounds = false
  }
  
  private let addressLabel = UILabel().then {
    $0.backgroundColor = .CWhite
    $0.text = "위치 확인 중..."
    $0.textColor = .CBlack
    $0.textAlignment = .center
    $0.adjustsFontSizeToFitWidth = true
    $0.font = CustomFont.Head4.font()
  }
  
  private let addressRefreshButton = UIButton().then {
    $0.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
    $0.tintColor = .CBlack
  }
  
  private let buttonStackView = UIStackView().then {
    $0.alignment = .center
    $0.distribution = .fillEqually
    $0.axis = .horizontal
    $0.spacing = 8
  }
  
  private let currentLocationButton = UIButton().then {
    $0.setImage(UIImage(named: "locationButton"), for: .normal)
    $0.imageView?.contentMode = .scaleAspectFit
  }
  
  private let writingButton = UIButton().then {
    $0.setImage(UIImage(named: "writingButton"), for: .normal)
  }
  
  lazy var shelterButton: UIButton = createButton(
    title: "대피소",
    symbolName: "figure.run",
    baseColor: .CLightBlue,
    selectedColor: .CGreen
  )
  
  lazy var aedButton: UIButton = createButton(
    title: "제세동기",
    symbolName: "bolt.heart.fill",
    baseColor: .CLightBlue,
    selectedColor: .CRed
  )
  
  lazy var emergencyReportButton: UIButton = createButton(
    title: "사용자제보",
    symbolName: "megaphone.fill",
    baseColor: .CLightBlue,
    selectedColor: .CBlue
  )
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupViews()  // 뷰 설정
    setupConstraints()  // 제약 조건 설정
    setupButtonBindings()  // 버튼 바인딩 설정
    poiViewModel.delegate = self
    
    // 위치 업데이트 콜백 설정
    LocationManager.shared.onLocationUpdate = { [weak self] latitude, longitude in
//      self?.updatePlaceNameLabel(latitude: latitude, longitude: longitude)
      self?.autoUpdateAddressLabel()
    }
    
    addressRefreshButton.addTarget(self, action: #selector(didTapAddressRefreshButton), for: .touchUpInside)
    currentLocationButton.addTarget(self, action: #selector(didTapCurrentLocationButton), for: .touchUpInside)
    writingButton.addTarget(self, action: #selector(didTapWritingButton), for: .touchUpInside)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    LocationManager.shared.startUpdatingLocation()  // 위치 업데이트 시작
  }
  
  // MARK: - View Setup
  
  func setupViews() {
    addChild(onlineMapViewController)
    view.addSubview(onlineMapViewController.view)
    view.addSubview(offlineMapViewController.view)
    onlineMapViewController.didMove(toParent: self)
    offlineMapViewController.view.isHidden = true
    [
      addressView,
      currentLocationButton,
      buttonStackView,
      writingButton
    ].forEach { view.addSubview($0) }
    
    [
      shelterButton,
      aedButton,
      emergencyReportButton
    ].forEach { buttonStackView.addArrangedSubview($0) }
    
    [
      addressLabel,
      addressRefreshButton
    ].forEach { addressView.addSubview($0) }
  }
  
  // MARK: - Constraints Setup
  
  func setupConstraints() {
    onlineMapViewController.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    addressView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(-16)
      $0.width.equalTo(280)
      $0.height.equalTo(40)
    }
    
    addressLabel.snp.makeConstraints {
      $0.centerY.equalTo(addressView)
      $0.leading.equalTo(addressView).offset(8)
      $0.trailing.equalTo(addressRefreshButton.snp.leading).offset(-8)
    }
    
    addressRefreshButton.snp.makeConstraints {
      $0.centerY.equalTo(addressView)
      $0.trailing.equalTo(addressView).offset(-10)
      $0.width.height.equalTo(16)
    }
    
    currentLocationButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-16)
      $0.bottom.equalTo(writingButton.snp.top).offset(-8)
      $0.width.height.equalTo(40)
    }
    
    writingButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-16)
      $0.bottom.equalTo(buttonStackView.snp.top).offset(-16)
      $0.width.height.equalTo(40)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(13)
    }
    
    shelterButton.snp.makeConstraints {
      $0.height.equalTo(34)
    }
    
    aedButton.snp.makeConstraints {
      $0.height.equalTo(34)
    }
    
    emergencyReportButton.snp.makeConstraints {
      $0.height.equalTo(34)
    }
  }
  
  // MARK: - Button Creation & Bindings
  
  func createButton(title: String, symbolName: String, baseColor: UIColor, selectedColor: UIColor) -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: symbolName), for: .normal)
    button.tintColor = .CWhite
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = CustomFont.Body4.font()
    button.setTitleColor(.CWhite, for: .normal)
    button.backgroundColor = selectedColor
    button.layer.cornerRadius = 17
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 4)
    button.layer.shadowRadius = 4
    button.layer.shadowOpacity = 0.2
    button.layer.masksToBounds = false
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    button.isSelected = false
    return button
  }
  
  private func setupButtonBindings() {
    bindButtonTap(for: shelterButton) { [weak self] in
      guard let self = self else { return }
      self.viewModel.toggleShelterButton(mapController: self.onlineMapViewController.mapController!)
    }
    
    bindButtonTap(for: aedButton) { [weak self] in
      guard let self = self else { return }
      self.viewModel.toggleAedButton(mapController: self.onlineMapViewController.mapController!)
    }
    
    bindButtonTap(for: emergencyReportButton) { [weak self] in
      guard let self = self else { return }
      self.viewModel.toggleEmergencyReportButton(mapController: self.onlineMapViewController.mapController!)
    }
  }
  
  private func bindButtonTap(for button: UIButton, toggleAction: @escaping () -> Void) {
    button.rx.tap
      .bind {
        toggleAction()
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Location and Address Handling
  
//  func updatePlaceNameLabel(latitude: Double, longitude: Double) {
//    let regionFetcher = RegionFetcher()
//    regionFetcher.fetchRegion(longitude: longitude, latitude: latitude) { [weak self] documents, error in
//      guard let self = self else { return }
//      if let document = documents?.first {
//        self.si = document.region1DepthName
//        self.gu = document.region2DepthName
//        self.dong = document.region3DepthName
//        DispatchQueue.main.async {
//          let region = "\(self.si) \(self.gu) \(self.dong)"
//          self.addressLabel.text = region
//          print("Your Location is: \(region)")
//        }
//      }
//      if let error = error {
//        print("Error fetching region: \(error)")
//      }
//    }
//  }
//  
  func autoUpdateAddressLabel() {
    guard let mapView = onlineMapViewController.mapController?.getView("mapview") as? KakaoMap else {
      print("Error: Failed to get mapView")
      return
    }
    let viewCenter = CGPoint(x: onlineMapViewController.view.bounds.midX, y: onlineMapViewController.view.bounds.midY)
    let centerMapPoint = mapView.getPosition(viewCenter)
    let latitude = centerMapPoint.wgsCoord.latitude
    let longitude = centerMapPoint.wgsCoord.longitude
    let regionFetcher = RegionFetcher()
    regionFetcher.fetchRegion(longitude: longitude, latitude: latitude) { [weak self] documents, error in
      guard let self = self else { return }
      if let document = documents?.first {
        self.si = document.region1DepthName
        self.gu = document.region2DepthName
        self.dong = document.region3DepthName
        DispatchQueue.main.async {
          let region = "\(self.si) \(self.gu) \(self.dong)"
          self.addressLabel.text = region
          print("Your Location is: \(region)")
        }
      }
      if let error = error {
        print("Error fetching region: \(error)")
      }
    }
  }
  
  @objc private func didTapAddressRefreshButton() {
    print("AddressRefreshButton clicked")
    guard let mapView = onlineMapViewController.mapController?.getView("mapview") as? KakaoMap else {
      print("Error: Failed to get mapView")
      return
    }
    let viewCenter = CGPoint(x: onlineMapViewController.view.bounds.midX, y: onlineMapViewController.view.bounds.midY)
    let centerMapPoint = mapView.getPosition(viewCenter)
    let latitude = centerMapPoint.wgsCoord.latitude
    let longitude = centerMapPoint.wgsCoord.longitude
    poiViewModel.fetchDataForLocation(latitude: latitude, longitude: longitude)
//    updatePlaceNameLabel(latitude: latitude, longitude: longitude)
    autoUpdateAddressLabel()
    LocationManager.shared.stopUpdatingLocation()
    print("Latitude: \(latitude), Longitude: \(longitude)")
  }
  
  @objc private func didTapCurrentLocationButton() {
    print("CurrentLocation button tapped")
    if let currentLocation = LocationManager.shared.currentLocation {
      let latitude = currentLocation.coordinate.latitude
      let longitude = currentLocation.coordinate.longitude
      onlineMapViewController.updateCurrentLocation(latitude: latitude, longitude: longitude)
      onlineMapViewController.moveCameraToCurrentLocation(latitude: latitude, longitude: longitude)
      poiViewModel.fetchDataForLocation(latitude: latitude, longitude: longitude)
//      updatePlaceNameLabel(latitude: latitude, longitude: longitude)
      autoUpdateAddressLabel()
    } else {
      LocationManager.shared.startUpdatingLocation()
    }
  }
  
  @objc private func didTapWritingButton() {
    if Auth.auth().currentUser != nil {
      // 사용자가 로그인된 상태이면 글쓰기 화면으로 이동
      let emergencyWrittingVC = EmergencyWrittingViewController()
      emergencyWrittingVC.setOnlineViewController(self)
      emergencyWrittingVC.latitude = LocationManager.shared.currentLocation?.coordinate.latitude ?? 0.0
      emergencyWrittingVC.longitude = LocationManager.shared.currentLocation?.coordinate.longitude ?? 0.0
      let bottomSheetVC = MapBottomSheetViewController()
      bottomSheetVC.configureContentViewController(emergencyWrittingVC)
      present(bottomSheetVC, animated: true)
      print("Emergency Writing button tapped")
    } else {
      // 로그인되지 않은 상태일 때 알림창 표시
      showLoginAlert()
    }
  }
  
  // MARK: - POI Interactions
  
  func didTapAed(poiID: String, address: String, adminName: String, adminNumber: String, managementAgency: String, location: String) {
    let aedVC = AedViewController()
    aedVC.poiName = poiID
    aedVC.poiAddress = address
    aedVC.adminName = adminName
    aedVC.adminNumber = adminNumber
    aedVC.managementAgency = managementAgency
    aedVC.location = location
    let bottomSheetVC = MapBottomSheetViewController()
    bottomSheetVC.configureContentViewController(aedVC)
    present(bottomSheetVC, animated: true)
  }
  
  func didTapEmergencyReport(poiID: String, address: String) {
    let emergencyReportVC = EmergencyReportViewController()
    firestore.collection("posts").document(poiID).getDocument { document, error in
      if let document = document, document.exists {
        let data = document.data()
        emergencyReportVC.postCategory = data?["category"] as? String ?? "Unknown"
        emergencyReportVC.reportName = data?["title"] as? String ?? "Unknown"
        emergencyReportVC.reportAddress = "\(data?["si"] ?? "") \(data?["gu"] ?? "") \(data?["dong"] ?? "")"
        emergencyReportVC.authorName = data?["author"] as? String ?? "Unknown Author"
        emergencyReportVC.postTime = (data?["posttime"] as? Timestamp)?.dateValue()
        emergencyReportVC.postContent = data?["contents"] as? String ?? "No content available"
        let bottomSheetVC = MapBottomSheetViewController()
        bottomSheetVC.configureContentViewController(emergencyReportVC)
        self.present(bottomSheetVC, animated: true)
      } else {
        print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
      }
    }
  }
  
  func didTapShelter(poiID: String, shelterType: String, address: String) {
    let shelterVC = ShelterViewController()
    shelterVC.poiName = poiID
    shelterVC.poiAddress = address
    shelterVC.poiType = shelterType
    let bottomSheetVC = MapBottomSheetViewController()
    bottomSheetVC.configureContentViewController(shelterVC)
    present(bottomSheetVC, animated: true)
  }
  
  private func showLoginAlert() {
    let alert = UIAlertController(title: "로그인 필요", message: "로그인 후 글쓰기가 가능합니다.", preferredStyle: .alert)
    
    // 회원가입 버튼
    let signUpAction = UIAlertAction(title: "Login", style: .default) { [weak self] _ in
      self?.navigateToLogin()
    }
    alert.addAction(signUpAction)
    
    // 취소 버튼
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    
    // 알림창 표시
    present(alert, animated: true, completion: nil)
  }
  
  private func navigateToLogin() {
    let loginVC = LoginViewController()
    let navController = UINavigationController(rootViewController: loginVC)
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
      let window = windowScene.windows.first
      window?.rootViewController = navController
      window?.makeKeyAndVisible()
    }
  }
}
