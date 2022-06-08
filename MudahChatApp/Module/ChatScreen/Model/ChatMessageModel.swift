//
//  ChatMessageModel.swift
//  MudahChatApp
//
//  Created by Scott.L on 07/06/2022.
//

import Foundation

struct ChatMessageModel: Codable {
    var chat: [ChatMessageDetail]
}
        
struct ChatMessageDetail: Codable {
    var timestamp: String?
    var direction: String?
    var message: String?
}
        
enum ChatDirection: String, CaseIterable {
    case INCOMING = "INCOMING"
    case OUTGOING = "OUTGOING"
}   
