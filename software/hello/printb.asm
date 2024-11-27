; set up the PIO Port B for output
; Configure the LCD for 4-bit mode
; Output a "B" to the LCD

; NOTE: the PIO lives at IO port 0x4000
; address 0x00 PORT A
; address 0x01 PORT B
; address 0x02 PORT C
; address 0x03 Control Word

E equ 0x01
RS equ 0x04
RW equ 0x02

PORTA equ 0x4000
PORTB equ 0x4001
PORTC equ 0x4002
CTRL equ 0x4003

BITS 16

; the upper ROM chip starts at address 0xFE000
org 0xFE000

  ; set up GROUP A/B for MODE 0 output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; set 8-bit mode; 2-line display; 5x8 font
  mov al, 0b00111000
  mov dx, PORTB
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, CTRL
  out dx, al
wait1:
  mov al, RW
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E | RW
  out dx, al
  ; read the busy flag
  mov dx, PORTB
  in al, dx
  and al, 0x80
  jne wait1
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; display on; cursor on; blink off
  mov al, 0b00001110
  mov dx, PORTB
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, CTRL
  out dx, al
wait2:
  mov al, RW
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E | RW
  out dx, al
  ; read the busy flag
  mov dx, PORTB
  in al, dx
  and al, 0x80
  jne wait2
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; increment and shift cursor; don't shift display
  mov al, 0b00000110
  mov dx, PORTB
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, CTRL
  out dx, al
wait3:
  mov al, RW
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E | RW
  out dx, al
  ; read the busy flag
  mov dx, PORTB
  in al, dx
  and al, 0x80
  jne wait3
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; Clear display
  mov al, 0b00000001
  mov dx, PORTB
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, CTRL
  out dx, al
wait4:
  mov al, RW
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E | RW
  out dx, al
  ; read the busy flag
  mov dx, PORTB
  in al, dx
  and al, 0x80
  jne wait4
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

printb:
  ; send an ASCII "B" to the LCD
  mov al, 'B'
  mov dx, PORTB
  out dx, al
  ; set RS bit to send data
  mov al, RS
  mov dx, PORTC
  out dx, al
  ; set E bit to send data
  mov al, RS | E
  out dx, al
  ; clear E bit
  mov al, RS
  out dx, al
  ; clear RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, CTRL
  out dx, al
wait5:
  mov al, RW
  mov dx, PORTC
  out dx, al
  ; set E bit to send instruction
  mov al, E | RW
  out dx, al
  ; read the busy flag
  mov dx, PORTB
  in al, dx
  and al, 0x80
  jne wait5
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; print another B
  jmp printb

  ; output 0s to PORT B
  mov al, 0
  mov dx, PORTB
  out dx, al

  ; output 0s to PORT C
  mov al, 0
  mov dx, PORTC
  out dx, al

  ; halt the CPU
  hlt

; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  cli ; clear interrupts
  jmp 0xFE00:0x0000

; pad to 0xFFFFF
; $ represents the current address, and $$ represents the starting address
  times (0x100000 - 0xFE000) - ($ - $$) db 0
