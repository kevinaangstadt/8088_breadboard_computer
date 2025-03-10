; BIOS functions

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
; Print String Function                                                        ;
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