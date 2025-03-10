; BIOS fragment for setting up the 82C59 PIC

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
  ; disable all interrupts
  mov al, 0b11111111
  mov dx, PIC_MASK
  out dx, al