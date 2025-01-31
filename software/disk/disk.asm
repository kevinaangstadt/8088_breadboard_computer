; Read and print card information

UART_BASE equ 0x6000
UART_DATA equ UART_BASE + 0
UART_IER equ UART_BASE + 1
UART_IIR equ UART_BASE + 2
UART_FIFO equ UART_BASE + 2
UART_LCR equ UART_BASE + 3
UART_MCR equ UART_BASE + 4
UART_LSR equ UART_BASE + 5
UART_MSR equ UART_BASE + 6
UART_SCR equ UART_BASE + 7

UART_DIVISOR_L equ UART_BASE + 0
UART_DIVISOR_H equ UART_BASE + 1


; CF card registers
CFBASE	equ 0xA000
CFREG0	equ	CFBASE+0	; DATA PORT
CFREG1	equ	CFBASE+1	; READ: ERROR CODE, WRITE: FEATURE
CFREG2	equ	CFBASE+2	; NUMBER OF SECTORS TO TRANSFER
CFREG3	equ	CFBASE+3	; SECTOR ADDRESS LBA 0 [0:7]
CFREG4	equ	CFBASE+4	; SECTOR ADDRESS LBA 1 [8:15]
CFREG5	equ	CFBASE+5	; SECTOR ADDRESS LBA 2 [16:23]
CFREG6	equ	CFBASE+6	; SECTOR ADDRESS LBA 3 [24:27 (LSB)]
CFREG7	equ	CFBASE+7	; READ: STATUS, WRITE: 

; data storage segmanet
DSEG equ 0x2000
RSEG equ 0xF000


org 0xFE000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the UART                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set the stack segment to 0x1000
  mov ax, 0x1000
  mov ss, ax

  ; set the stack pointer to 0xFFFF
  mov sp, 0xFFFF

  ; set up FIFO
  mov dx, UART_FIFO
  mov al, 0b10000001
  out dx, al

  ; set up line control register
  ; 8N1, enable baud setup
  mov dx, UART_LCR
  mov al, 0b10000011
  out dx, al

  ; set BAUD rate to 9600
  mov dx, UART_DIVISOR_L
  mov al, 20
  out dx, al

  mov dx, UART_DIVISOR_H
  mov al, 0
  out dx, al

  ; disable baud setup
  mov dx, UART_LCR
  in al, dx
  and al, 0b01111111
  out dx, al

  ; set up auto flow control
  mov dx, UART_MCR
  mov al, 0b00100010
  out dx, al

  ; enable interrupts
  mov dx, UART_IER
  mov al, 0b00000101
  out dx, al

  mov dx, UART_DATA
  mov al, 'K'
  out dx, al

  call CFInit
  mov al, 'I'
  call print_char
  call CFInfo

halt:
  hlt
  jmp halt

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

  mov al, '!'
  call print_char

  mov dx, CFREG1
  in al, dx
  
  call print_hex

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
CFRead_Loop:
  call CFWaitReady
  call CFCheckError
  mov dx, CFREG7
  in al, dx
  and al, 0x08  ; filter out DRQ
  cmp al, 0x08
  jne CFReadE
  mov dx, CFREG0
  in al, dx
  mov [ds:di], al 
  inc di
  inc cx
  jmp CFRead_Loop
CFReadE:
  mov ax, cx
  pop cx
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function CFInfo                                                              ;
; prints information about the CF card                                         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CFInfo:
  call CFWaitReady
  call CFCheckError

  mov al, 'W'
  call print_char

  mov dx, CFREG7
  mov al, 0xEC ; drive ID command
  out dx, al

  mov ax, DSEG
  mov ds, ax
  xor di, di

  call CFRead 

  mov si, d_crlf
  call printROM

  call print_hexx

  mov al, 'h'
  call print_char

  mov si, d_crlf
  call printROM

  ; print serial
  mov si, d_serial
  call printROM

  mov si, 20
  mov ax, 20
  call print_n_string
  mov si, d_crlf
  call printROM

  ; print firmware rev
  mov si, d_fw
  call printROM

  mov si, 46
  mov ax, 8
  call print_n_string

  mov si, d_crlf
  call printROM

  ; print model number 
  mov si, d_model
  call printROM

  mov si, 54
  mov ax, 40
  call print_n_string

  mov si, d_crlf
  call printROM

  ; print LBA size
  mov si, d_lba_size
  call printROM

  mov si, 123
  mov cx, 4
lba_info:
  mov al, [ds:si] 
  call print_hex
  dec si
  loop lba_info

  mov si, d_crlf
  call printROM

  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function print_n_string                                                      ;
; prints n characters from the string at DS:SI                                 ;
; assumes that characters are stored in big-endian order                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_n_string:
  push cx
  mov cx, ax
  ; divide by 2 because we are reading two bytes at a time
  shr cx, 1
print_n_string_loop:
  lodsw
  ; we just loaded two bytes
  ; we need to print ah then al
  push ax
  mov al, ah
  call print_char
  pop ax
  call print_char
  loop print_n_string_loop
  pop cx
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function printROM                                                            ;
; prints a ROM data to the UART                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printROM:
  push ax
  push ds
  mov ax, RSEG
  mov ds, ax
  call print_string
  pop ds
  pop ax
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function print_char                                                          ;
; prints a character to the UART                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_char:
  push ax
  ; busy wait for space in the transmit buffer
  mov dx, UART_LSR
print_char_wait:
  in al, dx
  test al, 0x20
  jz print_char_wait

  pop ax
  mov dx, UART_DATA
  out dx, al
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function print_hex                                                           ;
; print the contents of al in two hex digits to UART                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_hex:
  ; print the high nibble
  mov ah, al
  shr al, 1
  shr al, 1
  shr al, 1
  shr al, 1
  call print_hex_digit

  ; print the low nibble
  mov al, ah
  and al, 0x0F
  call print_hex_digit
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function print_hexx                                                          ;
; print the contents of ax in four hex digits to UART                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_hexx:
  push ax
  ; print the high byte
  mov al, ah
  call print_hex

  ; print the low byte
  pop ax
  call print_hex
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function print_hex_digit                                                     ;
; print the contents of al as a hex digit to UART                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_hex_digit:
  cmp al, 0x0A
  jl print_hex_digit_noadd
  add al, 0x07

print_hex_digit_noadd:
  add al, '0'
  call print_char
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function print_string                                                        ;
; print a null-terminated string to UART                                       ;
; data is at DS:SI                                                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_string:
  print_string_loop:
    lodsb
    test al, al
    jz print_string_done
    call print_char
    jmp print_string_loop

  print_string_done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data section                                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

d_serial:
  db "  Serial: ", 0
d_model:
  db "   Model: ", 0
d_fw:
  db "Firmware: ", 0
d_lba_size:
  db "LBA size: ", 0
d_crlf:
  db 0x0D, 0x0A, 0


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