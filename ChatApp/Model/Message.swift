//
//  Message.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import Foundation

enum MessageStatus : String, Codable {
    case sending
    case sent
    case failed
    case received
}

struct Message: Identifiable, Codable, Equatable {
    let id : UUID
    let text: String
    let isSender: Bool
    let timestamp: Date
    var status : MessageStatus
    
    static let mocck = Message(id: UUID(), text: "Hello", isSender: true, timestamp: Date(), status: .sent)
}
