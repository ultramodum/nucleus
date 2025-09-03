#!/bin/bash

echo "Building Coreboot..."

if [[ "$conf" == "x86" ]]; then
    make "Using x86 configuration..."
    make crossgcc-x64 CPUS=$(nproc)

elif [[ "$conf" == "arm" ]]; then
    echo "Using ARM configuration..."
    make crossgcc-aarch64 CPUS=$(nproc)

elif [[ "$conf" == "riscv" ]]; then
    echo "Using RISC-V configuration..."
    make crossgcc-riscv CPUS=$(nproc)

else
    echo "Not a supported config."
    exit 1
fi

echo "Extracting relevant commands..."
make V=1 -j$(nproc) >> make.log
grep -E -a "gcc.*\.${ext}($|[ ;\"])" make.log | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh
