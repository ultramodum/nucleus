import os
import hashlib

hashes = set()
blocks = set()

trash = []      # Lots of directives.

def main(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()

            lines = [line for line in lines if line.strip()]
            block = []

            opening = 0     # Not strictly necessary,
            closing = 0     # but boosts readability.
            depth = 0       # This alone does the job.
            i = 0

            # Go through file
            while i < len(lines):
                line = lines[i]   # Move one up?

                # Go through all code (if any) below a header (.h) inclusion
                if line.startswith("# ") and '.h"' in line:
                    i += 1

                    if i >= len(lines):
                        break

                    line = lines[i]

                    if line.startswith("# "):
                        reset = True

                    else:
                        reset = False

                    while not reset:
                        if not block:   # == []
                            block.append(lines[i-1])

                        if not line.startswith("# "):
                            block.append(line)

                            opening += line.count('{')
                            closing += line.count('}')
                            depth   += line.count('{') - line.count('}')

                            i += 1

                            if i >= len(lines):
                                break

                            line = lines[i]

                        else:
                            if depth != 0 and opening != closing:
                                i += 1

                                if i >= len(lines):
                                    break

                                line = lines[i]

                            else:
                                block = "\n".join(block)
                                hash = hashlib.sha256(block.encode('utf-8')).hexdigest()
                                if hash not in hashes:
                                    hashes.add(hash)
                                    blocks.add(block)

                                block = []
                                reset = True

                # Go through all code (if any) below a source (.c) inclusion
                elif line.startswith("# ") and '.c"' in line:
                    i += 1

                    if i >= len(lines):
                            break

                    line = lines[i]

                    while not line.startswith("# "):
                        block.append(line)
                        i += 1

                        if i >= len(lines):
                            break

                        line = lines[i]
                        #print(i+1, file, line)

                    if block:   # != []
                        name = os.path.splitext(path)[0]
                        path = name + ".c"
                        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND)
                        os.write(fd, "".join(block).encode())
                        os.close(fd)
                        block.clear()

                else:
                    trash.append(line)
                    i += 1    # Discard lines such as <built-in> / <command-line>

        path = root + "includes.h"
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND)

        # Write directives
        for line in trash:
            os.write(fd, (line + "\n").encode())

        # Write header blocks
        for block in blocks:
            block_text = block
            os.write(fd, block_text.encode("utf-8"))

        os.close(fd)


if __name__ == "__main__":
    print("Deduplicating...")
    path = "./"
    main(path)
