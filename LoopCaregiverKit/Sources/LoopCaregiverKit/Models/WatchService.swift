//
//  WatchService.swift
//
//
//  Created by Bill Gestrich on 2/9/24.
//

import Foundation
import WatchConnectivity

public final class WatchService: NSObject, ObservableObject, WatchConnectivityServiceDelegate {
    
    @Published public var lastMessageSent: Date? = nil
    @Published public var activated: Bool = false
    @Published public var receivedWatchConfiguration: WatchConfiguration? = nil
    private let accountService: AccountService
    private let connectivityService: WatchConnectivityService
     
    public init(accountService: AccountService) {
        self.accountService = accountService
        self.connectivityService = WatchConnectivityService()
        super.init()
        self.connectivityService.delegate = self
    }
    
    #if os(iOS)
    public func sendLoopersToWatch() throws {
        let loopers = try accountService.getLoopers()
        let watchConfiguration = WatchConfiguration(loopers: loopers)
        let data = try JSONEncoder().encode(watchConfiguration)
        let dataString = String(data: data, encoding: .utf8)!
        connectivityService.send(dataString)
    }
    #endif
    
    public func isReachable() -> Bool {
        return connectivityService.isReachable()
    }
    
    public func sessionsSupported() -> Bool {
        return connectivityService.sessionsSupported()
    }
    
    public func isCounterpartAppInstalled() -> Bool {
        return connectivityService.isCounterpartAppInstalled()
    }
    
    
    // WatchConnectivityServiceDelegate
    
    public func didReceiveMessage(_ notificationMessage: NotificationMessage) {
        
        guard let data = notificationMessage.text.data(using: .utf8) else {
            return
        }
        
        if let watchConfiguration = try? JSONDecoder().decode(WatchConfiguration.self, from: data) {
            receivedWatchConfiguration = watchConfiguration
        }
    }
    
    public func activatedStateChanged(_ activated: Bool) {
        self.activated = activated
    }
    
    public func lastMessageSentDateChanged(_ lastMessageSentDate: Date) {
        self.lastMessageSent = lastMessageSentDate
    }
    
}
