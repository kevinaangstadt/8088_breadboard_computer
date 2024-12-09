; Print Hello, World! to the LCD

BITS 16

; set up the PIO Port B for output

; NOTE: the PIO lives at IO port 0x4000
; address 0x00 PORT A
; address 0x01 PORT B
; address 0x02 PORT C
; address 0x03 Control Word

PORTA equ 0x4000
PORTB equ 0x4001
PORTC equ 0x4002
CTRL equ 0x4003

; NOTE: the timer lives at IO port 0x2000

CNT_A equ 0x2000
CNT_B equ 0x2001
CNT_C equ 0x2002
TIMER_CTL equ 0x2003

; the upper ROM chip starts at address 0xFE000
org 0xFE000

  ; set up GROUP A/B for MODE 0 output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; set up timer C for square wave output
  ; input clock is 4 MHz
  ; we want a 440 Hz square wave
  ; so we need a count of 9091?

  ; control word format is
  ; D7  D6  D5  D4  D3 D2 D1 D0
  ; SC1 SC0 RW1 RW0 M2 M1 M0 BC
  ; SC1 SC0 = 10 for counter C
  ; RW1 RW0 = 11 to write LSB then MSB
  ; M2 M1 M0 = 011 for square wave output (mode 3)
  ; BC = 0 for binary counting
  mov al, 0b10110110
  mov dx, TIMER_CTL
  out dx, al

  ; write the count to the timer
  mov ax, 9091
  mov dx, CNT_C
  out dx, al
  mov al, ah
  out dx, al

  ; set the GATE bit to start the timer
  ; set the Speaker bit to enable the speaker
  mov al, 0x03
  mov dx, PORTA
  out dx, al

repeat:
  ; delay for a while
  mov cx, 0xffff  ; 65536 loops
delay_loop1:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop delay_loop1 ; 17 cycles

  ; turn off the speaker
  mov al, 0x01
  out dx, al

  ; delay for a bit
  mov cx, 0xffff  ; 65536 loops
delay_loop2:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop delay_loop2 ; 17 cycles

  ; turn on the speaker
  mov al, 0x03
  out dx, al

  jmp repeat

  ; halt the CPU
  hlt

  ; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  cli ; clear interrupts
  jmp 0xFE00:0x0000

  ; pad to 0xFFFFF
  ; $ represents the current address, and $$ represents the starting address
  times (0x100000 - 0xFE000) - ($ - $$) db 0