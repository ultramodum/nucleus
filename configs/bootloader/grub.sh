#!/bin/bash

echo "Building GRUB..."

if [[ "$conf" == "x86" ]]; then
    ./configure --target=x86_64 --with-platform=efi

elif [[ "$conf" == "arm" ]]; then
    ./configure --target=aarch64 --with-platform=efi CC=aarch64-linux-gnu-gcc

elif [[ "$conf" == "riscv" ]]; then
    ./configure --target=riscv64 --with-platform=efi CC=riscv64-linux-gnu-gcc

else
    echo "Not a supported config."
    exit 1
fi

make V=1 -j$(nproc) | grep 'gcc.*\.c ' | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh
