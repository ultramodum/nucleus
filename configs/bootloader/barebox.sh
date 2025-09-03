#!/bin/bash

echo "Building Barebox..."

if [[ "$conf" == "x86" ]]; then
    export CROSS_COMPILE=
    make ARCH=x86 efi_defconfig
    make ARCH=x86 V=1 -j$(nproc) | grep "gcc.*\.${ext}$" | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh

elif [[ "$conf" == "arm" ]]; then
    export CROSS_COMPILE=arm-linux-gnueabihf-
    make ARCH=arm multi_v7_defconfig
    make ARCH=arm V=1 -j$(nproc) | grep "arm-linux-gnueabihf-gcc.*\.${ext}$" | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh

else
    echo "Not a supported config."
    exit 1
fi
