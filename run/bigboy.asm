org 0x8000
bits 32

%define SW 320
%define SH 200

start:
    mov	    AX, 16		; set data segments to data selector (0x10)
	mov	    DS, AX
	mov	    SS, AX
	mov	    ES, AX
    mov     FS, AX
    mov     GS, AX
	mov		ESP, 90000h
    call    main

main:
    xor EAX, EAX
    xor EBX, EBX
    xor ECX, ECX
    xor EDI, EDI
    xor ESI, ESI

.outer:
    cmp EBX, SH
    jge .end

.inner:
    cmp EDI, SW
    jge .nextouter

    mov EAX, EBX      ; AX = row
    mov ECX, SW       ; CX = SW
    mul ECX           ; AX = AX * CX = row * SW
    mov ESI, EAX      ; SI = AX = row * SW
    add ESI, EDI      ; SI = SI + DI = row * SW + col
    add ESI, VRAM     ; SI = SI + VRAM = VRAM + row * SW + col = VRAM[row * SW + col]
    mov [ESI], 0x04   ; VRAM[row * SW + col] = 0xFF

    inc EDI
    jmp .inner

.nextouter:
    mov EDI, 0 
    inc EBX
    jmp .outer

.end:
    call halt

halt:
    jmp halt

VRAM EQU 0xA0000
