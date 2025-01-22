; echo back over UART whatever was received

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

; NOTE: the PIC lives at IO port 0x0000
PIC_0 equ 0x0000
PIC_1 equ 0x0001
PIC_MASK equ PIC_1


org 0xFE000

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
  mov al, 0b11101111
  mov dx, PIC_MASK
  out dx, al


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up interrupt vector table                                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; data for now is interrupt vector table
  mov ax, 0x0000
  mov ds, ax

  ; set up the not implemented interrupt
  mov ax, unused_interrupt
  mov [0x0000], ax
  mov [0x0004], ax
  mov [0x0008], ax
  mov [0x000C], ax
  mov [0x0010], ax
  mov [0x0020], ax  ; timer unused

  mov [0x0002], word 0xF000
  mov [0x0006], word 0xF000
  mov [0x000A], word 0xF000
  mov [0x000E], word 0xF000
  mov [0x0012], word 0xF000
  mov [0x0022], word 0xF000

  ; set up the UART interrupt
  mov ax, uart_interrupt
  mov [0x0030], ax
  mov [0x0032], word 0xF000


  ; enable interrupts and halt
busy_wait:
  sti
  hlt
  jmp busy_wait
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UART Interrupt Service Routine                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
uart_interrupt:
  push ax
  push dx 

  ; read the interrupt identification register
  mov dx, UART_IIR
  in al, dx

  ; check if the interrupt is for reading data
  and al, 0b00001110
  cmp al, 0b00000010

  ; if equal, this was a line status error
  je uart_interrupt_done


  ; read the data from the fifo register
  mov dx, UART_DATA
  in al, dx

;   ; we are going to be bad and busy wait in an interrupt handler 
;   ; until the transmit buffer is empty
;   mov dx, UART_LSR
; uart_interrupt_wait:
;   in al, dx
;   cmp al, 0b00100000
;   jne uart_interrupt_wait

  ; write the data to the data register
  mov dx, UART_DATA
  out dx, al

  ; done
uart_interrupt_done:
  pop dx
  pop ax
  iret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up the unused handler                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

unused_interrupt:
  iret

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