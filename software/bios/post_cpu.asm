; bios fragment for step 1 8088 CPU tests

POST_CPU_TESTS:

  ; test each of the flags in the FLAGS register
  ; jmp to .test_halt if any of the tests fail

  mov ax, 0x0000
  ; test carry flag
  ; set carry flag
  stc
  ; test if carry flag is set
  jnc .test_halt
  ; clear carry flag
  clc
  jc .test_halt

  ; test parity flag
  ; set parity flag
  mov al, 0b00000010
  add al, 1
  ; test if parity flag is set
  jnp .test_halt
  ; clear parity flag
  sub al, 1
  jp .test_halt

  ; test adjust flag (alternate carry flag)
  ; set adjust flag
  mov al, 0b00001111
  add al, 0b00001111
  ; test if adjust flag is set
  lahf  ; load flags into AH
  and ah, 0b00010000
  jz .test_halt
  ; clear adjust flag
  inc al
  lahf
  and ah, 0b00010000
  jnz .test_halt

  ; test zero flag
  ; set zero flag
  xor ax, ax
  ; test if zero flag is set
  jnz .test_halt
  ; clear zero flag
  inc ax
  jz .test_halt

  ; test sign flag
  ; set sign flag
  mov al, 0b01111111
  inc al
  ; test if sign flag is set
  jns .test_halt
  ; clear sign flag
  dec al
  js .test_halt

  ; test overflow flag
  ; set overflow flag
  mov al, 0b01111111
  inc al
  ; test if overflow flag is set
  jno .test_halt
  ; clear overflow flag
  inc al
  ; test if overflow flag is clear
  jo .test_halt

  jmp .test_complete

.test_halt:
  hlt
  jmp .test_halt

.test_complete:
