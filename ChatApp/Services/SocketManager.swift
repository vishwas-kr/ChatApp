//
//  SocketManager.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import Foundation

protocol SocketServiceDelegate: AnyObject {
    func didReceive(text: String)
    func didChangeStatus(isConnected: Bool)
}

class SocketManager: NSObject, URLSessionWebSocketDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    weak var delegate: SocketServiceDelegate?
    
    private let url = URL(string:
        "wss://s15497.blr1.piesocket.com/v3/1?api_key=1h55yVESjYq89AEGy4wyyBY3SiOUW5Bje7AhS8St&notify_self=0"
    )!
    
    private lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }()
    
    var isSimulationMode = false
    private var simulationTimer: Timer?
    
    func connect() {

        if let task = webSocketTask, task.state == .running {
            print("WebSocket already running — skipping connect()")
            return
        }
        
        if isSimulationMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.delegate?.didChangeStatus(isConnected: true)
                self.startSimulationIncoming()
            }
            return
        }

        print("Opening WebSocket connection...")

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    func disconnect() {
        if isSimulationMode {
            simulationTimer?.invalidate()
            self.delegate?.didChangeStatus(isConnected: false)
            return
        }
        
        print("Closing WebSocket connection...")
        webSocketTask?.cancel(with: .goingAway, reason: nil)

        webSocketTask = nil
        
        delegate?.didChangeStatus(isConnected: false)
    }
    
    func send(text: String, completion: @escaping (Bool) -> Void) {
        if isSimulationMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(true)
            }
            return
        }
        
        guard let task = webSocketTask, task.state == .running else {
            print("Cannot send — no active WebSocket connection")
            completion(false)
            return
        }

        task.send(.string(text)) { error in
            if let error = error {
                print("Socket Send Error: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Socket Receive Error: \(error)")
                self?.delegate?.didChangeStatus(isConnected: false)
                
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.delegate?.didReceive(text: text)
                    }
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            print("WebSocket Connected")
            self.delegate?.didChangeStatus(isConnected: true)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            print("WebSocket Closed")
            self.delegate?.didChangeStatus(isConnected: false)
        }
        
        // Clear task
        self.webSocketTask = nil
    }
    
    func startSimulationIncoming() {
        simulationTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            let replies = ["That's interesting!", "Tell me more.", "I am a real-time bot.", "Connectivity is good."]
            self?.delegate?.didReceive(text: replies.randomElement()!)
        }
    }
    
    func triggerManualIncoming(text: String) {
        self.delegate?.didReceive(text: text)
    }
}
