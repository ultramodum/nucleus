#!/bin/bash

prefix=$HOME/thesis/

if [[ "$#" -ne 3 ]]; then
    echo "Usage:   $0 <path> <config> <type>"
    echo "Example: ./run.sh kernels/linux/ tiny i"
    exit 1
fi

suffix="$1"
config="$2"
type="$3"

if   [ "$type" = "i" ]; then ext="c"
elif [ "$type" = "s" ]; then ext="S"
else echo "[NOTICE] Type must be either 'i' or 's'!"; exit 1; fi

affix=$prefix/$suffix/
stages=$affix/stages/
script=$prefix/script/
configs=$script/configs/

cd $affix 2>/dev/null || { echo "[NOTICE] No such directory."; exit 1; }
#: > run-$type.sh

############### KERNELS ###############
if [[ "$suffix" == *linux* ]]; then
    source $configs/kernels/linux.sh

elif [[ "$suffix" == *unikraft* ]]; then
    source $configs/kernels/unikraft.sh

elif [[ "$suffix" == *genode* ]]; then
    source $configs/kernels/genode.sh

elif [[ "$suffix" == *zephyr* ]]; then
    source $configs/kernels/zephyr.sh

elif [[ "$suffix" == *fiwix* ]]; then
    make V=1 -j$(nproc) >> make.log
    source $script/pathify.sh

############### FIRMWARE ###############
elif [[ "$suffix" == *coreboot* ]]; then
    source $configs/firmware/coreboot.sh

elif [[ "$suffix" == *libreboot* ]]; then
    source $configs/firmware/libreboot.sh

elif [[ "$suffix" == *tianocore* ]]; then
    source $configs/firmware/tianocore.sh

############### BOOTLOADERS ###############
elif [[ "$suffix" == *grub* ]]; then
    source $configs/bootloader/grub.sh

elif [[ "$suffix" == *uboot* ]]; then
    source $configs/bootloader/uboot.sh

elif [[ "$suffix" == *limine* ]]; then
    source $configs/bootloader/limine.sh

elif [[ "$suffix" == *barebox* ]]; then
    source $configs/bootloader/barebox.sh

############### CRYPTOLIBS ###############
elif [[ "$suffix" == *openssl* ]]; then
    source $configs/cryptolib/openssl.sh

elif [[ "$suffix" == *wolfssl* ]]; then
    source $configs/cryptolib/wolfssl.sh

elif [[ "$suffix" == *mbedtls* ]]; then
    source $configs/cryptolib/mbedtls.sh

else
    echo "[NOTICE] Path must contain supported software:"
    echo "- KERNELS: Linux, Unikraft, Genode, Fiwix"
    echo "- FIRMWARE: Coreboot, Libreboot, Tianocore"
    echo "- BOOTLOADERS: GRUB, Uboot, Limine, Barebox"
    echo "- CRYPTOLIBRARIES: OpenSSL, WolfSSL, MbedTLS"
    exit 1
fi


source $script/output.sh

mkdir -p ./dump/
mkdir -p ./stages/dedup/$type/
mkdir -p ./stages/norm/$type/
mkdir -p ./stages/final/$type/

echo -e "\aPreprocessing..."
: <<'COMMENT'
source $script/traverse.sh
source $script/copy.sh $affix/dump/ $stages/dedup/$type/ i ii

echo -e "\aDeduplicating..."
cd $stages/dedup/$type/
python3 $script/deduplicate.py
source $script/copy.sh . $stages/norm/$type/ c h

echo -e "\aNormalizing..."
cd $stages/norm/$type/
python3 $script/normalize.py includes.h
source $script/copy.sh . $stages/final/$type/ c h

echo -e "\aPruning..."
cd $stages/final/$type/
python3 $script/prune.py includes.h


prepro=$(scc $stages/dedup/$type/ --include-ext i 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
dedup=$(scc $stages/dedup/$type/ --include-ext cpp,cc,c,h 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
norm=$(scc $stages/norm/$type/ --include-ext cpp,cc,c,h 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
final=$(scc $stages/final/$type/ --include-ext cpp,cc,c,h 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
nofpos=$(scc $stages/final/$type/ --include-ext cpp,cc,c 2>/dev/null | awk '/^Total/ {print $(NF-5)}')

echo "SLOC:  $source"
echo "--------------"
echo "PELOC: $prepro"
echo "DELOC: $dedup"
echo "NELOC: $norm"
echo "--------------"
echo "FELOC: $final"
echo "=============="
echo "SNOF:  $nofpre"
echo "ENOF:  $nofpos"
COMMENT
