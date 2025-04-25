//
//  LoginViewModel.swift
//  Duriso
//
//  Created by t2023-m0102 on 8/28/24.
//

import FirebaseAuth
import RxCocoa
import RxSwift

class LoginViewModel {
  
  let email = PublishSubject<String>()
  let password = PublishSubject<String>()
  let loginTap = PublishSubject<Void>()
  let appleLoginTap = PublishSubject<Void>()
  
  let loginSuccess = PublishSubject<Void>()
  let loginError = PublishSubject<String>()
  let appleLoginSuccess = PublishSubject<Void>() // Apple 로그인 성공 시 사용
  
  private let disposeBag = DisposeBag()
  
  init() {
    let credentials = Observable.combineLatest(email.asObservable(), password.asObservable())
    
    loginTap
      .withLatestFrom(credentials)
      .flatMapLatest { [weak self] email, password -> Observable<AuthDataResult> in
        guard let self = self else { return .empty() }
        
        // 입력값 유효성 검사
        if email.isEmpty || password.isEmpty {
          self.loginError.onNext("이메일과 비밀번호를 모두 입력해주세요.")
          return .empty()
        }
        
        // 이메일 형식 검사
        if !self.isValidEmail(email) {
          self.loginError.onNext("올바른 이메일 형식이 아닙니다.")
          return .empty()
        }
        
        return FirebaseAuthManager.shared.signIn(withEmail: email, password: password)
      }
      .subscribe(onNext: { [weak self] _ in
        self?.loginSuccess.onNext(())
      }, onError: { [weak self] error in
        let errorMessage = self?.translateFirebaseError(error) ?? "로그인에 실패했습니다. 다시 시도해주세요."
        self?.loginError.onNext(errorMessage)
      })
      .disposed(by: disposeBag)
    
    appleLoginTap
      .flatMapLatest {
        FirebaseAuthManager.shared.signInWithApple()
      }
      .flatMap { result -> Observable<(AuthDataResult, [String: Any]?)> in
        let uid = result.user.uid
        return FirebaseFirestoreManager.shared.fetchUserData(uid: uid)
          .map { userData in (result, userData) }
          .catchAndReturn((result, nil))
      }
      .flatMap { result, existingUserData -> Observable<Void> in
        let uid = result.user.uid
        let email = result.user.email ?? ""
        
        if let existingUserData = existingUserData, existingUserData["nickname"] as? String != nil {
          // 기존 사용자: 데이터 업데이트 없이 로그인 성공
          return Observable.just(())
        } else {
          // 새로운 사용자 또는 닉네임이 없는 사용자: 기본 데이터 저장
          return FirebaseFirestoreManager.shared.saveUserData(uid: uid, data: ["email": email, "nickname": "", "postcount": 0, "reportedpostcount": 0, "uuid": uid])
        }
      }
      .subscribe(onNext: { [weak self] in
        self?.appleLoginSuccess.onNext(())
      }, onError: { [weak self] error in
        self?.loginError.onNext(error.localizedDescription)
      })
      .disposed(by: disposeBag)
  }
  
  private func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
  }
  
  private func translateFirebaseError(_ error: Error) -> String {
    let errorCode = (error as NSError).code
    
    switch errorCode {
    case AuthErrorCode.invalidEmail.rawValue:
      return "이메일 또는 비밀번호가 올바르지 않습니다."
    case AuthErrorCode.wrongPassword.rawValue:
      return "이메일 또는 비밀번호가 올바르지 않습니다."
    case AuthErrorCode.userNotFound.rawValue:
      return "이메일 또는 비밀번호가 올바르지 않습니다."
    case AuthErrorCode.invalidCredential.rawValue:
      return "이메일 또는 비밀번호가 올바르지 않습니다."
    case AuthErrorCode.networkError.rawValue:
      return "네트워크 오류가 발생했습니다. 다시 시도해주세요."
    case AuthErrorCode.userDisabled.rawValue:
      return "이 계정은 비활성화되었습니다. 관리자에게 문의해주세요."
    case AuthErrorCode.tooManyRequests.rawValue:
      return "너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요."
    default:
      return "로그인에 실패했습니다. 다시 시도해주세요."
    }
  }
}
