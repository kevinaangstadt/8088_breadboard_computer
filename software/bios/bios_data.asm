; static data from the BIOS

memcheck_patterns: db 0xAA, 0x55, 0x00, 0xFF, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80
memcheck_str: db "KiB Verified", 0
memcheck_passed_str: db "Memcheck Passed", 0
crc_passed: db "CRC Passed", 0
booting: db "Booting...", 0
boot_error: db "No Bootable Device", 0

CF_ERROR: db "CF Error: ", 0
CF_str_serial:
  db "  Serial: ", 0
CF_str_model:
  db "   Model: ", 0
CF_str_fw:
  db "Firmware: ", 0

