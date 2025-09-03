#!/bin/bash

echo "Building Linux..."

if [[ "$conf" == "tiny" ]]; then
      echo "Using minimal configuration..."
      make tinyconfig
yes | make V=1 -j$(nproc) >> make.log

elif [[ "$conf" == "x86" ]]; then
      echo "Using x86 default configuration..."
      make ARCH=x86_64 defconfig
yes | make ARCH=x86_64 V=1 -j$(nproc) >> make.log

elif [[ "$conf" == "arm" ]]; then
      echo "Using ARM default configuration..."
      make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
yes | make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- V=1 -j$(nproc) >> make.log

elif [[ "$conf" == "riscv" ]]; then
      echo "Using RISC-V default configuration..."
      make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
yes | make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- V=1 -j$(nproc) >> make.log

elif [[ "$conf" == "mips" ]]; then
      echo "Using MIPS default configuration..."
#      make ARCH=mips CROSS_COMPILE=!!!!!!!!-linux-gnu- defconfig
#yes | make ARCH=mips CROSS_COMPILE=!!!!!!!!-linux-gnu- V=1 -j$(nproc) >> make.log

else
    echo "Not a supported config."
    exit 1
fi

echo -e "\a"
echo "Extracting relevant commands..."
grep -E -a "gcc.*\.${ext}($|[ ;\"])" make.log | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh
