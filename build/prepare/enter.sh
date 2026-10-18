# This script ensures that the correct directory is entered before running the
# corresponding compile command. Always use this instead of fixing file paths.

#!/usr/bin/env bash

home=/home/edward/thesis/.../

while IFS= read -r line; do
    cd $home
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    echo -e "[RUN] $line"

    # Run compile command
    if ! output=$($line 2>&1); then
        echo "$output"

        # Extract file (including any preceding directories) from the error
        miss=$(echo "$output" \
                  | grep -oE "fatal error: [^:]+: No such file or directory" \
                  | awk '{print $3}' \
                  | sed 's/:$//' \
                  | head -n1)

        if [[ -n "$miss" ]]; then
            echo "[INFO] Missing file: $miss"

            # Find full relative path to that file
            found=$(find . -path "*/$miss" | head -n1)
            if [[ -z "$found" ]]; then
                echo "[ERROR] Could not locate $miss"
                continue
            fi

            dir1=$(dirname "$found")
            #dir=${dir%/*}   # Might be broken!

            dir2=$(dirname "$miss")
            base2=$(basename "$dir2")

            if [[ "$dir1" == */"$base2" ]]; then
                target=$(dirname "$dir1")  # => ./one
            else
                target="$dir1"
            fi

            echo "[INFO] Retrying in $dir"
            cd $target

            if [[ ! "$line" ]]; then
                echo "[FAILED] Command still failed in $dir"
                exit 1
            fi
        else
            echo "[ERROR] Unknown failure."
            #exit 1
        fi
    fi
done < run.sh

echo -e "\a[SUCCESS] Build finished."
