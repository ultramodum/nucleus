#!/usr/bin/env bash

while read -r line; do
    src=$(echo "$line" | sed -n 's/.* \([^ ]*\)\.c.*/\1.c/p')
    rel=${src#$HOME/thesis/kernels/genode/}
    obj="dump/${rel%.c}.o"
    mkdir -p "$(dirname "$obj")"
    echo "$line" | sed "s@-o [^ ]\+@-o $obj@"
done < temp.sh > run-i.sh
