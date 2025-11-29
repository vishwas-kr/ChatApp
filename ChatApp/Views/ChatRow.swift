//
//  ChatRow.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//
import SwiftUI

struct ChatRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(conversation.avatarColor == "blue" ? .systemBlue : .systemGreen))
                .frame(width: 50, height: 50)
                .overlay(Text(conversation.botName.prefix(1)).foregroundColor(.white).font(.headline))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.botName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(timeString(from: conversation.lastMessageTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(conversation.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(conversation.hasUnread ? .primary : .gray)
                        .lineLimit(1)
                        .fontWeight(conversation.hasUnread ? .semibold : .regular)
                    
                    if conversation.hasUnread {
                        Spacer()
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
