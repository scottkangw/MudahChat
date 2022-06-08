//
//  ChatScreenViewModel.swift
//  MudahChatApp
//
//  Created by Scott.L on 07/06/2022.
//

import Foundation

enum connectStatus: String {
    case connected = "Your internet are restored."
    case lostConnected = "There's no internet connection."
}

class ChatScreenViewModel: ChatScreenInterface {
    
    let api = APIRequest()
    var networkStatusMessage: connectStatus = .connected
    var responseMessage = Bindable(MessageResponseModel())
    
    // Read Local Json
    func getChatHistory() -> [ChatMessageDetail]? {
        if let path = Bundle.main.path(forResource: "chat", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ChatMessageModel.self, from: data)
                return jsonData.chat
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    // API Request Completion
    func fetchMessage(message: String) {
        api.dataRequest(requestModel: MessageRequestModel(message: message)) { [weak self] data in
            guard let self = self, let result = data else { return }
            self.responseMessage.value = result
        }
    }
    
    // Decode String to Bool
    func getDirection(direction: String) -> Bool {
        switch ChatDirection(rawValue: direction) {
        case .INCOMING:
            return true
        default:
            return false
        }
    }
}
