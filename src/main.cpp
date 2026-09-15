#include <format>
#include <iostream>
#include <string>

int main() {

    std::string name = "Billy";
    int age = 31;
    
    std::string formatted_string = std::format("Hello my name is {}! I'm {} years old.", name, age);

    std::cout << formatted_string << '\n'; 
    
    return 0;

}