//
//  ViewController.swift
//  Dopuni Kredit
//
//  Created by Vedad Sose on 23/12/2016.
//  Copyright © 2016 Vedad Sose. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire

class ViewController: UIViewController {

  @IBOutlet weak var buttonsView: UIView!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var settingsLabel: UILabel!
  
  let keychain = KeychainSwift()

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        
    // Determine what to show
    var setUp = false
    if let _ = keychain.get("phoneNumber") {
      // Amount buttons
      self.renderButtons([2, 5, 10])
      setUp = true
    }
    
    self.settingsLabel.isHidden = setUp
    self.buttonsView.isHidden = !setUp
    self.amountLabel.isHidden = !setUp
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Settings button
    let settingsButton = UIBarButtonItem(image: UIImage(named: "settings"),
                                         style: UIBarButtonItemStyle.plain ,
                                         target: self, action: #selector(self.openSettings))
    self.navigationItem.rightBarButtonItem = settingsButton
  }
  
  func openSettings() {
    self.performSegue(withIdentifier: "openSettings", sender: self)
  }
  
  func renderButtons(_ amounts: [Int]) {
    let parentSize: CGRect = buttonsView.bounds
    let buttonHeight = 60
    let buttonSpacing = 20
    
    for (index, amt) in amounts.enumerated() {
      let button = UIButton(
        frame: CGRect(
          x: 0,
          y: index * (buttonHeight+buttonSpacing),
          width: Int(parentSize.width - 10.0),
          height: buttonHeight
        )
      )
      button.backgroundColor = UIColor.init(red: 0.17, green: 0.24, blue: 0.31, alpha: 1.0)
      button.setTitle("\(amt) KM", for: UIControlState.normal)
      button.addTarget(self, action: #selector(self.amountSelected), for: .touchUpInside)
      self.buttonsView.addSubview(button)
    }
  }
  
  func amountSelected(button: UIButton) {
    guard let titleLabel = button.titleLabel else {
      return
    }
    
    guard let title = titleLabel.text else {
      return
    }
    
    let amount = title.components(separatedBy: " ")[0]
    let payAlert = UIAlertController(title: "Sigurno?", message: "Novac će nestati sa kartice a pojaviti se u kreditu", preferredStyle: UIAlertControllerStyle.alert)
    
    payAlert.addAction(UIAlertAction(title: "Može", style: .default, handler: { (action: UIAlertAction!) in
      let parameters: Parameters = [
        "phoneNumber": self.keychain.get("phoneNumber") ?? "",
        "phoneOperator": self.keychain.get("phoneOperator") ?? "",
        "fullName": self.keychain.get("fullName") ?? "",
        "cardNumber": self.keychain.get("cardNumber") ?? "",
        "expirationMonth": self.keychain.get("expirationMonth") ?? "",
        "expirationYear": self.keychain.get("expirationYear") ?? "",
        "cvc": self.keychain.get("cvc") ?? "",
        "amount": amount
      ]
      
      Alamofire
        .request("https://napunikredit.info/pay", method: .post, parameters: parameters)
        .response { response in
            print(response)
        }
    }))
    
    payAlert.addAction(UIAlertAction(title: "Ipak ne", style: .cancel, handler: nil))
    
    present(payAlert, animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

