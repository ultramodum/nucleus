#!/bin/bash

echo "[INFO] Building Zephyr..."

python3 -m venv .venv
source .venv/bin/activate
pip install west

ZEPHYR_BASE="$affix/zephyr/"

west init
west update
west zephyr-export
west packages pip --install
west sdk install -d .

cd ./zephyr/

if [[ "$config" == "x86" ]]; then
    echo "[INFO] Using x86 configuration..."
    west build -b qemu_x86_64 -d build_x86 samples/hello_world/

elif [[ "$config" == "arm" ]]; then
    echo "[INFO] Using ARM configuration..."
    west build -b qemu_cortex_a53 -d build_arm samples/hello_world/

elif [[ "$config" == "riscv" ]]; then
    echo "[INFO] Using RISC-V configuration..."
    west build -b qemu_riscv64 -d build_riscv samples/hello_world/

else
    echo "[ABORTED] Supported configs: x86, arm, riscv"
    exit 1
fi

cd ./build_$config/
jq -r '.[] | select(.file | endswith(".c")) | .command + " -save-temps"' ./compile_commands.json > run-i.sh
