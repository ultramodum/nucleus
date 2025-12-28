# This script ensures that a file has the correct path before the corresponding
# compile command is run. Note that this is a half-way solution - include paths
# may still be incomplete. Unless experimenting, always use the traverse script!

#!/bin/bash

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
