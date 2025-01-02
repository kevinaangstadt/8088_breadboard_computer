; Calculate the CRC of the ROM while executing from the ROM

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
STRB equ 0x08

PORTA equ 0x4000
PORTB equ 0x4001
PORTC equ 0x4002
CTRL equ 0x4003

; the upper ROM chip starts at address 0xFE000
; org 0xFE000

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform a CRC-16 Check of ROM                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; The CRC-16-IBM algorithm is as follows:
  ; 1. Load the CRC-16 register with 0x0000
  ; 2. For each byte in the ROM, XOR the byte with the CRC-16 register
  ; 3. Shift the CRC-16 register right by 1 bit
  ; 4. If the least significant bit of the CRC-16 register is 1, XOR the CRC-16
  ;    register with 0xA001
  ; 5. Repeat steps 2-4 for each byte in the ROM
  ; 6. The final CRC-16 value is the CRC-16 of the ROM

  ; set the DS to the start of ROM
  xor ax, ax
  or ax, 0xFE00
  mov ds, ax
  
  ; Initialize CRC register to 0x0000
  mov ax, 0x0000

  ; Set the starting address of the ROM
  mov si, 0x0

  ; Set the ending address of the ROM
  ; little endian so 0x1FFE is 0xFE1F
  ;mov di, 0x1FFE
  mov di, 8190
crc_loop: 
  ; XOR the byte with the CRC register
  xor al, [ds:si]

  ; Increment the ROM address
  inc si

  ; Process each bit in the byte
  mov cx, 8
bit_loop:
  ; Shift the CRC register right by 1 bit
  shr ax, 1
  ; If the least significant bit is 1, XOR with 0xA001
  jnc no_xor
  xor ax, 0xA001
no_xor:
  loop bit_loop

  ; Check if we have reached the end of the ROM
  cmp si, di
  ; jump if below
  jb crc_loop

  ; store a copy of the CRC value in BX
  mov bx, ax

  ; compare with the CRC value stored at 0xFFFFE
  mov si, 0x1FFE
  mov ax, [ds:si]

  cmp ax, bx
  jne error

  mov si, passed_str
  jmp output_result

error:
  mov si, failed_str

output_result:

  mov cx, 16

print_crc:

  ; print the result in bx as ASCII
  ; get the upper nibble and add '0'
  mov ax, bx
  sub cx, 4
  shr ax, cl
  and al, 0x0F

  cmp al, 10
  jl add_0
  add al, 'A' - 10
  jmp out_digit

add_0:
  add al, '0'

out_digit:
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
p2:
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
  jne p2
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

  ; loop back to print the next digit
  cmp cx, 0
  ja print_crc
  

print_loop:
  ; load the character into AL
  lodsb

  ; if AL is 0, we're done
  cmp al, 0
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

passed_str: db 0xa, "CRC Passed", 0
failed_str: db 0xa, "CRC Failed", 0

  ; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  cli ; clear interrupts
  jmp 0xFE00:0x0000

  ; pad to 0xFFFFE
  ; note that we do this because we will inject 2 Bytes for the CRC at 0xFFFFE
  ; $ represents the current address, and $$ represents the starting address
  times (0xFFFFE - 0xFE000) - ($ - $$) db 0 
