//
//  Server.hpp
//  KeyChat
//
//  Created by Mostafa Mazrouh on 2024-05-29.
//

#ifndef Server_hpp
#define Server_hpp

#include <stdio.h>
#include <iostream>
#include <string>
#include <vector>
#include <unistd.h>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <fcntl.h>

#define MAX_CLIENTS 30
#define BUFFER_SIZE 1024

class Server {
public:
    Server(const std::string &ip, int port);
    ~Server();
    void start();

private:
    void handle_new_connection();
    void handle_client_message(int client_socket);
    void broadcast_message(const std::string &message, int sender_socket);

    std::string ip_;
    int port_;
    int server_socket_;
    std::vector<int> client_sockets_;
};


#endif /* Server_hpp */
