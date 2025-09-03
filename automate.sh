#!/bin/bash

if [[ "$#" -ne 3 ]]; then
    echo "Usage:   $0 <software-path> <config> <type>"
    echo "Example: ./automate.sh kernel/linux/tiny/ tiny i"
    exit 1
fi

path="$1"
conf="$2"
type="$3"

if [[ "$conf" != "tiny" && "$conf" != "x86" && "$conf" != "arm" && "$conf" != "riscv" && "$conf" != "full" ]]; then
    echo "Architecture must be either 'tiny', 'x86', 'arm', 'riscv' or 'full'!"
    exit 1
fi

if [[ "$type" != "i" && "$type" != "s" ]]; then
    echo "Type must be either 'i' or 's'!"
    exit 1
fi

home="/home/edward/Documents/Thesis/"
full=$home/$path
script=$home/script
configs=$script/configs

cd $full
mkdir -p stages/

[ -d ./dump/ ] && rm -rf ./dump/* || mkdir -p ./dump/
#[ -d $home/dedup/$type/ ] && rm -rf $home/dedup/$type/* || mkdir -p $home/dedup/$type/
rm -rf stages/dedup/$type/ && mkdir -p stages/dedup/$type/
rm -rf stages/norm/$type/  && mkdir -p stages/norm/$type/
rm -rf stages/final/$type/ && mkdir -p stages/final/$type/

if [ "$type" = "i" ]; then
    ext="c"
else
    ext="S"
fi

: > make-$type.sh

skip=false

############### KERNELS ###############
if [[ "$path" == *linux* ]]; then
    source $configs/kernel/linux.sh

elif [[ "$path" == *unikraft* ]]; then
    source $configs/kernel/unikraft.sh

elif [[ "$path" == *genode* ]]; then
    source $configs/kernel/genode.sh
    $type="ii"

elif [[ "$path" == *fiwix* ]]; then
    make V=1 -j$(nproc) >> make.log
    $script/pathify.sh
    skip=true


############### FIRMWARE ###############
elif [[ "$path" == *coreboot* ]]; then
    $configs/firmware/coreboot.sh

elif [[ "$path" == *libreboot* ]]; then
    $configs/firmware/libreboot.sh

elif [[ "$path" == *tianocore* ]]; then
    $configs/firmware/tianocore.sh


############### BOOTLOADERS ###############
elif [[ "$path" == *grub* ]]; then
    $configs/bootloader/grub.sh

elif [[ "$path" == *uboot* ]]; then
    $configs/bootloader/uboot.sh

elif [[ "$path" == *limine* ]]; then
    $configs/bootloader/limine.sh

elif [[ "$path" == *barebox* ]]; then
    $configs/bootloader/barebox.sh


############### CRYPTOLIBS ###############
elif [[ "$path" == *openssl* ]]; then
    $configs/cryptolib/openssl.sh

elif [[ "$path" == *wolfssl* ]]; then
    $configs/cryptolib/wolfssl.sh

elif [[ "$path" == *mbedtls* ]]; then
    $configs/cryptolib/mbedtls.sh


else
    echo "Path does not contain a supported piece of software, such as 'linux'."
    exit 1
fi

echo -e "\a"

if ! $skip; then
    chmod +x make-$type.sh
    echo "Compiling relevant files..."
    $script/wrapper.sh
    echo -e "\a"
fi

cd ./dump/
prepro=$(scc --include-ext i 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
find . -name "*.$type" -exec cp {} $full/stages/dedup/$type/ \;

echo "Deduplicating..."
cd $full/stages/dedup/$type/
python3 $script/deduplicate.py
dedup=$(scc --include-ext c,h 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
find . -name "includes.h" -exec cp {} $full/stages/norm/$type/ \;
find . -name "*.$ext" -exec cp {} $full/stages/norm/$type/ \;

echo "Normalizing..."
cd $full/stages/norm/$type/
python3 $script/normalize.py includes.h
norm=$(scc --include-ext c,h 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
find . -name "includes.h" -exec cp {} $full/stages/final/$type/ \;
find . -name "*.$ext" -exec cp {} $full/stages/norm/$type/ \;

echo "Pruning..."
cd $full/stages/final/$type/
python3 $script/prune.py includes.h
final=$(scc --include-ext c,h 2>/dev/null | awk '/^Total/ {print $(NF-1)}')

nofpost=$(scc --include-ext c,h 2>/dev/null | awk '/^Total/ {print $(NF-5)}')

echo
#echo "Total LOC source:       $source"
echo "-------------------------------"
echo "Total LOC preprocessed: $prepro"
echo "Total LOC deduplicated: $dedup"
echo "Total LOC normalized:   $norm"
echo "-------------------------------"
echo "Total LOC final:        $final"
echo
#echo "Total NOF before:       $nofpre"
echo "Total NOF after:        $nofpost"
echo
