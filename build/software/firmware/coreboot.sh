#!/bin/bash

echo "Building Coreboot..."

make clean
make distclean
touch .config

./util/scripts/config --enable CONFIG_PAYLOAD_ELF
./util/scripts/config --disable CONFIG_PAYLOAD_NONE
./util/scripts/config --set-str CONFIG_PAYLOAD_FILE "payloads/coreinfo/build/coreinfo.elf"

if [[ "$config" == "x86" ]]; then
    echo "Using x86 configuration..."
    make crossgcc-i386 CPUS=$(nproc)
    ./util/scripts/config --enable CONFIG_BOARD_EMULATION_QEMU_X86_I440FX

elif [[ "$config" == "arm" ]]; then
    echo "Using ARM configuration..."
    make crossgcc-aarch64 CPUS=$(nproc)
    ./util/scripts/config --enable CONFIG_BOARD_EMULATION_QEMU_AARCH64

elif [[ "$config" == "riscv" ]]; then
    echo "Using RISC-V configuration..."
    make crossgcc-riscv CPUS=$(nproc)
    ./util/scripts/config --enable CONFIG_BOARD_EMULATION_QEMU_RISCV_RV64

else
    echo "Not a supported config."
    exit 1
fi

make olddefconfig

echo "Extracting relevant commands..."
make V=1 -j$(nproc) | grep -a -E "gcc.*\.${ext}($|[ ;\"])" | sed 's/$/ -save-temps/' >> run-$config.sh

# Get rid of unnecessary lines
grep -v "CC=" run-$config.sh >> tmp && mv tmp run-$config.sh
grep -v "CC+STRIP" run-$config.sh >> tmp && mv tmp run-$config.sh
