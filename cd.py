#!/usr/bin/env python3
import sys
import re

enter_re = re.compile(r"make\[\d+\]: Entering directory '([^']+)'")
leave_re = re.compile(r"make\[\d+\]: Leaving directory '([^']+)'")

def rewrite_make_output(lines):
    dir_stack = []
    output_lines = []

    for line in lines:
        line = line.rstrip("\n")

        # Handle entering directory
        m = enter_re.search(line)
        if m:
            dir_stack.append(m.group(1))
            continue

        # Handle leaving directory
        m = leave_re.search(line)
        if m:
            if dir_stack and dir_stack[-1] == m.group(1):
                dir_stack.pop()
            continue

        # Handle compile line (or any command)
        if line.startswith("gcc "):
            if dir_stack:
                output_lines.append(f"cd {dir_stack[-1]}")
            output_lines.append(line)
            continue

        # Preserve any other lines if needed
        # (you can comment this out if you want only gcc lines)
        output_lines.append(line)

    return output_lines

if __name__ == "__main__":
    lines = sys.stdin.readlines()
    rewritten = rewrite_make_output(lines)
    for out_line in rewritten:
        print(out_line)
