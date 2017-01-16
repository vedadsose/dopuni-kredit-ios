//
//  SettingsTableViewController.swift
//  Dopuni Kredit
//
//  Created by Vedad Sose on 24/12/2016.
//  Copyright © 2016 Vedad Sose. All rights reserved.
//

import UIKit
import KeychainSwift

class SettingsTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate  {

  @IBOutlet weak var phoneNumber: UITextField!
  @IBOutlet weak var phoneOperator: UIPickerView!
  @IBOutlet weak var fullName: UITextField!
  @IBOutlet weak var cardNumber: UITextField!
  @IBOutlet weak var expirationDate: MonthYearPickerView!
  @IBOutlet weak var cvc: UITextField!
  
  let keychain = KeychainSwift()
  let tags = ["phoneNumber", "fullName", "cardNumber", "cvc"]
  let operators = ["bhtelecom", "eronet", "mtel", "haloo", "happy"]
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set delegates
    phoneNumber.delegate = self
    phoneOperator.delegate = self
    fullName.delegate = self
    cardNumber.delegate = self
    cvc.delegate = self
    
    // Load data
    phoneNumber.text = keychain.get("phoneNumber") ?? ""
    fullName.text = keychain.get("fullName") ?? ""
    cardNumber.text = keychain.get("cardNumber") ?? ""
    cvc.text = keychain.get("cvc") ?? ""
    phoneOperator.selectRow(operators.index(where: { $0 == (keychain.get("phoneOperator") ?? "bhtelecom") }) ?? 0, inComponent: 0, animated: false)

    if let year = keychain.get("expirationYear"), let month = keychain.get("expirationMonth") {
      expirationDate.year = Int(year)!
      expirationDate.month = Int(month)!
    }
    
    expirationDate.onDateSelected = { (month: Int, year: Int) in
      self.keychain.set("\(month)", forKey: "expirationMonth")
      self.keychain.set("\(year)", forKey: "expirationYear")
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let key = tags[textField.tag]
    let val = textField.text ?? ""
    if (val != "") {
      keychain.set(val, forKey: key)
    } else {
      keychain.delete(key)
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return operators.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return operators[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    keychain.set(operators[row], forKey: "phoneOperator")
  }
}
