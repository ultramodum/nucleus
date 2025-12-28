import os
import hashlib
import glob

def normalize_code_block(lines):
    return '\n'.join([line.rstrip() for line in lines if not line.strip().startswith('# ')]).strip()

def hash_code_block(code):
    return hashlib.sha256(code.encode('utf-8')).hexdigest()

def process_file(file_path, seen_hashes):
    new_lines = []
    current_block = []
    bracket_depth = 0

    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            current_block.append(line)
            bracket_depth += line.count('{') - line.count('}')

            if bracket_depth == 0 and current_block:
                code = normalize_code_block(current_block)
                if code:
                    h = hash_code_block(code)
                    if h not in seen_hashes:
                        seen_hashes.add(h)
                        new_lines.extend(current_block)
                current_block = []

    # Include any leftover lines
    if current_block:
        code = normalize_code_block(current_block)
        if code:
            h = hash_code_block(code)
            if h not in seen_hashes:
                seen_hashes.add(h)
                new_lines.extend(current_block)

    # Overwrite file with deduplicated content
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

def deduplicate_i_files_inplace(file_pattern):
    seen_hashes = set()
    for file_path in glob.glob(file_pattern):
        process_file(file_path, seen_hashes)

if __name__ == "__main__":
    # Example: process all .i files in current directory
    deduplicate_i_files_inplace("*.i")
