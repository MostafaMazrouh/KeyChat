//
//  Server.cpp
//  KeyChat
//
//  Created by Mostafa Mazrouh on 2024-05-29.
//

#include "Server.hpp"

Server::Server(const std::string &ip, int port)
    : ip_(ip), port_(port), server_socket_(-1) {}

Server::~Server() {
    if (server_socket_ != -1) {
        close(server_socket_);
    }
    for (int client_socket : client_sockets_) {
        close(client_socket);
    }
}

void Server::start() {
    server_socket_ = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket_ < 0) {
        std::cerr << "Error creating socket" << std::endl;
        exit(EXIT_FAILURE);
    }

    int opt = 1;
    setsockopt(server_socket_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(ip_.c_str());
    server_addr.sin_port = htons(port_);

    if (bind(server_socket_, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        std::cerr << "Error binding socket" << std::endl;
        close(server_socket_);
        exit(EXIT_FAILURE);
    }

    if (listen(server_socket_, 3) < 0) {
        std::cerr << "Error listening on socket" << std::endl;
        close(server_socket_);
        exit(EXIT_FAILURE);
    }

    std::cout << "Server started on " << ip_ << ":" << port_ << std::endl;

    fd_set readfds;
    while (true) {
        FD_ZERO(&readfds);
        FD_SET(server_socket_, &readfds);
        int max_sd = server_socket_;

        for (int client_socket : client_sockets_) {
            if (client_socket > 0) {
                FD_SET(client_socket, &readfds);
            }
            if (client_socket > max_sd) {
                max_sd = client_socket;
            }
        }

        int activity = select(max_sd + 1, &readfds, NULL, NULL, NULL);
        if ((activity < 0) && (errno != EINTR)) {
            std::cerr << "Select error" << std::endl;
        }

        if (FD_ISSET(server_socket_, &readfds)) {
            handle_new_connection();
        }

        for (auto it = client_sockets_.begin(); it != client_sockets_.end(); it++) {
            int sd = *it;
            if (FD_ISSET(sd, &readfds)) {
                handle_client_message(sd);
            }
        }
    }
}

void Server::handle_new_connection() {
    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);
    int new_socket = accept(server_socket_, (struct sockaddr *)&client_addr, &client_len);
    if (new_socket < 0) {
        std::cerr << "Error accepting connection" << std::endl;
        return;
    }
    client_sockets_.push_back(new_socket);
    std::cout << "New connection: socket FD is " << new_socket << ", IP is: " << inet_ntoa(client_addr.sin_addr) << ", port: " << ntohs(client_addr.sin_port) << std::endl;
    
    std::string my_message = std::to_string(new_socket);
    
    send(new_socket, my_message.c_str(), my_message.size(), 0);
}

void Server::handle_client_message(int client_socket) {
    char buffer[BUFFER_SIZE];
    long valread = read(client_socket, buffer, BUFFER_SIZE);
    
    if (valread == 0) {
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        getpeername(client_socket, (struct sockaddr *)&client_addr, &client_len);
        std::cout << "Host disconnected, IP: " << inet_ntoa(client_addr.sin_addr) << ", port: " << ntohs(client_addr.sin_port) << std::endl;
        close(client_socket);
        
        client_sockets_.erase(
            std::remove(client_sockets_.begin(), client_sockets_.end(), client_socket), client_sockets_.end());
        
    } else {
        buffer[valread] = '\0';
        std::string message(buffer);
        std::cout << "Message from socket " << client_socket << ": " << message << std::endl;
        
        broadcast_message(message, client_socket);
    }
}

void Server::broadcast_message(const std::string &message, int sender_socket) {
    
    std::string sender;
    
    for (int client_socket : client_sockets_) {
        if (client_socket != sender_socket) {
            sender = "Slot " + std::to_string(sender_socket) + ": ";
        } else {
            sender = "Me: ";
        }
        
        std::string full_message = sender + message;
        
        send(client_socket, full_message.c_str(), full_message.size(), 0);
    }
}
