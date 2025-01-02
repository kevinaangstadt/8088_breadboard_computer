# CRC-16 Checks on Contents of ROM

This directory contains a ROM that will perform a CRC check of itself and print
the results to the LCD screen.  It will require the following to be working:

- 8284A clock generator
- 80C88 processor
- Address latching
- Data buffering
- IO/M̅ decoding and buffering
- Upper 8K ROMs
- 80C55 PIO
- 1602 LCD Module