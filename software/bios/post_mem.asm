; BIOS excerpt for testing the remaining parts of memory

POST_MEM:

  ; set DS to the start of ROM
  push ds
  mov ax, 0xF000
  mov ds, ax

  ; print the static string of RAM checked at LCD offset 4
  mov ax, 4
  call fn_lcd_move_cursor
  mov ax, memcheck_str
  call fn_print_lcd_str
  
  mov ax, 0x0501
  call fn_uart_move_cursor

  mov ax, memcheck_str
  call fn_uart_print_str
  pop ds

  ; move LCD to 0
  xor al, al
  call fn_lcd_move_cursor

  call fn_uart_move_cursor_home

  ; get the size of the RAM
  ; set the ES to the BDA segment
  mov ax, 0x0040
  mov es, ax

  ; set the DS to the BIOS
  mov ax, 0xF000
  mov ds, ax

  mov cx, [es:BDA_RAM]
  ; subtract the 16KB we already tested
  sub cx, 0x10

  ; store the number of 4k blocks in AX
  mov ax, 4

.loop:
  ; ax contains the number of 4KiB blocks tested 
  push ax

  ; multiple number of blocks by 4KiB
  shl ax, 1
  shl ax, 1

  push cx
  
  call fn_print_lcd_int
  call fn_uart_print_int

  ; pop cx
  pop cx

  ; see if we have more to do
  cmp cx, 0
  je .done

  push cx

  ; store base pointer
  push bp
  mov bp, sp 

  ; push the start address (0x400 * [ES:BDA_RAM] - CX)
  ; this is because it is the start = 1024 * (total RAM - 64)KB
  mov ax, [es:BDA_RAM]
  sub ax, cx
  ; store this start in KB
  mov bx, ax
  mov cx, 10
  shl ax, cl
  push ax

  ; push the data segment
  ; restore the start in KB
  mov ax, bx
  mov cx, 6
  ; shift this into the high byte
  shl ax, cl
  ; and out just the high nibble 
  and ax, 0xF000
  push ax  

  ; call the function 
  call fn_memcheck_4kb

  ; pop the arguments 
  add sp, 4

  ; restore bp
  pop bp 

  ; pop cx
  ; it contains KB to check
  pop cx

  ; subtract the 4Kb
  sub cx, 4

  ; move LCD to 0
  xor al, al
  call fn_lcd_move_cursor
  call fn_uart_move_cursor_home

  ; restore the number of 4KiB blocks tested
  pop ax
  ; increment by 1 for the next tested
  inc ax 

  ; jump back to the start of the loop
  jmp .loop

.done:
  ; trampoline because the offset is too far
  jmp POST_MEM_DONE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function to check a 4KiB block of RAM                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fn_memcheck_4kb:
  ; function for checking the RAM at a specific 4KiB block
  ; bp - 2: start address
  ; bp - 4: data segment
  ; bp - 6: return address

  ; back up the data segment
  push ds

  ; back up the extra segment
  push es

  ; set the extra segment to the ROM
  xor ax, ax
  or ax, 0xF000
  mov es, ax

  ; back si and di
  push si
  push di

  mov ds, [bp - 4]
  mov si, [bp - 2]

  ; set the ending address of the RAM block
  mov di, si
  add di, 0xFFF

  ; loop through the 4KiB block
.memcheck_4kb_loop:

  ; set up CX to loop through the patterns
  mov cx, 0
  mov bx, memcheck_patterns

  ; loop through the patterns
.memcheck_4kb_pattern_loop:
  ; write the pattern to the RAM

  mov al, [es:bx]
  mov [ds:si], al
  ; read the RAM
  mov al, [ds:si]
  ; compare the RAM with the pattern
  cmp al, [es:bx]
  jne .memcheck_4kb_pattern_failed

  inc cx
  inc bx

  ; check if cx < 5
  ; per https://retrocomputing.stackexchange.com/a/7872
  ; we only need to check 5 patterns
  ; 0x00, 0xFF, 0xAA, 0x55, 0x01
  cmp cx, 5
  jl .memcheck_4kb_pattern_loop

  ; increment the address (use add not inc because it allows for CF to be set)
  add si, 1
  ; when we do 0xFFFF, we will wrap around to 0x0000, which breaks the loop
  jc .memcheck_4kb_pattern_passed

  ; check if we have reached the end of the 4KiB block
  cmp si, di
  jbe .memcheck_4kb_loop

.memcheck_4kb_pattern_passed:
  ; restore
  pop di
  pop si
  pop es
  pop ds
  ret

.memcheck_4kb_pattern_failed:
  push ax
  mov al, 0x40
  call fn_lcd_move_cursor
  pop ax
  xor ah, ah
  call fn_print_lcd_hex_int
.halt:
  ; halt the CPU
  hlt  


POST_MEM_DONE:
  ; print a newline
  call fn_uart_newline