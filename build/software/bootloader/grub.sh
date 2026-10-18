#!/bin/bash
# Note that for all configs below, both --build and --host, as well as their corresponding CC, are (and should be) implicitly set to x86-64.
# It IS possible to set host to ARM or RISC-V when cross-compiling for either, but this requires mounting to be disabled with --disable-grub-mount.

echo "Building GRUB..."

if [[ "$config" == "x86" ]]; then
    ./configure --target=x86_64 --with-platform=efi

elif [[ "$config" == "arm" ]]; then
    ./configure --target=aarch64 --with-platform=efi TARGET_CC=aarch64-linux-gnu-gcc TARGET_OBJCOPY=aarch64-linux-gnu-objcopy TARGET_STRIP=aarch64-linux-gnu-strip

elif [[ "$config" == "riscv" ]]; then
    ./configure --target=riscv64 --with-platform=efi TARGET_CC=riscv64-linux-gnu-gcc TARGET_OBJCOPY=riscv64-linux-gnu-objcopy TARGET_STRIP=riscv64-linux-gnu-strip

else
    echo "Not a supported config."
    exit 1
fi

make -j$(nproc) >> make.log
grep -a -E "gcc.*\.${ext}($|[ ;\"])|Entering directory|Leaving directory" make.log | sed 's/$/ -save-temps/' >> run-$config.sh

# Get rid of preprocess-only lines
grep -v -E "gcc -E.*\.${ext}" run-$config.sh >> tmp && mv tmp run-$config.sh

python3 $script/cd.py < run-$config.sh > tmp && mv tmp run-$config.sh
