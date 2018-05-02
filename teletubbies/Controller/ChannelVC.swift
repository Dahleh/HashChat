//
//  ChannelVC.swift
//  teletubbies
//
//  Created by Faris Dahleh on 4/23/18.
//  Copyright © 2018 Faris Dahleh. All rights reserved.
//

import UIKit

class ChannelVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var loginBtn: UIButton!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}
    @IBOutlet var userImg: RoundedImage!
    @IBOutlet var searchBar: UISearchBar!
    
    var filteredChannels = [Channel]()
    //public var favChannels = [Channel]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MessageService.instance.favChannels = loadFav()
        //print(favChannels,"after restart")
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.userDataDidChanged(_:)), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.channelsLoaded(_:)), name: NOTIF_CHANNELS_LOADED, object: nil)
        SocketService.instance.getChannel { (success) in
            if success{
                self.tableView.reloadData()
            }
        }
        SocketService.instance.getMessage { (newMessage) in
            if newMessage.channelId != MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn {
                MessageService.instance.unReadChannels.append(newMessage.channelId)
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        setupUserInfo()
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn {
            let profile = ProfileVC()
            profile.modalPresentationStyle = .custom
            present(profile, animated: true, completion: nil)
        }else{
            performSegue(withIdentifier: TO_LOGIN, sender: nil)
        }
    }
    
    @objc func userDataDidChanged(_ notif: Notification){
        setupUserInfo()
    }
    @objc func channelsLoaded(_ notif: Notification){
        tableView.reloadData()
    }
    
    func setupUserInfo(){
        if AuthService.instance.isLoggedIn {
            loginBtn.setTitle(UserDataService.instance.name, for: .normal)
            userImg.image = UIImage(named: UserDataService.instance.avatarName)
            userImg.backgroundColor = UserDataService.instance.returnUIColor(components: UserDataService.instance.avatarColor)
        }else {
            loginBtn.setTitle("Login", for: .normal)
            userImg.image = UIImage(named: "menuProfileIcon")
            userImg.backgroundColor = UIColor.clear
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell {
            filteredChannels.sort(by: { $0.channelTitle < $1.channelTitle })
            MessageService.instance.channels.sort(by: { $0.channelTitle < $1.channelTitle })
            if isSearching {
                let channel = filteredChannels[indexPath.row]
                cell.configureCell(channel: channel)
                return cell
            }else{
                let channel = MessageService.instance.channels[indexPath.row]
                cell.configureCell(channel: channel)
                return cell
//                if MessageService.instance.favChannels.count > 0{
//                    print(MessageService.instance.favChannels)
//                    let channel = MessageService.instance.favChannels[indexPath.row]
//                    print(channel)
//                    cell.configureCell(channel: channel)
//                    return cell
//                }else{
//                    let channel = MessageService.instance.channels[indexPath.row]
//                    cell.configureCell(channel: channel)
//                    return cell
//                }
            }
            
        }else{
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredChannels.count
        }
//        if MessageService.instance.favChannels.count > 0 {
//            return MessageService.instance.favChannels.count
//        }
        
        return MessageService.instance.channels.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.text == nil || searchBar.text == ""{
                let channel = MessageService.instance.channels[indexPath.row]
                MessageService.instance.selectedChannel = channel
                if MessageService.instance.unReadChannels.count > 0{
                    MessageService.instance.unReadChannels = MessageService.instance.unReadChannels.filter{$0 != channel.id}
                }
        }else{
            let channel = filteredChannels[indexPath.row]
            MessageService.instance.selectedChannel = channel
            if MessageService.instance.unReadChannels.count > 0{
                MessageService.instance.unReadChannels = MessageService.instance.unReadChannels.filter{$0 != channel.id}
            }
        }
        let index = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [index], with: .none)
        tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        NotificationCenter.default.post(name: NOTIF_CHANNELS_SELECTED, object: nil)
        self.revealViewController().revealToggle(animated: true)
        //MessageService.instance.favChannels.append(MessageService.instance.selectedChannel!)
        //print("Added")
        //print(MessageService.instance.favChannels)
        //saveFav()
        tableView.reloadData()
    }
    
    @IBAction func addChannelPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn{
            let addChannel = AddChannelVC()
            addChannel.modalPresentationStyle = .custom
            present(addChannel, animated: true, completion: nil)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredChannels = MessageService.instance.channels.filter{$0.channelTitle == searchBar.text?.lowercased()}
            tableView.reloadData()
        }
    }
//    func saveFav() {
//        let favData = NSKeyedArchiver.archivedData(withRootObject: favChannels)
//        UserDefaults.standard.set(favData, forKey: "favChannels")
//    }
//    func loadFav() {
//        guard let favData = UserDefaults.standard.object(forKey: "favChannels") as? NSData else {
//            print("'fav' not found in UserDefaults")
//            return
//        }
//
//        guard let favChannelsArray = NSKeyedUnarchiver.unarchiveObject(with: favData as Data) as? [Channel] else {
//            print("Could not unarchive from placesData")
//            return
//        }
//
//        favChannels = favChannelsArray
//
//    }
//    public func saveFav(){
//        let favData = try! JSONEncoder().encode(MessageService.instance.favChannels)
//        UserDefaults.standard.set(favData, forKey: "favChannels")
//        UserDefaults.standard.synchronize()
//    }
//
//    public func loadFav() -> [Channel]{
//        let favData = UserDefaults.standard.data(forKey: "favChannels")
//        let favChannelsArray = try! JSONDecoder().decode([Channel].self, from: favData!)
//        return favChannelsArray
//    }
}
