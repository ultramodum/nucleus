#!/bin/bash

cd /home/edward/Documents/Thesis/kernel/linux/...
mkdir ./dump/

make V=1 -j16 clean all | grep "\.c " | grep gcc | while read -r line; do
    cmd="${line%%.c*}.c -save-temps -dumpdir ./dump/"
    echo "$cmd" >> make-i.sh
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
