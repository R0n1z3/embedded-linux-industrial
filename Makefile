#VARS
cc := gcc
CROSS_COMPILE ?=
CFLAGS := -Wall -Wextra -Wpedantic
ARMFLAGS = -Wall -Wextra -Wpedantic
OUTPUT := build/app
OBJECTS = build/app build/app-arm
MK_BLDFLDR = mkdir -p build

#IF CROSS_COMPILE is declared by the user then it builds the arm binary
ifneq ($(CROSS_COMPILE),)
  cc := $(CROSS_COMPILE)gcc
  OUTPUT := build/app-arm
  CFLAGS := $(ARMFLAGS)

endif

#COMMANDS
$(OUTPUT) : src/main.c
	$(MK_BLDFLDR)
	$(cc) $(CFLAGS) src/main.c -o $(OUTPUT)


.PHONY : clean
clean :
		rm -f $(OBJECTS)
