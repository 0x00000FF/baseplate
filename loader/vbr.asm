[BITS 16]
[ORG 0x7C00]

vbr_main:
    jmp $

    ; check A20 line and enable

    ; read kernel loader

    ; jump to loader
    jmp 0x1000:0

vbr_fault:
    jmp 0xffff:0

__DATA_VARS:

__DATA_STR:

times 510 - ($ - $$) db 0x00

__MAGIC:
    db 0x55, 0xAA