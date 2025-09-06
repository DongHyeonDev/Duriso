//
//  UserPostViewController.swift
//  Duriso
//
//  Created by 신상규 on 9/10/24.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import RxCocoa
import RxSwift
import SnapKit

class UserPostViewController: UIViewController {
  
  private let disposeBag = DisposeBag()
  private let firestore = Firestore.firestore()
  private let nickname: BehaviorSubject<String> = BehaviorSubject(value: "")
  
  var userId: String?
  var postTitle: String?
  var postContent: String?
  var postImage: UIImage?
  var postTitleTop: String?
  var postAddress: String?
  var postTimes: Date?
  var post: Posts?
  
  private let postingScrollView = UIScrollView()
  private let contentView = UIView()
  
  private var isLiked = false
  private var likeCount = 0
  
  private var currentUUID: String = ""
  
  let db = Firestore.firestore()
  var documentRef: DocumentReference?
  
  private let postingTitleText = UILabel().then {
    $0.font = CustomFont.Head2.font()
    $0.textColor = .black
  }
  
  private let postingLineViews: [UIView] = (0..<4).map { _ in
    let view = UIView()
    view.backgroundColor = .lightGray
    return view
  }
  
  private var postingLineView1: UIView { return postingLineViews[0] }
  private var postingLineView2: UIView { return postingLineViews[1] }
  private var postingLineView3: UIView { return postingLineViews[2] }
  private var postingLineView4: UIView { return postingLineViews[3] }
  
  private let postingLocationeSymblo = UILabel().then {
    let clockAttachment = NSTextAttachment()
    clockAttachment.image = UIImage(systemName: "map")
    clockAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)  // 심볼 크기와 위치 조정
    let clockString = NSAttributedString(attachment: clockAttachment)
    $0.attributedText = clockString
  }
  
  private let postingLocationeName1 = UILabel().then {
    $0.font = CustomFont.Head4.font()
    $0.textColor = .black
  }
  
  private let postingTimeText = UILabel().then {
    let clockAttachment = NSTextAttachment()
    clockAttachment.image = UIImage(systemName: "clock")
    clockAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)  // 심볼 크기와 위치 조정
    let clockString = NSAttributedString(attachment: clockAttachment)
    $0.attributedText = clockString
  }
  
  private let postingTimeLabel = UILabel().then {
    $0.text = "00시 00분 00초"
    $0.font = CustomFont.Body4.font()
  }
  
  private let postingStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
  }
  
  private let postingUserTextLabel = UILabel().then {
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 100
    $0.textColor = .black
  }
  
  private let postingImage = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }
  
  private let ripotButton = UIButton().then {
    $0.setTitle("신고하기", for: .normal)
    $0.setTitleColor(.red, for: .normal)
    $0.titleLabel?.font = CustomFont.Body4.font()
  }
  
  private let cutoffUser = UIButton().then {
    $0.setTitle("차단하기", for: .normal)
    $0.setTitleColor(.red, for: .normal)
    $0.titleLabel?.font = CustomFont.Body4.font()
  }
  
  private let editButton = UIButton().then {
    $0.setTitle("Edit", for: .normal)
    $0.setTitleColor(.gray, for: .normal)
    $0.titleLabel?.font = CustomFont.Body4.font()
    $0.setImage(UIImage(systemName: "pencil"), for: .normal) // 시스템 심볼 이미지 추가
    $0.tintColor = .black // 심볼 색상 블랙으로 설정
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 이미지 위치 조정
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0) // 텍스트 위치 조정
  }
  
  private let deleteButton = UIButton().then {
    $0.setTitle("Delete", for: .normal)
    $0.setTitleColor(.gray, for: .normal)
    $0.titleLabel?.font = CustomFont.Body4.font()
    $0.setImage(UIImage(systemName: "trash"), for: .normal) // 시스템 심볼 이미지 추가
    $0.tintColor = .black // 심볼 색상 블랙으로 설정
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // 이미지 위치 조정
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0) // 텍스트 위치 조정
  }
  
  private let bottomStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
  }
  
  private let likeButton = UIButton().then {
    $0.setTitle("🙏", for: .normal)
    $0.backgroundColor = .clear
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    $0.layer.cornerRadius = 17
  }
  
  private let likeNumberLabel = UILabel().then {
    $0.text = "0"
    $0.font = CustomFont.Body4.font()
  }
  
  private let likeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .trailing
    $0.distribution = .equalSpacing
    $0.spacing = 8
  }
  
  private let nickNameTextSymbol = UILabel().then {
    let clockAttachment = NSTextAttachment()
    clockAttachment.image = UIImage(systemName: "person")
    clockAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
    let clockString = NSAttributedString(attachment: clockAttachment)
    $0.attributedText = clockString
  }
  
  private let nickNameLabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = CustomFont.Head4.font()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupView()
    alertButtonTap()
    fetchUserId()
    self.title = postTitleTop
    likeButtonTap()
    configureUI()
    changeButtonTap()
    removalButtonTap()
    cutoffUserTap()
    
    if let post = post {
      fetchNickname(forPostOwnerUUID: post.author)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchLikesStatus()
  }
  
  // MARK: - 레이아웃
  private func setupView() {
    [
      postingScrollView,
      bottomStackView,
      likeStackView
    ].forEach { view.addSubview($0) }
    
    [
      postingTitleText,
      postingLineView1,
      postingLineView2,
      nickNameLabel,
      postingLocationeSymblo,
      postingLocationeName1,
      postingStackView,
      postingImage,
      nickNameTextSymbol,
      postingUserTextLabel,
      postingLineView3,
      contentView,
      editButton,
      deleteButton
    ].forEach { postingScrollView.addSubview($0) }
    
    [
      postingTimeText,
      postingTimeLabel
    ].forEach { postingStackView.addArrangedSubview($0) }
    
    let spacerView = UIView()
    
    [
      cutoffUser,
      ripotButton,
      spacerView,
    ].forEach { bottomStackView.addArrangedSubview($0) }
    
    [
      likeButton,
      likeNumberLabel
    ].forEach { likeStackView.addArrangedSubview($0) }
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    postingScrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(postingScrollView.snp.width)
    }
    
    postingTitleText.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview()
      $0.height.equalTo(30)
    }
    
    postingLineView1.snp.makeConstraints {
      $0.top.equalTo(postingTitleText.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(1)
      $0.width.equalToSuperview().inset(24)
    }
    
    nickNameTextSymbol.snp.makeConstraints {
      $0.top.equalTo(postingLineView1.snp.bottom).offset(16)
      $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(24)
      $0.height.equalTo(30)
    }
    
    nickNameLabel.snp.makeConstraints {
      $0.top.equalTo(postingLineView1.snp.bottom).offset(16)
      $0.leading.equalTo(nickNameTextSymbol.snp.trailing).offset(8)
      $0.height.equalTo(30)
    }
    
    postingLocationeSymblo.snp.makeConstraints {
      $0.top.equalTo(nickNameLabel.snp.bottom)/*.offset(8)*/
      $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(24)
      $0.height.equalTo(30)
    }
    
    postingLocationeName1.snp.makeConstraints {
      $0.top.equalTo(nickNameLabel.snp.bottom)/*.offset(8)*/
      $0.leading.equalTo(postingLocationeSymblo.snp.trailing).offset(8)
      $0.height.equalTo(30)
    }
    
    postingStackView.snp.makeConstraints {
      $0.top.equalTo(postingLocationeName1.snp.bottom)
      $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(24)
      $0.height.equalTo(30)
    }
    
    postingLineView2.snp.makeConstraints {
      $0.top.equalTo(postingStackView.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(1)
      $0.width.equalToSuperview().inset(24)
    }
    
    postingImage.snp.makeConstraints {
      $0.top.equalTo(postingLineView2.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(200)
      $0.width.equalToSuperview().inset(30)
    }
    
    postingUserTextLabel.snp.makeConstraints {
      $0.top.equalTo(postingImage.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().inset(30)
    }
    
    postingLineView3.snp.makeConstraints {
      $0.top.equalTo(postingUserTextLabel.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(1)
      $0.width.equalToSuperview().inset(24)
    }
    
    likeStackView.snp.makeConstraints {
      $0.top.equalTo(postingLineView3.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(24)
      $0.height.equalTo(30)
      $0.width.greaterThanOrEqualTo(60)
    }
    
    likeButton.snp.makeConstraints {
      $0.leading.equalTo(likeStackView.snp.leading)
      $0.centerY.equalTo(likeStackView.snp.centerY)
      $0.width.height.equalTo(30)
    }
    
    likeNumberLabel.snp.makeConstraints {
      $0.leading.equalTo(likeButton.snp.trailing).offset(8)
      $0.centerY.equalToSuperview()
    }
    
    bottomStackView.snp.makeConstraints {
      $0.top.equalTo(likeStackView.snp.bottom).offset(8)
      //      $0.centerX.equalToSuperview()
      $0.trailing.equalTo(deleteButton.snp.trailing)
      //      $0.width.equalToSuperview().inset(30)
      $0.height.equalTo(50)
      $0.bottom.equalTo(contentView.snp.bottom).offset(-16)
    }
    
    deleteButton.snp.makeConstraints {
      $0.centerY.equalTo(likeStackView.snp.centerY)
      $0.trailing.equalToSuperview().inset(16)
      $0.width.equalTo(80)
    }
    
    editButton.snp.makeConstraints {
      $0.centerY.equalTo(likeStackView.snp.centerY)
      $0.trailing.equalTo(deleteButton.snp.leading).offset(16)
      $0.width.equalTo(80)
    }
  }
  
  //MARK: - 버튼 텝 이벤트
  private func changeButtonTap() {
    editButton.rx.tap
      .bind { [weak self] in
        self?.checkIfUserCanEdit()
      }
      .disposed(by: disposeBag)
  }
  
  private func likeButtonTap() {
    likeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.toggleLike()
      })
      .disposed(by: disposeBag)
  }
  
  private func alertButtonTap() {
    ripotButton.rx.tap
      .bind { [weak self] in
        self?.showReportAlert()
      }
      .disposed(by: disposeBag)
  }
  
  private func removalButtonTap() {
    deleteButton.rx.tap
      .bind { [weak self] in
        self?.confirmDeletion()
      }
      .disposed(by: disposeBag)
  }
  
  private func cutoffUserTap() {
    cutoffUser.rx.tap
      .bind { [weak self] in
        self?.blockUser()
      }
      .disposed(by: disposeBag)
  }
  
  //MARK: - 게시글 수정
  private func checkIfUserCanEdit() {
    guard let postUserNickname = post?.author else { return }
    
    if postUserNickname == self.currentUUID {
      presentEditViewController()
    } else {
      let alert = UIAlertController(
        title: "수정 권한 없음",
        message: "이 포스트를 수정할 수 있는 권한이 없습니다.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      present(alert, animated: true)
    }
  }
  
  private func presentEditViewController() {
    guard let post = self.post else { return }
    let postChangeViewController = EditPostViewController()
    postChangeViewController.currentPost = post
    postChangeViewController.onPostUpdated = { [weak self] title, content, image, category in
      self?.postTitle = title
      self?.postContent = content
      self?.postImage = image
      self?.postTitleTop = category
      self?.configureUI()
    }
    let navigationController = UINavigationController(rootViewController: postChangeViewController)
    self.navigationController?.pushViewController(postChangeViewController, animated: true)
  }
  
  // MARK: - 좋아요 만들기
  private func toggleLike() {
    guard let user = Auth.auth().currentUser else { return }
    let userId = user.uid
    
    // Firestore에서 현재 사용자가 좋아요를 눌렀는지 확인
    documentRef?.getDocument { [weak self] (document, error) in
      guard let self = self else { return }
      
      if let document = document, document.exists {
        let data = document.data()
        let likedUsers = data?["likedUsers"] as? [String] ?? []
        
        if likedUsers.contains(userId) {
          // 이미 좋아요를 눌렀다면 좋아요 취소
          self.isLiked = false
          self.likeButton.isSelected = false
          self.updateLikesCount(increment: false)
        } else {
          // 좋아요를 누르지 않았다면 좋아요 추가
          self.isLiked = true
          self.likeButton.isSelected = true
          self.updateLikesCount(increment: true)
        }
        
        self.updateLikeButtonBackground()
      }
    }
  }
  
  // 좋아요 수 업데이트
  private func updateLikesCount(increment: Bool) {
    guard let documentRef = documentRef, let userId = Auth.auth().currentUser?.uid else { return }
    
    let updateData: [String: Any] = [
      "likescount": FieldValue.increment(Int64(increment ? 1 : -1)),
      "likedUsers": increment ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId])
    ]
    
    documentRef.updateData(updateData) { [weak self] error in
      if let error = error {
        print("좋아요 수 업데이트 실패: \(error.localizedDescription)")
      } else {
        print("좋아요 수 업데이트 성공")
        self?.fetchLikesStatus()  // 좋아요 상태 다시 불러오기
      }
    }
  }
  
  // 좋아요 버튼 UI 업데이트
  private func updateLikeButton() {
    likeNumberLabel.text = "\(likeCount)"
    likeButton.tintColor = isLiked ? .red : .lightGray
  }
  
  // 좋아요 버튼 배경색 업데이트
  private func updateLikeButtonBackground() {
    if likeButton.isSelected {
      likeButton.backgroundColor = .CLightBlue2 // 선택된 상태의 배경색
    } else {
      likeButton.backgroundColor = .clear // 선택되지 않은 상태의 배경색
    }
  }
  
  // MARK: - 좋아요 상태 가져오기
  private func fetchLikesStatus() {
    guard let user = Auth.auth().currentUser else { return }
    let userId = user.uid
    
    documentRef?.getDocument { [weak self] (document, error) in
      if let document = document, document.exists {
        let data = document.data()
        let likedUsers = data?["likedUsers"] as? [String] ?? []
        
        self?.isLiked = likedUsers.contains(userId)
        self?.likeCount = (data?["likescount"] as? Int) ?? 0
        
        self?.updateLikeButton()  // 좋아요 버튼 상태 업데이트
      }
    }
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
  
  private func fetchNickname(forPostOwnerUUID uuid: String) {
    firestore.collection("users").whereField("uuid", isEqualTo: uuid).getDocuments { [weak self] (querySnapshot, error) in
      guard let self = self else { return }
      if let error = error {
        print("닉네임을 가져오는 데 실패했습니다: \(error.localizedDescription)")
        return
      }
      
      if let document = querySnapshot?.documents.first {
        let data = document.data()
        let nickname = data["nickname"] as? String ?? "닉네임 없음"
        
        DispatchQueue.main.async {
          self.nickNameLabel.text = nickname
        }
      } else {
        print("해당 UUID에 대한 닉네임을 찾을 수 없습니다.")
      }
    }
  }
  
  // MARK: - 데이터 확인
  func setPostData(post: Posts) {
    self.post = post  // 추가: Post 객체 설정
    self.postTitle = post.title
    self.postContent = post.contents
    self.postAddress = "\(post.si) \(post.gu) \(post.dong)"
    self.postTimes = post.posttime
    self.postTitleTop = post.category
    self.documentRef = db.collection("posts").document(post.postid)
    
    if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
      loadImage(from: url)
    } else {
      configureUI()
    }
  }
  
  // 이미지 로드
  private func loadImage(from url: URL) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let data = data, let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.postImage = image
          self.configureUI()
        }
      } else {
        DispatchQueue.main.async {
          self.postImage = nil
          self.configureUI()
        }
      }
    }.resume()
  }
  
  
  // MARK: - 삭제 확인 및 실행
  private func confirmDeletion() {
    guard let postUserUUID = post?.author else { return }
    
    // 작성자 UUID와 현재 유저 UUID가 일치하지 않을 때 삭제 권한이 없다는 메시지
    if postUserUUID != self.currentUUID {
      let alert = UIAlertController(
        title: "삭제 권한 없음",
        message: "이 포스트를 삭제할 수 있는 권한이 없습니다.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    
    // 작성자 UUID와 일치할 때 삭제 확인 알림 표시
    let alertController = UIAlertController(
      title: "삭제 확인",
      message: "이 포스트를 삭제하시겠습니까?",
      preferredStyle: .alert
    )
    
    alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
    alertController.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
      self?.deletePost()
    }))
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func deletePost() {
    guard let documentRef = documentRef else { return }
    
    // Firestore에서 포스트 삭제
    documentRef.delete { [weak self] error in
      if let error = error {
        print("포스트 삭제 실패: \(error.localizedDescription)")
      } else {
        print("포스트 삭제 성공")
        self?.decreasePostCount() // 삭제 후 postcount 감소
        self?.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  private func decreasePostCount() {
    guard let currentUser = Auth.auth().currentUser else { return }
    let uid = currentUser.uid
    let userRef = firestore.collection("users").document(uid)
    
    userRef.getDocument { (document, error) in
      if let error = error {
        print("사용자 정보 불러오기 실패: \(error.localizedDescription)")
        return
      }
      
      if let document = document, document.exists {
        // postcount가 0보다 큰 경우에만 감소
        if let postcount = document.data()?["postcount"] as? Int, postcount > 0 {
          userRef.updateData([
            "postcount": postcount - 1
          ]) { error in
            if let error = error {
              print("postcount 감소 실패: \(error.localizedDescription)")
            } else {
              print("postcount 감소 성공")
            }
          }
        }
      }
    }
  }
  
  // MARK: -  타입명시
  private func configureUI() {
    postingTitleText.text = postTitle
    postingUserTextLabel.text = postContent
    postingLocationeName1.text = postAddress
    self.title = postTitleTop
    
    if let image = postImage {
      postingImage.image = image
      postingImage.alpha = 1
      postingImage.snp.updateConstraints {
        $0.height.equalTo(200)
      }
    } else {
      postingImage.alpha = 0
      postingImage.snp.updateConstraints {
        $0.height.equalTo(0)
      }
    }
    
    if let time = postTimes {
      postingTimeLabel.text = formatTime(from: time)
    }
    
    view.layoutIfNeeded()
  }
  
  // MARK: -  timeStamp 변환
  private func formatTime(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: date)
  }
  
  
  // MARK: -  신고하기
  private func showReportAlert() {
    let reportAlert = UIAlertController(
      title: "신고 사유 선택",
      message: "신고 사유에 맞지 않는 신고일 경우,\n해당 신고는 처리되지. 않습니다.\n누적 신고횟수가 3회 이상인 유저는 게시글 작성을 할 수 없습니다.",
      preferredStyle: .actionSheet
    )
    
    // 신고 사유 추가
    let reasons = [
      "잘못된 정보",
      "스팸성 콘텐츠",
      "불법 또는 유해한 콘텐츠",
      "명예 훼손 또는 모욕",
      "폭력 또는 혐오 발언",
      "부적절한 콘텐츠"
    ]
    
    for reason in reasons {
      reportAlert.addAction(UIAlertAction(title: reason, style: .default, handler: { [weak self] _ in
        self?.checkIfUserCanReport(withReason: reason)
      }))
    }
    
    // 취소 버튼
    reportAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
    
    // iPad에서 ActionSheet가 crash 되는 문제 방지
    if let popoverController = reportAlert.popoverPresentationController {
      popoverController.sourceView = self.view
      popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
      popoverController.permittedArrowDirections = []
    }
    
    present(reportAlert, animated: true, completion: nil)
  }
  
  private func checkIfUserCanReport(withReason reason: String) {
    guard let user = Auth.auth().currentUser else { return }
    let userId = user.uid
    
    // 자기 자신을 신고하는지 확인
    if userId == post?.author {
      showCannotReportSelfAlert()
      return
    }
    
    documentRef?.getDocument { [weak self] (document, error) in
      if let document = document, document.exists {
        let data = document.data()
        let reportedUsers = data?["reportedUsers"] as? [String] ?? []
        
        if reportedUsers.contains(userId) {
          self?.showAlreadyReportedAlert()
        } else {
          self?.updateReportCount(withReason: reason)
        }
      }
    }
  }
  
  private func showCannotReportSelfAlert() {
    let alert = UIAlertController(
      title: "신고 불가",
      message: "자신의 게시물은 신고할 수 없습니다.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true, completion: nil)
  }
  
  private func showAlreadyReportedAlert() {
    let alert = UIAlertController(title: "알림", message: "이미 신고한 사용자입니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true, completion: nil)
  }
  
  private func updateReportCount(withReason reason: String) {
    guard let user = Auth.auth().currentUser, let documentRef = documentRef else { return }
    let userId = user.uid
    
    documentRef.updateData([
      "reportcount": FieldValue.increment(Int64(1)),
      "reportedUsers": FieldValue.arrayUnion([userId]),
      "reportReasons": FieldValue.arrayUnion([reason])
    ]) { error in
      if let error = error {
        print("신고 수 업데이트 실패: \(error.localizedDescription)")
      } else {
        print("신고 수 업데이트 성공")
        self.showReportConfirmationAlert()
      }
    }
  }
  
  private func showReportConfirmationAlert() {
    let confirmationAlert = UIAlertController(
      title: "신고가 완료되었습니다.",
      message: "검토까지 최대 24시간 소요 될 예정입니다.",
      preferredStyle: .alert
    )
    confirmationAlert.addAction(UIAlertAction(title: "확인", style: .default))
    present(confirmationAlert, animated: true, completion: nil)
  }
  
  // MARK: - 유저 차단 기능
  private func blockUser() {
    guard let postUserUUID = post?.author else { return }
    guard let currentUser = Auth.auth().currentUser else { return }
    
    if postUserUUID == currentUser.uid {
      showAlert(title: "차단 불가", message: "자기 자신은 차단할 수 없습니다.")
      return
    }
    
    let alertController = UIAlertController(
      title: "차단 확인",
      message: "이 사용자를 차단하시겠습니까?",
      preferredStyle: .alert
    )
    
    alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
    alertController.addAction(UIAlertAction(title: "차단", style: .destructive, handler: { [weak self] _ in
      self?.addUserToBlockList(blockedUserUUID: postUserUUID)
    }))
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func addUserToBlockList(blockedUserUUID: String) {
    guard let currentUser = Auth.auth().currentUser else { return }
    let uid = currentUser.uid
    let userRef = firestore.collection("users").document(uid)
    
    userRef.getDocument { (document, error) in
      if let error = error { return }
      
      if let document = document, document.exists {
        userRef.updateData([
          "blockedusers": FieldValue.arrayUnion([blockedUserUUID])
        ]) { error in
          if let error = error {
            // 차단 업데이트 실패 처리
          } else {
            self.showBlockConfirmationAlert()
          }
        }
      }
    }
  }
  
  private func showBlockConfirmationAlert() {
    let confirmationAlert = UIAlertController(
      title: "차단 완료",
      message: "차단된 사용자의 게시물은 더 이상 표시되지 않습니다.",
      preferredStyle: .alert
    )
    confirmationAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
      self?.navigationController?.popViewController(animated: true)
    }))
    present(confirmationAlert, animated: true, completion: nil)
  }
  
  // 경고 메시지를 보여주는 메서드
  private func showAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    present(alertController, animated: true, completion: nil)
  }
  
}
