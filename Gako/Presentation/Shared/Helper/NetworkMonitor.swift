//
//  NetworkMonitor.swift
//  Gako
//
//  Created by Kevin Fairuz on 06/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Network connectivity monitoring class using Network framework
//  Usage: Use this class to monitor and observe network connection status changes
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    private let monitor = NWPathMonitor()
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
