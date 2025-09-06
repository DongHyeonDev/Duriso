//
//  SceneDelegate.swift
//  Duriso
//
//  Created by 김동현 on 9/1/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  
  /// 새로운 UIWindow를 생성하고 rootViewController를 설정
  /// 장면이 연결될 때 호출
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // 이 메서드를 사용하면 제공된 UIWindowScene `scene`에 선택적으로 UIWindow `window`를 구성하고 첨부할 수 있습니다.
    // 스토리보드를 사용하는 경우 `window` 프로퍼티가 자동으로 초기화되어 씬에 첨부됩니다.
    // 이 델리게이트는 연결 장면이나 세션이 새로운 것을 의미하지 않습니다(대신 `application:configurationForConnectingSceneSession` 참조).
    
    // scene이 UIWindowScene으로 캐스팅되지 않으면 함수 종료
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    // window를 생성하고 UIWindowScene에 연결
    let window = UIWindow(windowScene: windowScene)
    
    // MARK: - 개발용 : 로그인 페이지 건너뛰고 MainTabBar로 바로 이동
    
//    let mainTabBarViewModel = MainTabBarViewModel()
//    let mainTabBarViewController = MainTabBarViewController(viewModel: mainTabBarViewModel)
//    
//    window.rootViewController = mainTabBarViewController
    
    // MARK: - 실 서비스용 : 로그인 페이지를 첫 화면으로 할 경우
    
    let rootVC = LoginViewController()
    let introNavigationVC = UINavigationController(rootViewController: rootVC)
    window.rootViewController = introNavigationVC
    
    // MARK: - window 적용 부분
    self.window = window
    window.makeKeyAndVisible()
    
    print("장면이 연결되었습니다.")
  }
  
  /// scene이 연결 해제될 때 호출되는 메서드
  /// 장면이 분리될 때 호출
  func sceneDidDisconnect(_ scene: UIScene) {
    // scene이 시스템에 의해 릴리스될 때 호출됩니다.
    // scene이 백그라운드로 들어간 직후 또는 해당 세션이 삭제될 때 발생합니다.
    // 다음에 scene이 연결될 때 다시 생성할 수 있는 이 scene과 관련된 모든 리소스를 해제합니다.
    // 해당 세션이 반드시 삭제된 것은 아니므로 나중에 장면이 다시 연결될 수 있습니다(대신 `application:didDiscardSceneSessions` 참조).
    
    print("장면이 분리되었습니다.")
  }

  /// 장면이 활성화될 때 호출
  func sceneDidBecomeActive(_ scene: UIScene) {
    // scene이 비활성 상태에서 활성 상태로 전환되었을 때 호출됩니다.
    // scene이 비활성 상태일 때 일시 중지되었거나 아직 시작되지 않은 작업을 다시 시작하려면 이 메서드를 사용합니다.
    print("장면이 활성화되었습니다.")
  }

  /// 장면이 비활성화될 때 호출
  func sceneWillResignActive(_ scene: UIScene) {
    // scene이 활성 상태에서 비활성 상태로 전환될 때 호출됩니다.
    // 일시적인 중단(예: 전화 수신)으로 인해 발생할 수 있습니다.
    print("장면이 비활성화됩니다.")
  }

  /// 장면이 포그라운드로 전환될 때 호출
  func sceneWillEnterForeground(_ scene: UIScene) {
    // scene이 배경에서 전경으로 전환될 때 호출됩니다.
    // 배경에 진입할 때 변경한 내용을 취소하려면 이 메서드를 사용합니다.
    print("장면이 포그라운드로 전환됩니다.")
  }

  /// 장면이 백그라운드로 전환될 때 호출
  func sceneDidEnterBackground(_ scene: UIScene) {
    // scene이 전경에서 배경으로 전환될 때 호출됩니다.
    // 이 메서드를 사용하면 데이터를 저장하고, 공유 리소스를 해제하고, scene별 상태 정보를 충분히 저장할 수 있습니다.
    // scene을 현재 상태로 복원할 수 있습니다.
    print("장면이 백그라운드로 전환되었습니다.")
  }


}

