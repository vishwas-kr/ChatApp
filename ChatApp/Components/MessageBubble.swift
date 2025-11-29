//
//  MessageBubble.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isSender {
                Spacer()
                HStack(alignment: .bottom) {
                    if message.status == .failed {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                    } else if message.status == .sending {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    
                    Text(message.text)
                        .padding()
                        .background(message.status == .failed ? Color.red.opacity(0.2) : Color.blue)
                        .foregroundColor(message.status == .failed ? .red : .white)
                        .cornerRadius(16)
                }
            } else {
                Text(message.text)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(.black)
                    .cornerRadius(16)
                Spacer()
            }
        }
    }
}

