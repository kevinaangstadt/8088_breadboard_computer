; Print Hello, World! to the LCD
; This uses only ROM, but at least does some looping over a string

BITS 16

; set up the PIO Port B for output
; Configure the LCD for 8-bit mode

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

; the upper ROM chip starts at address 0xFE000
org 0xFE000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize the LCD                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; set up GROUP A/B for MODE 0 output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; See the LCD datasheet for the initialization sequence
  ; Figure 23 on page 45 of the HD44780U datasheet for 8-Bit Interface Initialization

  ; busy wait for 40ms to allow the LCD to power up
  ; at 8Mhz, 1 cycle is 125ns meaning we need to busy wait for 320,000 cycles
  ; 320,000 cycles / 4 cycles per loop = 80,000 loops
  mov cx, 12000  ; 40000 loops
delay_loop1:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop delay_loop1 ; 17 cycles to decrement and jump if not zero

  ; initialize with 8-bit mode with 3 commands 0x00110000
  mov al, 0b00110000
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

  ; wait for the LCD to process the instruction (more than 4.1ms)
  ; at 8Mhz, 1 cycle is 125ns meaning we need to busy wait for at least 32,800 cycles
  ; we will busy wait for 40,000 cycles
  mov cx, 1200  ; 10000 loops
delay_loop2:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop delay_loop2 ; 17 cycles

  ; initialize a second time with 8-bit mode with 3 commands 0x00110000
  mov al, 0b00110000
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

  ; wait for the LCD to process the instruction (more than 100us)
  ; at 8Mhz, 1 cycle is 125ns meaning we need to busy wait for at least 800 cycles
  ; we will busy wait for 1000 cycles
  mov cx, 35    ; 34 loops
delay_loop3:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop delay_loop3 ; 17 cycles

  ; initialize a third and final time time with 8-bit mode with 3 commands 0x00110000
  mov al, 0b00110000
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
wait6:
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
  jne wait6
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the LCD with our desired settings                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

  ; pause for about a bit
  mov cx, 0xffff  ; 65536 loops
delay_loop4:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop delay_loop4 ; 17 cycles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print "Hello, World!" to the LCD                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the DS to the start of ROM
  mov ax, 0xFE00
  mov ds, ax
  ; set SI to the address of the string
  mov si, hello_str
print_loop:
  ; load the character into AL
  lodsb
  ; if AL is 0, we're done
  ; this bit-wise and's the AL register against itself
  ; and sets the zero flag if the result is zero
  test al, al
  jz done

  ; write the character to the LCD
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
p1:
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
  jne p1
  mov al, 0
  mov dx, PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, CTRL
  out dx, al

  ; output 0s to PORT B
  mov al, 0
  mov dx, PORTB
  out dx, al

  ; output 0s to PORT C
  mov al, 0
  mov dx, PORTC
  out dx, al

  ; loop back to print the next character
  jmp print_loop

done:
  ; we are done with the loop, so we can just halt the CPU
  ; halt the CPU
  hlt

hello_str: db "Hello, World!", 0

  ; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  cli ; clear interrupts
  jmp 0xFE00:0x0000

  ; pad to 0xFFFFF
  ; $ represents the current address, and $$ represents the starting address
  times (0x100000 - 0xFE000) - ($ - $$) db 0