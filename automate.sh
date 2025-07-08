#!/bin/bash

if [ "$#" -ne 2 ] || [[ "$1" != "i" && "$1" != "s" ]]; then
  echo "Usage: $0 [i|s] <kernel-path>"
  exit 1
fi

arg="$1"
path="$2"

home="/home/edward/Documents/Thesis/"

cd $home/kernel/$path
[ -d ./dump/ ] && rm -rf ./dump/* || mkdir -p ./dump/
[ -d $home/dedup/$arg/ ] && rm -rf $home/dedup/$arg/* || mkdir -p $home/dedup/$arg/

if [ "$arg" = "i" ]; then
  ext="c"
else
  ext="S"
fi

: > make-$arg.sh

if [[ "$path" == *linux* ]]; then
    make V=1 -j16 | grep "\.${ext} " | grep gcc | while read -r line; do
        cmd="${line%%.${ext}*}.${ext} -save-temps -dumpdir ./dump/"
        echo "$cmd" >> make-$arg.sh
    done
elif [[ "$path" == *unikraft* ]]; then
    find build/ -name '*.cmd' | xargs grep gcc | grep "\.${ext} " | while read -r line; do
        cmd=$(echo "$line" | sed -E 's/^.*\bgcc/gcc/')
        new_cmd="$cmd -save-temps -dumpdir ./dump/"
        echo "$new_cmd" >> make-$arg.sh
    done
else
    echo "Path contains neither 'linux' nor 'unikraft'."
    exit 1
fi

chmod +x make-$arg.sh
./make-$arg.sh

find ./dump/ -name "*.$arg" -exec cp {} $home/dedup/$arg/ \;

cd $home/dedup/$arg/

total_code_pre=$(scc 2>/dev/null | awk '/^Total/ {print $(NF-1)}')
python3 $home/script/dedup.py $arg
total_code_post=$(scc 2>/dev/null | awk '/^Total/ {print $(NF-1)}')

echo "Total lines of code before: $total_code_pre"
echo "Total lines of code after: $total_code_post"
