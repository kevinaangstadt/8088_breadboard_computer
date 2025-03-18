; BIOS fragment to detect and initialize the CF card
POST_CF:
  call CFInit

  ; store the CF info BDA:CF_INFO
  mov ax, 0x0040
  mov ds, ax
  mov di, BDA_CF_INFO
  call CFInfo
