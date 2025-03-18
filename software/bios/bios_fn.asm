; BIOS functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to halt the machine                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_halt:
  ; halt the machine
  cli 
  hlt 
  jmp fn_halt  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function clear_lcd                                                           ;
; clear the LCD                                                                ;  
; input: none                                                                  ;
; return: none                                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_clear_lcd:
  ; clear the lcd 
  mov al, 0b00000001
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/RW/E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  call fn_wait_lcd

  ; move the cursor to the home position
  mov al, 0b00000010
  mov dx, PIO_PORTB
  out dx, al

  ; clear LCD_RS/RW/E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  call fn_wait_lcd

  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for LCD Function                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_wait_lcd:
  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, PIO_CTRL
  out dx, al
.fn_wait_lcd_p1:
  mov al, LCD_RW
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E | LCD_RW
  out dx, al
  ; read the busy flag
  mov dx, PIO_PORTB
  in al, dx
  and al, 0x80
  jne .fn_wait_lcd_p1
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al

  ; output 0s to PORT B
  mov al, 0
  mov dx, PIO_PORTB
  out dx, al

  ; output 0s to PORT C
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  
  ;return
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
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/RW/E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  call fn_wait_lcd
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to print an integer to the LCD                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_lcd_int:
  ; save the integer
  push ax

  ; check if the integer is negative
  test ax, 0x8000
  jz .fn_print_int_positive

  ; print a '-'
  mov al, '-'
  call fn_print_lcd_char

  ; negate the integer
  neg ax

  

.fn_print_int_positive:
  ; print the integer
  mov cx, 10
  

  ; keep count of digits in bx
  xor bx, bx

.fn_print_int_loop:
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
  jnz .fn_print_int_loop

.fn_print_int_print_loop:
  ; pop the remainder from the stack
  pop ax

  ; decrement the digit count
  dec bx

  ; add '0' to the remainder
  ; add al, '0'

  push bx
  ; print the character
  call fn_print_lcd_char
  pop bx

  ; check if the digit count is 0
  cmp bx, 0
  jnz .fn_print_int_print_loop

  ; restore the integer
  pop ax

  ; return
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print int as hex function                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_lcd_hex_int:
  ; ax contains the int. print it as hex digits
  push bx
  push cx  
  
  mov bx, 4
  mov cx, 12

.loop:
  push ax
  shr ax, cl
  and ax, 0x0F

  cmp ax, 10
  jb .print_digit
  add al, 'A' - '0' - 10

.print_digit:
  add al, '0'
  call fn_print_lcd_char

  ; restore original number
  pop ax 

  ; decrement the shift
  sub cx, 4
  ; decrement digits
  dec bx

  ; jump if digits left
  jnz .loop
  
  pop cx
  pop bx
  ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print Character Function                                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_lcd_char:
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
  ; clear LCD_RS/RW/E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  call fn_wait_lcd

  ; return
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LCD Print String Function                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_lcd_str:
  push si
  ; load the address of the string into SI
  mov si, ax

  ; loop through the string
.loop:
  ; load the character into AL
  lodsb

  ; if AL is 0, we're done
  cmp al, 0
  jz .done

  call fn_print_lcd_char

  ; loop back to print the next character
  jmp .loop

.done:
  pop si
  ; return
  ret
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART Move Cursor Function                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_move_cursor:
  ; move the cursor to the specified position
  ; al contains the line
  ; ah contains the column

  ; ESC[{line};{column}H
  push ax
  mov ax, UART_ESC
  call fn_uart_print_char
  mov al, '['
  call fn_uart_print_char
  pop ax
  push ax 
  xor ah, ah
  call fn_uart_print_int
  mov al, ';'
  call fn_uart_print_char
  pop ax
  mov al, ah
  xor ah, ah
  call fn_uart_print_int
  mov al, 'H'
  call fn_uart_print_char
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART Print Character Function                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_print_char:
  ; al contains the character to print
  push ax
  call fn_uart_wait_to_write
  pop ax
  mov dx, UART_DATA
  out dx, al
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART Print String Function                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_print_str:
  ; print a string to the UART
  push si
  ; load the address of the string into SI
  mov si, ax

  ; loop through the string

.loop:
  ; load the character into AL
  lodsb

  ; if AL is 0, we're done
  cmp al, 0
  jz .done

  call fn_uart_print_char

  ; loop back to print the next character
  jmp .loop

.done:
  pop si
  ; return
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function to print an integer to the UART                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_print_int:
  ; save the integer
  push ax

  ; check if the integer is negative
  test ax, 0x8000
  jz .fn_print_int_positive

  ; print a '-'
  mov al, '-'
  call fn_uart_print_char

  ; negate the integer
  neg ax

  

.fn_print_int_positive:
  ; print the integer
  mov cx, 10
  

  ; keep count of digits in bx
  xor bx, bx

.fn_print_int_loop:
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
  jnz .fn_print_int_loop

.fn_print_int_print_loop:
  ; pop the remainder from the stack
  pop ax

  ; decrement the digit count
  dec bx

  ; add '0' to the remainder
  ; add al, '0'

  push bx
  ; print the character
  call fn_uart_print_char
  pop bx

  ; check if the digit count is 0
  cmp bx, 0
  jnz .fn_print_int_print_loop

  ; restore the integer
  pop ax

  ; return
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART Print int as hex function                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_print_hex_int:
  ; ax contains the int. print it as hex digits
  push bx
  push cx  
  
  mov bx, 4
  mov cx, 12

.loop:
  push ax
  shr ax, cl
  and ax, 0x0F

  cmp ax, 10
  jb .print_digit
  add al, 'A' - '0' - 10

.print_digit:
  add al, '0'
  call fn_uart_print_char

  ; restore original number
  pop ax 

  ; decrement the shift
  sub cx, 4
  ; decrement digits
  dec bx

  ; jump if digits left
  jnz .loop
  
  pop cx
  pop bx
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART clear screen function                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_clear_screen:
  ; clear the screen
  ; ESC[2J
  mov al, UART_ESC
  call fn_uart_print_char
  mov al, '['
  call fn_uart_print_char
  mov al, '2'
  call fn_uart_print_char
  mov al, 'J'
  call fn_uart_print_char

  ; call fn_uart_move_cursor_home
  ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART move cursor home function                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_move_cursor_home:
  ; move cursor to the home position
  ; ESC[H
  mov al, UART_ESC
  call fn_uart_print_char
  mov al, '['
  call fn_uart_print_char
  mov al, 'H'
  call fn_uart_print_char
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART wait to write function                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_wait_to_write:
  ; wait for the UART to be ready to write
  ; check if the UART is ready to write
  mov dx, UART_LSR
.loop:
  in al, dx
  and al, 0x20
  jz .loop

  ; return
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hide UART cursor                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_hide_cursor:
  ; hide the cursor
  ; ESC[?25l
  mov al, UART_ESC
  call fn_uart_print_char
  mov al, '['
  call fn_uart_print_char
  mov al, '?'
  call fn_uart_print_char
  mov al, '2'
  call fn_uart_print_char
  mov al, '5'
  call fn_uart_print_char
  mov al, 'l'
  call fn_uart_print_char
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Show UART cursor                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_show_cursor:
  ; show the cursor
  ; ESC[?25h
  mov al, UART_ESC
  call fn_uart_print_char
  mov al, '['
  call fn_uart_print_char
  mov al, '?'
  call fn_uart_print_char
  mov al, '2'
  call fn_uart_print_char
  mov al, '5'
  call fn_uart_print_char
  mov al, 'h'
  call fn_uart_print_char
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART go to beginning of next line function                                   ;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_uart_newline:
  ; move cursor to the next line
  ; ESC[1E
  mov al, UART_ESC
  call fn_uart_print_char
  mov al, '['
  call fn_uart_print_char
  mov al, '1'
  call fn_uart_print_char
  mov al, 'E'
  call fn_uart_print_char
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; funciton CFInit                                                              ;
; initializes the CF card                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CFInit:
  ; reset the CF card
  ; mov dx, CFREG7
  ; mov al, 0x04
  ; out dx, al
  call CFWaitReady

  ; reset the CF card
  mov dx, CFREG7
  mov al, 0x04
  out dx, al
  call CFWaitReady

  ; LBA3=0, Master, Mode=LBA
  mov dx, CFREG6 
  mov al, 0xE0
  out dx, al

  ; 8-bit transfers 
  mov dx, CFREG1
  mov al, 0x01 
  out dx, al

  ; set feature command 
  mov dx, CFREG7 
  mov al, 0xEF
  out dx, al

  call CFWaitReady
  call CFCheckError
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function CFWaitReady                                                         ;
; waits for the CF card to be ready                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CFWaitReady:
  mov dx, CFREG7
  in al, dx
  ; push ax
  ; call print_hex 
  ; pop ax
  and al, 0x80
  cmp al, 0x00
  jne CFWaitReady
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function CFCheckError                                                        ;
; checks for errors in the CF card                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CFCheckError:
  mov dx, CFREG7
  in al, dx
  ; mask error bit
  and al, 0x01
  cmp al, 0x00 
  je CFNError

  ; set DS to ROM
  mov ax, 0xF000
  mov ds, ax

  call fn_uart_newline
  mov ax, CF_ERROR
  call fn_uart_print_str

  mov dx, CFREG1
  in al, dx
  
  call fn_uart_print_hex_int
  call fn_halt

CFNError:
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function CFRead                                                              ;
; reads data from the CF card                                                  ;
; reads into [ds:di]                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CFRead:
  push cx
  xor cx, cx
.loop:
  call CFWaitReady
  call CFCheckError
  mov dx, CFREG7
  in al, dx
  and al, 0x08  ; filter out DRQ
  cmp al, 0x08
  jne .done
  mov dx, CFREG0
  in al, dx
  mov [ds:di], al 
  inc di
  inc cx
  jmp .loop
.done:
  mov ax, cx
  pop cx
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function CFInfo                                                              ;
; prints information about the CF card                                         ;
; DS should be the segment where the data should go                            ;
; DI should be the offset for the start of CFINFO 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CFInfo:
  call CFWaitReady
  call CFCheckError

  mov dx, CFREG7
  mov al, 0xEC ; drive ID command
  out dx, al

  ; backup di
  push di

  call CFRead 

  ; print serial header
  mov ax, CF_str_serial
  call fn_print_bios_str

  ; grab a copy of di
  pop ax
  push ax
  add ax, 20
  mov si, ax
  mov ax, 20
  call fn_cf_print_n_str
  call fn_uart_newline

  ; print firmware rev
  mov ax, CF_str_fw
  call fn_print_bios_str

  ; grab a copy of di
  pop ax
  push ax
  add ax, 46
  mov si, ax
  mov ax, 8
  call fn_cf_print_n_str
  call fn_uart_newline

  ; print model number 
  mov ax, CF_str_model
  call fn_print_bios_str

  ; grab a copy of di
  pop ax
  add ax, 54
  mov si, ax
  mov ax, 40
  call fn_cf_print_n_str
  call fn_uart_newline

  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BIOS String Print Function                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_print_bios_str:
  push ds
  push ax
  mov ax, 0xF000
  mov ds, ax
  pop ax
  call fn_uart_print_str
  pop ds
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CF Print N String Function                                                   ;
; Big Endian string print function                                             ;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_cf_print_n_str:
  ; si contains the address of the string
  ; ax contains the count of characters
  push cx
  ; loop through the string
  mov cx, ax
  ; divide by 2 because we want to print 2 characters at a time
  shr cx, 1
.loop:
  ; load the character into AL
  lodsw
  ; we just loaded two bytes
  ; we need to print ah then al
  push ax
  mov al, ah
  call fn_uart_print_char
  pop ax
  call fn_uart_print_char
  loop .loop

  pop cx
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CF Function Read Sector                                                      ;
; ax : lower 16 bit of the LBA address                                         ;
; bx : upper 16 bit of the LBA address                                         ;
; ds:di : address to read to                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_cf_read_sector:
  ; set the LBA address

  ; LBA 0
  mov dx, CFREG3
  out dx, al

  ; LBA 1
  mov dx, CFREG4
  mov al, ah
  out dx, al

  ; LBA 2
  mov dx, CFREG5
  mov al, bl
  out dx, al

  ; LBA 3
  mov dx, CFREG6
  mov al, bh
  ; FILTER out the LBA bits
  and al, 0x0F
  ; MODE LBA, Master
  or al, 0xE0
  out dx, al

  ; read one sector
  mov dx, CFREG2
  mov al, 1
  out dx, al

  ; set the read command
  mov dx, CFREG7
  mov al, 0x20
  out dx, al

  ; wait for the CF card to be ready
  call CFWaitReady
  call CFCheckError

  ; read the data
  call CFRead

  call CFCheckError

  ret
