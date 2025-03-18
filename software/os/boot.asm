bits 16

; starts at 0 in segment 0x7c00
org 0x0000

KSEG	  equ 0x1000		;kernel goes into memory at 0x10000

    mov ax, KSEG
    mov ss, ax

    mov ax, 0x07C0
    mov ds, ax

    ; let's have the stack start at KSEG:fff0
	mov ax,0xfff0
	mov sp,ax
	mov bp,ax

    ; print hello world using the uart
    mov ax, hello
    int 0x05

halt:
    hlt
    jmp halt

hello:
    db 'Hello World!', 0

    ; fill remaining bytes with 0
	times 510-($-$$) db 0

	; AA55 tells BIOS that this is a valid bootloader
	dw 0xAA55