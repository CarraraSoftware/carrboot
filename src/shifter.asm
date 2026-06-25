BITS 32

%define BASEG 0x0
%define HALT jmp $

section .text
; -----------------------------------------------------------------------------;
; 32 BITS - CODE - Protected Mode                                              ;
; -----------------------------------------------------------------------------;
section .text.32

global _start
_start: ; protected_mode_main:
    call set_text_mode

    mov EAX,  0  ; col
    mov EBX,  10 ; row
    mov ECX, '$' ; char
    mov ESI, 10
.loop:
    cmp ESI, 0
    jle .end
    call putc ; putc(EAX, EBX, ECX) = putc(col, row, char)
    inc AL    ; col ++
    dec ESI   ; esi --
    jmp .loop
 .end:
    HALT
 
protected_mode_entry: ; Entry Point for when shifting from real mode
    mov AX, 0x10
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX
    mov SS, AX

    mov ESP, dword [protected_mode_sp] 
    mov EBP, dword [protected_mode_bp] 

    jmp dword [protected_mode_ret] ; goto [return]

    HALT

shift_real_mode: ; Shift[Prot Mode -> Real Mode]
    pusha
    mov dword [protected_mode_sp],  ESP
    mov dword [protected_mode_bp],  EBP
    mov dword [protected_mode_ret], the_return

    jmp real_mode
the_return:
    popa
    ret

putc:
; mov EAX, col
; mov EBX, row
; mov ECX, char
    pusha

    xor ESI, ESI

    ; idx = 2 * (row * NCOLS + col)
    mov ESI, 80      ; ESI = NCOLS 
    mul ESI, EBX     ; ESI = NCOLS * row
    add ESI, EAX     ; ESI = NCOLS * row + col
    mul ESI, 2       ; ESI = 2 * (NCOLS * row + col)

    mov EAX, 0xB8000 ; VRAM for text mode
    add EAX, ESI     ; EAX = VRAM[idx]
    mov [EAX], ECX   ; EAX = char
    inc EAX          ; EAX = VRAM[idx + 1]
    mov [EAX], 0x0A  ; EAX = { BG = black, FG = green }

    popa
    ret

set_text_mode:
    pusha
    mov dword [real_mode_cb], rtext_mode_cb ; which function from real mode do we need to run?
    call shift_real_mode
    popa
    ret


BITS 16
; -----------------------------------------------------------------------------;
; 16 BITS - CODE - Real Mode                                                   ;
; -----------------------------------------------------------------------------;
section .text.16.real

align 16
rtext_mode: 
    push AX
    mov AH, 0x00   ; select video mode
    mov AL, 0x02   ; text mode
    int 0x10       ; video interrupt
    pop AX
    ret

align 16
rtext_mode_cb:
    call rtext_mode           ; set video mode to text
    jmp shift_protected_mode ; go back to protected mode
    HALT ; unreachable

align 16
shift_protected_mode:  ; Shift[Real Mode -> Prot Mode]
    lgdt [gdtr]
    cli

    push EAX
    mov EAX, CR0      ; cr0                          
    or  EAX, 1        ; |--- 32 bits ---|           
    mov CR0, EAX      ; [ # # # # ... 1 ]           
    pop EAX           ;               ^-  protected mode
                           
    jmp 0x8:protected_mode_entry
    HALT


align 16
real_mode_entry:  ; Entry Point for when shifting from protected mode
    mov AX, BASEG
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX

    mov AX, 0x8000
    mov SS, AX
    mov SP, 0xFFFF

    lidt [idtr]
    sti

    jmp dword [real_mode_cb] ; run callback
    HALT ; unreachable


; -----------------------------------------------------------------------------;
; 16 BITS - CODE - Protected Mode                                              ;
; -----------------------------------------------------------------------------;
section .text.16.prot
align 16 

real_mode:
    cli
    mov EAX, CR0                       ; cr0
    and EAX, 0xFFFFFFFE                ; |--- 32 bits ---|
    mov CR0, EAX                       ; [ # # # # ... 0 ]
    jmp 0x0:real_mode_entry            ;               ^-  real mode


section .data

BITS 32 
; -----------------------------------------------------------------------------;
; 32 BITS - DATA - Protected Mode                                              ;
; -----------------------------------------------------------------------------;
section .data.32

protected_mode_ret: dd 0         ; where to return to in protected mode, when coming back from real mode
protected_mode_bp:  dd 0x80000   ; save stack base pointer 
protected_mode_sp:  dd 0x90000   ; save stack pointer 
real_mode_cb:  dd 0              ; callback to run in real mode 
    



BITS 16
;------------------------------------------------------------------------------;
; 16 BITS - Data                                                               ;
;------------------------------------------------------------------------------;
section .data.16

align 16
idtr:
idtsize:   dw 0xFFFF
idtoffset: dd 0

align 16
gdtr:
gdt_size: dw gdtend - gdt - 1
gdt_ptr:  dd gdt
align 16
gdt:
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 0x00: null segment
db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00 ; 0x08: 32bit - code segment (kernel)
db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00 ; 0x10: 32bit - data segment (kernel)
db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0x8F, 0x00 ; 0x18: 16bit - code segment (kernel)
db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0x8F, 0x00 ; 0x20: 16bit - data segment (kernel)
gdtend:

hello:    db "eh isso ai, soh uma demozinha pra fechar por hoje", 0x0D, 0x0A
hellolen: dw $ - hello

