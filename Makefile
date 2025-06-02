# Paths
SRC_DIR := 8051/c
BUILD_DIR := $(SRC_DIR)/build
SRC := $(SRC_DIR)/main.c
TARGET := main

# Output files
IHX := $(BUILD_DIR)/$(TARGET).ihx
ASM := $(BUILD_DIR)/$(TARGET).asm
LST := $(BUILD_DIR)/$(TARGET).lst
SYM := $(BUILD_DIR)/$(TARGET).sym

# Default target
all: $(IHX) $(ASM) $(LST) $(SYM)

# Compile .c to .ihx
$(IHX): $(SRC) | $(BUILD_DIR)
	sdcc -o $@ $<

# Move other generated files
$(ASM): $(IHX)
	mv $(SRC_DIR)/$(TARGET).asm $@

$(LST): $(IHX)
	mv $(SRC_DIR)/$(TARGET).lst $@

$(SYM): $(IHX)
	mv $(SRC_DIR)/$(TARGET).sym $@

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
