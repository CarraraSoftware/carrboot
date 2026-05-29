org 0x8000
bits 32
main:
    mov		AX, 0x10		; set data segments to data selector (0x10)
	mov		DS, AX
	mov		SS, AX
	mov		ES, AX
	mov		ESP, 90000h
    mov     EAX, 0x10
halt:
    jmp halt
