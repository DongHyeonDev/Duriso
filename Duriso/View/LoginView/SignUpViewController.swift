//
//  SingUpViewController.swift
//  Duriso
//
//  Created by t2023-m0102 on 8/27/24.
//

import UIKit

import FirebaseAuth
import RxCocoa
import RxSwift
import SnapKit

class SignUpViewController: UIViewController {
  
  private let titleLabel = UILabel().then {
    $0.text = "환영합니다! \n회원가입"
    $0.font = CustomFont.Head.font()
    $0.textColor = .CBlack
    $0.numberOfLines = 0
    $0.textAlignment = .left
  }
  
  private let emailLabel = UILabel().then {
    $0.text = "이메일"
    $0.font = CustomFont.Head3.font()
    $0.textColor = .CBlack
  }
  
  private let emailTextField = UITextField().then {
    $0.placeholder = "이메일을 입력하세요"
    $0.font = CustomFont.Body3.font()
    $0.backgroundColor = .lightGray
    $0.borderStyle = .roundedRect
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  private let nicknameLabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = CustomFont.Head3.font()
    $0.textColor = .CBlack
  }
  
  private let nicknameTextField = UITextField().then {
    $0.placeholder = "닉네임을 입력하세요"
    $0.font = CustomFont.Body3.font()
    $0.backgroundColor = .lightGray
    $0.borderStyle = .roundedRect
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
  
  private let checkpasswordLabel = UILabel().then {
    $0.text = "비밀번호 확인"
    $0.font = CustomFont.Head3.font()
    $0.textColor = .CBlack
  }
  
  private let checkpasswordTextField = UITextField().then {
    $0.borderStyle = .roundedRect
    $0.placeholder = "비밀번호를 입력하세요"
    $0.font = CustomFont.Body3.font()
    $0.backgroundColor = .lightGray
    $0.autocorrectionType = .no
    $0.isSecureTextEntry = true
    $0.autocapitalizationType = .none
  }
  
  private let legalNoticeTableView = UITableView().then {
    $0.register(SignUpTableViewCell.self, forCellReuseIdentifier: "LegalNoticeCell")
    $0.backgroundColor = .CWhite
    $0.rowHeight = 32
    $0.isScrollEnabled = false
  }
  
  private let saveButton = UIButton().then {
    $0.setTitle("저장", for: .normal)
    $0.backgroundColor = .lightGray
    $0.titleLabel?.font = CustomFont.Head4.font()
    $0.layer.cornerRadius = 10
    $0.isEnabled = false
  }
  
  private let disposeBag = DisposeBag()
  private let viewModel = SignUpViewModel()
  private let viewModel2 = LegalNoticeViewModel()
  
  private var checkedCount = 0
  private let totalCheckboxes = 3
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .CWhite
    
    configureUI()
    bindViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  private func configureUI() {
    [
      titleLabel,
      emailLabel,
      emailTextField,
      nicknameLabel,
      nicknameTextField,
      passwordLabel,
      passwordTextField,
      checkpasswordLabel,
      checkpasswordTextField,
      legalNoticeTableView,
      saveButton
    ].forEach { view.addSubview($0) }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    emailLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(32)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    emailTextField.snp.makeConstraints {
      $0.top.equalTo(emailLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
    
    nicknameLabel.snp.makeConstraints {
      $0.top.equalTo(emailTextField.snp.bottom).offset(24)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    nicknameTextField.snp.makeConstraints {
      $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
    
    passwordLabel.snp.makeConstraints {
      $0.top.equalTo(nicknameTextField.snp.bottom).offset(24)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    passwordTextField.snp.makeConstraints {
      $0.top.equalTo(passwordLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
    
    checkpasswordLabel.snp.makeConstraints {
      $0.top.equalTo(passwordTextField.snp.bottom).offset(24)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
    }
    
    checkpasswordTextField.snp.makeConstraints {
      $0.top.equalTo(checkpasswordLabel.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
    
    legalNoticeTableView.snp.makeConstraints{
      $0.top.equalTo(checkpasswordTextField.snp.bottom).offset(16)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
      $0.bottom.equalTo(saveButton.snp.top).offset(-16)
    }
    
    saveButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.height.equalTo(48)
    }
  }
  
  private func bindViewModel() {
    emailTextField.rx.text.orEmpty
      .bind(to: viewModel.emailText)
      .disposed(by: disposeBag)
    
    nicknameTextField.rx.text.orEmpty
      .bind(to: viewModel.nicknameText)
      .disposed(by: disposeBag)
    
    passwordTextField.rx.text.orEmpty
      .bind(to: viewModel.passwordText)
      .disposed(by: disposeBag)
    
    checkpasswordTextField.rx.text.orEmpty
      .bind(to: viewModel.checkPasswordText)
      .disposed(by: disposeBag)
    
    // 약관 동의 체크박스 관련 처리
    viewModel2.items
      .bind(to: legalNoticeTableView.rx.items(
        cellIdentifier: "LegalNoticeCell",
        cellType: SignUpTableViewCell.self)
      ) { [weak self] row, item, cell in
        cell.configure(with: item.title)
        cell.onCheckboxStateChange = { isChecked in
          if isChecked {
            self?.checkedCount += 1
          } else {
            self?.checkedCount -= 1
          }
          let isEnabled = self?.checkedCount == self?.totalCheckboxes
          self?.saveButton.isEnabled = isEnabled
          self?.saveButton.backgroundColor = isEnabled ? .CBlue : .lightGray
        }
      }
      .disposed(by: disposeBag)
    
    // 약관 세부 내용 보기
    legalNoticeTableView.rx.modelSelected(LegalNoticeModel.self)
      .subscribe(onNext: { [weak self] item in
        let detailVC = LegalNoticeDetailViewController(notice: item)
        self?.navigationController?.pushViewController(detailVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 저장 버튼 클릭 처리
    saveButton.rx.tap
      .flatMapLatest { [weak self] _ -> Observable<Result<AuthDataResult, Error>> in
        guard let self = self else { return Observable.empty() }
        return self.viewModel.performUserCreation()
          .map { Result.success($0) }
          .catch { error in Observable.just(Result.failure(error)) }
      }
      .subscribe(onNext: { [weak self] result in
        switch result {
        case .success:
          self?.showSuccessAlert()
        case .failure(let error):
          self?.showErrorAlert(error: error)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func showSuccessAlert() {
    let alert = UIAlertController(
      title: "회원가입 성공",
      message: "계정이 성공적으로 생성되었습니다.", preferredStyle: .alert
    )
    let action = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
      self?.navigationController?.popViewController(animated: true)
    }
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  private func showErrorAlert(error: Error) {
    let errorMessage = translateFirebaseError(error)
    
    let alert = UIAlertController(
      title: "회원가입 실패",
      message: errorMessage, preferredStyle: .alert
    )
    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  private func translateFirebaseError(_ error: Error) -> String {
    let errorCode = (error as NSError).code
    
    switch errorCode {
    case AuthErrorCode.invalidEmail.rawValue:
      return "유효하지 않은 이메일 주소입니다. 다시 확인해주세요."
    case AuthErrorCode.emailAlreadyInUse.rawValue:
      return "이미 사용 중인 이메일 주소입니다."
    case AuthErrorCode.weakPassword.rawValue:
      return "비밀번호는 최소 6자리 이상이어야 합니다."
    case AuthErrorCode.networkError.rawValue:
      return "네트워크 오류가 발생했습니다. 다시 시도해주세요."
    case 1001: // 닉네임 중복에 관한 에러코드가 따로 없음
      return "이미 사용 중인 닉네임입니다. 다른 닉네임을 사용해주세요."
    case 1002:
      return "비밀번호가 일치하지 않습니다."
    default:
      return error.localizedDescription
    }
  }
}

//@available(iOS 17.0, *)
//#Preview {
//  SignUpViewController()
//}
