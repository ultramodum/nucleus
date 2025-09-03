#!/bin/bash

echo "Building WolfSSL..."

if [[ "$conf" == "x86" ]]; then
    ./configure --host=x86_64-linux-gnu

elif [[ "$conf" == "arm" ]]; then
    ./configure --host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc

elif [[ "$conf" == "riscv" ]]; then
    ./configure --host=riscv64-linux-gnu CC=riscv64-linux-gnu-gcc

else
    echo "Not a supported config."
    exit 1
fi

make V=1 -j$(nproc) | grep "gcc.*\.${ext}$" | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh
