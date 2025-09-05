//
//  SignUpTableViewCell.swift
//  Duriso
//
//  Created by t2023-m0102 on 9/24/24.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class SignUpTableViewCell: UITableViewCell {
  
  private let checkboxButton = UIButton().then {
    $0.setImage(UIImage(systemName: "square"), for: .normal)
    $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
    $0.tintColor = .CBlue
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private let titleLabel = UILabel().then {
    $0.font = CustomFont.Head5.font()
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  private let disposeBag = DisposeBag()
  var isChecked: BehaviorRelay<Bool> = BehaviorRelay(value: false)
  var onCheckboxStateChange: ((Bool) -> Void)?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    setupUI()
    bindCheckbox()
    
    backgroundColor = .CWhite
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setupUI()
    bindCheckbox()
    
    backgroundColor = .CWhite
  }
  
  private func setupUI() {
    [
      checkboxButton,
      titleLabel
    ].forEach { contentView.addSubview($0) }
    
    checkboxButton.snp.makeConstraints {
      $0.centerY.equalTo(contentView.safeAreaLayoutGuide).offset(2)
      $0.leading.equalTo(contentView.safeAreaLayoutGuide).offset(16)
      $0.width.height.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(contentView.safeAreaLayoutGuide)
      $0.leading.equalTo(checkboxButton.snp.trailing).offset(8)
    }
  }
  
  private func bindCheckbox() {
    isChecked
      .bind(to: checkboxButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    checkboxButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.isChecked.accept(!self.isChecked.value)
        self.onCheckboxStateChange?(self.isChecked.value)
      })
      .disposed(by: disposeBag)
  }
  
  func configure(with item: String) {
    titleLabel.text = "(필수) " + item
    accessoryType = .disclosureIndicator
  }
}
