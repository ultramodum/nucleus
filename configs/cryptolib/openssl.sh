#!/bin/bash

echo "Building OpenSSL..."

if [[ "$config" == "x86" ]]; then
    ./Configure linux-x86_64 no-tests
    make V=1 -j$(nproc) | grep -E "^gcc.*\.${ext}$" | while read -r line; do
        cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
        echo "$cmd" >> make-$type.sh
    done

elif [[ "$config" == "arm" ]]; then
    ./Configure linux-aarch64 no-tests --cross-compile-prefix=aarch64-linux-gnu-
    make V=1 -j$(nproc) | grep -E "aarch64-linux-gnu-gcc.*\.${ext}$" | while read -r line; do
        cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
        echo "$cmd" >> make-$type.sh
    done

elif [[ "$config" == "riscv" ]]; then
    ./Configure linux64-riscv64 no-tests --cross-compile-prefix=riscv64-linux-gnu-
    make V=1 -j$(nproc) | grep -E "riscv64-linux-gnu-gcc.*\.${ext}$" | while read -r line; do
        cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
        echo "$cmd" >> make-$type.sh
    done

elif [[ "$config" == "mips" ]]; then
    ./Configure linux64-mips64 no-tests --cross-compile-prefix=mips64-linux-gnu-
    make V=1 -j$(nproc) | grep -E "mips64-linux-gnu-gcc.*\.${ext}$" | while read -r line; do
        cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
        echo "$cmd" >> make-$type.sh
    done

else
    echo "Not a supported config."
    exit 1
fi
