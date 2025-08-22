import os
import hashlib

hashes = set()
blocks = set()

def main(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()

            block = []

            opening = 0     # Not strictly necessary,
            closing = 0     # but boosts readability.
            depth = 0       # This alone does the job.
            pos = 0

            # Go through file
            while pos < len(lines):
                line = lines[pos]   # Move one up?

                # Go through all code (if any) below a header (.h) inclusion
                if line.startswith("# ") and line[2:].split(maxsplit=1)[0].isdigit() and '.h"' in line:
                    pos += 1

                    if pos >= len(lines):
                            break

                    line = lines[pos]

                    if line.startswith("# ") and line[2:].split(maxsplit=1)[0].isdigit():
                        reset = True

                    else:
                        reset = False

                    while reset == False:
                        if not (line.startswith("# ") and line[2:].split(maxsplit=1)[0].isdigit()):
                            block.append(line)

                            opening += line.count('{')
                            closing += line.count('}')
                            depth   += line.count('{') - line.count('}')

                            pos += 1

                            if pos >= len(lines):
                                break

                            line = lines[pos]

                        else:
                            if depth != 0 and opening != closing:
                                pos += 1

                                if pos >= len(lines):
                                    break

                                line = lines[pos]

                            else:
                                block = "\n".join(block)
                                hash = hashlib.sha256(block.encode('utf-8')).hexdigest()
                                if hash not in hashes:
                                    hashes.add(hash)
                                    blocks.add(block)

                                block = []
                                reset = True

                # Go through all code (if any) below a source (.c) inclusion
                elif line.startswith("# ") and line[2:].split(maxsplit=1)[0].isdigit() and '.c"' in line:
                    pos += 1

                    if pos >= len(lines):
                            break

                    line = lines[pos]

                    while not (line.startswith("# ") and line[2:].split(maxsplit=1)[0].isdigit()):
                        block.append(line)
                        pos += 1

                        if pos >= len(lines):
                            break

                        line = lines[pos]

                    if block:   # != []
                        name = os.path.splitext(path)[0]
                        path = name + ".c"
                        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND)
                        os.write(fd, "".join(block).encode())
                        os.close(fd)
                        block.clear()

                else:
                    pos += 1    # Discard lines such as <built-in> / <command-line>

        path = root + "includes.h"
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND)

        # Write header blocks
        for block in blocks:
            block_text = block
            os.write(fd, block_text.encode("utf-8"))

        os.close(fd)


if __name__ == "__main__":
    path = "./"
    main(path)
