; BIOS fragment for checking that the first 16KB of RAM are working

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Perform a Check of the RAM                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POST_MEMCHECK16K:
  ; Valid addresses for RAM are 0x00000 to 0xFBFFF
  
  ; Do first 16KiB separately so we can use it for the stack once it is verified
  mov si, 0x0000

  ; we're going to test AA, 55, 00, FF, 01, 02, 04, 08, 10, 20, 40, 80
  ; This is stored in "memcheck_patterns" in the BIOS data

  ; set the DS to the start of RAM
  xor ax, ax
  mov ds, ax

  ; set the ES to the ROM
  xor ax, ax
  or ax, 0xF000
  mov es, ax

.memcheck_loop:
  ; set bx to the base address of the patterns
  mov bx, memcheck_patterns

  ; set cx to 0
  xor cx, cx

.memcheck_pattern_loop:
  ; write pattern to the RAM
  mov al, [es:bx]
  mov [ds:si], al
  ; copy the value to dl
  ; mov dl, [es:bx]
  ; read the RAM
  mov dl, [ds:si]
  ; compare the RAM with pattern
  cmp al, dl
  jne .memcheck_error

  inc bx
  inc cx

  ; check that cx < 12 (number of patterns)
  cmp cx, 12
  jl .memcheck_pattern_loop

  ; increment the address
  inc si

  ; check if we have reached the end of the first 16KiB
  ; there will be a carry if we have
  jnc .memcheck_loop

  ; halt
  jmp .memcheck_done

.memcheck_error:
  ; print an E to the LCD
  mov al, 'E'
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
  ; clear RS/RW/E bits
  mov al, 0
  out dx, al

.halt:
  hlt
  jmp .halt

.memcheck_done: