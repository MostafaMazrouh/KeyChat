//
//  ChatVM.swift
//  KeyChatMac
//
//  Created by Mostafa Mazrouh on 2024-07-12.
//

import Foundation
import CxxStdlib


@Observable
class ChatVM {
    
    var messages: [Message] = []
    
    let localServerIp: std.string  = std.string("127.0.0.1")
    let serverPort: Int32 = 2525
    
    var userTitle = "Welcome"
    private(set) var isConnected = false
    
    
    private var client: ChatClient?
        
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedMessage(_:)), name: .receivedMessage, object: nil)
    }
    
    func connectToLocalServer() {
        
        client = ChatClient(localServerIp, serverPort)
        
        if client?.connect_to_server() ?? false {
            
            Task {
                client?.receive_message { messagePtr in
                    
                    guard let messagePtr = messagePtr else { return }
                    let message = String(cString: messagePtr)
                    
                    NotificationCenter.default.post(name: .receivedMessage, object: nil, userInfo: ["message": message])
                }
            }
        } else {
            userTitle = "No running server found"
        }
    }
    
    func disconnect() {
        client?.disconnect()
        client = nil
        isConnected = false
        userTitle = "Welcome"
        messages = []
    }
    
    @objc private func handleReceivedMessage(_ notification: Notification) {
        guard let message = notification.userInfo?["message"] as? String else { return }
        
        DispatchQueue.main.async {
            
            // First message from the server is the given slot
            if self.isConnected == false,
               let mySlot = Int(message) {
                self.userTitle = "You are on slot: \(mySlot)"
                self.isConnected = true
                return
            }
            
            self.messages.append(Message(text: message))
        }
    }
    
    func sendMessage(message: String) {
        client?.send_message(std.string(message))
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
}

extension Notification.Name {
    static let receivedMessage = Notification.Name("receivedMessage")
}

