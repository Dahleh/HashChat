//
//  RoundedImage.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/28/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImage: UIImageView {

    override func awakeFromNib() {
        self.setupView()
    }
    
    func setupView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
}
