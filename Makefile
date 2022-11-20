# Makefile
# Project: x64 GAS Demo 7
# By: Derek Tan

# assembler vars
CC := gcc
CFLAGS := -no-pie -g -Wall -Werror

BIN_DIR := ./bin
SRC_DIR := ./src

SRCS := $(shell find $(SRC_DIR) -name *.s)
OBJS := $(patsubst $(SRC_DIR)/%.s, %.o, $(SRCS))
EXES := $(patsubst $(SRC_DIR)/%.s, $(BIN_DIR)/%.out, $(SRCS))

# Make Rules
.PHONY: tell all clean

vpath %.s $(SRC_DIR)

tell:
	@echo "SRCS:"
	@echo $(SRCS)
	@echo "OBJS:"
	@echo $(OBJS)
	@echo "EXES:"
	@echo $(EXES) 

all: $(EXES)

$(BIN_DIR)/%.out: %.o
	$(CC) $(CFLAGS) $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(EXES) *.o
