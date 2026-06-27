bits 16
org 0x7C00
jmp main

main:
    mov AL, [bigo]
    mov AH, byte 0x0E 
    mov BH, byte 0x00
    mov BL, byte 0x00
    int 0x10

    jmp $ - 1

    cli
    lgdt [gdtr]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp 0x8:bigboy


align 16
gdtr:
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
gdtend:


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
; code ,   b, 

; codedesc:
; .size1:  dw 0xFFFF ; size[00:15] 0xff, 0xff
; .base1:  dw 0x0000 ; base[00:15] 0x00, 0x00,
; .base2:  db 0x00   ; base[16:23] 0x00,
;         ;   [   |  |  |   |   |    |    |   ]
;         ;   [ P | DPL | S | X | DC | RW | A ]
;         ;     1   00    1   1   0    1    0

;         ;     1   00    1   1   0    1    0
; .flags1: db 0b10011010
;         ;   [   |   |   |   |  |  |  |   ]
;         ;   [ G | D | L | V | size[16:19 ] 
;         ;   [ 1 | 1 | 0 | 0 |  0xF       ]
;         ;     0   0   0   0    0x0
; .flags2: db 0b11001111
; .base3:  db 0x00   ; base[24:31] 0x00
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
; 



bigo: db 0x6F
biga: db 0x41


bits 32
bigboy:
    mov EAX, 0xFFFFFFFF
    jmp bigboy 


bits 16
TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
