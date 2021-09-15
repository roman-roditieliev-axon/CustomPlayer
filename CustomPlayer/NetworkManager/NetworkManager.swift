//
//  NetworkManager.swift
//  CustomPlayer
//
//  Created by User on 15.09.2021.
//

import Foundation
import Reachability

protocol NetworkDelegate: AnyObject {
    func onNetworkOffline()
    func onNetworkOnline()
}

class NetworkManager: NSObject {

    var reachability: Reachability!

    static let sharedInstance: NetworkManager = { NetworkManager() }()

    let networkMulticast = MulticastDelegate<NetworkDelegate>()

    override init() {
        super.init()

        reachability = try? Reachability()

        NotificationCenter.default.addObserver(self, selector: #selector(networkStatusChanged(_:)), name: .reachabilityChanged, object: reachability)

        try? reachability.startNotifier()
    }

    @objc func networkStatusChanged(_ notification: Notification) {
        guard let notification = notification.object as? Reachability else { return }

        if notification.connection == .unavailable {
            networkMulticast.invokeDelegates { delegate in
                delegate.onNetworkOffline()
            }
        }

        if notification.connection == .cellular || notification.connection == .wifi {
            networkMulticast.invokeDelegates { delegate in
                delegate.onNetworkOnline()
            }
        }
    }

    static func stopNotifier() {
        do {
            try NetworkManager.sharedInstance.reachability.startNotifier()
        } catch { }
    }

    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if NetworkManager.sharedInstance.reachability.connection != .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }

    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if NetworkManager.sharedInstance.reachability.connection == .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }

    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if NetworkManager.sharedInstance.reachability.connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }

    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if NetworkManager.sharedInstance.reachability.connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}
