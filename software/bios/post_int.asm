; BIOS fragment for setting up the interrupt vectors
POST_IRQ_SETUP:
  ; set the ds to 0
  xor ax, ax
  mov ds, ax

  ; IRQ0-4 are IRQ_NOP
  mov ax, IRQ_nop
  mov [ds:0x0000], ax
  mov [ds:0x0002], word 0xF000
  mov [ds:0x0004], ax
  mov [ds:0x0006], word 0xF000
  mov [ds:0x0008], ax
  mov [ds:0x000A], word 0xF000
  mov [ds:0x000C], ax
  mov [ds:0x000E], word 0xF000

  ; IRQ5 is the println
  mov ax, IRQ_5h
  mov [ds:0x0014], ax
  mov [ds:0x0016], word 0xF000

  ; IRQ8 is the timer
  mov ax, IRQ_timer
  mov [ds:0x0020], ax
  mov [ds:0x0022], word 0xF000

  ; IRQ12 is the UART
  mov ax, IRQ_text
  mov [ds:0x0030], ax
  mov [ds:0x0032], word 0xF000

  ; set the ds to the BDA
  mov ax, 0x0040
  mov ds, ax

  ; set up the KBD and Timer values
  xor ax, ax
  mov [ds:BDA_TIMER_COUNT], al
  mov [ds:BDA_CLK], ax
  mov [ds:BDA_CLK + 2], ax
  mov [ds:BDA_CLK_Rollover], al

  mov [ds:BDA_KB_BUFFER_SIZE], al
  mov [ds:BDA_KB_BUFFER_TL], byte BDA_KB_BUFFER
  mov [ds:BDA_KB_BUFFER_HD], byte BDA_KB_BUFFER
  
  ; enable IRQ0 and IRQ4 on the PIC
  mov dx, PIC_MASK
  in al, dx
  and al, 0b11101110
  out dx, al

  ; enable interrupts
  sti
