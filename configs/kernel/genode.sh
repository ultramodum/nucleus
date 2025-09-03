#!/bin/bash

echo "Building Genode..."

if [[ "$conf" == "x86" ]]; then
    make "Using x86 configuration..."
    ./tool/create_builddir x86_64

elif [[ "$conf" == "arm" ]]; then
    echo "Using ARM configuration..."
    ./tool/create_builddir arm_v8a

elif [[ "$conf" == "riscv" ]]; then
    echo "Using RISC-V configuration..."
    ./tool/create_builddir riscv

else
    echo "Not a supported config."
    exit 1
fi

make kernel=hw VERBOSE= -j$(nproc) | grep -E "g(\+\+|cc).*\.${ext}($|[ c;\"])" | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh
