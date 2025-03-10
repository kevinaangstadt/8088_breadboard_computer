; BIOS fragment for setting up TIMER 0 on the PIT

POST_PIT:
  ; set up timer C for square wave output
  ; input clock is 4 MHz
  ; we want a 440 Hz square wave
  ; so we need a count of 9091?

  ; control word format is
  ; D7  D6  D5  D4  D3 D2 D1 D0
  ; SC1 SC0 RW1 RW0 M2 M1 M0 BC
  ; SC1 SC0 = 00 for counter A, 01 for counter B, 10 for counter C
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

  ; check that TIME 0 counts with a reasonable rate
  ; We'll enable the IRQ0 and see how many loop iterations we can do
  ; before the IRQ0 is triggered

  ; enable IRQ0
  mov dx, PIC_MASK
  in al, dx
  and al, 0b11111110
  out dx, al

  
  ; set ds to the start of the BIOS
  mov ax, 0xF000
  mov ds, ax

  ; set the interrupt vector to our local handler
  ; IRQ0 is 0x08
  ; we need to set the vector to 0xF000:POST_PIC_IRQ
  ; set up the timer interrupt
  mov ax, POST_PIC_IRQ
  mov [0x0020], ax
  mov [0x0022], word 0xF000

  ; input clock is 4 MHz
  ; we want to test for 10ms
  ; so we need a count of 40000
  mov al, 0b0010110
  mov dx, TIMER_CTL 
  out dx, al

  mov ax, 40000
  mov dx, CNT_A
  out dx, al
  mov al, ah
  out dx, al

  ; enable interrupts
  sti

  ; loop to count how long the interrupt takes
  mov cx, 0xFFFF
.loop:
  loop .loop

  ; disable interrupts
  cli

  ; check if IRQ0 is disabled
  mov dx, PIC_MASK
  in al, dx
  and al, 0b00000001
  ; jmp to POST_PIC_FAILED if it is not disabled
  cmp al, 0b00000001
  je POST_PIC_FAILED

  ; check if the count is reasonable
  ; if it is, we can assume the timer is working
  ; if it is not, we can assume the timer is not working

  ; the loop above takes about 17 cycles per iteration
  ; the clock for the CPU is 8 MHz, so this takes 0.002125 ms
  ; we expect the square wave to go high in about 0.5 ms
  ; so we expect 235 loop iterations to take place

  ; CX should be around 0xFF14 when we trigger
  ; check that AX is close to 0xFF14

  ; let's say 0xFF30 is too fast
  cmp ax, 0xFF30
  jge POST_PIC_FAILED
  ; let's say 0xFF00 is too slow
  cmp ax, 0xFF00
  jle POST_PIC_FAILED
  ; if we get here, the timer is working
  ; we can assume the timer is working

  ; set up CNT_A for a 18.2 Hz square wave
  ; input clock is 4 MHz
  ; we want a count of 21818
  mov ax, 21818
  mov dx, CNT_A
  out dx, al
  mov al, ah
  out dx, al

  jmp POST_PIC_DONE
  
POST_PIC_IRQ:
  ; store current count in ax
  mov ax, cx

  ; disable IRQ0
  mov dx, PIC_MASK
  in al, dx
  or al, 0b00000001
  out dx, al

  iret

POST_PIC_FAILED:
  ; print an F to the LCD
  mov al, 'F'
  ; write the character to the LCD
  mov dx, PIO_PORTB
  out dx, al
  ; set RS bit to send data
  mov al, LCD_RS
  mov dx, PIO_PORTC
  out dx, al
  ; set E bit to send data
  mov al, LCD_RS | LCD_E
  out dx, al
  ; clear E bit
  mov al, LCD_RS
  out dx, al
  ; clear RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; long beep
  ; enable the speaker
  mov al, 0x03
  mov dx, PIO_PORTA
  out dx, al

  ; wait about a second
  mov cx, 0xFFFF
.loop:
  loop .loop
  ; disable the speaker
  mov al, 0x00
  mov dx, PIO_PORTA
  out dx, al

  ; wait about 0.5 seconds
  mov cx, 0x7FFF
.loop2:
  loop .loop2

  ; short beep
  ; enable the speaker
  mov al, 0x03
  mov dx, PIO_PORTA
  out dx, al

  ; wait about a half a second
  mov cx, 0x7FFF
.loop3:
  loop .loop3
  ; disable the speaker
  mov al, 0x00
  mov dx, PIO_PORTA
  out dx, al

.halt:
  hlt
  jmp .halt

POST_PIC_DONE: