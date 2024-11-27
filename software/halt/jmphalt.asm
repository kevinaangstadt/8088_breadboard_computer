BITS 16

; jump to the beginning of ROM to run the halt commands

; the upper ROM chip starts at address 0xFE000
org 0xFE000
  hlt
  
; pad up to 0xFFFF0
  times (0xFFFF0 - 0xFE000) - ($ - $$) db 0


; we are now at 0xFFFF0, the reset vector
  cli
  jmp 0xFE00:0x0000

; pad to 0xFFFFF
; $ represents the current address, and $$ represents the starting address
  times (0x100000 - 0xFE000) - ($ - $$) db 0

