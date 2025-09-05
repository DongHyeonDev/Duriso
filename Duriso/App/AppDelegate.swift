//
//  AppDelegate.swift
//  Duriso
//
//  Created by 김동현 on 8/25/24.
//

import UIKit

import FirebaseCore
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import KakaoMapsSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  /// 어플리케이션이 실행될 때 딱 한번 실행되는 메소드
  /// 앱 초기화 코드
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // 애플리케이션 실행 후 사용자 지정에 대한 재정의 지점.
    
    print("앱이 시작되었습니다.")
    FirebaseApp.configure()
    
    SDKInitializer.InitSDK(appKey: Environment.kakaoMapApiKey)
    
    let aedDataManager = AedDataManager()
    DispatchQueue.global(qos: .background).async {
      aedDataManager.fetchAllAeds()
        .subscribe(onNext: { response in },
                   onError: { error in
          print("Error fetching AEDs: \(error)")
        })
        .disposed(by: aedDataManager.disposeBag)
    }
    
    // 네트워크 모니터링 시작
    NetworkMonitor.shared.startMonitoring()
    
    // IQKeyboardManager 사용 설정
    IQKeyboardManager.shared.enable = true
    IQKeyboardToolbarManager.shared.isEnabled = true
    IQKeyboardManager.shared.resignOnTouchOutside = true
    
    // TabBar 색상 지정
    if #available(iOS 15, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .CWhite
      UITabBar.appearance().standardAppearance = appearance
      UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    return true
  }
  
  /// 어플리케이션이 종료될 때 실행되는 메소드
  /// 앱이 비활성화될 때 호출
  func applicationWillResignActive(_ application: UIApplication) {
    print("앱이 비활성화 상태로 전환됩니다.")
  }
  
  /// 앱이 백그라운드로 전환될 때 호출
  func applicationDidEnterBackground(_ application: UIApplication) {
    print("앱이 백그라운드로 전환되었습니다.")
  }
  
  /// 앱이 다시 포그라운드로 전환될 때 호출
  func applicationWillEnterForeground(_ application: UIApplication) {
    print("앱이 포그라운드로 전환됩니다.")
  }
  
  /// 앱이 활성화 상태로 전환될 때 호출
  func applicationDidBecomeActive(_ application: UIApplication) {
    print("앱이 활성화 상태로 전환되었습니다.")
  }
  
  /// 앱이 종료될 때 호출
  func applicationWillTerminate(_ application: UIApplication) {
    // 앱 종료 시 네트워크 모니터링 중지
    NetworkMonitor.shared.stopMonitoring()
    print("앱이 종료됩니다.")
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // 새 scene 세션이 생성될 때 호출됩니다.
    // 새 scene을 생성할 구성을 선택하려면 이 메서드를 사용합니다.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // 사용자가 장면 세션을 삭제할 때 호출됩니다.
    // 애플리케이션이 실행 중이 아닌 동안 세션이 삭제된 경우, 이 메서드는 application:didFinishLaunchingWithOptions 직후에 호출됩니다.
    // 이 메서드를 사용하면 폐기된 씬과 관련된 모든 리소스가 반환되지 않으므로 해제할 수 있습니다.
  }
}

