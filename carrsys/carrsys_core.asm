%ifndef CARRSYS_ASM_
%define CARRSYS_ASM_

%define HALT jmp $


BITS 32
section .text
;------------------------------------------------------------------------------;
; 32 BITS - CODE - Protected Mode {                                            ;
;------------------------------------------------------------------------------;
section .text.32

;//////////// Exported Routines /////////////////// ;
; @NOTE: this is here for testing the library as an standalone executable,
;        which may prove valuable in case of problems when linking with C (or anything else, i guess),
;        but it should not be present if there's actually a C file being linked with,
;        because the '_start' entry point should be over there and not here.
%ifdef CARRSYS_EXEC
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
%endif


global add 
; extern int add(int a, int b);
add:
    push EBP
    mov EBP, ESP

    mov EAX, [EBP + 8]  ; int a 
    mov ECX, [EBP + 12] ; int b
    add EAX, ECX

    mov ESP, EBP
    pop EBP

    ret

global set_graphics_mode
; extern void set_graphics_mode();
set_graphics_mode:
    push EBP
    mov EBP, ESP

    mov dword [real_mode_cb], rgraphics_mode; which function from real mode do we need to run?
    call shift_real_mode

    mov ESP, EBP
    pop EBP

    ret


global set_text_mode 
; extern void set_text_mode();
set_text_mode:
    push EBP
    mov EBP, ESP

    mov dword [real_mode_cb], rtext_mode ; which function from real mode do we need to run?
    call shift_real_mode

    mov ESP, EBP
    pop EBP

    ret


global read_file
; extern void read_file(char* name, char* buffer);
;+- EBP -+ EBP - 00
;|oldEBP |
;+-------+ EBP + 04
;|name   |
;+-------+ EBP + 08
;|buffer |
;+-------+ EBP + 12
read_file:
    push EBP
    mov EBP, ESP

    push EBX
    push EDI

    mov EDI, [EBP + 8]  ; name
    mov EBX, [EBP + 12] ; buffer

    mov dword [real_mode_cb], readfile
    call shift_real_mode

    pop EDI
    pop EBX

    mov ESP, EBP
    pop EBP
    ret

global read_sectors
; extern void read_sectors(byte* buffer, word lba, word num_sectors);
;+- EBP ------+ EBP - 00
;|oldEBP      |
;+------------+ EBP + 04
;|buffer      |
;+------------+ EBP + 08
;|lba         |
;+------------+ EBP + 10
;|num_sectors |
;+------------+ EBP + 12
read_sectors:
    push EBP
    mov EBP, ESP

    push EBX
    push EDI

    mov EBX, dword [EBP + 8] ; buffer
    mov CX,  word [EBP + 12] ; lba
    mov DI,  word [EBP + 16] ; num_sectors

    mov dword [real_mode_cb], read_sectors_RM
    call shift_real_mode

    pop EDI
    pop EBX

    mov ESP, EBP
    pop EBP
    ret



; global set_mode
; ; extern int set_mode(SysMode mode);
; set_mode: ; @TODO: implement parametrized set_mode
;     HALT

;///////////////////////////////////////////////// ;

protected_mode_entry: ; Entry Point for when shifting from real mode
    xor EAX, EAX
    mov AX, word 0x10
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX
    mov SS, AX

    mov ESP, dword [protected_mode_sp] 
    mov EBP, dword [protected_mode_bp] 

    jmp dword [protected_mode_ret] ; goto [return]
    HALT ; unreachable

shift_real_mode: ; Shift[Prot Mode -> Real Mode]
    mov dword [protected_mode_sp],  ESP ; expected to be initialized by alberto
    mov dword [protected_mode_bp],  EBP ; expected to be initialized by alberto
    mov dword [protected_mode_ret], the_return
    jmp far 0x18:real_mode
the_return:
    ret


; @TODO: mov this function to C code
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

;------------------------------------------------------------------------------;
; END 32 BITS - CODE - Protected Mode }                                        ;
;------------------------------------------------------------------------------;


;//////////////////////////////////////////////////////////////////////////////;


BITS 16
; -----------------------------------------------------------------------------;
; 16 BITS - CODE - Protected Mode {                                            ;
; -----------------------------------------------------------------------------;
section .text.16.prot
align 16 
; @NOTE: is this actually UNreal mode? 
real_mode:
    mov AX, 0x20
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX
    mov SS, AX

    cli

    mov EAX, CR0                       ; cr0
    and EAX, 0xFFFFFFFE                ; |--- 32 bits ---|
    mov CR0, EAX                       ; [ # # # # ... 0 ]
                                       ;               ^-real mode
    jmp far 0x0:real_mode_entry ; @NOTE: 0x0? why?

; -----------------------------------------------------------------------------;
; END 16 BITS - CODE - Protected Mode }                                        ;
; -----------------------------------------------------------------------------;


; /////////////////////////////////////////////////////////////////////////////;


BITS 16
; -----------------------------------------------------------------------------;
; 16 BITS - CODE - Real Mode  {                                                ; 
; -----------------------------------------------------------------------------;
section .text.16.real

align 16
shift_protected_mode:  ; Shift[Real Mode -> Prot Mode]
    cli

    lgdt [gdtr]

    xor EAX, EAX
    mov CR3, EAX

    xor EAX, EAX
    mov EAX, CR0      ; cr0                          
    or  EAX, 1        ; |--- 32 bits ---|           
    mov CR0, EAX      ; [ # # # # ... 1 ]           
                      ;               ^-  protected mode
                           
    jmp 0x8:protected_mode_entry
    HALT

align 16
real_mode_entry:  ; Entry Point for when shifting from protected mode.
                  ; This routine should be called from 16 bits protected mode code.

    ; call restore_ivt
    lidt [idtr]
    sti

    xor AX, AX
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX
    mov SS, AX
    mov SP, rstackini
    mov BP, SP

    call dword [real_mode_cb] ; run callback

    jmp shift_protected_mode  ; go back to protected mode
    HALT ; unreachable


%define FAT_CODE_
%include "include/fat.asm"
%undef FAT_CODE_

%include "src/realio.asm"

%define IVT_CODE_
%include "include/ivt.asm"
%undef IVT_CODE_


; -----------------------------------------------------------------------------;
; END 16 BITS - CODE - Real Mode  }                                            ; 
; -----------------------------------------------------------------------------;


; /////////////////////////////////////////////////////////////////////////////;


BITS 32 
; -----------------------------------------------------------------------------;
; 32 BITS - DATA - Protected Mode {                                            ;
; -----------------------------------------------------------------------------;
section .data.32

protected_mode_ret: dd 0  ; where to return to in protected mode, when coming back from real mode
protected_mode_bp:  dd 0  ; save stack base pointer 
protected_mode_sp:  dd 0  ; save stack pointer 

real_mode_cb:       dd 0  ; callback to run in real mode 

; -----------------------------------------------------------------------------;
; END 32 BITS - DATA - Protected Mode }                                        ;
; -----------------------------------------------------------------------------;


;//////////////////////////////////////////////////////////////////////////////;


BITS 16
;------------------------------------------------------------------------------;
; 16 BITS - Data {                                                             ;
;------------------------------------------------------------------------------;
section .data.16

%define FAT_BPB_
%include "include/fat.asm"
%undef FAT_BPB_


; IVT (Interrupt Vector Table)
%define IVT_DATA_
%include "include/ivt.asm"
%undef IVT_DATA_

%include "include/gdt.asm"
%include "include/mem.asm"

;------------------------------------------------------------------------------;
; END 16 BITS - Data }                                                         ;
;------------------------------------------------------------------------------;
%endif ; CARRSYS_ASM_
