; bios fragment for setting up 8255 PIO and the 1602 LCD

; set up the PIO Port B for output
; Configure the LCD for 8-bit mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Initialize the LCD                                                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POST_PIO_LCD:
  ; set up GROUP A/B for MODLCD_E 0 output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al

  ; See the LCD datasheet for the initialization sequence
  ; Figure 23 on page 45 of the HD44780U datasheet for 8-Bit Interface Initialization

  ; busy wait for 40ms to allow the LCD to power up
  ; at 8Mhz, 1 cycle is 125ns meaning we need to busy wait for 320,000 cycles
  ; 320,000 cycles / 4 cycles per loop = 80,000 loops
  mov cx, 12000  ; 40000 loops
.loop:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop .loop ; 17 cycles to decrement and jump if not zero

POST_PIO_LCD_INIT_1:
  ; initialize with 8-bit mode with 3 commands 0x00110000
  mov al, 0b00110000
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction (more than 4.1ms)
  ; at 8Mhz, 1 cycle is 125ns meaning we need to busy wait for at least 32,800 cycles
  ; we will busy wait for 40,000 cycles
  mov cx, 1200  ; 10000 loops
.loop:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop .loop ; 17 cycles

POST_PIO_LCD_INIT_2:
  ; initialize a second time with 8-bit mode with 3 commands 0x00110000
  mov al, 0b00110000
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction (more than 100us)
  ; at 8Mhz, 1 cycle is 125ns meaning we need to busy wait for at least 800 cycles
  ; we will busy wait for 1000 cycles
  mov cx, 35    ; 34 loops
.loop:
  nop            ; 4 cycle
  nop            ; 4 cycle
  nop            ; 4 cycle
  loop .loop ; 17 cycles

POST_PIO_LCD_INIT_3:
  ; initialize a third and final time time with 8-bit mode with 3 commands 0x00110000
  mov al, 0b00110000
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, PIO_CTRL
  out dx, al
.loop:
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
  jne .loop
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the LCD with our desired settings                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POST_PIO_LCD_SLCD_ETUP:
  ; set 8-bit mode; 2-line display; 5x8 font
  mov al, 0b00111000
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, PIO_CTRL
  out dx, al
.loop:
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
  jne .loop
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al

POST_PIO_LCD_CULCD_RSOR:
  ; display on; cursor off; blink off
  mov al, 0b00001100
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, PIO_CTRL
  out dx, al
.loop:
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
  jne .loop
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al

POST_PIO_LCD_INC:
  ; increment and shift cursor; don't shift display
  mov al, 0b00000110
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, PIO_CTRL
  out dx, al
.loop:
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
  jne .loop
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al

POST_PIO_LCD_LCD_CLEAR:
  ; Clear display
  mov al, 0b00000001
  mov dx, PIO_PORTB
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set LCD_E bit to send instruction
  mov al, LCD_E
  out dx, al
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; wait for the LCD to process the instruction
  ; set PORT B to input
  mov al, 0b10000010
  mov dx, PIO_CTRL
  out dx, al
.loop:
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
  jne .loop
  mov al, 0
  mov dx, PIO_PORTC
  out dx, al
  ; set PORT B back to output
  mov al, 0b10000000
  mov dx, PIO_CTRL
  out dx, al