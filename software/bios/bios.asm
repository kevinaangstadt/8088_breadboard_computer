; BIOS for ARC86-based systems 

BITS 16

%include "defs.asm"

; 8KB bios starts at 0xFE000
org 0xFE000

reset:
  ; step 0
  ; disable maskable interrupts
  cli

  ; step 1 
  ; 8088 CPU tests

  %include "post_cpu.asm"

  ; step 2
  ; initialize 8255 PIO (LCD)
  %include "post_pio.asm"

  ; step 3
  ; verify CRC of the BIOS
  ; it is located in the last two bytes of the BIOS
  %include "post_crc.asm"

  ; DEBUG
  ; print P and halt to see if we made it this far
  mov al, 'P'
  ; write the character to the LCD
  mov dx, PIO_PORTB
  out dx, al
  ; set LCD_RS bit to send data
  mov al, LCD_RS
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send data
  mov al, LCD_RS | LCD_E
  out dx, al
  ; clear LCD_E bit
  mov al, LCD_RS
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; we don't care about waiting because we're going to halt anyway
  hlt



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the reset vector                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  jmp 0xF000:0xE000

  ; pad to 0xFFFFE
  ; note that we do this because we will inject 2 Bytes for the CRC at 0xFFFFE
  ; $ represents the current address, and $$ represents the starting address
  times (0xFFFFE - 0xFE000) - ($ - $$) db 0 