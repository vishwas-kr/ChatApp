//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject, SocketServiceDelegate {

    // MARK: - Published Properties
    @Published var conversations: [Conversation] = []
    @Published var isSocketConnected: Bool = false
    @Published var isSocketConnecting: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isOfflineModeForced: Bool = false

    // (ChatID, MessageID, Text)
    private var messageQueue: [(UUID, UUID, String)] = []

    private let socketManager = SocketManager()
    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()

    private let conversationsKey = "savedConversations"
        

    // MARK: - Init
    init() {
        socketManager.delegate = self
        loadInitialData()
        observeNetwork()
        socketManager.connect()
        handleFirstLaunch()
    }


    // MARK: - App State Persistence
    private func handleFirstLaunch() {
        let running = UserDefaults.standard.bool(forKey: "appWasRunning")

        if !running {
            conversations = []
            UserDefaults.standard.removeObject(forKey: conversationsKey)
        }

        UserDefaults.standard.set(true, forKey: "appWasRunning")
    }

    func handleAppBackground() {
        saveConversations()
    }

    func handleAppTermination() {
        UserDefaults.standard.set(false, forKey: "appWasRunning")
        UserDefaults.standard.removeObject(forKey: conversationsKey)
    }


    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: conversationsKey)
        }
    }


    private func loadInitialData() {
        conversations = []
    }


    // MARK: - Network Monitoring
    private func observeNetwork() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                guard let self = self else { return }

                if connected && !self.isOfflineModeForced {
                    print("Network is back online, attempting to reconnect WebSocket...")
                    self.processQueue()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !self.isSocketConnected {
                            print("WebSocket not connected, initiating connection...")
                            self.isSocketConnecting = true
                            self.socketManager.connect()
                        }
                    }
                } else if !connected {
                    print("Network lost, WebSocket will disconnect")
                    self.isSocketConnecting = false
                }
            }
            .store(in: &cancellables)
    }


    // MARK: - Socket Delegate
    func didReceive(text: String) {
        if conversations.isEmpty {
            let chat = Conversation(
                id: UUID(),
                botName: "Chat Bot",
                avatarColor: "blue",
                messages: [],
                hasUnread: false
            )
            conversations.append(chat)
        }

        if var chat = conversations.first {
            let msg = Message(id: UUID(), text: text, isSender: false, timestamp: Date(), status: .received)
            chat.messages.append(msg)
            chat.hasUnread = true
            conversations[0] = chat

            conversations.sort { $0.lastMessageTime > $1.lastMessageTime }
        }
    }

    func didChangeStatus(isConnected: Bool) {
        DispatchQueue.main.async {
            self.isSocketConnected = isConnected
            self.isSocketConnecting = false
            
            print("WebSocket status changed: \(isConnected ? "Connected" : "Disconnected")")

            if isConnected {
                self.processQueue()
            } else if !self.isOfflineModeForced && self.networkMonitor.isConnected {
                print("WebSocket disconnected unexpectedly, will retry connection in 3 seconds...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if !self.isSocketConnected && self.networkMonitor.isConnected && !self.isOfflineModeForced {
                        print("Retrying WebSocket connection...")
                        self.isSocketConnecting = true
                        self.socketManager.connect()
                    }
                }
            }
        }
    }



    // MARK: - Sending Messages
    func sendMessage(_ text: String, in chatID: UUID, messageID: UUID? = nil) {
        guard let chatIndex = conversations.firstIndex(where: { $0.id == chatID }) else { return }

        let msg: Message

        if let existingID = messageID,
           let idx = conversations[chatIndex].messages.firstIndex(where: { $0.id == existingID }) {
            msg = conversations[chatIndex].messages[idx]
            conversations[chatIndex].messages[idx].status = .sending
        }
        else {
            msg = Message(id: UUID(), text: text, isSender: true, timestamp: Date(), status: .sending)
            conversations[chatIndex].messages.append(msg)
            conversations[chatIndex].hasUnread = false
        }


        // Connection check
        if !networkMonitor.isConnected || isOfflineModeForced || !isSocketConnected {

            updateMessageStatus(in: chatID, messageID: msg.id, status: .failed)

            if !messageQueue.contains(where: { $0.1 == msg.id }) {
                messageQueue.append((chatID, msg.id, text))
            }

            if messageQueue.count == 1 {
                errorMessage = "No internet. Messages are queued."
                showError = true
            }
            return
        }


        // Send Message
        socketManager.send(text: text) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if success {
                    self.updateMessageStatus(in: chatID, messageID: msg.id, status: .sent)
                } else {
                    self.updateMessageStatus(in: chatID, messageID: msg.id, status: .failed)

                    if !self.messageQueue.contains(where: { $0.1 == msg.id }) {
                        self.messageQueue.append((chatID, msg.id, text))
                    }
                }
            }
        }
    }



    // MARK: - Queue Handling
    private func processQueue() {
        guard !messageQueue.isEmpty else { return }

        print("Processing Offline Queue: \(messageQueue.count) messages")

        let snapshot = messageQueue
        messageQueue.removeAll()

        for (chatID, msgID, text) in snapshot {

            if let chatIndex = conversations.firstIndex(where: { $0.id == chatID }),
               let msgIndex = conversations[chatIndex].messages.firstIndex(where: { $0.id == msgID }) {
                conversations[chatIndex].messages[msgIndex].status = .sending
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.sendMessage(text, in: chatID, messageID: msgID)
            }
        }
    }


    // MARK: - Conversation Helpers
    func markConversationAsRead(_ conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }) else { return }
        conversations[index].hasUnread = false
    }


    private func updateMessageStatus(in chatID: UUID, messageID: UUID, status: MessageStatus) {
        guard let chatIndex = conversations.firstIndex(where: { $0.id == chatID }) else { return }
        guard let msgIndex = conversations[chatIndex].messages.firstIndex(where: { $0.id == messageID }) else { return }

        conversations[chatIndex].messages[msgIndex].status = status
    }
}
