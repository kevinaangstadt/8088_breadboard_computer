; BIOS fragment for short beep of success
POST_BEEP_SUCCESS:
  ; turn on the speaker
  mov al, 0x03
  mov dx, PIO_PORTA
  out dx, al

  ; wait about 1/2 second
  mov cx, 0x7FFF
.loop:
  loop .loop

  ; turn off the speaker
  mov al, 0x00
  mov dx, PIO_PORTA
  out dx, al



