bits 16
org 0x7C00

; jmp main
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
