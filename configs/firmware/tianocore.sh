#!/bin/bash

echo "Building Tianocore..."

make -C BaseTools
. edksetup.sh

if [[ "$conf" == "x86" ]]; then
        build -p OvmfPkg/OvmfPkgX64.dsc -a X64 -t GCC5 -b RELEASE | grep -E "gcc.*\.${ext}$" | while read -r line; do
        cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
        echo "$cmd" >> make-$type.sh
    done

elif [[ "$conf" == "arm" ]]; then
    echo "ok"

else
    echo "Not a supported config."
    exit 1
fi
