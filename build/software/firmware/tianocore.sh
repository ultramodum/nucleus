#!/bin/bash

echo "Building Tianocore..."

. edksetup.sh
make -C BaseTools
rm ./Build/ -rf

if [[ "$config" == "x86" ]]; then
    build -p ./OvmfPkg/OvmfPkgX64.dsc -a X64 -t GCC -b RELEASE >> make-$config.log

elif [[ "$config" == "arm" ]]; then
    export GCC_AARCH64_PREFIX=aarch64-linux-gnu-
    build -p ./ArmVirtPkg/ArmVirtQemu.dsc -a AARCH64 -t GCC -b RELEASE >> make-$config.log

else
    echo "Not a supported config."
    exit 1
fi

grep -a -E "gcc.*\.${ext}($|[ ;\"])" make-$config.log | sed 's/$/ -save-temps/' >> run-$config.sh
