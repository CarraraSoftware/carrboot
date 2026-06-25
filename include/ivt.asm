BITS 16

%ifdef IVT_CODE_

align 16
store_ivt: ; save 1024 bytes from range [0x0-0x3FF] to address that [ivtsave] poins to
           ; expects everything to be in segment 0.
    pusha
    xor SI, SI      ; source  = 0x0
    mov DI, ivtsave ; dest    = ivtsave
    mov CX, 0x500   ; num_rep = 1024
    rep movsb       ; mov byte from SI to DI and increment them, CX times
    popa
    ret

align 16
restore_ivt: ; save 1024 bytes from the address pointed by [ivtsave] to range [0x0-0x3FF] 
             ; expects everything to be in segment 0.
    pusha
    mov SI, ivtsave ; source  = ivtsave
    xor DI, DI      ; dest    = 0
    mov CX, 0x500   ; num_rep = 1024
    rep movsb       ; mov byte from SI to DI and increment them, CX times
    popa
    ret


%endif

; -----------------------------------------------------------------------------

%ifdef IVT_DATA_

align 16 
idtr:
idtsize:   dw 0x3FF
idtoffset: dd 0x000

%endif
