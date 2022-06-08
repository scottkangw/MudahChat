//
//  ViewController.swift
//  MudahChatApp
//
//  Created by Scott.L on 07/06/2022.
//

import UIKit

class ChatScreenViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var textField: UITextField!
    
    private let viewModel = ChatScreenViewModel()
    var chatMessage: [ChatMessageDetail]?
    
    fileprivate let cellId = "ChatMessageCell"
    fileprivate let localization = {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIView()
        guard let getChatMessage = viewModel.getChatHistory() else { return }
        chatMessage = getChatMessage
        bindResponse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DeviceInternetMonitor.shared.isSuccessful = { [weak self] in
            guard let self = self else { return }
            self.lostNetworkAction()
        }
        tableView.reloadData()
        guard let count = chatMessage?.count else { return }
        let index = IndexPath(item: count-1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        guard let count = chatMessage?.count else { return }
        let index = IndexPath(item: count-1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: animated)
    }
}

//MARK: -
//MARK: SetupUI

fileprivate extension ChatScreenViewController {
    func setupUIView() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "NavigationBarColor")
        
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "Message"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        textField.delegate = self
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        tableView.keyboardDismissMode = .onDrag
    }
}

//MARK: -
//MARK: Binding

fileprivate extension ChatScreenViewController {
    func bindResponse() {
        viewModel.responseMessage.bindAndFire { [weak self] data in
            guard let self = self else { return }
            if let message = data.message,
               let createAt = data.createdAt,
               let id = data.id {
                DispatchQueue.main.async {
                    let lostConnectionAlert = UIAlertController(title: "ID: \(id)", message: "Message: \(message)\n CreateAt: \(createAt)", preferredStyle: .alert)
                    lostConnectionAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { cancel in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(lostConnectionAlert, animated: true, completion: nil)
                }
            }
        }
    }
}

//MARK: -
//MARK: Network Monitor

fileprivate extension ChatScreenViewController {
    
    func lostNetworkAction() {
        // Main Thread Present Alert
        DispatchQueue.main.async {
            if DeviceInternetMonitor.shared.isConnected {
                self.viewModel.networkStatusMessage = .lostConnected
                let lostConnectionAlert = UIAlertController(title: "Network", message: self.viewModel.networkStatusMessage.rawValue, preferredStyle: .alert)
                lostConnectionAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { cancel in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(lostConnectionAlert, animated: true, completion: nil)
            } else {
                self.viewModel.networkStatusMessage = .connected
                let lostConnectionAlert = UIAlertController(title: "Network", message: self.viewModel.networkStatusMessage.rawValue, preferredStyle: .alert)
                lostConnectionAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { cancel in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(lostConnectionAlert, animated: true, completion: nil)
            }
        }
    }
}

//MARK: -
//MARK: TableView Delegate & DataSource

extension ChatScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = chatMessage?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        guard let chatDetail = chatMessage?[indexPath.row] else { return UITableViewCell() }
        
        cell.messageLabel.text = chatDetail.message
        if let direction = chatDetail.direction {
            cell.isIncoming = viewModel.getDirection(direction: direction)
        }
        return cell
    }
}

//MARK: -
//MARK: TextField Delegate & Auto Reply

extension ChatScreenViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.viewModel.fetchMessage(message: textField.text!)
        self.textField.text = ""
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Detect User Typing
        if range.location == 0 {
            var timer: Timer? = nil
            timer?.invalidate()
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(getHints),
                userInfo: ["textField": textField],
                repeats: false)
        }
        return true
    }
    
    @objc func getHints(timer: Timer) {
        guard let message = textField.text else { return }
        if !message.isEmpty {
            let currentDate = Date()
            // Message Added
            chatMessage?.append(ChatMessageDetail(timestamp: currentDate.formatCurrentDate(), direction: "INCOMING", message: "Are you there?"))
            tableView.reloadData()
            // Scroll To Bottom
            guard let count = chatMessage?.count else { return }
            let index = IndexPath(item: count-1, section: 0)
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }
}
