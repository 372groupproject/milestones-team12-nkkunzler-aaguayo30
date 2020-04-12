ASM = ../bin/nasm
ASMFLAGS = -f elf64
LD = ld
LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2

ifneq "$(MAKECMDGOALS)" "clean"
TARGET = $(MAKECMDGOALS)
OBJ = $(TARGET).o
endif

EXEC = $(basename $(wildcard *.asm))
ifeq "$(EXEC)" "*"
EXEC = ""
endif

$(TARGET): $(OBJ)
	@ $(LD) $(LDFLAGS) -o $@ -lc $^
	@ ./$@

%.o: %.asm
	@ $(ASM) $(ASMFLAGS) $< -o $@

all:
	@echo all: NOT YET ADDED

.PHONY: clean
clean:
	rm -f *.o $(EXEC)
