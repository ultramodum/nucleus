for each file in directory
	for each line in file

        # Write only one instance of each unique header block into dedicated file
		if line starts with "# <number>" AND contains ".h"  # while instead?
			line++

            if line starts with "# <number>"
                reset = true
                line--  # Assuming "for each line in file" loop increments line

            else
                reset = false

            # Go through each line in block
			while !reset
				if line does not start with "# <number>"
					block += line

					for each time line contains '{'     opening += 1
					for each time line contains '}'     closing += 1
                    
                    line++

				else
					if opening != closing
						if file in line has same name (INCLUDING .h) as file in previous line containing ".h"
							line++

						else
                            Print: "FIX THIS! Fragmented blocks apparently don't always follow each other."
                            # break from while loop (continue?)

					else
						hash = encode(block)
                        if hash not in hashes
                            hashes.add(hash)
                            write block into dedicated header file

                        line--  # Assuming "for each line in file" loop increments line
						block.empty()
                        reset = true
			done

        # Write all included code from .c file into new file ending with .c (PERFECT LOGIC - NO NEED TO RENAME LATER!)
		else if line starts with "# <number>" AND contains ".c"
			line++

			while line does not start with "# <number>"
                write line to .c file
				line++
			done

            # To increment or not to increment line?

        # Discard all other lines such as instances of "<built-in>" and "<command-line>"
		else if line starts with "# <number>"
            Do nothing... Next line...

        else if line does not start with "# <number>"
            Do nothing... Next line...

        else
            Print: This should not happen...
	done
done