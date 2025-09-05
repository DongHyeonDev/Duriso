//
//  OfflineViewController.swift
//  Duriso
//
//  Created by 김동현 on 9/10/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class OfflineViewController: UIViewController {
  private let offlineMapViewController = OfflineMapViewController()
  private let disposeBag = DisposeBag()
  
  let buttonStackView = UIStackView().then {
    $0.alignment = .center
    $0.distribution = .fillEqually
    $0.axis = .horizontal
    $0.spacing = 8
  }
  
  lazy var shelterButton: UIButton = createButton(
    title: "대피소",
    symbolName: "figure.run",
    baseColor: .CLightBlue,
    selectedColor: .CGreen
  )
  
  lazy var aedButton: UIButton = createButton(
    title: "제세동기",
    symbolName: "bolt.heart.fill",
    baseColor: .CLightBlue,
    selectedColor: .CRed
  )
  
  lazy var civilDefenseButton: UIButton = createButton(
    title: "민방위대피소",
    symbolName: "figure.run",
    baseColor: .CLightBlue,
    selectedColor: .CYellow
  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    setupConstraints()
    bindButtonsToViewModel()
  }
  
  private func setupViews() {
    [
      offlineMapViewController
    ].forEach { self.addChild($0) }
    
    [
      offlineMapViewController.view
    ].forEach { self.view.addSubview($0) }
    
//    addChild(offlineMapViewController)
//    view.addSubview(offlineMapViewController.view)
    offlineMapViewController.didMove(toParent: self)
    
    [
      buttonStackView
    ].forEach { view.addSubview($0) }
    
    [
      shelterButton,
      aedButton,
      civilDefenseButton
    ].forEach { buttonStackView.addArrangedSubview($0) }
  }
  
  private func setupConstraints() {
    buttonStackView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
    }
    
    [
      shelterButton,
      aedButton,
      civilDefenseButton
    ].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(34)
      }
    }
  }
  
  private func bindButtonsToViewModel() {
    // AED 버튼
    aedButton.rx.tap
      .map { [unowned self] in !self.aedButton.isSelected }
      .do(onNext: { [unowned self] isSelected in
        self.aedButton.isSelected = isSelected
        self.aedButton.backgroundColor = isSelected ? .CRed : .CLightBlue
      })
      .bind(to: offlineMapViewController.viewModel.aedVisible)
      .disposed(by: disposeBag)
    
    // Civil Defense 버튼
    civilDefenseButton.rx.tap
      .map { [unowned self] in !self.civilDefenseButton.isSelected }
      .do(onNext: { [unowned self] isSelected in
        self.civilDefenseButton.isSelected = isSelected
        self.civilDefenseButton.backgroundColor = isSelected ? .CYellow : .CLightBlue
      })
      .bind(to: offlineMapViewController.viewModel.civilDefenseVisible)
      .disposed(by: disposeBag)
    
    // Shelter 버튼
    shelterButton.rx.tap
      .map { [unowned self] in !self.shelterButton.isSelected }
      .do(onNext: { [unowned self] isSelected in
        self.shelterButton.isSelected = isSelected
        self.shelterButton.backgroundColor = isSelected ? .CGreen : .CLightBlue
      })
      .bind(to: offlineMapViewController.viewModel.disasterVisible)
      .disposed(by: disposeBag)
  }
  
  func createButton(title: String, symbolName: String, baseColor: UIColor, selectedColor: UIColor)
  -> UIButton {
    
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: symbolName), for: .normal)
    button.tintColor = .CWhite
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = CustomFont.Body4.font()
    button.setTitleColor(.CWhite, for: .normal)
    button.backgroundColor = selectedColor
    
    button.isSelected = false
    button.layer.cornerRadius = 17
    
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 4)
    button.layer.shadowRadius = 4
    button.layer.shadowOpacity = 0.2
    button.layer.masksToBounds = false
    
    button.isSelected = false
    return button
  }
}

//@available(iOS 17.0, *)
//#Preview {
//  OfflineViewController()
//}
