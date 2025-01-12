; Experimenting with the timer interrupt ... display a count 

; Note: this is just testing out interrupts, so we are not doing any CRC
; validation or memory integrity checks. Proceed with caution.

BITS 16

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

; NOTE: the timer lives at IO port 0x2000

CNT_A equ 0x2000
CNT_B equ 0x2001
CNT_C equ 0x2002
TIMER_CTL equ 0x2003

; NOTE: the PIC lives at IO port 0x0000
PIC_0 equ 0x0000
PIC_1 equ 0x0001
PIC_MASK equ PIC_1

; the upper ROM chip starts at address 0xFE000
org 0xFE000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize the PIC                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; ICW1 
  ; edge triggered, interval 8, single, ICW4 needed
  mov al, 0b00010011
  mov dx, PIC_0
  out dx, al

  ; ICW2
  ; set the interrupt vector to have the 8-bit set (i.e., IRQ0 is 0x08)
  mov al, 0b00001000
  mov dx, PIC_1
  out dx, al

  ; ICW4
  ; 8088 mode, Auto EOI, master, buffered, not special fully nested
  mov al, 0b00001111
  mov dx, PIC_1
  out dx, al

  ; set up the PIC mask
  ; 0 means enabled, 1 means disabled
  mov al, 0b11111110
  mov dx, PIC_MASK
  out dx, al

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
; Set up the call stack                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set up a stack near the top of memory
  mov ax, 0xE000
  mov ss, ax
  mov sp, 0xFFFF

  ; data for now is interrupt vector table
  mov ax, 0x0000
  mov ds, ax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the interrupt vector table                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set up the divide by zero interrupt
  mov ax, int_0h
  mov [0x0000], ax
  mov [0x0002], word 0xF000

  ; set up the not implemented interrupt
  mov ax, int_not_implemented
  mov [0x0004], ax
  mov [0x0008], ax
  mov [0x000C], ax

  mov [0x0006], word 0xF000
  mov [0x000A], word 0xF000
  mov [0x000E], word 0xF000

  ; set up the overflow interrupt
  mov ax, int_4h
  mov [0x0010], ax
  mov [0x0012], word 0xF000

  ; set up the timer interrupt
  mov ax, int_8h
  mov [0x0020], ax
  mov [0x0022], word 0xF000




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the timer test                                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  mov ax, 0xF000
  mov ds, ax
  
  mov ax, msg_start
  call fn_print_str

  
  
  ; we want the timer to go off once every second (triggering IRQ0)

  ; 0xF000:0x0000 stores the count of ticks
  ; 0xF000:0x0002 stores the count of seconds
  mov word [0x0000], 0
  mov word [0x0002], 0

  ; control word format is
  ; D7  D6  D5  D4  D3 D2 D1 D0
  ; SC1 SC0 RW1 RW0 M2 M1 M0 BC
  ; SC1 SC0 = 00 for counter A
  ; RW1 RW0 = 11 to write LSB then MSB
  ; M2 M1 M0 = 011 for square wave output (mode 3)
  ; BC = 0 for binary counting
  mov al, 0b00110110
  mov dx, TIMER_CTL
  out dx, al

  ; write the count to the timer
  ; the peripheral clock is running at 4MHz
  ; we would like a tick at 120Hz
  ; so we need to count down from 33333
  mov ax, 33333
  mov dx, CNT_A
  out dx, al
  mov al, ah
  out dx, al


  ; enable interrupts and halt
busy_wait:
  sti
  hlt
  jmp busy_wait

  ; we should never reach this point

  mov ax, 0
  mov ds, ax
  call fn_lcd_move_cursor
  mov ax, word [0x0020]
  call fn_print_int_hex
  mov ax, 0x40
  call fn_lcd_move_cursor
  mov ax, word [0x0022]
  call fn_print_int_hex
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to print integer to LCD as Hex                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_int_hex:
  ; save the integer
  push ax

  ; print "0x"
  mov al, '0'
  call fn_print_char
  mov al, 'x'
  call fn_print_char

  ; print the integer
  mov cx, 16

  ; keep count of digits in bx
  xor bx, bx

fn_print_int_hex_loop:
  ; clear the remainder register
  xor dx, dx

  ; divide the integer by 16
  div cx

  ; push the remainder onto the stack
  push dx

  ; increment the digit count
  inc bx

  ; check if the quotient is 0
  cmp ax, 0
  jnz fn_print_int_hex_loop

fn_print_int_hex_print_loop:
  ; pop the remainder from the stack
  pop ax

  ; decrement the digit count
  dec bx

  ; convert the remainder to a printable character
  cmp al, 10
  jl fn_print_int_hex_print_loop_digit
  add al, 'A' - 10
  jmp fn_print_int_hex_print_loop_done

fn_print_int_hex_print_loop_digit:
  add al, '0'

fn_print_int_hex_print_loop_done:

  push bx
  ; print the character
  call fn_print_char
  pop bx

  ; check if the digit count is 0
  cmp bx, 0
  jnz fn_print_int_hex_print_loop

  ; restore the integer
  pop ax

  ; return
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int 0h - Divide by zero interrupt handler                                    ;             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int_0h:
  ; print the error message
  mov si, msg_divide_by_zero
  call fn_print_str

  ; halt the CPU
  hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int 1h, 2h, 3h – Not implmented interrupt handlers                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int_not_implemented:
  ; print the error message
  mov si, msg_not_implemented
  call fn_print_str

  ; halt the CPU
  hlt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int 4h - Overflow interrupt handler                                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int_4h:
  ; do nothing
  iret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int 8h - Timer interrupt handler                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int_8h:
  ; save the registers we will use
  push ds
  push ax
  push cx

  ; set the data segment to our memory location
  mov ax, 0xF000
  mov ds, ax

  ; increment the counter
  mov cx, word [0x0000]
  inc cx
  mov word [0x0000], cx

  ; check if we've reached 120 (roughly 1 second)
  cmp cx, 120
  jne int_8h_done
  ; reset the counter
  mov cx, 0
  mov word [0x0000], cx

  ; move the cursor
  mov ax, 0x40
  call fn_lcd_move_cursor

  ; increment the count
  mov ax, word [0x0002]
  inc ax
  mov word [0x0002], ax

  ; print the count
  call fn_print_int

int_8h_done:
  ; restore the registers
  pop cx
  pop ax
  pop ds

  ; return from the interrupt
  iret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data Section                                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msg_divide_by_zero db "Divide by zero error!", 0
msg_not_implemented db "Not implemented!", 0
msg_start db "Starting timer", 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the reset vector                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0

  cli ; clear interrupts
  jmp 0xFE00:0x0000

  ; pad to 0xFFFFF
  ; $ represents the current address, and $$ represents the starting address
  times (0x100000 - 0xFE000) - ($ - $$) db 0