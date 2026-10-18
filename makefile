BREW_PREFIX := $(shell brew --prefix)
CXX         := $(BREW_PREFIX)/opt/llvm/bin/clang++
OBJCOPY     := $(BREW_PREFIX)/opt/llvm/bin/llvm-objcopy
LLD_DIR     := $(BREW_PREFIX)/opt/lld/bin
BUILD_DIR   := build
OUTPUT_DIR  := rtl/machine_code/code
ELF         := $(BUILD_DIR)/program.elf
INSTR_BIN   := $(BUILD_DIR)/instructions.bin
DATA_BIN    := $(BUILD_DIR)/data.bin
INSTR_HEX   := $(OUTPUT_DIR)/instructions.hex
DATA_HEX    := $(OUTPUT_DIR)/data.hex
CPP_SOURCE  := code/main.cpp code/helper.cpp
CPP_HEADERS := code/peripherals.hpp code/helper.hpp

CXXFLAGS := --target=riscv32-unknown-elf \
	-march=rv32i -mabi=ilp32 \
	-Os \
	-ffreestanding -fno-builtin -fno-stack-protector \
	-fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-use-cxa-atexit \
	-msmall-data-limit=0 -nostdlib
LDFLAGS := -fuse-ld=lld -B$(LLD_DIR) -Wl,-T,code/linker.ld

.PHONY: all images clean

all: images

# Build the freestanding RV32I C++ program and two 4 KiB, 32-bit-word
# $readmemh images.  peripherals.hpp is header-only, so no .cpp file is needed.
images: $(CPP_SOURCE) $(CPP_HEADERS) code/crt0.s code/linker.ld
	mkdir -p $(BUILD_DIR) $(OUTPUT_DIR)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(ELF) code/crt0.s $(CPP_SOURCE)
	$(OBJCOPY) -O binary --only-section=.text --only-section=.rodata $(ELF) $(INSTR_BIN)
	$(OBJCOPY) -O binary --only-section=.data $(ELF) $(DATA_BIN)
	test $$(wc -c < $(INSTR_BIN)) -le 4096
	dd if=/dev/zero of=$(BUILD_DIR)/instructions.padded.bin bs=4096 count=1 2>/dev/null
	dd if=$(INSTR_BIN) of=$(BUILD_DIR)/instructions.padded.bin conv=notrunc 2>/dev/null
	xxd -e -g4 -c4 $(BUILD_DIR)/instructions.padded.bin | awk '{print $$2}' > $(INSTR_HEX)
	test $$(wc -c < $(DATA_BIN)) -le 4096
	dd if=/dev/zero of=$(BUILD_DIR)/data.padded.bin bs=4096 count=1 2>/dev/null
	dd if=$(DATA_BIN) of=$(BUILD_DIR)/data.padded.bin conv=notrunc 2>/dev/null
	xxd -e -g4 -c4 $(BUILD_DIR)/data.padded.bin | awk '{print $$2}' > $(DATA_HEX)

clean:
	rm -rf $(BUILD_DIR)
