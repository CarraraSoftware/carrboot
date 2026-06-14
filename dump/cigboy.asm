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
	call main

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
	.align 4
.LC0:
	.string	"\303\211 HORA DE RODAR ISSO AQUI NO TOSHIB\303\203O"
	.section	.data.rel.local,"aw"
	.align 4
	.type	msg, @object
	.size	msg, 4
msg:
	.long	.LC0
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
	.globl	main
	.type	main, @function
main:
.LFB2:
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
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	WORD PTR -10[ebp], 0
	jmp	.L5
.L6:
	mov	ecx, 753664
	movsx	edx, WORD PTR -10[ebp]
	add	edx, edx
	add	edx, ecx
	mov	BYTE PTR [edx], 32
	mov	ecx, 753664
	movsx	edx, WORD PTR -10[ebp]
	add	edx, edx
	add	edx, 1
	add	edx, ecx
	mov	BYTE PTR [edx], 0
	movzx	edx, WORD PTR -10[ebp]
	add	edx, 1
	mov	WORD PTR -10[ebp], dx
.L5:
	cmp	WORD PTR -10[ebp], 79
	jle	.L6
	mov	WORD PTR -10[ebp], 0
.L9:
	mov	ecx, DWORD PTR msg@GOTOFF[eax]
	movsx	edx, WORD PTR -10[ebp]
	add	edx, ecx
	movzx	edx, BYTE PTR [edx]
	test	dl, dl
	je	.L12
	mov	ecx, DWORD PTR msg@GOTOFF[eax]
	movsx	edx, WORD PTR -10[ebp]
	add	edx, ecx
	movzx	ecx, BYTE PTR [edx]
	mov	ebx, 753664
	movsx	edx, WORD PTR -10[ebp]
	add	edx, edx
	add	edx, ebx
	mov	BYTE PTR [edx], cl
	mov	ecx, 753664
	movsx	edx, WORD PTR -10[ebp]
	add	edx, edx
	add	edx, 1
	add	edx, ecx
	mov	BYTE PTR [edx], 15
	movzx	edx, WORD PTR -10[ebp]
	add	edx, 1
	mov	WORD PTR -10[ebp], dx
	jmp	.L9
.L12:
	nop
	mov	WORD PTR -10[ebp], 160
	mov	DWORD PTR -16[ebp], 26
	mov	DWORD PTR -20[ebp], 64
	sub	esp, 8
	push	64
	push	26
	mov	ebx, eax
	call	add@PLT
	add	esp, 16
	mov	DWORD PTR -24[ebp], eax
	mov	edx, 753664
	movsx	eax, WORD PTR -10[ebp]
	add	eax, edx
	mov	edx, DWORD PTR -24[ebp]
	mov	BYTE PTR [eax], dl
	mov	edx, 753664
	movsx	eax, WORD PTR -10[ebp]
	add	eax, 1
	add	eax, edx
	mov	BYTE PTR [eax], 15
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
.LFE2:
	.size	main, .-main
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB3:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE3:
	.ident	"GCC: (GNU) 15.2.1 20260209"
	.section	.note.GNU-stack,"",@progbits
