; various definitions for the bios

; NOTE: the PIC lives at IO port 0x0000
PIC_0 equ 0x0000
PIC_1 equ 0x0001
PIC_MASK equ PIC_1

; NOTE: the timer lives at IO port 0x2000

CNT_A equ 0x2000
CNT_B equ 0x2001
CNT_C equ 0x2002
TIMER_CTL equ 0x2003

; NOTE: the PIO lives at IO port 0x4000
PIO_PORTA equ 0x4000
PIO_PORTB equ 0x4001
PIO_PORTC equ 0x4002
PIO_CTRL equ 0x4003

LCD_E equ 0x01
LCD_RS equ 0x04
LCD_RW equ 0x02

; NOTE: the UART lives at IO port 0x6000
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

UART_ESC equ 0x1B

; RAM size in KB
RAM_SIZE equ 0x3F0


; BIOS Data Area
BDA_RAM equ 0x0013