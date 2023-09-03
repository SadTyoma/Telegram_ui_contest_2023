//
//  ViewController.swift
//  telegram_ui_contest_2023
//
//  Created by Artem Shuneyko on 26.08.23.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    private let archiveChatInfo = ChatInfo(name: "archive", image: UIImage(systemName: "person.circle")!, messages: ["message 1", "message 2", "message 3", "message 4"])
    private var chatArray = [ChatInfo(name: "User 1", image: UIImage(systemName: "person.circle")!, messages: ["message 1","message 2", "message 3", "message 4"]), ChatInfo(name: "User 2", image: UIImage(systemName: "person.circle.fill")!, messages: ["message 1","message 2", "message 3", "message 4"])]
    
    private var tableView: UITableView!
    private var archiveCreationP1View: ArchiveCreationP1View!
    private var archiveCreationP2View: ArchiveCreationP2View!
    private var canAddCell = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let barHeight: CGFloat = 60
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height

        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)

        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = .white
        backgroundView.layer.zPosition = -1
        tableView.addSubview(backgroundView)

        archiveCreationP1View = ArchiveCreationP1View()
        archiveCreationP1View.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 0)
        archiveCreationP1View.layer.zPosition = -2
        tableView.addSubview(archiveCreationP1View)

        archiveCreationP2View = ArchiveCreationP2View(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 150))
        archiveCreationP2View.layer.zPosition = 100
        tableView.addSubview(archiveCreationP2View)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedItem = chatArray[indexPath.row]
        
        let addToFolderAction = UIAction(title: "Add To Folder", image: UIImage(systemName: "folder.badge.plus")) { action in
            // Implement functionality here
        }
        
        let markAsUnreadAction = UIAction(title: "Mark As Unread", image: UIImage(systemName: "message.badge.filled.fill")) { action in
            // Implement functionality here
        }
        
        let pinAction = UIAction(title: "Pin", image: UIImage(systemName: "pin")) { action in
            // Implement functionality here
        }
        
        let muteAction = UIAction(title: "Mute", image: UIImage(systemName: "bell.slash.fill")) { action in
            // Implement functionality here
        }
        
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { action in
            // Implement functionality here
        }

        let actions = [addToFolderAction, markAsUnreadAction, pinAction, muteAction, deleteAction]

        let actionProvider: UIContextMenuActionProvider = { _ in
            return UIMenu(title: "", children: actions)
        }

        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            return CustomPreviewViewController(chatInfo: selectedItem, viewWidth: self.view.frame.width - 60)
        }, actionProvider: actionProvider)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let currentLastItem = chatArray[indexPath.row]
        cell.configure(with: currentLastItem)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let minOffsetY = -150.0
        let threshold: CGFloat = 140
        if contentOffsetY < minOffsetY {
            scrollView.contentOffset.y = minOffsetY
        }

        changeViewHeight(contentOffsetY)

        if contentOffsetY < -threshold {
            canAddCell = true
        } else{
            canAddCell = false
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if canAddCell{
            appendCell()
        }
    }

    private func changeViewHeight(_ offset: CGFloat){
        let width = self.view.bounds.size.width
        if(offset < 0){
            self.archiveCreationP1View.frame = CGRect(x: 0, y: 0, width: width, height: offset)
        }else{
            self.archiveCreationP1View.frame = CGRect(x: 0, y: 0, width: width, height: 0)
        }
        archiveCreationP1View.changes.onNext(offset)
    }

    private func appendCell() {
        guard chatArray.contains(where: { chatInfo in
            return chatInfo.name == archiveChatInfo.name &&
            chatInfo.image == archiveChatInfo.image &&
            chatInfo.messages == archiveChatInfo.messages
        }) == false else { return }
        let oldContentHeight: CGFloat = tableView.contentSize.height
        let oldOffsetY: CGFloat = tableView.contentOffset.y
        chatArray.insert(archiveChatInfo, at: 0)

        archiveCreationP2View.startAnimation()
        archiveCreationP1View.removeFromSuperview()

        tableView.reloadData()
        let newContentHeight: CGFloat = tableView.contentSize.height
        tableView.contentOffset.y = oldOffsetY + (newContentHeight - oldContentHeight)
    }
}

struct ChatInfo {
    var name : String
    var image : UIImage
    var messages : [String]
}

class CustomPreviewViewController: UIViewController {
    private let chatView: ChatPreviewView

    override func loadView() {
        view = chatView
    }

    init(chatInfo: ChatInfo, viewWidth: CGFloat) {
        chatView = ChatPreviewView()
        super.init(nibName: nil, bundle: nil)
        preferredContentSize = CGSize(width: viewWidth, height: 500)
        chatView.frame.size = CGSize(width: viewWidth, height: 500)
        chatView.setupUI(chatInfo: chatInfo)
        chatView.loadMessages(chatInfo.messages)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChatPreviewView: UIView {
    private let headerHeight: CGFloat = 60.0
    private let messageViewHeight: CGFloat = 60.0
    private let labelAlignment: NSTextAlignment = .center
    private var chatTableView: UITableView!

    var messages: [String] = []
    
    func setupUI(chatInfo: ChatInfo) {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: headerHeight))
        headerView.backgroundColor = .lightGray.withAlphaComponent(0.1)

        let label1 = UILabel(frame: CGRect(x: 0, y: 10, width: self.frame.width, height: 20))
        label1.textAlignment = labelAlignment
        label1.text = chatInfo.name

        let label2 = UILabel(frame: CGRect(x: 0, y: 35, width: self.frame.width, height: 20))
        label2.textAlignment = labelAlignment
        label2.text = "Last seen just now"
        label2.font = UIFont.systemFont(ofSize: 10)

        headerView.addSubview(label1)
        headerView.addSubview(label2)
        
        chatTableView = UITableView(frame: CGRect(x: 0, y: headerHeight, width: self.frame.width - 40, height: self.frame.height - headerHeight))
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        chatTableView.separatorStyle = .none
        
        
        addSubview(headerView)
        addSubview(chatTableView)
    }
    
    func loadMessages(_ messages: [String]) {
        self.messages = messages
        chatTableView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension ChatPreviewView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            cell.textLabel?.textAlignment = .left
        } else {
            cell.textLabel?.textAlignment = .right
        }
        
        return cell
    }
}
