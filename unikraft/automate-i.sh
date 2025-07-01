#!/bin/bash

cd /home/edward/Documents/Thesis/kernel/unikraft/...
mkdir ./dump/

find build/ -name '*.cmd' | xargs grep gcc | grep "\.c " | while read -r line; do
    # Extract everything starting from 'gcc' (preserve gcc and remove preceding path/junk)
    cmd=$(echo "$line" | sed -E 's/^.*\bgcc/gcc/')
    new_cmd="$cmd -save-temps -dumpdir ./dump/"
    echo "$new_cmd" >> make-i.sh
done

chmod +x make-i.sh
./make-i.sh

find ./dump/ -name "*.i" -exec cp {} /home/edward/Documents/Thesis/dedup/i/ \;

cd /home/edward/Documents/Thesis/dedup/i/

total_code_pre=$(scc 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
python3 /home/edward/Documents/Thesis/script/dedup-i.py
total_code_post=$(scc 2>/dev/null | awk '/^Total/ {print $(NF-1)}')

echo "Total lines of code before: $total_code_pre"
echo "Total lines of code after: $total_code_post"
