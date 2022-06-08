//
//  Network.swift
//  MudahChat
//
//  Created by Scott.L on 07/06/2022.
//

import Foundation
import Network
import UIKit

enum NetworkStatus: String {
    case NoInternet = "No Internet"
    case Connected = "Connected"
}

final class DeviceInternetMonitor {
    
    static let shared = DeviceInternetMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    var isSuccessful: (() -> ())?
    
    public private(set) var connectionType: ConnectionType?
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    // Monitoring Network of App
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.getConnectionType(path: path)
            self?.isSuccessful?()
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    // Detect connected Type
    private func getConnectionType(path: NWPath) {
        if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
