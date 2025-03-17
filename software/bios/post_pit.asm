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

  
  ; set ds to the interrupt vector
  xor ax, ax
  mov ds, ax

  ; set the interrupt vector to our local handler
  ; IRQ0 is 0x08
  ; we need to set the vector to 0xF000:POST_PIT_IRQ
  ; set up the timer interrupt
  mov [0x0020], word POST_PIT_IRQ
  mov [0x0022], word 0xF000

  ; set ds to the start of the BIOS
  mov ax, 0xF000
  mov ds, ax

  ; input clock is 4 MHz
  ; we want to test for 10ms
  ; so we need a count of 40000
  mov al, 0b00110110
  mov dx, TIMER_CTL 
  out dx, al

  mov ax, 40000
  mov dx, CNT_A
  out dx, al
  mov al, ah
  out dx, al

  ; set ax to 1
  xor ax, ax
  inc ax

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
  ; jmp to POST_PIT_FAILED if it is not disabled
  cmp al, 0b00000001
  jne POST_PIT_FAILED

  ; check if the count is reasonable
  ; if it is, we can assume the timer is working
  ; if it is not, we can assume the timer is not working

  ; the loop above takes about 17 cycles per iteration
  ; the clock for the CPU is 8 MHz, so this takes 0.002125 ms
  ; we expect the square wave to go high in about 10 ms
  ; so we expect 4706 loop iterations to take place

  ; CX should be around 0xFFFF - 4706 = 0xED9D when we trigger
  ; we'll allow 5% error (235 iterations)

  ; check if it is too fast
  cmp ax, 0xFFFF - 4706 + 235
  jge POST_PIT_FAILED
  ; check if it is too slow
  cmp ax, 0xFFFF - 4706 - 235
  jle POST_PIT_FAILED
  ; if we get here, the timer is working
  ; we can assume the timer is working

  ; set up CNT_A for a ~61Hz square wave
  ; input clock is 4 MHz
  ; we want a count of 65536 (this is the slowest we can go)
  mov ax, 65536
  mov dx, CNT_A
  out dx, al
  mov al, ah
  out dx, al

  jmp POST_PIC_DONE
  
POST_PIT_IRQ:
  ; INTR signal takes about 61 clock cycles
  ; check if this is the first time
  ; check if ax is 1
  cmp ax, 1   ; 4 cycles
  jne .done   ; 4 cycles (fail)

  ; the is first timer interrupt
  ; reset the count to 
  ; This portion of the IRQ takes about 99 cycles
  mov cx, 0xFFFF - 10   ; 4 cycles
  ; mark that not the first time
  dec ax  ; 2 cycles
  iret    ; 24 cycles

.done:
  ; store current count in ax
  mov ax, cx

  ; set cx to 1
  xor cx, cx
  inc cx

  ; disable IRQ0
  mov dx, PIC_MASK
  in al, dx
  or al, 0b00000001
  out dx, al

  iret

POST_PIT_FAILED:
  call fn_print_lcd_hex_int
  ; print an T to the LCD (timer failed)
  mov al, 'T'
  call fn_print_lcd_char

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

  ; wait about 1 second
  mov cx, 0xFFFF
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