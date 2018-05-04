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
    @IBOutlet var segmentControl: UISegmentedControl!
    
    var filteredChannels = [Channel]()
    public var favChannelsRemove = [Channel]()
    var isSearching = false
    var channelType = ChannelType.all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MessageService.instance.favChannels = loadFav()
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
            cell.link = self
            filteredChannels.sort(by: { $0.channelTitle < $1.channelTitle })
            MessageService.instance.channels.sort(by: { $0.channelTitle < $1.channelTitle })
            if channelType == .all{
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
                                    let channel = MessageService.instance.favChannels[indexPath.row]
                if channel.isFav{
                    cell.configureCell(channel: channel)
                }
                
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
        if channelType == .fav {
            return MessageService.instance.favChannels.count
        }
        
        return MessageService.instance.channels.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channelType == .all {
            selectRow(channelArray: MessageService.instance.channels, indexPath: indexPath)
        }else{
            selectRow(channelArray: MessageService.instance.favChannels, indexPath: indexPath)
        }
        let index = IndexPath(row: indexPath.row, section: 0)
        tableView.reloadRows(at: [index], with: .none)
        tableView.selectRow(at: index, animated: false, scrollPosition: .none)
        NotificationCenter.default.post(name: NOTIF_CHANNELS_SELECTED, object: nil)
        self.revealViewController().revealToggle(animated: true)

    }
    
    func selectRow(channelArray: [Channel], indexPath: IndexPath){
        if searchBar.text == nil || searchBar.text == ""{
            let channel = channelArray[indexPath.row]
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
    }
    
    func addToFav(cell: UITableViewCell){
        print("insideController")
        guard let indexPathTapped = tableView.indexPath(for: cell) else { return }
        if channelType == .all {
            if isSearching{
                if filteredChannels[indexPathTapped.row].isFav == false{
                    filteredChannels[indexPathTapped.row].isFav = true
                    MessageService.instance.favChannels.append(filteredChannels[indexPathTapped.row])
                    saveFav()
                    print("Added")
                }else{
                    filteredChannels[indexPathTapped.row].isFav = false
                    print(MessageService.instance.favChannels.count)

                    MessageService.instance.favChannels.remove(at: indexPathTapped.row)
                    saveFav()
                    print("Removed")
                }
                
            }else{
                if MessageService.instance.channels[indexPathTapped.row].isFav == false{
                    MessageService.instance.channels[indexPathTapped.row].isFav = true
                    MessageService.instance.favChannels.append(MessageService.instance.channels[indexPathTapped.row])
                    print("Added")
                    saveFav()
                }else{
                    MessageService.instance.channels[indexPathTapped.row].isFav = false
                    print(MessageService.instance.channels[indexPathTapped.row].isFav)
                    MessageService.instance.favChannels.remove(at: indexPathTapped.row)
                    print("Removed")
                    saveFav()
                }
                
            }

            
        }else{
                print(MessageService.instance.favChannels[indexPathTapped.row])
                MessageService.instance.favChannels[indexPathTapped.row].isFav = false
            print(MessageService.instance.channels[indexPathTapped.row].isFav)
                MessageService.instance.favChannels.remove(at: indexPathTapped.row)
                saveFav()
                print("removed")

        }
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
    public func saveFav(){
        let favData = try! JSONEncoder().encode(MessageService.instance.favChannels)
        UserDefaults.standard.set(favData, forKey: "favChannels")
        UserDefaults.standard.synchronize()
    }

    public func loadFav() -> [Channel]{
        if let favData = UserDefaults.standard.data(forKey: "favChannels"){
            let favChannelsArray = try! JSONDecoder().decode([Channel].self, from: favData)
            return favChannelsArray
        }else{
            return [Channel]()
        }
        
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0 {
            channelType = .all
        }else{
            channelType = .fav
        }
        tableView.reloadData()
    }
    
}
