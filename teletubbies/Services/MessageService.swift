//
//  MessageService.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/28/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
    
    static let instance = MessageService()
    
    var channels = [Channel]()
    var selectedChannel: Channel?
    
    var messages = [Message]()
    var unReadChannels = [String]()
    
    func findAllChannels(completion: @escaping CompletionHandler){
        Alamofire.request(URL_GET_CHANNELS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (respones) in
            if respones.result.error == nil {
                guard let data = respones.data else{return}
                if let json = JSON(data: data).array{
                    for item in json {
                        let name = item["name"].stringValue
                        let channelDescription = item["description"].stringValue
                        let id = item["_id"].stringValue
                        let channel = Channel(channelTitle: name, channelDescription: channelDescription, id: id)
                        self.channels.append(channel)
                    }
                    NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                    completion(true)
                }
            }else {
                completion(false)
                debugPrint(respones.result.error as Any)
            }
        }
    }
    
    func clearChannels(){
        channels.removeAll()
    }
    
    func findAllMessagesForChannel(channelId: String,completion: @escaping CompletionHandler){
        Alamofire.request("\(URL_GET_MESSAGES)\(channelId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (respones) in
            if respones.result.error == nil{
                self.clearMessages()
                guard let data = respones.data else{return}
                if let json = JSON(data: data).array{
                    for item in json {
                        let messageBody = item["messageBody"].stringValue
                        let channelId = item["channelId"].stringValue
                        let id = item["_id"].stringValue
                        let userName = item["userName"].stringValue
                        let userAvatar = item["userAvatar"].stringValue
                        let userAvatarColor = item["userAvatarColor"].stringValue
                        let timeStamp = item["timeStamp"].stringValue
                        let message = Message(message: messageBody, userName: userName, channelId: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                        self.messages.append(message)
                    }
                    print(self.messages)
                    completion(true)
                }
            }else{
                debugPrint(respones.result.error as Any)
                completion(false)
            }
        }
    }
    
    func clearMessages(){
        messages.removeAll()
    }
}
