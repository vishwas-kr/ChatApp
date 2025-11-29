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
The application fulfills all requirements outlined in the task:

1. Chat Interface
 - Single-Screen Layout: A clean interface displaying a list of active chatbot conversations.
 - Message Previews: Each chat entry displays a preview of the latest message (P1).
 - Ephemeral Data: All conversations are stored in memory and are cleared on app close, ensuring a fresh state every launch.

2. Real-Time Syncing (P0)
 - Socket Communication: Implemented using native URLSessionWebSocketTask.
 - PieHost Integration: Connected to PieHost (PieSocket) public demo cluster for reliable real-time updates.
 - Instant Updates: Incoming messages update the UI immediately without any pull-to-refresh mechanism.

3. Offline Functionality (P0)
 - Network Detection: Uses NWPathMonitor to detect internet availability in real-time.
 - Message Queueing: Messages sent while offline are flagged as "Failed" and added to an internal retry queue.
 - Auto-Retry: The app automatically attempts to resend queued messages as soon as the connection is restored.

4. Error Handling & Empty States
 - Visual Alerts: Clear red banner and icon indicators for network failures.
 - Empty States: Handles scenarios for "No chats available" and "No internet connection" with user-friendly UI.

5. Chat Preview & Navigation:
 - Show unread message previews for each chat. 

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
