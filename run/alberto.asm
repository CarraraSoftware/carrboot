bits 16
org 0x1000

jmp main
main:
    ; init stack
    ; cli
    ; xor AX, AX
    ; mov DS, AX
    ; mov ES, AX

    ; mov AX, 0x6000
    ; mov SS, AX
    ; mov SP, 0x0000
    ; mov BP, 0x0000
    ; sti

    call init

    mov SI, hello
    call print_str

    ; mov AH, 0x00
    ; mov AL, 0x13
    ; int 0x10

    call a20
    cli
    lgdt [gdtr]
    mov eax, cr0
    or al, 1
    mov cr0, eax


    ; init = LOAD /init
    ; kernel = LOAD /LINUX
    ; flags = "initrd=/init rdinit=/bin/sh\0"
    ; params = &init, &flags
    ; push params
    ; jmp kernel
    ; encontrar corretamente o entry point do kernel
    ; jmp 0x8:kernel

    jmp 0x8:bigboy ; + bigboyoffset
    ; hlt
    ; jmp halt

a20:
    push AX
    mov AH, 0x24
    mov AL, 0x00
    int 0x15
    call checkcf
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


align 16
gdtr:
; dw = 2 bytes ; dd = double word = 4 bytes ; dq = quad word = 8 bytes
gdt_size: dw gdtend - gdt - 1
gdt_ptr:  dd gdt


align 16
gdt:

; null segment
dd 0x00, 0x00
; code segment
db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00
; data segment
db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00


; nulldesc:
; .size1:  dw 0x0000 ; size[00:15]
; .base1:  dw 0x0000 ; base[00:15]
; .base2:  db 0x00   ; base[16:23]
;         ;   [   |    |    |   |   |  |  |   ]
;         ;   [ A | RW | DC | X | S | DPL | P ]
; .flags1: db 0b00000000
;         ;   [  |  |  |    |   |   |   |   ]
;         ;   [ size[16:19] | V | L | D | G ]
; .flags2: db 0b00000000
; .base3:  db 0x00   ; base[24:31]
; nulldesc_end:
; 
; codedesc:
; .size1:  dw 0xFFFF ; size[00:15]
; .base1:  dw 0x0000 ; base[00:15]
; .base2:  db 0x00   ; base[16:23]
;         ;   [   |  |  |   |   |    |    |   ]
;         ;   [ P | DPL | S | X | DC | RW | A ]
;         ;     1   00    1   1   0    1    0
; .flags1: db 0b10011010
;         ;   [   |   |   |   |  |  |  |   ]
;         ;   [ G | D | L | V | size[16:19 ] 
;         ;   [ 1 | 1 | 0 | 0 |  0xF       ]
; .flags2: db 0b11001111
; .base3:  db 0x00   ; base[24:31]
; codedesc_end:
; 
; datadesc:
; .size1:  dw 0xFFFF ; size[00:15]
; .base1:  dw 0x0000 ; base[00:15]
; .base2:  db 0x00   ; base[16:23]
;         ;   [   |  |  |   |   |    |    |   ]
;         ;   [ P | DPL | S | X | DC | RW | A ]
;         ;   [ 1 | 00  | 1 | 0 | 0  |  1 | 0
; .flags1: db 0b10010010
;         ;   [   |   |   |   |  |  |  |   ]
;         ;   [ G | D | L | V | size[16:19 ]
;         ;   [ 1 | 1 | 0 | 0 |  0xF       ]
; .flags2: db 0b11001111
; .base3:  db 0x00   ; base[24:31]
; datadesc_end:

gdtend:




DRIVE_NUMBER: db 0
hello: db "hello from alberto", 0x0D, 0x0A, 0x00
cfnoerrormsg: db "No error in CF.", 0x0D, 0x0A, 0x00
cferrormsg:   db "An error was detected in CF.", 0x0D, 0x0A, 0x00
nullstr: db "\0", 0
filecluster: dw 0
errmsg: db "err", 0x00
buffat: dw 0xD000


bigboy       equ    0x8000
bigboyoffset equ 0x11843f0
base         equ 0x01156000
segoffset    equ 0x157000
    ; jmp bigboy
    ; mov		AX, 0x10		; set data segments to data selector (0x10)
	; mov		DS, AX
	; mov		SS, AX
	; mov		ES, AX
	; mov		ESP, 0x90000
    ; mov     EAX, 0x10
