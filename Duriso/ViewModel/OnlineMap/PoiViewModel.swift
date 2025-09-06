//
//  PoiViewModel.swift
//  Duriso
//
//  Created by 이주희 on 8/26/24.
//

import CoreLocation

import FirebaseFirestore
import KakaoMapsSDK
import RxSwift


// MARK: - Protocol for Delegate
protocol PoiViewModelDelegate: AnyObject {
  func didTapShelter(poiID: String, shelterType: String, address: String)
  func didTapAed(poiID: String, address: String, adminName: String, adminNumber: String, managementAgency: String, location: String)
  func didTapEmergencyReport(poiID: String, address: String)
}

// MARK: - PoiViewModel Class
class PoiViewModel {
  
  // MARK: - Properties
  static let shared = PoiViewModel()  // Singleton 패턴
  weak var delegate: PoiViewModelDelegate?
  
  private let boardFirebaseService = BoardFirebaseService()
  private let disposeBag = DisposeBag()
  
  let shelterNetworkManager = ShelterNetworkManager()
  let aedNetworkManager = AedNetworkManager()
  
  let shelterPois = PublishSubject<[Shelter]>()
  let aedPois = PublishSubject<[Aed]>()
  let emergencyReportPois = PublishSubject<[Posts]>()
  
  // MARK: - POI 데이터 설정 및 바운딩 박스 계산
  
  /// 현재 위치 기반으로 POI 데이터를 설정하고 바운딩 박스를 계산
  func setupPoiData() {
    guard let currentLocation = LocationManager.shared.currentLocation else { return }
    
    let boundingBox = calculateBoundingBox(for: currentLocation, radius: 2000)
    
    // 쉘터, AED, 긴급 보고 데이터 요청
    fetchShelterData(boundingBox: boundingBox)
    fetchAedData(boundingBox: boundingBox)
    fetchEmergencyReportData()
  }
  
  // MARK: - Shelter Data Fetching
  private func fetchShelterData(boundingBox: (startLat: Double, endLat: Double, startLot: Double, endLot: Double)) {
    shelterNetworkManager.fetchShelters(boundingBox: boundingBox)
      .subscribe(onNext: { shelterResponse in
        self.shelterPois.onNext(shelterResponse.body)
      }, onError: { error in
        print("Error fetching shelters: \(error)")
      }).disposed(by: disposeBag)
  }
  
  // MARK: - AED Data Fetching
  private func fetchAedData(boundingBox: (startLat: Double, endLat: Double, startLot: Double, endLot: Double)) {
    aedNetworkManager.fetchAeds(boundingBox: boundingBox)
      .subscribe(onNext: { aedResponse in
        self.aedPois.onNext(aedResponse.body)
      }, onError: { error in
        print("Error fetching AEDs: \(error)")
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Emergency Report Data Fetching
  private func fetchEmergencyReportData() {
    boardFirebaseService.fetchPosts()
      .subscribe(onNext: { [weak self] posts in
        self?.emergencyReportPois.onNext(posts)
      }, onError: { error in
        print("Error fetching posts: \(error)")
      }).disposed(by: disposeBag)
  }
  
  // MARK: - Bounding Box 계산
  func calculateBoundingBox(for location: CLLocation, radius: Double) -> (startLat: Double, endLat: Double, startLot: Double, endLot: Double) {
    let earthRadius = 6371000.0
    let deltaLat = (radius / earthRadius) * (180.0 / .pi)
    let deltaLon = (radius / (earthRadius * cos(.pi * location.coordinate.latitude / 180.0))) * (180.0 / .pi)
    
    let startLat = location.coordinate.latitude - deltaLat
    let endLat = location.coordinate.latitude + deltaLat
    let startLot = location.coordinate.longitude - deltaLon
    let endLot = location.coordinate.longitude + deltaLon
    
    return (startLat, endLat, startLot, endLot)
  }
  
  // MARK: - AED 필터링
  private func filterAedsInBoundingBox(aeds: [Aed], boundingBox: (startLat: Double, endLat: Double, startLot: Double, endLot: Double)) -> [Aed] {
    return aeds.filter { aed in
      return aed.latitude >= boundingBox.startLat && aed.latitude <= boundingBox.endLat &&
      aed.longitude >= boundingBox.startLot && aed.longitude <= boundingBox.endLot
    }
  }
  
  // MARK: - POI 데이터 바인딩 및 스타일 설정
  func bindPoiData(to mapController: KMController) {
    bindLodPoiType(poiObservable: aedPois,
                   styleID: "aedStyle",
                   imageName: "AEDMarker.png",
                   layerID: "aedLayer",
                   createLodPoiFunction: { [weak self] aeds, layerID, styleID, mapController in
      self?.aedCreateLodPoi(aeds: aeds, layerID: layerID, styleID: styleID, mapController: mapController)
    },
                   mapController: mapController)
    
    bindLodPoiType(poiObservable: shelterPois,
                   styleID: "shelterStyle",
                   imageName: "ShelterMarker.png",
                   layerID: "shelterLayer",
                   createLodPoiFunction: { [weak self] shelters, layerID, styleID, mapController in
      self?.shelterCreateLodPoi(shelters: shelters, layerID: layerID, styleID: styleID, mapController: mapController)
    },
                   mapController: mapController)
    
    bindLodPoiType(poiObservable: emergencyReportPois,
                   styleID: "emergencyReportStyle",
                   imageName: "NotificationMarker.png",
                   layerID: "emergencyReportLayer",
                   createLodPoiFunction: { [weak self] reports, layerID, styleID, mapController in
      self?.emergencyReportCreateLodPoi(posts: reports, layerID: layerID, styleID: styleID, mapController: mapController)
    },
                   mapController: mapController)
  }
  
  // MARK: - POI 생성 및 바인딩
  private func bindLodPoiType<T>(
    poiObservable: Observable<[T]>,
    styleID: String,
    imageName: String,
    layerID: String,
    createLodPoiFunction: @escaping ([T], String, String, KMController) -> Void,
    mapController: KMController) {
      poiObservable
        .subscribe(onNext: { [weak self] pois in
          self?.createLodPoiStyle(styleID: styleID, imageName: imageName, mapController: mapController)
          createLodPoiFunction(pois, layerID, styleID, mapController)
        }, onError: { error in
          print("Error receiving LodPOIs for \(styleID): \(error)")
        }).disposed(by: disposeBag)
    }
  
  // MARK: - POI 스타일 생성
  private func createLodPoiStyle(styleID: String, imageName: String, mapController: KMController) {
    guard let mapView = mapController.getView("mapview") as? KakaoMap else {
      print("Error: mapView is nil.")
      return
    }
    
    let labelManager = mapView.getLabelManager()
    if let image = UIImage(named: imageName) {
      let icon = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0))
      let perLevelStyle = PerLevelPoiStyle(iconStyle: icon, level: 0)
      let lodPoiStyle = PoiStyle(styleID: styleID, styles: [perLevelStyle])
      labelManager.addPoiStyle(lodPoiStyle)
    } else {
      print("Error: Failed to load image: \(imageName)")
    }
  }
  
  // MARK: - POI 생성 및 이벤트 핸들링
  
  // MARK: - POI 생성 함수
  private func createLodPoi<T>(
      items: [T],
      layerID: String,
      styleID: String,
      mapController: KMController,
      getPoiID: (T) -> String,
      getCoordinates: (T) -> (latitude: Double, longitude: Double),
      getAddress: (T) -> String?,
      getAdditionalInfo: (T) -> String?,
      getAdditionalInfo2: (T) -> String?,
      getAdditionalInfo3: (T) -> String?,
      getAdditionalInfo4: (T) -> String?
  ) {
      guard let mapView = mapController.getView("mapview") as? KakaoMap else {
          print("Error: mapView is nil")
          return
      }

      let labelManager = mapView.getLabelManager()
      guard let layer = labelManager.getLabelLayer(layerID: layerID) else {
          print("Error: Failed to get layer with ID \(layerID)")
          return
      }

      // 기존 레이어의 POI를 모두 삭제
      layer.clearAllItems()

      for item in items {
          let coordinates = getCoordinates(item)
          let poiID = getPoiID(item)
          let address = getAddress(item) ?? "제공받은 데이터가 없습니다."
          let additionalInfo1 = getAdditionalInfo(item) ?? "제공받은 데이터가 없습니다."
          let additionalInfo2 = getAdditionalInfo2(item) ?? "제공받은 데이터가 없습니다."
          let additionalInfo3 = getAdditionalInfo3(item) ?? "제공받은 데이터가 없습니다."
          let additionalInfo4 = getAdditionalInfo4(item) ?? "제공받은 데이터가 없습니다."

          // POI를 레이어에 추가
          if let poiItem = layer.addPoi(option: PoiOptions(styleID: styleID, poiID: poiID), at: MapPoint(longitude: coordinates.longitude, latitude: coordinates.latitude)) {
              poiItem.show()
              poiItem.clickable = true

              // POI에 사용자 정의 데이터를 저장
              poiItem.userObject = NSDictionary(dictionary: [
                  "poiID": poiID,
                  "latitude": coordinates.latitude,
                  "longitude": coordinates.longitude,
                  "address": address,
                  "additionalInfo1": additionalInfo1,
                  "additionalInfo2": additionalInfo2,
                  "additionalInfo3": additionalInfo3,
                  "additionalInfo4": additionalInfo4
              ])

              // POI 클릭 이벤트 핸들러 설정
              _ = poiItem.addPoiTappedEventHandler(target: self) { (self) in
                  return { param in
                      self.poiTapped(param)
                  }
              }
          }
      }
  }
  private func aedCreateLodPoi(aeds: [Aed], layerID: String, styleID: String, mapController: KMController) {
    createLodPoi(
      items: aeds,
      layerID: layerID,
      styleID: styleID,
      mapController: mapController,
      getPoiID: { String($0.serialNumber) },
      getCoordinates: { ($0.latitude, $0.longitude) },
      getAddress: { $0.address },
      getAdditionalInfo: { $0.location },
      getAdditionalInfo2: { $0.adminName },
      getAdditionalInfo3: { $0.adminNumber },
      getAdditionalInfo4: { $0.managementAgency }
    )
  }
  
  private func shelterCreateLodPoi(shelters: [Shelter], layerID: String, styleID: String, mapController: KMController) {
    createLodPoi(
      items: shelters,
      layerID: layerID,
      styleID: styleID,
      mapController: mapController,
      getPoiID: { $0.shelterName ?? "제공받은 데이터가 없습니다." },
      getCoordinates: { ($0.latitude, $0.longitude) },
      getAddress: { $0.address },
      getAdditionalInfo: { $0.shelterTypeName },
      getAdditionalInfo2: { _ in nil },
      getAdditionalInfo3: { _ in nil },
      getAdditionalInfo4: { _ in nil }
    )
  }
  
  private func emergencyReportCreateLodPoi(posts: [Posts], layerID: String, styleID: String, mapController: KMController) {
    createLodPoi(
      items: posts,
      layerID: layerID,
      styleID: styleID,
      mapController: mapController,
      getPoiID: { $0.postid },
      getCoordinates: { ($0.postlatitude, $0.postlongitude) },
      getAddress: { $0.dong + " " + $0.gu },
      getAdditionalInfo: { _ in nil },
      getAdditionalInfo2: { _ in nil },
      getAdditionalInfo3: { _ in nil },
      getAdditionalInfo4: { _ in nil }
    )
  }
  
  // MARK: - POI 터치 이벤트 처리
  func poiTapped(_ param: PoiInteractionEventParam) {
    let poiItem = param.poiItem
    guard let userObject = poiItem.userObject as? [String: Any],
          let poiID = userObject["poiID"] as? String else {
      print("Error: POI ID is nil or invalid.")
      return
    }
    
    switch param.poiItem.layerID {
    case "shelterLayer":
      handleShelterPoi(poiID: poiID, userObject: userObject)
    case "aedLayer":
      handleAedPoi(poiID: poiID, userObject: userObject)
    case "emergencyReportLayer":
      handleEmergencyReportPoi(poiID: poiID, userObject: userObject)
    default:
      print("Error: POI style ID is unknown.")
    }
  }
  
  // MARK: - 각 POI 타입에 따른 터치 이벤트 처리
  private func handleAedPoi(poiID: String, userObject: [String: Any]) {
    let location = userObject["additionalInfo1"] as? String ?? "제공받은 데이터가 없습니다."
    let adminName = userObject["additionalInfo2"] as? String ?? "제공받은 데이터가 없습니다."
    let adminNumber = userObject["additionalInfo3"] as? String ?? "제공받은 데이터가 없습니다."
    let managementAgency = userObject["additionalInfo4"] as? String ?? "제공받은 데이터가 없습니다."
    let address = userObject["address"] as? String ?? "제공받은 데이터가 없습니다."
    
    delegate?.didTapAed(poiID: poiID, address: address, adminName: adminName, adminNumber: adminNumber, managementAgency: managementAgency, location: location)
  }
  
  private func handleShelterPoi(poiID: String, userObject: [String: Any]) {
    let address = userObject["address"] as? String ?? "제공받은 데이터가 없습니다."
    let shelterType = userObject["additionalInfo1"] as? String ?? "제공받은 데이터가 없습니다."
    
    delegate?.didTapShelter(poiID: poiID, shelterType: shelterType, address: address)
  }
  
  private func handleEmergencyReportPoi(poiID: String, userObject: [String: Any]) {
    _ = userObject["name"] as? String ?? "제공받은 데이터가 없습니다."
    let reportAddress = userObject["address"] as? String ?? "제공받은 데이터가 없습니다."
    
    delegate?.didTapEmergencyReport(poiID: poiID, address: reportAddress)
  }
  
  // MARK: - POI 숨김/표시
  private func togglePoisVisibility(mapController: KMController, layerID: String, show: Bool) {
    guard let mapView = mapController.getView("mapview") as? KakaoMap else { return }
    
    let labelManager = mapView.getLabelManager()
    if let layer = labelManager.getLabelLayer(layerID: layerID) {
      show ? layer.showAllPois() : layer.hideAllPois()
    } else {
      print("Error: Failed to get layer with ID \(layerID)")
    }
  }
  
  func hideShelters(mapController: KMController) {
    togglePoisVisibility(mapController: mapController, layerID: "shelterLayer", show: false)
  }
  
  func showShelters(mapController: KMController) {
    togglePoisVisibility(mapController: mapController, layerID: "shelterLayer", show: true)
  }
  
  func hideAeds(mapController: KMController) {
    togglePoisVisibility(mapController: mapController, layerID: "aedLayer", show: false)
  }
  
  func showAeds(mapController: KMController) {
    togglePoisVisibility(mapController: mapController, layerID: "aedLayer", show: true)
  }
  
  func hideEmergencyReport(mapController: KMController) {
    togglePoisVisibility(mapController: mapController, layerID: "emergencyReportLayer", show: false)
  }
  
  func showEmergencyReport(mapController: KMController) {
    togglePoisVisibility(mapController: mapController, layerID: "emergencyReportLayer", show: true)
  }
  
  // MARK: - 위치 기반 데이터 요청
  func fetchDataForLocation(latitude: Double, longitude: Double) {
    let boundingBox = calculateBoundingBox(for: CLLocation(latitude: latitude, longitude: longitude), radius: 2000)
    
    fetchShelterData(boundingBox: boundingBox)
    fetchAedData(boundingBox: boundingBox)
    fetchEmergencyReportData()
  }
}
