//
//  ChatView.swift
//  KeyChatMac
//
//  Created by Mostafa Mazrouh on 2024-07-12.
//

import SwiftUI


struct ChatView: View {
    
    let chatVM = ChatVM()
    @State private var newMessage: String = ""
    
    
    var body: some View {
        VStack {
            
            HStack {
                VStack {
                    
                    Text(chatVM.userTitle)
                    
                    Spacer()
                    
                    Button(action: connectToLocalServer) {
                        Text(chatVM.isConnected ? "Connected" : "Connect++")
                    }
                    .disabled(chatVM.isConnected)
                    
                    Button("Disconnect") {
                        chatVM.disconnect()
                    }
                    .disabled(!chatVM.isConnected)
                }
                
                Spacer()
                
                PhotoView()
            }
            .padding()
            
            List(chatVM.messages) { message in
                Text(message.text)
            }
            
            VStack(alignment: .leading) {
                TextField("Enter message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: CGFloat(30))
                
                Button(action: sendMessage) {
                    Text("Send")
                }
            }
            .padding()
            
            .padding()
        }
        .frame(maxWidth: 1000, maxHeight: 1000)
    }
    
    func connectToLocalServer() {
        chatVM.connectToLocalServer()
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        chatVM.sendMessage(message: newMessage)
        newMessage = ""
    }
}

#Preview {
    ChatView()
}
