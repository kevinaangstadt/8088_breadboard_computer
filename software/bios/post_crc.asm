; CRC Checksum for BIOS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform a CRC-16 Check of ROM                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POST_CRC:
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
  or ax, 0xFE00
  mov ds, ax
  
  ; Initialize CRC register to 0x0000
  mov ax, 0x0000

  ; Set the starting address of the ROM
  mov si, 0x0

  ; Set the ending address of the ROM
  mov di, 0x1FFE
.crc_loop: 
  ; XOR the byte with the CRC register
  xor al, [ds:si]

  ; Increment the ROM address
  inc si

  ; Process each bit in the byte
  mov cx, 8
.bit_loop:
  ; Shift the CRC register right by 1 bit
  shr ax, 1
  ; If the least significant bit is 1, XOR with 0xA001
  jnc .no_xor
  xor ax, 0xA001
.no_xor:
  loop .bit_loop

  ; Check if we have reached the end of the ROM
  cmp si, di
  ; jump if below
  jb .crc_loop

  ; store a copy of the CRC value in BX
  mov bx, ax

  ; compare with the CRC value stored at 0xFFFFE
  mov si, 0x1FFE
  mov ax, [ds:si]

  cmp ax, bx
  je .done

  ; otherwise, halt
  ; display 'E' on the LCD
  mov al, 'E'
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
  ; clear LCD_RS/LCD_RW/LCD_E bits
  mov al, 0
  out dx, al

  ; we don't care about waiting because we're going to halt anyway

.halt:
  hlt
  jmp .halt

.done: