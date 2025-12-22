#!/bin/bash

echo "[INFO] Building Linux..."

if [[ "$config" == "tiny" ]]; then
      echo "[INFO] Using minimal configuration..."
      make tinyconfig
yes | make V=1 -j$(nproc) >> make.log

elif [[ "$config" == "full" ]]; then
      echo "[INFO] Using complete configuration..."
      make fullconfig # ?!
yes | make V=1 -j$(nproc) >> make.log

elif [[ "$config" == "x86" ]]; then
      echo "[INFO] Using x86 default configuration..."
      make ARCH=x86_64 defconfig
yes | make ARCH=x86_64 V=1 -j$(nproc) >> make.log

elif [[ "$config" == "arm" ]]; then
      echo "[INFO] Using ARM default configuration..."
      make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
yes | make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- V=1 -j$(nproc) >> make.log

elif [[ "$config" == "riscv" ]]; then
      echo "[INFO] Using RISC-V default configuration..."
      make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
yes | make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- V=1 -j$(nproc) >> make.log

elif [[ "$config" == "mips" ]]; then
      echo "[INFO] Using MIPS default configuration..."
#      make ARCH=mips CROSS_COMPILE=!!!!!!!!-linux-gnu- defconfig
#yes | make ARCH=mips CROSS_COMPILE=!!!!!!!!-linux-gnu- V=1 -j$(nproc) >> make.log

else
    echo "[ABORTED] Supported configs: tiny, full, x86, arm, riscv, mips"
    exit 1
fi

echo -e "\aExtracting relevant commands..."
grep -a -E "gcc.*\.${ext}($|[ ;\"])" make.log | sed 's/$/ -save-temps -dumpdir .\/dump\//' >> make-$type.sh
