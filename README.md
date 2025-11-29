# ChatApp - Real-time WebSocket Chat Application

## Installation
1. Clone the repository:
~~~ bash
git clone <repository-url>
cd ChatApp
~~~
2. Open the project in Xcode:
~~~ bash
open ChatApp.xcodeproj
~~~
3. Build and run on simulator or device (⌘R)
4. WebSocket Configuration
The app uses PieSocket for WebSocket connections. The URL is configured in `SocketManager.swift`:
``` bash
private let url = URL(string:
    "YOUR_WEBSEOCKET_URL"
)!
```
To use your own WebSocket server, replace this URL with your endpoint.

## Core Functionality

- Real-time Messaging: Instant message delivery using WebSocket (PieSocket)
- Automatic Reconnection: Seamlessly reconnects when network becomes available
- Offline Message Queue: Messages are queued when offline and automatically sent when connection is restored
- Message Status Indicators: Visual feedback for message states (sending, sent, failed, received)
- Connection Status Banners: Real-time UI feedback for connection states


## Connection States

- Connecting (Orange banner): Displayed when establishing WebSocket connection
- Connected (No banner): Normal operational state
- Offline (Red banner): No internet or forced offline mode

## Architecture
The app follows the Model-View-ViewModel architecture:
~~~
Models/
├── Conversation.swift    # Chat conversation data model
└── Message.swift        # Individual message data model

Views/
├── HomeScreen.swift     # Main chat list screen
├── ChatDetailView.swift # Individual chat screen
├── ChatRow.swift        # Chat list item
├── MessageBubble.swift  # Message UI component
└── NoChat.swift         # Empty state view

ViewModels/
└── ChatViewModel.swift  # Business logic and state management

Services/
├── SocketManager.swift  # WebSocket connection handling
└── NetworkMonitor.swift # Network connectivity monitoring

~~~

## Demo:
https://github.com/user-attachments/assets/d1519487-0d9e-4ac1-a667-862270701abe
