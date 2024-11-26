# Basic Bring-Up Assembly Programs

This directory contains very simple programs for testing if the CPU is running.
It will require the following to be working:

- 8284A clock generator
- 80C88 processor
- Address latching
- Data buffering
- IO/M̅ decoding and buffering
- Upper 8K ROM

## Halt.asm
First, let's just make sure that the reset vector is loadable. The program
will execute two instructions:

```asm
cli
hlt
```

One way to check for proper behavior is to trigger a scope on the falling edge
of the reset signal and watch the ALE pin of the processor. There should be four
(4) pulses before ALE stops.

## Jmphalt.asm
Once you can halt the processor, it would be good to check more of the address
decoding. This assembly routine move the `hlt` instruction to address `0xFE000`,
which is the start of the upper ROM. We then jump to this instruction after
clearing interrupts.

You should see similar behavior as above, but with a few more ALE pulses.

# Making and Uploading
These assembly programs were written with NASM syntax. You will need both `nasm`
and `minipro` to compile and upload.  The entire process can be done by
executing one of the following:

```sh
make upload halt.bin
make upload jmphalt.bin
```