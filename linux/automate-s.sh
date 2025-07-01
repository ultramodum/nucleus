#!/bin/bash

cd /home/edward/Documents/Thesis/kernel/linux/...
mkdir ./dump/

make V=1 -j16 | grep "\.S " | grep gcc | while read -r line; do
    cmd="${line%%.S*}.S -save-temps -dumpdir ./dump/"
    echo "$cmd" >> make-s.sh
done

chmod +x make-s.sh
./make-s.sh

find ./dump/ -name "*.s" -exec cp {} /home/edward/Documents/Thesis/dedup/s/ \;

cd /home/edward/Documents/Thesis/dedup/s/

total_code_pre=$(scc 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
python3 /home/edward/Documents/Thesis/script/dedup-s.py
total_code_post=$(scc 2>/dev/null | awk '/^Total/ {print $(NF-1)}')

echo "Total lines of code before: $total_code_pre"
echo "Total lines of code after: $total_code_post"
