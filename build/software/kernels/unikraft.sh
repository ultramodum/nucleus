#!/bin/bash

echo "[INFO] Building Unikraft..."

touch .config

if [[ "$config" == "x86" ]]; then
    make "Using x86 configuration..."
    echo "CONFIG_ARCH_X86_64=y" >> .config

elif [[ "$config" == "arm" ]]; then
    echo "Using ARM configuration..."
    echo "CONFIG_ARCH_ARM_64=y" >> .config

else
    echo "Not a supported config."
    exit 1
fi

if [[ "$plat" == "kvm" ]]; then echo "CONFIG_PLAT_KVM=y" >> .config
elif [[ "$plat" == "xen" ]]; then echo "CONFIG_PLAT_XEN=y" >> .config
else echo "Not a supported platform."; exit 1

make olddefconfig
make -j$(nproc)

find build/ -name '*.cmd' | xargs grep -a -E "gcc.*\.${ext}($|[ ;\"])" | while read -r line; do
    cmd=$(echo "$line" | sed -E 's/^.*\bgcc/gcc/')

    if   [[ "$config" == "x86" ]]; then
        new_cmd="$cmd -save-temps"

    elif [[ "$config" == "arm" ]]; then
        new_cmd="aarch64-linux-gnu-$cmd -save-temps"

    else
        echo "[ABORTED] Supported configs: x86, arm"
        rm make-$type.sh
        exit 1
    fi

    echo "$new_cmd" >> make-$type.sh
done
