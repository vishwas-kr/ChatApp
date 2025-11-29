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
                
                // Network Error Banner
                if !viewModel.isSocketConnected || viewModel.isOfflineModeForced {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "wifi.slash")
                            Text("No Connection - Offline Mode")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: viewModel.isSocketConnected)
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.triggerIncomingDemo() }) {
                            Label("Simulate Incoming Msg", systemImage: "arrow.down.message")
                        }
                        Button(action: { viewModel.toggleOfflineSimulation() }) {
                            Label(viewModel.isOfflineModeForced ? "Go Online" : "Go Offline", systemImage: "wifi")
                        }
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Internet Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
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



