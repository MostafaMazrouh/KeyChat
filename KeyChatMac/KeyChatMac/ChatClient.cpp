//
//  ChatClient.cpp
//  ProPhonePlus
//
//  Created by Mostafa Mazrouh on 2024-05-21.
//

#include "ChatClient.hpp"

ChatClient::ChatClient(const std::string &server_ip, int server_port)
    : server_ip_(server_ip), server_port_(server_port), client_socket_(-1) {}

ChatClient::~ChatClient() {
    disconnect();
}

void ChatClient::disconnect() {
    if (client_socket_ != -1) {
        close(client_socket_);
    }
}

bool ChatClient::connect_to_server() {
    client_socket_ = socket(AF_INET, SOCK_STREAM, 0);
    if (client_socket_ < 0) {
        std::cerr << "Error creating socket" << std::endl;
        return false;
    }

    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(server_port_);

    if (inet_pton(AF_INET, server_ip_.c_str(), &server_addr.sin_addr) <= 0) {
        std::cerr << "Invalid address/ Address not supported" << std::endl;
        return false;
    }

    int c = connect(client_socket_, (struct sockaddr *)&server_addr, sizeof(server_addr));
    std::cout << "C::: " << c << std::endl;
    
    if (c < 0) {
        std::cerr << "Connection failed" << std::endl;
        return false;
    }

    std::cout << "Connected to the server with client_socket: " << client_socket_ << std::endl;
    return true;
}

void ChatClient::start() {
    std::thread read_thread(&ChatClient::receive_messages, this);
    send_messages();
    read_thread.join();
}

void ChatClient::send_message(std::string message) {
    send(client_socket_, message.c_str(), message.size(), 0);
}

void ChatClient::send_messages() {
    std::string message;
    while (true) {
        std::getline(std::cin, message);
        if (message == "/quit") {
            break;
        }
        send(client_socket_, message.c_str(), message.size(), 0);
    }
}

void ChatClient::receive_messages() {
    char buffer[BUFFER_SIZE];
    while (true) {
        long bytes_received = read(client_socket_, buffer, BUFFER_SIZE - 1);
        if (bytes_received > 0) {
            buffer[bytes_received] = '\0';
            std::cout << "Server: " << buffer << std::endl;
        } else if (bytes_received == 0) {
            std::cout << "Server disconnected" << std::endl;
            break;
        } else {
            std::cerr << "Error receiving data" << std::endl;
            break;
        }
    }
}

void ChatClient::receive_message(MessageCallback callback) {
    char buffer[BUFFER_SIZE];
    while (true) {
        
        long bytes_received = read(client_socket_, buffer, BUFFER_SIZE - 1);
        
        if (bytes_received > 0) {
            buffer[bytes_received] = '\0';
            std::cout << "Server: " << buffer << std::endl;
            callback(buffer);
            
        } else if (bytes_received == 0) {
            std::cout << "Server disconnected" << std::endl;
            break;
        } else {
            std::cerr << "Error receiving data" << std::endl;
            break;
        }
    }
}
