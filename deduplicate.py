# This script performs deduplication of identical header code (blocks) that appear across
# different preprocessed files. It always keeps directives, even if its related block is
# duplicate and thus removed. While this somewhat increases the complexity, directives
# are necessary for when we later - using separate scripts - perform the following:
#
# Normalization: Identical directives enable identififcation of near-identical blocks.
# Pruning: Removal of all line directives helps us examine their impact on line counts.


import os
import hashlib

hashes = set()
blocks = set()

trash = []      # Lots of directives.

def main(directory):
    numdirs = 0
    numfiles = 0
    totaldirs = sum(len(dirs) for _, dirs, _ in os.walk(directory))

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

                if line.startswith("# "):
                    directive = line

                    # Go through all code (if any) below a header (.h) inclusion
                    if '.h"' in line:
                        i += 1
                        if i >= len(lines): break
                        line = lines[i]

                        if line.startswith("# "):
                            #trash.append(directive)
                            reset = True

                        else:
                            reset = False

                        while not reset:
                            if not line.startswith("# "):
                                block.append(line)

                                opening += line.count('{')
                                closing += line.count('}')
                                depth   += line.count('{') - line.count('}')

                                i += 1
                                if i >= len(lines): break
                                line = lines[i]

                            else:
                                if depth != 0 and opening != closing:
                                    i += 1
                                    if i >= len(lines): break
                                    line = lines[i]
                                    #trash.append(directive)

                                else:
                                    block = "".join(block)
                                    hash = hashlib.sha256(block.encode()).hexdigest()
                                    if hash not in hashes:
                                        hashes.add(hash)

                                        # Need directive for normalization
                                        segment = directive + block
                                        blocks.add(segment)

                                    #else:
                                    #    trash.append(directive)

                                    block = []
                                    reset = True

                    # Go through all code (if any) below a source (.c) inclusion
                    elif '.c"' or '.cc"' or '.cpp"' in line:
                        i += 1
                        if i >= len(lines): break
                        line = lines[i]
                        #trash.append(directive)

                        while not line.startswith("# "):
                            block.append(line)
                            i += 1
                            if i >= len(lines): break
                            line = lines[i]
                            #print(i+1, file, line)

                        if block:   # != []
                            name = os.path.splitext(path)[0]
                            path = name + ".c" # FIX!!!
                            fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND)
                            os.write(fd, "".join(block).encode())
                            os.close(fd)
                            block.clear()

                    else:
                        #trash.append(directive)
                        i += 1

                else:
                    #trash.append(line)
                    i += 1

            numfiles += 1

        for dir in dirs:
            numdirs += 1
            percent = (numdirs / totaldirs) * 100
            print(f"[{numdirs}/{totaldirs}] ({percent:.2f}%) Now entering: {os.path.join(root, dir)}")

    print("Number of files:", numfiles)
    print("Number of hashes:", len(hashes))

    path = directory + "/includes.h"
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND)

    # Write header blocks
    for block in blocks:
        os.write(fd, block.encode())

    os.close(fd)


if __name__ == "__main__":
    path = "./"
    main(path)
