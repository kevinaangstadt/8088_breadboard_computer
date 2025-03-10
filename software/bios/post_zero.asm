; BIOS fragment to zero all of the RAM
; We're going to do this naively by zeroing the full 1MB address space
; Writing to ROM has no effect

POST_ZERO:
  ; set cx to 16 (the number of 64KiB blocks)
  mov cx, 16

  xor ax, ax

.segment_loop:
  ; set the DS to the current segment
  mov ds, ax
  
  ; set SI to the start of block
  xor si, si

.loop:
  mov byte [ds:si], 0
  inc si
  ; there will be a carry if we have reached the end of the block
  jnc .loop

  ; increment the segment
  add ax, 0x1000
  
  loop .segment_loop
