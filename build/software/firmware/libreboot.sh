#!/bin/bash

echo "Building Libreboot..."

sudo ./mk dependencies ubuntu

if [[ "$config" == "grub" ]]; then
    echo "Using GRUB payload..."
    ./mk -b grub default
    cd ./src/grub/default/

elif [[ "$config" == "seabios" ]]; then
    echo "Using SeaBIOS payload..."
    ./mk -b seabios default
    cd ./src/seabios/default/

else
    echo "Not a supported payload."
    exit 1
fi

echo "Extracting relevant commands..."
make V=1 -j$(nproc) | grep -a -E "^cc.*\.${ext}($|[ ;\"])" | sed 's/$/ -save-temps/' >> run-$config.sh

# Get rid of preprocess-only lines
grep -v -E "gcc -E.*\.${ext}" run-$config.sh >> tmp && mv tmp run-$config.sh
