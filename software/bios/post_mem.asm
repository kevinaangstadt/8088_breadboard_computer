; BIOS excerpt for testing the remaining parts of memory

POST_MEM:
  

  call fn_clear_lcd

  ; get the size of the RAM
  ; set the ES to the start of RAM
  xor ax, ax
  mov es, ax

  ; set the DS to the BIOS
  mov ax, 0xF000
  mov ds, ax

  mov cx, [es:BDA_RAM]
  ; subtract the 64KB we already tested
  sub cx, 0x40

  ; store the number of 4k blocks in AX
  mov ax, 16

  push ax
  ; multiple number of blocks by 4KiB
  shl ax, 1
  shl ax, 1

  push cx
  
  call fn_print_lcd_int

  mov ax, memcheck_str
  call fn_print_lcd_str


.loop:

  ; pop cx
  pop cx

  ; see if we have more to do
  cmp cx, 0
  je POST_MEM_DONE

  ; subtract 4KiB from the size
  sub cx, 4

  push cx

  ; store base pointer
  push bp
  mov bp, sp 

  ; push the start address (0x400 * [ES:BDA_RAM] - CX)
  mov ax, [es:BDA_RAM]
  sub ax, cx
  mov cx, 10
  shl ax, cl





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

  ; check if cx < 12
  cmp cx, 12
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
.halt:
  ; halt the CPU
  hlt  


POST_MEM_DONE: