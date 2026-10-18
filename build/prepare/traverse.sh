#!/usr/bin/env bash

echo "[INFO] Making sure correct directories are entered..."
count=0

while IFS= read -r cmd; do
    count=$((count + 1))
    echo "LINE NUMBER: $count"

    cfile=$(echo "$cmd" | grep -o '[^ ]*\.c' | head -n1)

    if [[ "$cfile" == /home/* ]]; then
        echo ">>> Absolute path detected ($cfile), running in current dir"
        echo ">>> Running: $cmd"
        $cmd
        continue
    fi

    fullpath=$(find . -type f -path "*/$cfile" | head -n1)

    if [ -z "$fullpath" ]; then
        echo "[ERROR] Could not locate $cfile in the source tree!" >&2
        continue
    fi

    cfile_found=${fullpath#./}
    prefix=${cfile_found%"$cfile"}
    dir_to_cd="${prefix%/}"

    if [ -n "$dir_to_cd" ]; then
        echo ">>> cd into $dir_to_cd"
        ( cd "$dir_to_cd" && echo ">>> Running: $cmd" && eval "$cmd" )
    else
        echo ">>> Already in correct directory, running: $cmd"
        eval "$cmd"
    fi

done < run-$config.sh
