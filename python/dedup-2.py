import os
import hashlib

def hash_block(block_lines):
    """Return SHA256 hash of a block (ignoring trailing/leading whitespace)."""
    block_str = "\n".join(line.rstrip() for line in block_lines).strip()
    return hashlib.sha256(block_str.encode("utf-8")).hexdigest()

def process_file(path, seen_hashes):
    """
    Processes a single .i file.
    Removes duplicate header blocks based on hash, except for the first occurrence.
    Returns True if file was modified.
    """
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    new_lines = []
    i = 0
    modified = False

    while i < len(lines):
        line = lines[i]
        # Detect header start
        if line.startswith("#") and ".h" in line:
            block_lines = []
            header_line = line
            i += 1
            # Capture block until next line starting with '#' or EOF
            while i < len(lines) and not lines[i].startswith("#"):
                block_lines.append(lines[i])
                i += 1

            h = hash_block(block_lines)
            if h in seen_hashes:
                # Duplicate — skip writing it
                modified = True
                continue
            else:
                seen_hashes.add(h)
                # Keep header line and block
                new_lines.append(header_line)
                new_lines.extend(block_lines)
        else:
            new_lines.append(line)
            i += 1

    if modified:
        with open(path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
    return modified


def process_directory(directory):
    seen_hashes = set()
    for root, _, files in os.walk(directory):
        for fname in files:
            if fname.endswith(".i"):
                path = os.path.join(root, fname)
                changed = process_file(path, seen_hashes)
                if changed:
                    print(f"Modified: {path}")


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <directory>")
        sys.exit(1)
    process_directory(sys.argv[1])
