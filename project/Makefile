ASM = ../bin/nasm
ASMFLAGS = -g -f elf64
LD = ld
LDFLAGS = -g -dynamic-linker /lib64/ld-linux-x86-64.so.2

ifneq "$(MAKECMDGOALS)" "clean"
TARGET = $(MAKECMDGOALS)
SRC = $(TARGET).asm
OBJ = $(TARGET).o
endif

EXEC = $(basename $(wildcard *.asm))
ifeq "$(EXEC)" "*"
EXEC = ""
endif

$(TARGET): $(OBJ)
	@ $(LD) $(LDFLAGS) -o $(TARGET) -lc $(OBJ) -lncurses

%.o: %.asm
	@ $(ASM) $(ASMFLAGS) $< -o $@

all:
	@echo all: NOT YET ADDED

.PHONY: clean
clean:
	rm -f *.o $(EXEC)
