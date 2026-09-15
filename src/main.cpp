#include <format>
#include <iostream>
#include <string>

int main() {
    
    try {
        
        std::string name = "Billy";
        const int age = 31;
        
        std::string formatted_string = std::format("Hello my name is {}! I'm {} years old.", name, age);
        
        std::cout << formatted_string << '\n'; 
        
        return 0;
        
    }
    catch (const std::exception& e) {
        std::cerr << e.what() << '\n';
        return 1;
    }
    
}

