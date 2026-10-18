#!/bin/bash

echo "Building MbedTLS..."

python3 -m pip install --user -r scripts/basic.requirements.txt

if [[ "$config" == "x86" ]]; then
    export CC=x86_64-linux-gnu-gcc
    export CFLAGS="-O2 -march=x86-64"
    export LDFLAGS=""

elif [[ "$config" == "arm" ]]; then
    export CC=aarch64-linux-gnu-gcc
    export CFLAGS="-O2 -march=armv8-a"
    export LDFLAGS=""

elif [[ "$config" == "riscv" ]]; then
    export CC=riscv64-unknown-elf-gcc
    export CFLAGS="-O2 -march=rv64gc"
    export LDFLAGS=""

elif [[ "$config" == "mips" ]]; then
    export CC=mips64-linux-gnuabi64-gcc
    export CFLAGS="-O2 -march=mips64"
    export LDFLAGS=""

else
    echo "Not a supported config."
    exit 1
fi

make clean
make no_test --trace -j$(nproc) | grep "gcc.*\.${ext}$" | sed 's/$/ -save-temps -dumpdir ./' >> make-$type.sh

cd ./dump/
chmod +x ../make-$type.sh
make-$type.sh
cd ..
skip=true
