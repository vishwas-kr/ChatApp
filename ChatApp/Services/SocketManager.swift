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
        "YOUR_WEBSOCKET_SERVER_URL_HERE"
    )!
    
    private lazy var session: URLSession = {
        URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }()
    
    
    func connect() {

        if let task = webSocketTask, task.state == .running {
            print("WebSocket already running — skipping connect()")
            return
        }
        
        print("Opening WebSocket connection...")

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    func disconnect() {
        print("Closing WebSocket connection...")
        webSocketTask?.cancel(with: .goingAway, reason: nil)

        webSocketTask = nil
        
        delegate?.didChangeStatus(isConnected: false)
    }
    
    func send(text: String, completion: @escaping (Bool) -> Void) {
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
        
        self.webSocketTask = nil
    }
}
