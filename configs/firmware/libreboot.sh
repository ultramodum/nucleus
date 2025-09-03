#!/bin/bash

echo "Building Libreboot..."

./mk -b coreboot qemu_x86_12mb | grep "\.${ext} " | grep gcc | while read -r line; do
    cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
    echo "$cmd" >> make-$type.sh
done
