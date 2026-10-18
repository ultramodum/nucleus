#!/bin/bash

echo "Building Barebox..."

if [[ "$config" == "x86" ]]; then
    export CROSS_COMPILE=
    make ARCH=x86 O=build/x86 efi_defconfig && cd build/x86
    make ARCH=x86 V=1 -j$(nproc) >> make.log

elif [[ "$config" == "arm" ]]; then
    export CROSS_COMPILE=aarch64-linux-gnu-
    make ARCH=arm O=build/arm multi_v8_defconfig && cd build/arm
    make ARCH=arm V=1 -j$(nproc) >> make.log

elif [[ "$config" == "riscv" ]]; then
    export CROSS_COMPILE=riscv64-linux-gnu-
    make ARCH=riscv O=build/riscv rv64i_defconfig && cd build/riscv
    make ARCH=riscv V=1 -j$(nproc) >> make.log

elif [[ "$config" == "mips" ]]; then
    export CROSS_COMPILE=mips64-linux-gnuabi64-
    make ARCH=mips O=build/mips qemu-malta64_defconfig && cd build/mips
    make ARCH=mips V=1 -j$(nproc) >> make.log

else
    echo "Not a supported config."
    exit 1
fi

grep -a -E "gcc.*\.${ext}($|[ ;\"])" make.log | sed 's/$/ -save-temps/' >> run.sh
cd ../..
