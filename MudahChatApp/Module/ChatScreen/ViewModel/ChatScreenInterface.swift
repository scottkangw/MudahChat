//
//  NetworkViewModel.swift
//  MudahChatApp
//
//  Created by Scott.L on 07/06/2022.
//

import Foundation

protocol ChatScreenInterface {
    
    var networkStatusMessage: connectStatus { get }
    func getChatHistory() -> [ChatMessageDetail]?;
    func getDirection(direction: String) -> Bool;
    
}
