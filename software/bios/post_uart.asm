; BIOS fragment to set up the UART and start output communication

POST_UART:
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

  ; FIXME test the UART with loopback