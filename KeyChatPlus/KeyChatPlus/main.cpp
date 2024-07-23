//
//  main.cpp
//  KeyChatPlus
//
//  Created by Mostafa Mazrouh on 2024-07-23.
//

#include <iostream>
#include "Server.hpp"


int main(int argc, const char * argv[]) {
    
    std::cout << "Press y to start a local server\n";
    
    char ch;
    std::cin >> ch;
    
    if (ch == 'y' || ch == 'Y') {
        Server server = Server("127.0.0.1", 2525);
        server.start();
    }
    
    return 0;
}
