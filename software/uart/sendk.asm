; send the letter K repeatedly over the UART

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

sendK:
  mov dx, UART_DATA
  mov al, 'K'
  out dx, al
  jmp sendK

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