# This script looks for duplicate line directives and removes them,
# as well as the code that follows below until a new line directive.
#
# Note that this is typically performed after deduplication.


import sys

def main():
    if len(sys.argv) < 2:
        print("Usage: python normalize.py <filename>")
        sys.exit(1)

    file = sys.argv[1]

    directives = set()
    output = []

    with open(file, 'r') as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i]

        if line.startswith("# "):
            output.append(line)

            if line in directives:
                i += 1

                # Skip block entirely until next line directive
                while i < len(lines) and not lines[i].startswith("# "):
                    i += 1

            else:
                directives.add(line)
                i += 1

            continue

        # Keep current line
        output.append(line)
        i += 1

    with open(file, 'w') as f:
        f.writelines(output)

if __name__ == "__main__":
    main()
