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
  ; start the memcheck if we pass the CRC check
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

  ; set the ES to the ROM
  xor ax, ax
  or ax, 0xF000
  mov es, ax

memcheck_loop:
  ; set bx to the base address of the patterns
  mov bx, memcheck_patterns

  ; set cx to 0
  xor cx, cx

memcheck_pattern_loop:
  ; write pattern to the RAM
  mov al, [es:bx]
  mov [ds:si], al
  ; copy the value to dl
  ; mov dl, [es:bx]
  ; read the RAM
  mov dl, [ds:si]
  ; compare the RAM with AA
  cmp al, dl
  jne memcheck_error

  inc bx
  inc cx

  ; check that cx < 12
  cmp cx, 12
  jl memcheck_pattern_loop

  ; increment the address
  inc si

  ; check if we have reached the end of the first 4KiB
  cmp si, di
  jbe memcheck_loop

  ; halt
  jmp memcheck_remaining_blocks

memcheck_error:
  ; print an E to the LCD
  mov al, 'E'
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

  jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First 4KiB RAM has been verified, so we can use it for the stack             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memcheck_remaining_blocks:
  ; set up the stack
  xor ax, ax
  mov ss, ax
  ; since we are using the first 4KiB of RAM for the stack, we can set the stack
  ; pointer to the end of the first 4KiB
  mov sp, 0x1000
  mov bp, sp

  ; set DS to ROM
  xor ax, ax
  or ax, 0xF000
  mov ds, ax

  ; print that we have verified the first 4KiB of RAM
  call fn_clear_lcd

  ; store number of 4KiB blocks verified
  mov ax, 1

  ; store ax to stack
  push ax

  ; multiply number of blocks by 4KiB
  ; we need to multiply by 4, so we can just shift left by 2
  shl ax, 1
  shl ax, 1

  call fn_print_int

  mov ax, memcheck_str
  call fn_print_str

  ; check the rest of the RAM

  ; first segment to check
  ; note we start checking from 0x1000 since we have already checked the first 4KiB
  mov si, 0x0000
  ; last segment to check
  ; note we only have to go up to 0xBFFF since the rest is ROM
  mov di, 0xF000

  ; however, we'll just deal with the ones in the current data
  ; segment...otherwise, it'll get messy...so there are 15 blocks for us to do

  mov cx, 15
memcheck_block_loop:
  ; call the function to check the RAM at a specific 4KiB block

  ; back up our loop value
  push cx

  ; store base pointer
  push bp
  mov bp, sp 

  ; push the start address (0x1000 * (16-cx))
  xor ax, ax
  cmp si, di
  je memcheck_final_segment
  mov ax, 16
  jmp memcheck_segment_calc

memcheck_final_segment:
  ; there are only 12 blocks to check in the final segment
  mov ax, 12

memcheck_segment_calc:
  sub ax, cx
  mov cx, 12
  shl ax, cl
  push ax

  ; push the data segment
  push si

  ; call the function
  call fn_memcheck_4kb

  ; pop the arguments
  add sp, 4

  ; restore bp
  pop bp

  ; print our progress
  call fn_clear_lcd

  ; restore cx
  pop cx
  
  ; print the number of blocks verified
  ; increment the number of blocks verified
  pop ax
  inc ax
  push ax

  push cx

  ; print the number of blocks verified
  shl ax, 1
  shl ax, 1
  call fn_print_int

  ; print " KiB RAM Verified"
  mov ax, memcheck_str
  call fn_print_str

  pop cx
  
  ; repeat
  loop memcheck_block_loop

  ; we have finished a segment
  add si, 0x1000
  ; if there is a carry, we have finished all the segments
  jc memory_check_done

  cmp si, di
  je memcheck_set_cx_last_segment
  ja memory_check_done

  ; set cx to 16
  mov cx, 16

  jmp memcheck_block_loop

memcheck_set_cx_last_segment:
  ; set cx to 12
  mov cx, 12

  ; jump if below or equal
  jmp memcheck_block_loop

memory_check_done:
  ; I do not trust that I wrote this code correctly, so let's check something 
  ; in segment 0xF000 to see if it has the last memory pattern
  mov ax, 0xF000
  mov ds, ax

  ; set si to 0xABCD...just something arbitrary
  mov si, 0xABCD

  ; read the address
  mov al, [ds:si]

  ; check if it is the last memory pattern
  ; set bx to the base address of the patterns
  mov si, memcheck_patterns + 11
  mov bl, [ds:si]

  ; halt and don't print the success message if the pattern fails to match
  cmp al, bl
  jne halt

  ; print that we have verified all the RAM
  ; on the second line
  mov al, 0x40
  call fn_lcd_move_cursor

  ; we are done...halt!
  mov ax, memcheck_passed_str
  call fn_print_str

  pop ax

  jmp halt  

output_al_bl:
  mov dx, PORTA
  out dx, al

  mov dx, PORTB
  mov al, bl
  out dx, al

  jmp halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to check a 4KiB block of RAM                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_memcheck_4kb:
  ; function for checking the RAM at a specific 4KiB block
  ; bp - 2: start address
  ; bp - 4: data segment
  ; bp - 6: return address

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

  mov ds, [bp - 4]
  mov si, [bp - 2]

  ; set the ending address of the RAM block
  mov di, si
  add di, 0xFFF

  ; loop through the 4KiB block
memcheck_4kb_loop:

  ; set up CX to loop through the patterns
  mov cx, 0
  mov bx, memcheck_patterns

  ; loop through the patterns
memcheck_4kb_pattern_loop:
  ; write the pattern to the RAM

  mov al, [es:bx]
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with the pattern
  cmp al, [es:bx]
  jne memcheck_4kb_pattern_failed

  inc cx
  inc bx

  ; check if cx < 12
  cmp cx, 12
  jl memcheck_4kb_pattern_loop

  ; increment the address (use add not inc because it allows for CF to be set)
  add si, 1
  ; when we do 0xFFFF, we will wrap around to 0x0000, which breaks the loop
  jc memcheck_4kb_pattern_passed

  ; check if we have reached the end of the 4KiB block
  cmp si, di
  jbe memcheck_4kb_loop

memcheck_4kb_pattern_passed:
  ; restore
  pop di
  pop si
  pop es
  pop ds
  ret

memcheck_4kb_pattern_failed:
halt:
  ; halt the CPU
  hlt  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print String Function                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_str:
  push si
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
  pop si
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
  jne fn_wait_lcd_p1
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

  ; move the cursor to the home position
  mov al, 0b00000010
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to move the cursor to a specific position on the LCD                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_lcd_move_cursor:
  ; al stores the position
  ; 0x00 - 0x0F: first line
  ; 0x40 - 0x4F: second line
  ; and with 0x7F to ensure that the position is within the bounds of the LCD
  and al, 0x7F
  ; or with 0x80 to set the bit indicating that we're setting DDRAM
  or al, 0x80

  ; write the command to the LCD
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
  ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to print an integer to the LCD                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_int:
  ; save the integer
  push ax

  ; check if the integer is negative
  test ax, 0x8000
  jz fn_print_int_positive

  ; print a '-'
  mov al, '-'
  call fn_print_char

  ; negate the integer
  neg ax

  

fn_print_int_positive:
  ; print the integer
  mov cx, 10
  

  ; keep count of digits in bx
  xor bx, bx

fn_print_int_loop:
  ; clear the remainder register
  xor dx, dx

  ; divide the integer by 10
  div cx

  ; push the remainder onto the stack
  add dl, '0'
  push dx

  ; increment the digit count
  inc bx

  ; check if the quotient is 0
  cmp ax, 0
  jnz fn_print_int_loop

fn_print_int_print_loop:
  ; pop the remainder from the stack
  pop ax

  ; decrement the digit count
  dec bx

  ; add '0' to the remainder
  ; add al, '0'

  push bx
  ; print the character
  call fn_print_char
  pop bx

  ; check if the digit count is 0
  cmp bx, 0
  jnz fn_print_int_print_loop

  ; restore the integer
  pop ax

  ; return
  ret


crc_failed_str: db " CRC Failed", 0
memcheck_str: db "KiB Verified", 0
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
