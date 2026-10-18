#!/bin/bash

echo "[INFO] Building Genode..."

if [[ "$config" == "x86" ]]; then
    echo "[INFO] Using x86 configuration..."
    ./tool/create_builddir x86_64
    cd ./build/x86_64/

elif [[ "$config" == "arm" ]]; then
    echo "[INFO] Using ARM configuration..."
    ./tool/create_builddir arm_v8a
    cd ./build/arm_v8a/

elif [[ "$config" == "riscv" ]]; then
    echo "[INFO] Using RISC-V configuration..."
    ./tool/create_builddir riscv
    cd ./build/riscv/

else
    echo "[ABORTED] Supported configs: x86, arm, riscv"
    exit 1
fi

# Set kernel/platform to bare metal
sed -i 's/^#KERNEL ?=.*/KERNEL ?= hw/' ./etc/build.conf

# Grep pattern: g++ / gcc -> anything -> .c -> lineshift OR space OR c (.cc files) OR semicolon OR double quotes
make VERBOSE= -j$(nproc) | grep -a -E "g(\+\+|cc).*\.${ext}($|[ ${ext};\"])" | sed 's/$/ -save-temps/' >> temp.sh

source $script/preserve.sh
