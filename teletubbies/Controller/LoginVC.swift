//
//  LoginVC.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/24/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    //Outlets
    @IBOutlet var userNameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    let placeHolderColor = #colorLiteral(red: 0.2588235294, green: 0.3294117647, blue: 0.7254901961, alpha: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_CREATE, sender: nil)
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        spinner.isHidden = false
        spinner.startAnimating()
        guard let email = userNameTxt.text , userNameTxt.text != "" else {return}
        guard let password = passwordTxt.text , passwordTxt.text != "" else {return}
        AuthService.instance.lognUser(email: email, password: password) { (success) in
            if success{
                AuthService.instance.findUserByEmail(completion: { (success) in
                    if success{
                        NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                        self.spinner.isHidden = true
                        self.spinner.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func setupView(){
        spinner.isHidden = true
        userNameTxt.attributedPlaceholder = NSAttributedString(string: "UserName", attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
    }
}
