#!/usr/bin/env bash
set -euo pipefail

while IFS= read -r line; do
    echo "[INFO] Running: $line"
    if ! eval "$line" 2>err.log; then
        if grep -q "fatal error: .*: No such file or directory" err.log; then
            echo "[WARN] Fatal error detected."

            fixed=$(echo "$line" | sed -E 's@[[:space:]]-o[[:space:]]+[^[:space:]]+@@')

            echo "[INFO] Retrying without -o: $fixed"
            if eval "$fixed"; then
                echo "[SUCCESS] Retried command executed correctly."
            else
                echo "[ERROR] Retried command also failed!"
                exit 1
            fi
        else
            echo "[ERROR] Command failed for another reason. See err.log."
            cat err.log
            exit 1
        fi
    fi
done < make-i.sh
