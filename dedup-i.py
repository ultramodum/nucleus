import os
import hashlib
from collections import Counter

def generate_hash(code_block):
    """Generate a hash for a given code block."""
    return hashlib.sha256(code_block.encode('utf-8')).hexdigest()

def clean_code_block(code_lines):
    """Remove empty/whitespace-only lines and join the rest."""
    cleaned = [line for line in code_lines if line.strip()]
    return ''.join(cleaned)

def is_code_complete(code_lines):
    """Check if the code block has balanced braces."""
    code = ''.join(code_lines)
    return code.count('{') == code.count('}')

def extract_code_blocks(file_path, hash_to_code, track_hashes=True):
    """Extract code blocks and return their hashes. Optionally store them."""
    code_hashes = []
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    current_code_block = []
    in_code_block = False

    for line in lines:
        if line.startswith('#') and '.h' in line:
            if current_code_block and is_code_complete(current_code_block):
                cleaned_block = clean_code_block(current_code_block)
                if cleaned_block:
                    block_hash = generate_hash(cleaned_block)
                    code_hashes.append((block_hash, current_code_block.copy()))
                    if track_hashes:
                        hash_to_code.setdefault(block_hash, cleaned_block)
            current_code_block = []
            in_code_block = True
        elif in_code_block:
            if line.startswith('#'):
                if current_code_block and is_code_complete(current_code_block):
                    cleaned_block = clean_code_block(current_code_block)
                    if cleaned_block:
                        block_hash = generate_hash(cleaned_block)
                        code_hashes.append((block_hash, current_code_block.copy()))
                        if track_hashes:
                            hash_to_code.setdefault(block_hash, cleaned_block)
                current_code_block = []
                in_code_block = False
            else:
                current_code_block.append(line)

    if current_code_block and is_code_complete(current_code_block):
        cleaned_block = clean_code_block(current_code_block)
        if cleaned_block:
            block_hash = generate_hash(cleaned_block)
            code_hashes.append((block_hash, current_code_block.copy()))
            if track_hashes:
                hash_to_code.setdefault(block_hash, cleaned_block)

    return code_hashes

def count_hashes_in_directory(directory):
    """Count hash occurrences in all .i files in the given directory."""
    hash_counter = Counter()
    hash_to_code = {}

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.i'):
                file_path = os.path.join(root, file)
                code_hashes = extract_code_blocks(file_path, hash_to_code)
                hash_counter.update(hash for hash, _ in code_hashes)

    return hash_counter, hash_to_code

def remove_frequent_code_blocks(directory, frequent_hashes):
    """Modify files by removing code blocks with high-frequency hashes."""
    for root, _, files in os.walk(directory):
        for file in files:
            if not file.endswith('.i'):
                continue
            file_path = os.path.join(root, file)
            new_lines = []
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()

            current_code_block = []
            in_code_block = False

            i = 0
            while i < len(lines):
                line = lines[i]
                if line.startswith('#') and '.h' in line:
                    new_lines.append(line)
                    current_code_block = []
                    in_code_block = True
                    i += 1
                    continue
                elif in_code_block:
                    if line.startswith('#'):
                        if current_code_block and is_code_complete(current_code_block):
                            cleaned_block = clean_code_block(current_code_block)
                            if cleaned_block:
                                block_hash = generate_hash(cleaned_block)
                                if block_hash not in frequent_hashes:
                                    new_lines.extend(current_code_block)
                        new_lines.append(line)
                        current_code_block = []
                        in_code_block = False
                    else:
                        current_code_block.append(line)
                    i += 1
                else:
                    new_lines.append(line)
                    i += 1

            # Final block
            if current_code_block and is_code_complete(current_code_block):
                cleaned_block = clean_code_block(current_code_block)
                if cleaned_block:
                    block_hash = generate_hash(cleaned_block)
                    if block_hash not in frequent_hashes:
                        new_lines.extend(current_code_block)

            # Overwrite the file with filtered lines
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)

def main(directory):
    """Main entry: count, display, and optionally clean .i files."""
    hash_counter, hash_to_code = count_hashes_in_directory(directory)

    most_common_hashes = hash_counter.most_common(10)

    print("\nTop 10 Most Common Code Blocks:\n" + "=" * 40)
    for idx, (hash_val, count) in enumerate(most_common_hashes, start=1):
        print(f"{idx}. Hash: {hash_val}")
        print(f"   Occurrences: {count}")
        print("   Code block:")
        print("-" * 40)
        print(hash_to_code[hash_val].strip())
        print("-" * 40 + "\n")

    frequent_hashes = {h for h, c in hash_counter.items() if c > 1}
    if frequent_hashes:
        print(f"Removing code blocks with more than 1 occurrence ({len(frequent_hashes)} block hashes)...")
        remove_frequent_code_blocks(directory, frequent_hashes)
        print("Done.")

if __name__ == "__main__":
    directory_path = "/home/edward/Documents/Thesis/dedup/i/"
    main(directory_path)
