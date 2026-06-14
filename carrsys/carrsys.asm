BITS 32

section .text
global add
; int add(int a, int b);
add:
    push EBP
    mov EBP, ESP

    mov EAX, [EBP + 8]  ; int a 
    mov ECX, [EBP + 12] ; int b
    add EAX, ECX

    pop EBP

    ret
