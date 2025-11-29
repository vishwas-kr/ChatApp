//
//  HomeScreen.swift
//  ChatApp
//
//  Created by VK on 29/11/25.
//

import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.conversations.isEmpty {
                    EmptyStateView(
                        iconName: "bubble.left.and.bubble.right",
                        title: "No Chats Available",
                        subtitle: viewModel.isSocketConnected ? "WebSocket: Connected" : "WebSocket: Disconnected"
                    )
                } else {
                    List {
                        ForEach(viewModel.conversations) { chat in
                            NavigationLink(destination: ChatDetailView(conversation: chat, viewModel: viewModel)) {
                                ChatRow(conversation: chat)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Connection Status Banners
                VStack {
                    Spacer()
                    
                    // Connecting Banner
                    if viewModel.isSocketConnecting {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            Text("Connecting to server...")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom))
                    }
                    // Offline Banner
                    else if !viewModel.isSocketConnected {
                        HStack {
                            Image(systemName: "wifi.slash")
                            Text("No Connection - Offline Mode")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom))
                    }
                }
                .animation(.easeInOut, value: viewModel.isSocketConnecting)
                .animation(.easeInOut, value: viewModel.isSocketConnected)
            }
            .navigationTitle("Chats")
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                viewModel.handleAppBackground()
            case .inactive:
                break
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    HomeScreen()
}
