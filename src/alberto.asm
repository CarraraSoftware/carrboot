bits 16
org 0x1000

%define PMODE_SP 0x90000

%macro sayhello 0
    mov SI, hello
    call print_str
%endmacro

%macro setmode 1
; mov AL, 0x13 ; Graphics mode
; mov AL, 0x02 ; Text mode
    mov AL, %1
    mov AH, 0x00
    int 0x10
%endmacro


section .text
global _start
_start:
    call init

    ; sayhello
    ; setmode 0x13

    call a20

    cli

    call store_ivt

    lgdt [gdtr]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    
    jmp 0x8:execelf

    ; init = LOAD /init
    ; kernel = LOAD /LINUX
    ; flags = "initrd=/init rdinit=/bin/sh\0"
    ; params = &init, &flags
    ; push params
    ; jmp kernel
    ; encontrar corretamente o entry point do kernel
    ; jmp 0x8:kernel

    ; jmp 0x8:bigboy; + bigboyoffset
    ; hlt

BITS 32
execelf:
    mov AX, 0x10
    mov DS, AX
    mov SS, AX
    mov ES, AX
    mov ESP, PMODE_SP
    mov EBP, ESP

; skip headers
    mov EBX, bigboy
    xor EAX, EAX
    mov AX, word [bigboy + 42] ; Elf32_Half e_phentsize
    mul AX, word [bigboy + 44] ; Elf32_Half e_phnum
    add EAX, 52                ; sizeof(Elf32_Ehdr)
    add EBX, EAX

; skip possible padding
.loop:
    mov SI, word [EBX]
    cmp SI, 0x0
    jne .end
    inc EBX
    jmp .loop
.end:
    inc EBX

; jump calculated offset
    jmp EBX


BITS 16
header:
    push SI
    push AX
    push BX
    push CX
    push ES

    mov AX, 0xB800
    mov ES, AX
    mov SI, 0 
.loop:
    cmp SI, 52
    jge .end
        
    mov CX, [bigboy + SI]
    mov BX, SI
    mul BX, 2
    mov [ES:BX], CX
    inc BX
    mov [ES:BX], 0x0F
    inc SI
    jmp .loop

.end:
    pop ES
    pop CX
    pop BX
    pop AX
    pop SI

    ret


a20:
    push AX
    mov AH, 0x24
    mov AL, 0x00
    int 0x15
    ; call checkcf
    pop AX
    ret

init:
    mov [DRIVE_NUMBER], DL
    call clear
    ; cursor to (0,0)
    mov AH, byte 0x02
    xor BX, BX
    xor DX, DX
    int 0x10

    ret

print_str:
; expects string at SI
    push AX
    push SI
.loop:
    mov AL, [SI]
    cmp AL, byte 0 
    je .end
    inc SI
    call print_chr
    jmp .loop
.end:
    pop SI
    pop AX
    ret

print_chr:
; expects char at AL
    pusha
    test AL, AL
    jnz .notzero
    mov SI, nullstr 
    call print_str
    jmp .end
.notzero:
    mov AH, byte 0x0E 
    mov BH, byte 0x00
    mov BL, byte 0x00
    int 0x10
.end:
    popa
    ret

halt:
    jmp halt

clear:
    mov AH, byte 0x06
    mov AL, byte 0x00
    mov BH, byte 0x0F
    mov BL, byte 0x00
    mov CH, byte 0x00
    mov CL, byte 0x00
    mov DH, byte 0xFF
    mov DL, byte 0xFF
    int 0x10
    ret

checkcf:
    push SI
    jc .cferror
    mov SI, cfnoerrormsg
    jmp .cfend
.cferror:
    mov SI, cferrormsg
.cfend:
    call print_str
    pop SI
    ret

%define IVT_CODE_
%include "include/ivt.asm"
%undef IVT_CODE_



align 16
section .data

%include "include/gdt.asm"
%include "include/mem.asm"

DRIVE_NUMBER: db 0
hello: db "hello from alberto", 0x0D, 0x0A, 0x00
cfnoerrormsg: db "No error in CF.", 0x0D, 0x0A, 0x00
cferrormsg:   db "An error was detected in CF.", 0x0D, 0x0A, 0x00
nullstr: db "\0", 0
filecluster: dw 0
errmsg: db "err", 0x00

