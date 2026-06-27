	.file	"cigboy.c"
	.intel_syntax noprefix
	.text
	.globl	_start
	.type	_start, @function
_start:
.LFB0:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
#APP
# 4 "src/cigboy.c" 1
	jmp main

# 0 "" 2
#NO_APP
	nop
	ud2
	.cfi_endproc
.LFE0:
	.size	_start, .-_start
	.globl	VRAM
	.section	.rodata
	.align 4
	.type	VRAM, @object
	.size	VRAM, 4
VRAM:
	.long	753664
	.globl	msg
.LC0:
	.string	"Essa eh uma string do cigboy."
	.section	.data.rel.local,"aw"
	.align 4
	.type	msg, @object
	.size	msg, 4
msg:
	.long	.LC0
	.globl	buf
	.data
	.align 4
	.type	buf, @object
	.size	buf, 4
buf:
	.long	45056
	.globl	name
	.section	.rodata
.LC1:
	.string	"TESTE      "
	.section	.data.rel.local
	.align 4
	.type	name, @object
	.size	name, 4
name:
	.long	.LC1
	.text
	.globl	halt
	.type	halt, @function
halt:
.LFB1:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
.L3:
	jmp	.L3
	.cfi_endproc
.LFE1:
	.size	halt, .-halt
	.globl	clear
	.type	clear, @function
clear:
.LFB2:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 16
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	BYTE PTR -5[ebp], 0
	mov	DWORD PTR -4[ebp], 0
	jmp	.L5
.L6:
	mov	edx, 753664
	mov	eax, DWORD PTR -4[ebp]
	add	eax, eax
	add	eax, edx
	mov	BYTE PTR [eax], 32
	mov	edx, 753664
	mov	eax, DWORD PTR -4[ebp]
	add	eax, eax
	inc	eax
	add	edx, eax
	mov	al, BYTE PTR -5[ebp]
	mov	BYTE PTR [edx], al
	inc	DWORD PTR -4[ebp]
.L5:
	cmp	DWORD PTR -4[ebp], 79
	jle	.L6
	nop
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE2:
	.size	clear, .-clear
	.globl	putc
	.type	putc, @function
putc:
.LFB3:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 8
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR 8[ebp]
	mov	eax, DWORD PTR 12[ebp]
	mov	BYTE PTR -4[ebp], dl
	mov	BYTE PTR -8[ebp], al
	mov	edx, 753664
	mov	eax, DWORD PTR 16[ebp]
	add	eax, eax
	add	edx, eax
	mov	al, BYTE PTR -4[ebp]
	mov	BYTE PTR [edx], al
	mov	edx, 753664
	mov	eax, DWORD PTR 16[ebp]
	add	eax, eax
	inc	eax
	add	edx, eax
	mov	al, BYTE PTR -8[ebp]
	mov	BYTE PTR [edx], al
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE3:
	.size	putc, .-putc
	.globl	print
	.type	print, @function
print:
.LFB4:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 20
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR 12[ebp]
	mov	BYTE PTR -20[ebp], al
	mov	DWORD PTR -4[ebp], 0
	jmp	.L9
.L10:
	movsx	edx, BYTE PTR -20[ebp]
	mov	ecx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR 8[ebp]
	add	eax, ecx
	mov	al, BYTE PTR [eax]
	movsx	eax, al
	push	DWORD PTR -4[ebp]
	push	edx
	push	eax
	call	putc
	add	esp, 12
	inc	DWORD PTR -4[ebp]
.L9:
	mov	edx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR 8[ebp]
	add	eax, edx
	mov	al, BYTE PTR [eax]
	test	al, al
	jne	.L10
	nop
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE4:
	.size	print, .-print
	.globl	printn
	.type	printn, @function
printn:
.LFB5:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 20
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR 12[ebp]
	mov	BYTE PTR -20[ebp], al
	mov	DWORD PTR -4[ebp], 0
	jmp	.L12
.L13:
	movsx	edx, BYTE PTR -20[ebp]
	mov	ecx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR 8[ebp]
	add	eax, ecx
	mov	al, BYTE PTR [eax]
	movsx	eax, al
	push	DWORD PTR -4[ebp]
	push	edx
	push	eax
	call	putc
	add	esp, 12
	inc	DWORD PTR -4[ebp]
.L12:
	mov	eax, DWORD PTR -4[ebp]
	cmp	eax, DWORD PTR 16[ebp]
	jl	.L13
	nop
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE5:
	.size	printn, .-printn
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	lea	ecx, 4[esp]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR -4[ecx]
	push	ebp
	mov	ebp, esp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	push	ebx
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x78,0x6
	.cfi_escape 0x10,0x3,0x2,0x75,0x7c
	sub	esp, 16
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	BYTE PTR -9[ebp], 2
	call	set_text_mode@PLT
	mov	edx, DWORD PTR buf@GOTOFF[ebx]
	mov	eax, DWORD PTR name@GOTOFF[ebx]
	sub	esp, 8
	push	edx
	push	eax
	call	read_file@PLT
	add	esp, 16
	call	clear
	sub	esp, 4
	push	0
	push	10
	push	42
	call	putc
	add	esp, 16
	mov	eax, DWORD PTR msg@GOTOFF[ebx]
	sub	esp, 8
	push	10
	push	eax
	call	print
	add	esp, 16
	mov	WORD PTR -12[ebp], 320
	mov	DWORD PTR -16[ebp], 26
	mov	DWORD PTR -20[ebp], 64
	sub	esp, 8
	push	64
	push	26
	call	add@PLT
	add	esp, 16
	mov	DWORD PTR -24[ebp], eax
	movsx	ecx, WORD PTR -12[ebp]
	movsx	edx, BYTE PTR -9[ebp]
	mov	eax, DWORD PTR -24[ebp]
	movsx	eax, al
	sub	esp, 4
	push	ecx
	push	edx
	push	eax
	call	putc
	add	esp, 16
	call	halt
	mov	eax, 0
	lea	esp, -8[ebp]
	pop	ecx
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	pop	ebx
	.cfi_restore 3
	pop	ebp
	.cfi_restore 5
	lea	esp, -4[ecx]
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB7:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE7:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB8:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE8:
	.ident	"GCC: (GNU) 15.2.1 20260209"
	.section	.note.GNU-stack,"",@progbits
