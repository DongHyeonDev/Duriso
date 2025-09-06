//
//  LoginViewController.swift
//  Duriso
//
//  Created by t2023-m0102 on 8/26/24.
//

import AuthenticationServices
import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class LoginViewController: UIViewController {
  
  let disposeBag = DisposeBag()
  private let viewModel = LoginViewModel()
  
  private let titleLabel = UILabel().then {
    $0.text = "반갑습니다! \n로그인 및 가입하기"
    $0.font = CustomFont.Head.font()
    $0.textColor = .CBlack
    $0.numberOfLines = 0
    $0.textAlignment = .left
  }
  
  private let idLabel = UILabel().then {
    $0.text = "이메일"
    $0.font = CustomFont.Head3.font()
    $0.textColor = .CBlack
  }
  
  private let idTextField = UITextField().then {
    $0.borderStyle = .roundedRect
    $0.placeholder = "이메일을 입력하세요"
    $0.font = CustomFont.Body3.font()
    $0.backgroundColor = .lightGray
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  private let passwordLabel = UILabel().then {
    $0.text = "비밀번호"
    $0.font = CustomFont.Head3.font()
    $0.textColor = .CBlack
  }
  
  private let passwordTextField = UITextField().then {
    $0.borderStyle = .roundedRect
    $0.placeholder = "비밀번호를 입력하세요"
    $0.font = CustomFont.Body3.font()
    $0.backgroundColor = .lightGray
    $0.autocorrectionType = .no
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
  }
  
  private let checkboxButton = UIButton().then {
    $0.setImage(UIImage(systemName: "square"), for: .normal)
    $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
    $0.tintColor = .CBlue
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private let autoLoginLabel = UILabel().then {
    $0.text = "자동 로그인"
    $0.font = CustomFont.Head4.font()
    $0.textColor = .CBlack
  }
  
  private let idLoginButton = UIButton().then {
//    $0.backgroundColor = .CBlack
    $0.backgroundColor = .white
//    $0.backgroundColor = .CBlue
//    $0.backgroundColor = .CLightBlue2
    $0.setImage(UIImage(systemName: "envelope.fill"), for: .normal)
//    $0.tintColor = .CWhite
    $0.tintColor = .CBlack
    $0.setTitle("이메일로 로그인", for: .normal)
    $0.titleLabel?.font = CustomFont.Head4.font()
//    $0.setTitleColor(.CWhite, for: .normal)
    $0.setTitleColor(.CBlack, for: .normal)
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
    $0.contentVerticalAlignment = .center
    $0.contentHorizontalAlignment = .center
    $0.layer.borderWidth = 1
    $0.layer.cornerRadius = 5
    $0.clipsToBounds = true
  }
  
  private let kakaoLoginButton = UIButton().then {
    $0.backgroundColor = UIColor(hexCode: "#FEE500")
    $0.setImage(UIImage(named: "kakaoLogo")?.resized(to: CGSize(width: 20, height: 20)), for: .normal)
    $0.setTitle("카카오 로그인", for: .normal)
    $0.titleLabel?.font = CustomFont.Head4.font()
    $0.setTitleColor(UIColor(hexCode: "#000000", alpha: 0.85), for: .normal)
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
    $0.layer.cornerRadius = 5
    $0.clipsToBounds = true
    $0.isHidden = true // 기능 구현 후 제거
  }
  
  // Apple 로그인 버튼을 기본 Apple 스타일로 변경
  private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
  
  private let signUpButton = UIButton().then {
    $0.setTitle("회원가입  |", for: .normal)
    $0.titleLabel?.font = CustomFont.Head4.font()
    $0.backgroundColor = .CWhite
    $0.setTitleColor(.CBlack, for: .normal)
  }
  
  private let nonMemeberButton = UIButton().then {
    $0.setTitle("비회원으로 둘러보기", for: .normal)
    $0.titleLabel?.font = CustomFont.Head4.font()
    $0.backgroundColor = .CWhite
    $0.setTitleColor(.CBlack, for: .normal)
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
//    $0.distribution = .fillEqually
    $0.spacing = 8
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .CWhite
    
    configureUI()
    bindUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    let isAutoLogin = UserDefaults.standard.bool(forKey: "autoLogin")
    checkboxButton.isSelected = isAutoLogin
    
    // 자동 로그인 상태에서 현재 사용자가 로그인되어 있는지 확인
    if isAutoLogin, let user = Auth.auth().currentUser {
      let mainTabBarViewModel = MainTabBarViewModel()
      let mainTabBarVC = MainTabBarViewController(viewModel: mainTabBarViewModel)
      self.navigationController?.setViewControllers([mainTabBarVC], animated: false)
    }
  }
  
  private func configureUI() {
    
    [
      signUpButton,
      nonMemeberButton
    ].forEach { buttonStackView.addArrangedSubview($0) }
    
    [
      titleLabel,
      idLabel,
      idTextField,
      passwordLabel,
      passwordTextField,
      kakaoLoginButton,
      appleLoginButton,
      idLoginButton,
      checkboxButton,
      autoLoginLabel,
      buttonStackView
    ].forEach { view.addSubview($0) }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(64)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    idLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(48)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    idTextField.snp.makeConstraints {
      $0.top.equalTo(idLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
    
    passwordLabel.snp.makeConstraints {
      $0.top.equalTo(idTextField.snp.bottom).offset(16)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.top.equalTo(passwordLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
    
    checkboxButton.snp.makeConstraints {
      $0.top.equalTo(passwordTextField.snp.bottom).offset(18)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(64)
    }
    
    autoLoginLabel.snp.makeConstraints {
      $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
      $0.leading.equalTo(checkboxButton.snp.trailing).offset(16)
    }
    
    idLoginButton.snp.makeConstraints {
      $0.centerX.equalTo(view.safeAreaLayoutGuide)
      $0.top.equalTo(checkboxButton.snp.bottom).offset(48)
      $0.width.equalTo(280)
      $0.height.equalTo(48)
    }
    
    appleLoginButton.snp.makeConstraints {
      $0.centerX.equalTo(view.safeAreaLayoutGuide)
      $0.top.equalTo(idLoginButton.snp.bottom).offset(24)
      $0.width.equalTo(280)
      $0.height.equalTo(48)
    }
    
    kakaoLoginButton.snp.makeConstraints {
      $0.centerX.equalTo(view.safeAreaLayoutGuide)
      $0.top.equalTo(appleLoginButton.snp.bottom).offset(24)
      $0.width.equalTo(280)
      $0.height.equalTo(48)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.centerX.equalTo(view.safeAreaLayoutGuide)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
  }
  
  private func bindUI() {
    // 이메일 텍스트 필드 입력을 ViewModel의 email 변수에 바인딩
    idTextField.rx.text.orEmpty
      .bind(to: viewModel.email)
      .disposed(by: disposeBag)
    
    // 비밀번호 텍스트 필드 입력을 ViewModel의 password 변수에 바인딩
    passwordTextField.rx.text.orEmpty
      .bind(to: viewModel.password)
      .disposed(by: disposeBag)
    
    // 체크박스 버튼 탭 이벤트 처리
    checkboxButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.checkboxButton.isSelected.toggle()
        UserDefaults.standard.set(self.checkboxButton.isSelected, forKey: "autoLogin")
      })
      .disposed(by: disposeBag)
    
    // 로그인 버튼 탭 이벤트 처리
    idLoginButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.viewModel.loginTap.onNext(())
      })
      .disposed(by: disposeBag)
    
    // 로그인 성공 이벤트 처리
    viewModel.loginSuccess
      .subscribe(onNext: { [weak self] in
        // 로그인 성공 시에만 자동 로그인 상태 저장
        if self?.checkboxButton.isSelected == true {
          UserDefaults.standard.set(true, forKey: "autoLogin")
        }
        let mainTabBarViewModel = MainTabBarViewModel()
        let mainTabBarVC = MainTabBarViewController(viewModel: mainTabBarViewModel)
        self?.navigationController?.setViewControllers([mainTabBarVC], animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.loginError
      .subscribe(onNext: { [weak self] errorMessage in
        let alert = UIAlertController(
          title: "로그인 실패",
          message: errorMessage, preferredStyle: .alert
        )
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        self?.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    // Apple 로그인 버튼 동작
    appleLoginButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
    
    viewModel.appleLoginSuccess
      .flatMap { _ -> Observable<[String: Any]> in
        guard let uid = FirebaseAuthManager.shared.getCurrentUserUid() else {
          return Observable.error(NSError(domain: "LoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get current user UID"]))
        }
        return FirebaseFirestoreManager.shared.fetchUserData(uid: uid)
      }
      .subscribe(onNext: { [weak self] userData in
        guard let self = self else { return }
        if let nickname = userData["nickname"] as? String, !nickname.isEmpty {
          self.goToMainScreen()  // 닉네임이 있으면 메인 화면으로 이동
        } else {
          self.goToSetNickNameScreen()  // 닉네임이 없으면 닉네임 설정 화면으로 이동
        }
      }, onError: { [weak self] error in
        print("Error fetching user data: \(error.localizedDescription)")
        let alert = UIAlertController(title: "로그인 오류", message: "사용자 데이터를 가져오는 데 실패했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    signUpButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let signUpVC = SignUpViewController()
        self.navigationController?.pushViewController(signUpVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    nonMemeberButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
          UserDefaults.standard.removeObject(forKey: "autoLogin")
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        let mainTabBarViewModel = MainTabBarViewModel()
        let mainTabBarVC = MainTabBarViewController(viewModel: mainTabBarViewModel)
        
        self.navigationController?.setViewControllers([mainTabBarVC], animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  @objc private func handleAppleLogin() {
    viewModel.appleLoginTap.onNext(())
  }
  
  private func handleLoginSuccess() {
    let mainTabBarViewModel = MainTabBarViewModel()
    let mainTabBarVC = MainTabBarViewController(viewModel: mainTabBarViewModel)
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
      window.rootViewController = mainTabBarVC
      window.makeKeyAndVisible()
    }
  }
  
  private func goToMainScreen() {
    let mainTabBarViewModel = MainTabBarViewModel()
    let mainTabBarVC = MainTabBarViewController(viewModel: mainTabBarViewModel)
    
    // Root ViewController를 메인 탭으로 교체
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first {
      window.rootViewController = mainTabBarVC
      window.makeKeyAndVisible()
    }
  }
  
  private func goToSetNickNameScreen() {
    let setNickNameVC = SetNickNameViewController()
    self.navigationController?.pushViewController(setNickNameVC, animated: true)
  }
}

//@available(iOS 17.0, *)
//#Preview {
//  LoginViewController()
//}
