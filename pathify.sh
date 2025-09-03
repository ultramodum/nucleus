# This script ensures that a file has the correct path before the corresponding
# compile command is run. Note that this is a half-way solution, since include
# paths may still be incomplete. Use wrapper.sh instead as it mitigates this.

#!/bin/bash

# Convert make V=1 output into a runnable compile script with full .c paths
awk '
/Entering directory/ {
    cwd=$NF
    gsub("'"'"'","",cwd)
    next
}
/Leaving directory/ { next }
/^gcc/ {
    for (i=1; i<=NF; i++) {
        if ($i ~ /\.c$/) {
            $i = cwd "/" $i
        }
    }
    print $0, "-save-temps -dumpdir ./dump/"
}
' make.log > make.sh

chmod +x make.sh
./make.sh
