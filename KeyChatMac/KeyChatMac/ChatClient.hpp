//
//  ChatClient.hpp
//  ProPhonePlus
//
//  Created by Mostafa Mazrouh on 2024-05-21.
//

#ifndef CHATCLIENT_HPP
#define CHATCLIENT_HPP

#include <iostream>
#include <string>
#include <unistd.h>
#include <cstring>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <thread>

#define BUFFER_SIZE 1024

extern "C" {
    typedef void (*MessageCallback)(const char* message);
}

class ChatClient {
public:
    ChatClient(const std::string &server_ip, int server_port);
    ~ChatClient();
    bool connect_to_server();
    void disconnect();
    void start();
    
//    void receive_message(std::function<void(std::string&)> callback);
    
    void receive_message(MessageCallback callback);
    
    void send_message(std::string message);

private:
    void send_messages();
    void receive_messages();
    
    std::string server_ip_;
    int server_port_;
    int client_socket_;
};

#endif // CHATCLIENT_HPP
