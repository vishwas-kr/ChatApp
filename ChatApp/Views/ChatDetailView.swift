//
//  ChatDetailView.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation
    @ObservedObject var viewModel: ChatViewModel
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(conversation.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: conversation.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(conversation.messages.last?.id, anchor: .bottom)
                    }
                }
                .onAppear {
                    if let lastMessage = conversation.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !messageText.isEmpty {
                        viewModel.sendMessage(messageText, in: conversation.id)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
        }
        .navigationTitle(conversation.botName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.markConversationAsRead(conversation.id)
        }
    }
}
