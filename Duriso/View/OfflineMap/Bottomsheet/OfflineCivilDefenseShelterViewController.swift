//
//  OfflineCivilDefenseShelterViewController.swift
//  Duriso
//
//  Created by 김동현 on 9/29/24.
//

import UIKit

import SnapKit
import Then

class OfflineCivilDefenseShelterViewController: UIViewController {
  
  // MARK: -property
  
  // POI 데이터를 저장할 변수
  var poiName: String?
  var poiAddress: String?
  var poiType: String?
  var poiLat: Double?
  var poiLon: Double?
  var poiScale: Int?
  var poiUnit: String?
  var poiUsualType: String?
  var poiInstName: String?
  var poiInstTel: String?
  var poiPerson: Int?
  
  // UI 요소들
  let typeStackView = UIStackView().then {
    
    $0.backgroundColor = .CWhite
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.alignment = .center
    $0.layer.borderColor = UIColor.CYellow.cgColor
    $0.layer.borderWidth = 1.0
    $0.layer.cornerRadius = 13
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowColor = UIColor.CBlack.cgColor
    $0.layer.shadowRadius = 4
    $0.layer.masksToBounds = false
  }
  
  let typeLogo = UIImageView().then {
    $0.image = UIImage(systemName: "figure.run")
    $0.tintColor = .CYellow
    $0.contentMode = .scaleAspectFit
  }
  
  let typeLabel = UILabel().then {
    $0.text = "대피소"
    $0.textColor = .CYellow
    $0.textAlignment = .center
    $0.font = CustomFont.Deco4.font()
  }
  
  let shelterName = UILabel().then {
    $0.text = "대피소 이름"
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Head2.font()
  }
  
  let shelterAddress = UILabel().then {
    $0.text = "위치 정보 받아오는 중..."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 0
    $0.adjustsFontSizeToFitWidth = true
  }
  
  let shelterType = UILabel().then {
    $0.text = "000 대피소"
    $0.textColor = .CBlack
    $0.textAlignment = .center
    $0.font = CustomFont.Body4.font()
  }
  
  let cancelButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    $0.tintColor = .CLightBlue
    $0.contentMode = .scaleAspectFit
  }
  
  final let latLabel = UILabel().then {
    $0.text = "위도 정보 받아오는 중.."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 1
  }
  
  final let lonLabel = UILabel().then {
    $0.text = "경도 정보 받아오는 중.."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 1
  }
  
  final let scaleLabel = UILabel().then {
    $0.text = "규모 정보 받아오는 중.."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 1
  }
  
  final let personLabel = UILabel().then {
    $0.text = "인원수 정보 받아오는 중.."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 1
  }
  
  final let instNameLabel = UILabel().then {
    $0.text = "관리기관 정보 받아오는 중.."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 1
  }
  
  final let instTelLabel = UILabel().then {
    $0.text = "관리기관 정보 받아오는 중.."
    $0.textColor = .CBlack
    $0.textAlignment = .left
    $0.font = CustomFont.Body3.font()
    $0.numberOfLines = 1
  }
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupView()
    setupConstraints()
    
    updatePoiData()
    
    cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
  }
  
  // MARK: - View Setup
  
  // UI 요소들을 서브뷰에 추가하는 함수
  func setupView() {
    [
      typeLogo,
      typeLabel
    ].forEach { typeStackView.addSubview($0) }
    
    // 스택 뷰와 라벨들을 메인 뷰에 추가
    [
      shelterName,
      typeStackView,
      shelterAddress,
      shelterType,
      cancelButton,
      latLabel,
      lonLabel,
      scaleLabel,
      personLabel,
      instNameLabel,
      instTelLabel
    ].forEach { view.addSubview($0) }
  }
  
  // MARK: - Constraints Setup
  
  // UI 요소들의 제약 조건 설정 함수
  func setupConstraints() {
    typeStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
//      $0.width.equalTo(85)   // 스택 뷰 너비 설정
      $0.height.equalTo(26)  // 스택 뷰 높이 설정
    }
    
    typeLogo.snp.makeConstraints {
      $0.leading.equalTo(typeStackView.snp.leading).offset(4)
      $0.bottom.equalTo(typeStackView.snp.bottom)
      $0.height.equalTo(22)
    }
    
    typeLabel.snp.makeConstraints {
      $0.leading.equalTo(typeLogo.snp.trailing)
      $0.trailing.equalTo(typeStackView.snp.trailing).offset(-4)
    }
    
    shelterName.snp.makeConstraints {
      $0.top.equalTo(typeStackView.snp.bottom).offset(16)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    shelterType.snp.makeConstraints {
      $0.top.equalTo(shelterName.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    shelterAddress.snp.makeConstraints {
      $0.top.equalTo(shelterType.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    cancelButton.snp.makeConstraints {
      $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
      $0.width.height.equalTo(32)  // 취소 버튼 크기 설정
    }
    
    latLabel.snp.makeConstraints {
      $0.top.equalTo(shelterAddress.snp.bottom).offset(8)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    lonLabel.snp.makeConstraints {
      $0.top.equalTo(latLabel.snp.bottom)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    scaleLabel.snp.makeConstraints {
      $0.top.equalTo(lonLabel.snp.bottom).offset(4)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    personLabel.snp.makeConstraints {
      $0.top.equalTo(scaleLabel.snp.bottom)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    instNameLabel.snp.makeConstraints {
      $0.top.equalTo(personLabel.snp.bottom)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
    
    instTelLabel.snp.makeConstraints {
      $0.top.equalTo(instNameLabel.snp.bottom)
      $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
    }
  }
  
  // MARK: - POI Data Update
  
  // 전달받은 POI 데이터를 UI에 반영하는 함수
  func updatePoiData() {
    shelterName.text = poiName ?? "제공받은 데이터가 없습니다."
    shelterAddress.text = "주소: \(poiAddress ?? "제공받은 데이터가 없습니다.")"
    shelterType.text = "\(poiType ?? "제공받은 데이터가 없습니다.") - \(poiUsualType ?? "활용유형 데이터가 없습니다.")"
    latLabel.text = "위도: \(poiLat ?? 0.0)"
    lonLabel.text = "경도: \(poiLon ?? 0.0)"
    scaleLabel.text = "규모: \(poiScale ?? 0) \(poiUnit ?? "단위")"
    personLabel.text = "수용 인원: \(poiPerson ?? 0) 명"
    instNameLabel.text = "관리기관명: \(poiInstName ?? "관리기관 데이터가 없습니다.")"
    instTelLabel.text = "관리기관 연락처: \(poiInstTel ?? "관리기관 연락처 데이터가 없습니다.")"
  }
  
  // MARK: - Actions
  
  // 취소 버튼 클릭 시 호출되는 함수
  @objc func didTapCancelButton() {
    dismiss(animated: true)
  }
}
