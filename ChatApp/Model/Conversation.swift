//
//  Conversation.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import Foundation

struct Conversation : Identifiable, Encodable{
    let id: UUID
    let botName: String
    let avatarColor : String
    var messages : [Message]
    var hasUnread: Bool
    
    var lastMessage : String {
        messages.last?.text ?? "No Messages Yet"
    }
    
    var lastMessageTime: Date{
        messages.last?.timestamp ?? Date()
    }
}
