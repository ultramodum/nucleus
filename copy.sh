#!/bin/bash

src=$1
dst=$2

one=$3   # .c / .i
two=$4   # .h / .ii

if [[ "$one" == 'c' ]]; then
    if [[ "$two" != 'h' ]]; then
        echo "[NOTICE] Final argument incorrect."
        exit 1
    fi

elif [[ "$one" == 'i' ]]; then
    if [[ "$two" != 'ii' ]]; then
        echo "[NOTICE] Final argument incorrect."
        exit 1

    fi
else
    echo "[NOTICE] Third argument incorrect."
    exit 1
fi

find "$src" \( -name "*.$one" -o -name "*.$two" \) | while read -r file; do
    rel="${file#$src}"

    # Rename .ii -> .i
    if [[ "$rel" == *.ii ]]; then
        rel="${rel%.ii}.i"
    fi

    new="$dst/$rel"
    mkdir -p "$(dirname $new)"
    cp "$file" "$new"
done
