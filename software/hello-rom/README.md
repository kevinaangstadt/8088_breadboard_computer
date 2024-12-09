# LCD Bring-Up Assembly Programs

> [!CAUTION]
> This directory is still a work in progress. Things are subject to change
> without warning.

This directory contains slightly more sophisticated programs that will start to
perform input/output. It will require the following to be working:

- 8284A clock generator
- 80C88 processor
- Address latching
- Data buffering
- IO/M̅ decoding and buffering
- Upper 8K ROMs
- 80C55 PIO
- 1602 LCD Module

Notably, we only use ROM for these programs, which makes them bulky, but
straight-forward.

## Printb.asm
First, let's just get the LCD up and running. Make sure that the LCD is wired
correctly (i.e., don't reverse the order of the data pins). This program will
initialize the LCD in 8-bit instruction mode. We follow the suggested
initialization timing from Figure 23 of the HD44780U data sheet. This requires
busy-waiting while setting the chip to 8-bit mode 3 times. See
[here](https://en.wikipedia.org/wiki/Hitachi_HD44780_LCD_controller#Mode_selection)
for a discussion of why this is necessary.

You should see a B print out with the cursor at the next cell.

## Hello-rom.asm
This program isn't fancy. It just extends `Printb.asm` to print the usual "Hello, World!" message.


# Making and Uploading
These assembly programs were written with NASM syntax. You will need both `nasm`
and `minipro` to compile and upload.  The entire process can be done by
executing one of the following:

```sh
make upload halt.bin
make upload jmphalt.bin
```