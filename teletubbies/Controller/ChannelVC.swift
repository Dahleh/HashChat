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
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            if isSearching {
                let channel = filteredChannels[indexPath.row]
                cell.configureCell(channel: channel)
                return cell
            }else{
                let channel = MessageService.instance.channels[indexPath.row]
                cell.configureCell(channel: channel)
                return cell
            }
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredChannels.count
        }
        
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
}
