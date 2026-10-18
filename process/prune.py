# This script looks for remaining line directives and removes them.
# as well as the code that follows below until a new line directive.
#
# Note that pruning is typically performed after deduplication.
# Recommended order after preprocessed files have been obtained:
# Deduplicate -> Normalize -> Prune

import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python prune.py <filename>")
        sys.exit(1)

    file = sys.argv[1]

    with open(file, "r") as f:
        lines = f.readlines()

    lines = [line for line in lines if not line.startswith("# ")]

    with open(file, "w") as f:
        f.writelines(lines)


if __name__ == "__main__":
    main()