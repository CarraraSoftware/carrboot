; just some useful wrappers to BIOS interrupts 
; related to outputing stuff into the screen

BITS 16

align 16
rgraphics_mode:
    mov AH, 0x00   ; select video mode
    mov AL, 0x13   ; graphics mode
    int 0x10       ; video interrupt
    ret

align 16
rtext_mode: 
    push AX
    mov AH, 0x00   ; select video mode
    mov AL, 0x02   ; text mode
    int 0x10       ; video interrupt
    pop AX
    ret

align 16
rprint:
; mov BX, string_pointer
; mov CX, string_len
    pusha
    push BP

    mov BX, somestr
    mov CX, [somelen]

    mov BP, BX           ; string_pointer goes in [ES:BP] for some reason, should use stack?
    mov AH, byte 0x13    ; write string 
    mov AL, byte 0x01    ; string with no attribute bytes, attr in BX && move cursor 
    mov BX, word 0x000F  ; attr => BG = black, FG = white
    mov DH, byte 0x04    ; row (starts from zero)
    mov DL, byte 0x00    ; col (starts from zero)
    int 0x10             ; video interrupt

    pop BP
    popa

    ret

align 16
rrstcur:
    pusha
    mov AH, byte 0x02   ; set cursor position
    xor DX, DX          ; cursor position (DH = row, DL = col)
    xor BH, BH          ; page number
    int 0x10            ; video interrupt
    popa
    ret

align 16
rclear:
    pusha
    mov AH, byte 0x06
    mov AL, byte 0x00
    mov BH, byte 0x0F
    mov BL, byte 0x00
    mov CH, byte 0x00
    mov CL, byte 0x00
    mov DH, byte 0xFF
    mov DL, byte 0xFF
    int 0x10
    popa
    ret

somestr: db "this is just some string", 0
somelen: dw $ - somestr
