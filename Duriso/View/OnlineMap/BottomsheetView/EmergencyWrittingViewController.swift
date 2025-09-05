//
//  EmergencyWrittingViewController.swift
//  Duriso
//
//  Created by 이주희 on 9/4/24.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SnapKit
import Then

class EmergencyWrittingViewController: UIViewController, UITextViewDelegate {
  
  // MARK: - Properties
  
  private let firestore = Firestore.firestore()
  var latitude: Double = 0.0
  var longitude: Double = 0.0
  private var currentUUID: String = ""
  private var onlineViewController: OnlineViewController?
  private let regionFetcher = RegionFetcher()
  
  func setOnlineViewController(_ viewController: OnlineViewController) {
    self.onlineViewController = viewController
  }
  
  // MARK: - UI Components
  
  internal let poiViewTitle = UILabel().then {
    $0.text = "우리 동네 한줄 제보"
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Deco2.font()
  }
  
  private let megaphoneLabel = UIImageView().then {
    $0.image = UIImage(systemName: "megaphone")
    $0.tintColor = .CRed
    $0.contentMode = .scaleAspectFit
  }
  
  // 닫기 버튼 비활성화
  //  private let cancelButton = UIButton().then {
  //    $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
  //    $0.tintColor = .CLightBlue
  //    $0.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
  //  }
  
  private let messageInputTextView = UITextView().then {
    $0.backgroundColor = UIColor.CWhite
    $0.font = CustomFont.Body3.font()
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.CBlue.cgColor
    $0.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    $0.isScrollEnabled = false
  }
  
  private let placeholderLabel = UILabel().then {
    $0.text = "꼭 필요한 정보만 50자 이내로 남겨주세요.\n발생 지역을 상세히 적어주시면 큰 도움이 됩니다!"
    $0.font = CustomFont.Body3.font()
    $0.textColor = .gray
    $0.numberOfLines = 0
  }
  
  private let addPostButton = UIButton().then {
    $0.setTitle("완료", for: .normal)
    $0.titleLabel?.font = CustomFont.Body4.font()
    $0.setTitleColor(.CWhite, for: .normal)
    $0.backgroundColor = .CBlue
    $0.layer.cornerRadius = 17
    $0.isEnabled = false  // 처음에 비활성화
    $0.alpha = 0.5  // 비활성화 상태일 때 반투명
  }
  
  private let characterLimitLabel = UILabel().then {
    $0.text = "50자 이내로 작성해주세요."
    $0.textColor = .CRed
    $0.font = CustomFont.Body4.font()
    $0.isHidden = true // 처음에는 숨김 상태
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupView()
    setupConstraints()
    messageInputTextView.delegate = self
    setupLocationUpdates()
    
    addPostButton.addTarget(self, action: #selector(didTapAddPostButton), for: .touchUpInside)
  }
  
  // MARK: - Setup
  private func setupView() {
    [
      poiViewTitle,
      megaphoneLabel,
      //      cancelButton,
      messageInputTextView,
      addPostButton,
      characterLimitLabel
    ].forEach { view.addSubview($0) }
    
    messageInputTextView.addSubview(placeholderLabel)
  }
  
  private func setupConstraints() {
    poiViewTitle.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
    }
    
    megaphoneLabel.snp.makeConstraints {
      $0.centerY.equalTo(poiViewTitle)
      $0.leading.equalTo(poiViewTitle.snp.trailing).offset(4)
      $0.width.height.equalTo(32)
    }
    
    //    cancelButton.snp.makeConstraints {
    //      $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
    //      $0.width.height.equalTo(32)
    //    }
    
    messageInputTextView.snp.makeConstraints {
      $0.centerX.equalTo(view.safeAreaLayoutGuide)
      $0.top.equalTo(poiViewTitle.snp.bottom).offset(24)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
      //      $0.width.equalTo(360)
      $0.height.equalTo(88)
    }
    
    addPostButton.snp.makeConstraints {
      $0.centerX.equalTo(view.safeAreaLayoutGuide)
      $0.top.equalTo(messageInputTextView.snp.bottom).offset(28)
      $0.width.equalTo(80)
      $0.height.equalTo(34)
    }
    
    placeholderLabel.snp.makeConstraints {
      $0.edges.equalTo(messageInputTextView)
        .inset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    characterLimitLabel.snp.makeConstraints {
      $0.top.equalTo(messageInputTextView.snp.bottom).offset(4)
      $0.leading.equalTo(messageInputTextView.snp.leading)
    }
  }
  
  private func setupLocationUpdates() {
    LocationManager.shared.onLocationUpdate = { [weak self] latitude, longitude in
      self?.latitude = latitude
      self?.longitude = longitude
      print("Updated Location: Latitude \(latitude), Longitude \(longitude)")
      self?.updateLocationNames(latitude: latitude, longitude: longitude)
    }
  }
  
  // MARK: - Actions
  //  @objc private func didTapCancelButton() {
  //    dismiss(animated: true)
  //  }
  
  @objc private func didTapAddPostButton() {
    guard let content = messageInputTextView.text,
          !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      print("내용을 입력해주세요.")
      return
    }
    
    let category = "긴급제보"
    
    guard latitude != 0.0, longitude != 0.0 else {
      print("현재 위치를 받아오는 중입니다. 잠시 후 다시 시도해주세요.")
      return
    }
    
    guard let onlineVC = onlineViewController else {
      print("지역 정보가 없습니다.")
      return
    }
    
    // 현재 로그인된 사용자의 uid 가져오기 (UUID)
    guard let user = Auth.auth().currentUser else {
      print("사용자 정보가 없습니다.")
      return
    }
    
    let authorUUID = user.uid  // Firebase Authentication에서 제공하는 사용자의 고유 ID
    
    let newPost = createPost(content: content, category: category, onlineVC: onlineVC, authorUUID: authorUUID)
    
    firestore.collection("posts").document(newPost.postid).setData(newPost.toDictionary()) {
      [weak self] error in
      guard let self = self else { return }
      if let error = error {
        print("Firestore에 데이터 저장 실패: \(error.localizedDescription)")
      } else {
        print("게시글 저장 성공")
        PoiViewModel.shared.setupPoiData()
        self.dismiss(animated: true)
      }
    }
  }
  
  private func createPost(content: String, category: String, onlineVC: OnlineViewController, authorUUID: String) -> Posts {
    return Posts(
      author: authorUUID,  // 사용자의 고유 UUID를 author에 저장
      contents: content,
      category: category,
      dong: onlineVC.dong,
      gu: onlineVC.gu,
      likescount: 0,
      postid: UUID().uuidString,
      postlatitude: self.latitude,
      postlongitude: self.longitude,
      posttime: Date(),
      reportcount: 0,
      si: onlineVC.si,
      title: "",
      imageUrl: ""
    )
  }
  
  //MARK: - 유저확인
  private func fetchUserId() {
    guard let user = Auth.auth().currentUser else { return }
    
    //    let safeEmail = user.email?.replacingOccurrences(of: ".", with: "-") ?? ""
    let uid = user.uid
    
    firestore.collection("users").document(uid).getDocument { [weak self] (document, error) in
      guard let self = self else { return }
      if let document = document, document.exists {
        let data = document.data()
        let nicknameFromFirestore = data?["uuid"] as? String ?? "닉네임 없음"
        self.currentUUID = nicknameFromFirestore
      }
    }
  }
  
  // MARK: - Helper Methods
  private func updateLocationNames(latitude: Double, longitude: Double) {
    regionFetcher.fetchRegion(longitude: longitude, latitude: latitude) { [weak self] documents, error in
      guard let self = self else { return }
      if let document = documents?.first {
        let si = document.region1DepthName
        let gu = document.region2DepthName
        let dong = document.region3DepthName
        
        self.onlineViewController?.si = si
        self.onlineViewController?.gu = gu
        self.onlineViewController?.dong = dong
        print("Updated Region: SI \(si), GU \(gu), DONG \(dong)")
      } else if let error = error {
        print("지역 정보 가져오기 실패: \(error.localizedDescription)")
      }
    }
  }
  
  // MARK: - UITextViewDelegate
  func textViewDidChange(_ textView: UITextView) {
    placeholderLabel.isHidden = !textView.text.isEmpty
    
    let trimmedText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedText.isEmpty {
      textView.text = ""
    }
    
    let characterCount = textView.text.count
    if characterCount > 50 {
      textView.text = String(textView.text.prefix(50))
      if characterLimitLabel.isHidden {
        characterLimitLabel.isHidden = false
      }
    } else {
      if !characterLimitLabel.isHidden {
        characterLimitLabel.isHidden = true
      }
    }
    
    let isValidInput = !trimmedText.isEmpty
    addPostButton.isEnabled = isValidInput
    addPostButton.alpha = isValidInput ? 1.0 : 0.5
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    // 텍스트뷰 편집 시작 시 placeholder 숨김
    placeholderLabel.isHidden = true
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    // 텍스트뷰 편집 종료 시 텍스트가 비어있으면 placeholder 표시
    if textView.text.isEmpty {
      placeholderLabel.isHidden = false
    }
  }
}
