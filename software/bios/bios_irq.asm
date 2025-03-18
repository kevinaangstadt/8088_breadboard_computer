; BIOS interrupt handlers

IRQ_halt:
  ; halt the CPU
  hlt
  jmp IRQ_halt

IRQ_nop:
  ; do nothing
  iret

IRQ_timer:
  ; backup ax
  push ax
  ; backup ds
  push ds

  ; set ds to BDA
  mov ax, 0x0040
  mov ds, ax
  
  ; dec the timer count
  dec byte [ds:BDA_TIMER_COUNT]
  ; check if the timer count is 0
  cmp byte [ds:BDA_TIMER_COUNT], 0
  ; if not, return
  jne .done

  ; reset the timer count (61 Hz)
  mov byte [ds:BDA_TIMER_COUNT], 61

  ; increment the clock by 1
  inc word [ds:BDA_CLK]

  ; check if there was a carry
  jnz .done

  ; there was a carry, increment the second
  inc word [ds:BDA_CLK + 2]

  ; check if there was a carry
  jnz .done

  ; increment the rollover
  inc byte [ds:BDA_CLK_Rollover]

.done:
  ; restore ds
  pop ds
  ; restore ax
  pop ax
  ; return from interrupt
  iret

IRQ_text:
  ; backup ax
  push ax
  ; backup dx
  push dx
  ; backup di
  push di
  ; backup ds
  push ds
  ; set ds to BDA
  mov ax, 0x0040
  mov ds, ax

  ; read the interrupt identification register
  mov dx, UART_IIR
  in al, dx

  ; check if the interrupt is for reading data
  and al, 0b00001110
  cmp al, 0b00000010

  ; if equal, this was a line status error
  je .done

  ; set the destinatino to the tail
  mov di, BDA_KB_BUFFER_TL

.read:
  ; check if there is space in the keyboard buffer
  mov al, [ds:BDA_KB_BUFFER_SIZE]
  cmp al, KB_BUFFER_SIZE
  jge .done

  ; there is space in the buffer

  ; check if there is data in the uart buffer
  mov dx, UART_LSR
  in al, dx
  and al, 0b00000001
  cmp al, 0
  je .done

  ; there is data in the buffer

  ; read the character from the uart buffer
  mov dx, UART_DATA
  in al, dx

  ; write the character to the keyboard buffer
  stosb

  ; increment the buffer size
  inc byte [ds:BDA_KB_BUFFER_SIZE]

  ; check if TL needs to wrap around
  cmp di, KB_BUFFER_SIZE + BDA_KB_BUFFER
  jb .read

  ; wrap around
  mov di, BDA_KB_BUFFER 

.done:
  ; restore ds
  pop ds
  ; restore di
  pop di
  ; restore dx
  pop dx
  ; restore ax
  pop ax
  ; return from interrupt
  iret


; IRQ 5 will be temporary to test the UART
IRQ_5h:
  ; print a string
  ; start of string in ax

  call fn_uart_print_str
  iret