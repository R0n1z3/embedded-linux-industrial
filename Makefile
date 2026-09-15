#VARS
CC := gcc
CXX := g++
CROSS_COMPILE ?= arm-linux-gnueabihf-
GCC_ARM = gcc
G++_ARM = g++
CFLAGS := -Wall -Wextra -Wpedantic
ARMFLAGS = -Wall -Wextra -Wpedantic
CXXFLAGS = -Wall -Wextra -Wpedantic -std=c++20
CXXARMFLAGS = -Wall -Wextra -Wpedantic -std=c++20
HOST_BINARIES = build/app  build/app-cpp
ARM_BINARIES = build/app-arm build/app-cpp-arm
MK_BLDFLDR = mkdir -p build

#COMMANDS
.PHONY : clean all host arm tidy

all : $(HOST_BINARIES) $(ARM_BINARIES)

host : $(HOST_BINARIES)

arm : $(ARM_BINARIES)

tidy : src/main.cpp
	clang-tidy src/main.cpp -- $(CXXFLAGS)

build/app : src/main.c
	$(MK_BLDFLDR)
	$(CC) $(CFLAGS) src/main.c -o build/app

build/app-arm : src/main.c
	$(MK_BLDFLDR)
	$(CROSS_COMPILE)$(GCC_ARM) $(ARMFLAGS) src/main.c -o build/app-arm

build/app-cpp : src/main.cpp
	$(MK_BLDFLDR)
	$(CXX) $(CXXFLAGS) src/main.cpp -o build/app-cpp

build/app-cpp-arm : src/main.cpp
	$(MK_BLDFLDR)
	$(CROSS_COMPILE)$(G++_ARM) $(CXXARMFLAGS) src/main.cpp -o build/app-cpp-arm


clean :
		rm -f $(HOST_BINARIES) $(ARM_BINARIES)
