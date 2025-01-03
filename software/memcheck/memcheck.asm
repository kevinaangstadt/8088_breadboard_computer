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

PORTA equ 0x4000
PORTB equ 0x4001
PORTC equ 0x4002
CTRL equ 0x4003

; the upper ROM chip starts at address 0xFE000 we're going to use 'org' in this
; case because we're going to be hopping around segments and we want to make
; sure that the code is placed at the correct address. That means we'll set the
; segment to 0xF000 so that the code is placed at 0xFE000
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
  or ax, 0xF000
  mov ds, ax
  
  ; Initialize CRC register to 0x0000
  mov ax, 0x0000

  ; Set the starting address of the ROM
  mov si, 0xE000

  ; Set the ending address of the ROM
  mov di, 0xFFFE
crc_loop: 
  ; XOR the byte with the CRC register
  xor al, [ds:si]

  ; Increment the ROM address
  inc si

  ; Process each bit in the byte
  mov cx, 8
crc_bit_loop:
  ; Shift the CRC register right by 1 bit
  shr ax, 1
  ; If the least significant bit is 1, XOR with 0xA001
  jnc crc_no_xor
  xor ax, 0xA001
crc_no_xor:
  loop crc_bit_loop

  ; Check if we have reached the end of the ROM
  cmp si, di
  ; jump if below
  jb crc_loop

  ; store a copy of the CRC value in BX
  mov bx, ax

  ; compare with the CRC value stored at 0xFFFFE
  mov si, 0xFFFE
  mov ax, [ds:si]

  cmp ax, bx
  jne crc_error
  jmp memcheck

crc_error:
  mov si, crc_failed_str

  ; print the result in bx as ASCII
  mov cx, 16

crc_print:
  ; get the upper nibble and add '0'
  mov ax, bx
  sub cx, 4
  shr ax, cl
  and al, 0x0F

  cmp al, 10
  jl crc_add_0
  add al, 'A' - 10
  jmp crc_out_digit

crc_add_0:
  add al, '0'

crc_out_digit:
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
crc_p2:
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
  jne crc_p2
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
  ja crc_print
  

crc_print_loop:
  ; load the character into AL
  lodsb

  ; if AL is 0, we're done
  cmp al, 0
  jz crc_done

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
crc_p1:
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
  jne crc_p1
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
  jmp crc_print_loop

crc_done:
  ; we are done with the loop, so we can just halt the CPU
  jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform a Check of the RAM                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memcheck:

  ; Valid addresses for RAM are 0x00000 to 0xFBFFF
  
  ; Do first 4KiB separately so we can use it for the stack once it is verified
  mov si, 0x0000
  mov di, 0x0FFF

  ; we're going to test AA, 55, 00, FF, 01, 02, 04, 08, 10, 20, 40, 80

  ; set the DS to the start of RAM
  xor ax, ax
  mov ds, ax

memcheck_loop:
  ; write AA to the RAM
  mov al, 0xAA
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with AA
  cmp al, 0xAA
  jne memcheck_error

  ; write 55 to the RAM
  mov al, 0x55
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 55
  cmp al, 0x55
  jne memcheck_error

  ; write 00 to the RAM
  mov al, 0x00
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 00
  cmp al, 0x00
  jne memcheck_error

  ; write FF to the RAM
  mov al, 0xFF
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with FF
  cmp al, 0xF
  jne memcheck_error

  ; write 01 to the RAM
  mov al, 0x01
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 01
  cmp al, 0x01
  jne memcheck_error

  ; write 02 to the RAM
  mov al, 0x02
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 02
  cmp al, 0x02
  jne memcheck_error

  ; write 04 to the RAM
  mov al, 0x04
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 04
  cmp al, 0x04
  jne memcheck_error

  ; write 08 to the RAM
  mov al, 0x08
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 08
  cmp al, 0x08
  jne memcheck_error

  ; write 10 to the RAM
  mov al, 0x10
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 10
  cmp al, 0x10
  jne memcheck_error

  ; write 20 to the RAM
  mov al, 0x20
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 20
  cmp al, 0x20
  jne memcheck_error

  ; write 40 to the RAM
  mov al, 0x40
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 40
  cmp al, 0x40
  jne memcheck_error

  ; write 80 to the RAM
  mov al, 0x80
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with 80
  cmp al, 0x80
  jne memcheck_error

  ; increment the address
  inc si

  ; check if we have reached the end of the first 4KiB
  cmp si, di
  jbe memcheck_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First 4KiB RAM has been verified, so we can use it for the stack             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set up the stack
  xor ax, ax
  mov ss, ax
  ; since we are using the first 4KiB of RAM for the stack, we can set the stack
  ; pointer to the end of the first 4KiB
  mov sp, 0x1000
  mov bp, sp

  ; print that we have verified the first 4KiB of RAM
  call fn_clear_lcd
  mov al, '4'
  call fn_print_char
  mov ax, memcheck_str
  call fn_print_str

  ; check the rest of the RAM
  ; there are 251 4KiB blocks of RAM left to check

  ; however, we'll just deal with the ones in the current data
  ; segment...otherwise, it'll get messy...so there are 15 blocks for us to do

  mov cx, 15
memcheck_block_loop:
  ; call the function to check the RAM at a specific 4KiB block

  push cx

  ; push the start address (0x1000 * (15-cx))
  xor ax, ax
  mov ax, 15
  sub ax, cx
  shl ax, 12
  push ax

  ; push the data segment
  xor ax, ax
  push ax
  
  ; call the function
  call fn_memcheck_4kb

  ; pop the data segment
  add sp, 2

  ; pop the start address
  pop ax

  pop cx

  ; print our progress
  call fn_clear_lcd
  ; (17 - CX) * 4KiB is what we have validated
  ; get the 10s digit
  mov ax, 17
  sub ax, cx
  shl ax, 12

  push ax ; save ax

  ; get the 10s digit
  mov bl, 10
  div bl
  add al, '0'
  call fn_print_char

  ; get the 1s digit
  pop ax ; restore ax
  mov bl, 10
  div bl
  add al, '0'
  call fn_print_char

  ; print " KiB RAM Verified"
  mov ax, memcheck_str
  call fn_print_str

  ; repeat
  loop memcheck_block_loop

  ; we are done...halt!
  mov ax, memcheck_passed_str
  call fn_print_str
  jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to check a 4KiB block of RAM                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_memcheck_4kb:
  ; function for checking the RAM at a specific 4KiB block
  ; bp + 2: return address
  ; bp + 4: data segment
  ; bp + 6: start address
  
  ; back up bp
  push bp

  ; set bp to the current stack frame
  mov bp, sp

  ; back up the data segment
  push ds

  ; back up the extra segment
  push es

  ; set the extra segment to the ROM
  xor ax, ax
  or ax, 0xF000
  mov es, ax

  ; back si and di
  push si
  push di

  mov ds, [bp + 4]
  mov si, [bp + 6]

  ; set the ending address of the RAM block
  mov di, si
  add di, 0xFFF

  ; loop through the 4KiB block
memcheck_4kb_loop:

  ; set up CX to loop through the patterns
  mov cx, 12

  ; loop through the patterns
memcheck_4kb_pattern_loop:
  ; write the pattern to the RAM
  ; location is determined by the pattern counter - 1 
  mov bx, memcheck_patterns - 1
  add bx, cx

  mov al, [es:bx]
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with the pattern
  cmp al, [es:bx]
  jne memcheck_error

  ; decrement the pattern counter
  loop memcheck_4kb_pattern_loop

  ; increment the address
  inc si

  ; check if we have reached the end of the 4KiB block
  cmp si, di
  jbe memcheck_4kb_loop

  ; restore
  pop di
  pop si
  pop es
  pop ds
  pop bp
  ret


memcheck_error:
halt:
  ; halt the CPU
  hlt  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print String Function                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_str:
  ; load the address of the string into SI
  mov si, ax

  ; loop through the string
fn_print_str_print_loop:
  ; load the character into AL
  lodsb

  ; if AL is 0, we're done
  cmp al, 0
  jz fn_print_str_done

  call fn_print_char

  ; loop back to print the next character
  jmp fn_print_str_print_loop

fn_print_str_done:
  ; return
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print Character Function                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_char:
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
  call fn_wait_lcd

  ; return
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for LCD Function                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_wait_lcd:
  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, CTRL
  out dx, al
fn_wait_lcd_p1:
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
  jne fn_wait_lcd
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
  
  ;return
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear LCD Function                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_clear_lcd:
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
  call fn_wait_lcd

  ; return
  ret


crc_failed_str: db " CRC Failed", 0
memcheck_str: db " KiB RAM Verified", 0
memcheck_passed_str: db "Memcheck Passed", 0
memcheck_patterns: db 0xAA, 0x55, 0x00, 0xFF, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x00

  ; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  cli ; clear interrupts
  jmp 0xFE00:0x0000

  ; pad to 0xFFFFE
  ; note that we do this because we will inject 2 Bytes for the CRC at 0xFFFFE
  ; $ represents the current address, and $$ represents the starting address
  times (0xFFFFE - 0xFE000) - ($ - $$) db 0 
