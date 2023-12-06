[BITS 16]
[ORG 0x7A00]

; pause any interrups
cli

; relocate mbr
mov si, 0x7C00
mov di, 0x7A00
mov cx, 0x0100

rep movsw

; initialize registers

mov ax, 0x00
mov ds, ax

mov ax, 0x07A0
mov ss, ax

xor ax, ax
xor bx, bx
xor cx, cx

xor si, si
xor di, di

; start mbr bootcode
jmp mbr_main

_REBOOT:
    jmp 0xFFFF:0000h
    hlt

mbr_main:
    sti

    mov  si, _STR_MSG_START
    call func_print_str

    call func_chk_part

    mov  si, _STR_MSG_DETECT
    call func_print_str

    call func_load_vbr
    
    mov  si, _STR_MSG_JUMP
    call func_print_str

    jmp 0:0x7c00

func_chk_part:
    push ax
    push bx

    mov bx, __ENTRY1
    
    func_chk_part.loop:
    cmp bx, __MAGIC
    jz  func_chk_part.end.err   ; no active partition found

    cmp BYTE[bx], 0x80          ; check partition is active
    jnz func_chk_part.loop.next

    mov al, BYTE[bx + 0x3]      ; set disk sector start
    jmp func_chk_part.end

    func_chk_part.loop.next:
    add bx, 0x10
    jmp func_chk_part.loop
    
    func_chk_part.end:
    mov cl, al
    
    pop bx
    pop ax

    ret

    func_chk_part.end.err:
    mov si, _STR_MSG_NOFACT
    call func_print_str
    
    hlt

func_load_vbr:
    mov si, _STR_MSG_LDRVBR
    call func_print_str

    ; load from dl
    ; cl is already loaded in func_chk_part
    ; with int 0x13, ah = 0x02
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov dh, 0x00

    ; target to 0x07C0:0000
    mov bx, 0x07C0
    mov es, bx
    xor bx, bx

    ; TODO: seems stuck here
    int 0x13
    jc  func_load_vbr.err

    ret

    func_load_vbr.err:
    mov si, _STR_MSG_VBRERR
    call func_print_str

    hlt


func_load_vbr.error_reboot:
    jmp _REBOOT

func_print_str:
    push ax
    push bx

    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x00        ; BG: Black, FG: Light green 

    func_print_str.loop:
        mov al, BYTE[si]
        int 0x10

        inc si
        cmp BYTE[si], 0x00
        jnz func_print_str.loop

    pop bx
    pop ax

    ret

_DBG:
    mov si, _STR_MSG_DEBUG
    call func_print_str
    
    hlt

__DATA_VARS:
    

__DATA_STR:
    _STR_MSG_DEBUG:  db  0x0D, 0x0A, "!DEBUG HIT!", 0x0D, 0x0A, 0x00
    _STR_MSG_START:  db "MBR Bootcode Started...", 0x0D, 0x0A, 0x00
    _STR_MSG_NOFACT: db "Active partition does not exist...", 0x0D, 0x0A, 0x00
    _STR_MSG_VBRERR: db "Error occured while reading VBR...", 0x0D, 0x0A, 0x00
    _STR_MSG_DETECT: db "VBR Bootcode Detected...", 0x0D, 0x0A, 0x00
    _STR_MSG_LDRVBR: db "Reading VBR Bootcode from current drive...", 0x0D, 0x0A, 0x00
    _STR_MSG_JUMP:   db "Starting VBR Bootcode...", 0x0D, 0x0A, 0x00


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
