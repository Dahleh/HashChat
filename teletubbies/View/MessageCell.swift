//
//  MessageCell.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/29/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    //Outlets
    @IBOutlet var userImg: RoundedImage!
    @IBOutlet var userLbl: UILabel!
    @IBOutlet var timeStampLbl: UILabel!
    @IBOutlet var messageBodyLbl: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(message: Message){
        messageBodyLbl.text = message.message
        userLbl.text = message.userName
        userImg.image = UIImage(named: message.userAvatar)
        userImg.backgroundColor = UserDataService.instance.returnUIColor(components: message.userAvatarColor)
        guard var isoDate = message.timeStamp else {return}
        let end = isoDate.index(isoDate.endIndex, offsetBy: -5)
        isoDate = isoDate.substring(to: end)
        
        let isoFormatter = ISO8601DateFormatter()
        let chatDate = isoFormatter.date(from: isoDate.appending("Z"))
        
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "MMM d, h:mm a"
        if let finalDate = chatDate{
            let finalDate = newFormatter.string(from: finalDate)
            timeStampLbl.text = finalDate
        }
    }
}
