# Verify RAM and ROM

This directory contains a ROM that will perform a CRC check of itself and print
the results to the LCD screen.  

It will then check all the RAM on board for correct behavior.

It will require the following to be working:

- 8284A clock generator
- 80C88 processor
- Address latching
- Data buffering
- IO/M̅ decoding and buffering
- Upper 8K ROM
- Upper and Lower RAM
- 80C55 PIO
- 1602 LCD Module