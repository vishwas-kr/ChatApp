//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import SwiftUI

@main
struct ChatApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appDelegate = AppDelegate()
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environmentObject(appDelegate)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                UserDefaults.standard.set(false, forKey: "appWasRunning")
            }
        }
    }
}

class AppDelegate: NSObject, ObservableObject {
    override init() {
        super.init()
    }
    
    deinit {
        UserDefaults.standard.set(false, forKey: "appWasRunning")
        UserDefaults.standard.removeObject(forKey: "savedConversations")
    }
}
