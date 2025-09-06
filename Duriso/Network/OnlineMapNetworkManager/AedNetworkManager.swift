//
//  AedNetworkManager.swift
//  Duriso
//
//  Created by 이주희 on 9/10/24.
//

import Foundation

import Alamofire
import RxSwift

// MARK: - AED 네트워크 매니저
class AedNetworkManager {
  
  // 기본 URL과 엔드포인트 설정
  private let baseURL = "https://www.safetydata.go.kr"
  private let endpoint = "/V2/api/DSSP-IF-00068"
  private let networkManager = NetworkManager()
  private let disposeBag = DisposeBag()
  
  // MARK: - AED 데이터를 API로부터 가져오는 함수
  /// - Parameters:
  ///   - boundingBox: 검색할 좌표 범위를 지정하는 파라미터
  /// - Returns: AED 데이터를 포함한 `Observable<AedResponse>` 객체를 반환합니다.
  func fetchAeds(boundingBox: (startLat: Double, endLat: Double, startLot: Double,
                               endLot: Double)) -> Observable<AedResponse> {
    let parameters: [String: Any] = [
      "serviceKey": Environment.aedApiKey,
      "numOfRows": 1000,
      "startLot": boundingBox.startLot,
      "endLot": boundingBox.endLot,
      "startLat": boundingBox.startLat,
      "endLat": boundingBox.endLat
    ]
    
    // NetworkManager의 request 메소드를 호출하여 데이터를 요청
    return networkManager.request(
      baseURL: baseURL,
      endpoint: endpoint,
      parameters: parameters,
      responseType: AedResponse.self
    )
  }
}
