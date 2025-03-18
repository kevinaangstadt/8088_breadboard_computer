; Attempt to boot from the CF Card
POST_BOOT:
  ; set ds to 0x07C0
  mov ax, 0x07C0
  mov ds, ax

  ; set di to 0
  xor di, di

  ; set LBA
  xor ax, ax
  xor bx, bx

  call fn_cf_read_sector

  ; check for the magic boot number
  mov si, 0x1FE
  lodsw ; load word at ds:si into ax
  cmp ax, 0xAA55
  jne .boot_error

  mov ax, booting
  call fn_print_bios_str
  call fn_uart_newline

  ; jump to the boot sector
  jmp 0x7C0:0x0000


.boot_error:
  mov ax, boot_error
  call fn_print_bios_str
  call fn_uart_newline
