[BITS 16]
ORG 0x7C00

jmp 0xFFFF:0h

times 510 - ($ - $$) db 0x00
db 0x55, 0xAA