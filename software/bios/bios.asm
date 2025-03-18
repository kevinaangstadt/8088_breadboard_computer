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

  ; step 4
  ; base 16K memory test
  %include "post_mem16k.asm"

  ; step 5
  ; zero memory
  ; %include "post_zero.asm"

  ; step 6
  ; initialize PIC
  %include "post_pic.asm"

  ; step 7
  ; initialize the Stack Segment and SP
  ; SS set to 0x0030
  ; SP set to 0x0100
  xor ax, ax
  mov ax, 0x0030
  mov ss, ax
  mov sp, 0x0100
  ; set up the bp
  mov bp, sp

  ; FIXME skipping test of PIC

  ; step 8
  ; test PIT and set up timer 0
  %include "post_pit.asm"

  ; step 9
  ; init/start UART
  %include "post_uart.asm"

  ; step 10
  ; store total RAM in BDA
  ; set DS to 0x0040
  mov ax, 0x0040
  mov ds, ax
  ; set the total RAM size
  mov word [ds:BDA_RAM], RAM_SIZE

  ; step 11
  ; clear the screens
  call fn_clear_lcd
  call fn_uart_clear_screen
  call fn_uart_move_cursor_home

  ; step 12
  ; additional RAM test
  %include "post_mem.asm"

  ; step 13 
  ; interrupt vectors
  %include "post_int.asm"

  ; step 14
  ; detect CF card
  %include "post_cf.asm"

  ; step 15
  ; short beep
  %include "post_beep.asm"

  ; step 16
  ; try to boot
  %include "post_boot.asm"

  ; we don't care about waiting because we're going to halt anyway
halt:
  hlt
  jmp halt

  ; IRQ handlers
  %include "bios_irq.asm"

  ; functions
  %include "bios_fn.asm"

  ; data area for the BIOS
  %include "bios_data.asm"

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