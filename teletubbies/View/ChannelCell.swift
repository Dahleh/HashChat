//
//  ChannelCell.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/28/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import UIKit

enum ChannelType{
    case all
    case fav
}

class ChannelCell: UITableViewCell {

    
    var link: ChannelVC?
    
    @IBOutlet var favBtn: UIButton!
    @IBOutlet var channelName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.layer.backgroundColor = UIColor(white: 1, alpha: 0.2).cgColor
        }else{
            self.layer.backgroundColor = UIColor.clear.cgColor
        }
    }
    
    func configureCell(channel: Channel){
        let title = channel.channelTitle ?? ""
        channelName.text = "#\(title)"
        channelName.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        for id in MessageService.instance.unReadChannels {
            if id == channel.id {
                channelName.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            }
        }
    }
    
    @IBAction func favBtn(_ sender: Any) {
        print("Marking as favorite")
        link?.addToFav(cell: self)
    }
    
}
