[BITS 16]
[ORG  0x7C00]

mov ax, 0x07c0

;mov ss, ax
;mov ds, ax

jmp mbr_main

_REBOOT:
    jmp 0xFFFF:0000h
    hlt

mbr_main:
    call func_chk_part
    call func_load_vbr
    
    jmp 0x07c0:0

func_chk_part:
    push bx
    push cx

    mov bx, __ENTRY1
    
    func_chk_part.loop:
    cmp bx, __MAGIC
    jz  func_chk_part.end 

    cmp BYTE[bx], 0x80
    jnz func_chk_part.loop.next

    mov cl, 0x01
    mov ax, WORD[bx + 0x3]      ; set disk sector start

    jmp func_chk_part.end

    func_chk_part.loop.next:
    add bx, 0x10
    
    func_chk_part.end:
    cmp cx, 0x00                ; check found
    jz func_chk_part.end.err
    
    pop bx
    pop cx

    ret

    func_chk_part.end.err:
    hlt

func_load_vbr:
    ; load from dl
    ; al is already loaded in func_chk_part
    ; with int 0x13, ah = 0x02
    mov ah, 0x02
    mov ch, 0x00
    mov dh, 0x00

    ; target to 0x07C0:0
    mov bx, 0x07C0
    mov es, bx

    xor bx, bx

    ; TODO: CF occurs fix needed 
    int 0x13
    ret

func_load_vbr.error_reboot:
    jmp _REBOOT

TIMES 446 - ($ - $$) db 0x00

__PARTITION_TABLE:
    __ENTRY1:
    db 0x80             ; Status (Active)
    db 0x00, 0x00, 0x03 ; CHS Start
    db 0x00,            ; Type
    db 0x00, 0x00, 0x14 ; CHS End
    
    dw 0x0000
    dw 0x0000           ; LBA Start
    dw 0x0000
    dw 0x0000           ; LBA Size (in Sectors)

    _ENTRY2:            ; Empty
    TIMES 16 db 0x00

    _ENTRY3:            ; Empty
    TIMES 16 db 0x00

    _ENTRY4:            ; Empty
    TIMES 16 db 0x00

__MAGIC:
    db 0x55, 0xAA