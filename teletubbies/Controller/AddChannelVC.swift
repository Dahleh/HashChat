//
//  AddChannelVC.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/28/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import UIKit


class AddChannelVC: UIViewController {
    
    //Outlets
    
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var descriptionTxt: UITextField!
    @IBOutlet var bgView: UIView!
    
    let placeHolderColor = #colorLiteral(red: 0.2588235294, green: 0.3294117647, blue: 0.7254901961, alpha: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createPressed(_ sender: Any) {
        guard let channelName = nameTxt.text , nameTxt.text != "" else {return}
        guard let channelDesc = descriptionTxt.text , descriptionTxt.text != "" else {return}
        SocketService.instance.addChannel(channelName: channelName, channelDescription: channelDesc) { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupView(){
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddChannelVC.closeTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
        nameTxt.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        descriptionTxt.attributedPlaceholder = NSAttributedString(string: "Description", attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
    }
    
    @objc func closeTap(_ recognaizer: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
}
