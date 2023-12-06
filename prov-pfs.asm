incbin "./loader/mbr"

times 512 db 0x00

incbin "./loader/vbr"