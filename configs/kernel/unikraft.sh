#!/bin/bash

echo "Building Unikraft..."

make -j$(nproc)

find build/ -name '*.cmd' | xargs grep gcc | grep "\.${ext} " | while read -r line; do
    cmd=$(echo "$line" | sed -E 's/^.*\bgcc/gcc/')

    if   [[ "$conf" == "x86" ]]; then
            new_cmd="$cmd -save-temps -dumpdir ./dump/"

    elif [[ "$conf" == "arm" ]]; then
            new_cmd="aarch64-linux-gnu-$cmd -save-temps -dumpdir ./dump/"

    else
        echo "Not a supported config."
        exit 1
    fi

    echo "$new_cmd" >> make-$type.sh
done
