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
# 5 "src/cigboy.c" 1
	_halt_forever: jmp _halt_forever

# 0 "" 2
#NO_APP
	nop
	ud2
	.cfi_endproc
.LFE0:
	.size	_start, .-_start
	.globl	VRAM
	.data
	.align 4
	.type	VRAM, @object
	.size	VRAM, 4
VRAM:
	.long	753664
	.globl	ivt
	.bss
	.align 4
	.type	ivt, @object
	.size	ivt, 4
ivt:
	.zero	4
	.globl	bios_data
	.data
	.align 4
	.type	bios_data, @object
	.size	bios_data, 4
bios_data:
	.long	1024
	.globl	alberto
	.align 4
	.type	alberto, @object
	.size	alberto, 4
alberto:
	.long	4096
	.globl	kernlreal
	.align 4
	.type	kernlreal, @object
	.size	kernlreal, 4
kernlreal:
	.long	4096
	.globl	ivtsave
	.align 4
	.type	ivtsave, @object
	.size	ivtsave, 4
ivtsave:
	.long	20480
	.globl	rstackend
	.align 4
	.type	rstackend, @object
	.size	rstackend, 4
rstackend:
	.long	24576
	.globl	rstackini
	.align 4
	.type	rstackini, @object
	.size	rstackini, 4
rstackini:
	.long	28672
	.globl	boot
	.align 4
	.type	boot, @object
	.size	boot, 4
boot:
	.long	31744
	.globl	bigboy
	.align 4
	.type	bigboy, @object
	.size	bigboy, 4
bigboy:
	.long	32768
	.globl	rootdir
	.align 4
	.type	rootdir, @object
	.size	rootdir, 4
rootdir:
	.long	46080
	.globl	fatsecs
	.align 4
	.type	fatsecs, @object
	.size	fatsecs, 4
fatsecs:
	.long	53248
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
	mov	ecx, DWORD PTR VRAM@GOTOFF[eax]
	mov	edx, DWORD PTR -4[ebp]
	add	edx, edx
	add	edx, ecx
	mov	BYTE PTR [edx], 32
	mov	ecx, DWORD PTR VRAM@GOTOFF[eax]
	mov	edx, DWORD PTR -4[ebp]
	add	edx, edx
	inc	edx
	add	ecx, edx
	mov	dl, BYTE PTR -5[ebp]
	mov	BYTE PTR [ecx], dl
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
	mov	ecx, DWORD PTR 8[ebp]
	mov	edx, DWORD PTR 12[ebp]
	mov	BYTE PTR -4[ebp], cl
	mov	BYTE PTR -8[ebp], dl
	mov	ecx, DWORD PTR VRAM@GOTOFF[eax]
	mov	edx, DWORD PTR 16[ebp]
	add	edx, edx
	add	ecx, edx
	mov	dl, BYTE PTR -4[ebp]
	mov	BYTE PTR [ecx], dl
	mov	edx, DWORD PTR VRAM@GOTOFF[eax]
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
	.globl	fmtbyte
	.type	fmtbyte, @function
fmtbyte:
.LFB6:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 20
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR 8[ebp]
	mov	BYTE PTR -20[ebp], al
	mov	DWORD PTR -4[ebp], 0
.L15:
	mov	cl, BYTE PTR -20[ebp]
	movzx	edx, cl
	mov	eax, edx
	sal	eax, 2
	add	eax, edx
	sal	eax, 3
	add	eax, edx
	lea	edx, 0[0+eax*4]
	add	eax, edx
	shr	ax, 8
	mov	dl, al
	shr	dl, 3
	mov	al, dl
	sal	eax, 2
	add	eax, edx
	sal	eax
	sub	ecx, eax
	mov	dl, cl
	lea	eax, 48[edx]
	mov	BYTE PTR -9[ebp], al
	mov	eax, DWORD PTR -4[ebp]
	lea	edx, 1[eax]
	mov	DWORD PTR -4[ebp], edx
	mov	edx, eax
	mov	eax, DWORD PTR 12[ebp]
	add	edx, eax
	mov	al, BYTE PTR -9[ebp]
	mov	BYTE PTR [edx], al
	mov	al, BYTE PTR -20[ebp]
	movzx	edx, al
	mov	eax, edx
	sal	eax, 2
	add	eax, edx
	sal	eax, 3
	add	eax, edx
	lea	edx, 0[0+eax*4]
	add	eax, edx
	shr	ax, 8
	shr	al, 3
	mov	BYTE PTR -20[ebp], al
	cmp	BYTE PTR -20[ebp], 0
	jne	.L15
	mov	DWORD PTR -8[ebp], 0
	jmp	.L16
.L17:
	mov	edx, DWORD PTR -8[ebp]
	mov	eax, DWORD PTR 12[ebp]
	add	eax, edx
	mov	al, BYTE PTR [eax]
	mov	BYTE PTR -10[ebp], al
	mov	eax, DWORD PTR -4[ebp]
	sub	eax, DWORD PTR -8[ebp]
	lea	edx, -1[eax]
	mov	eax, DWORD PTR 12[ebp]
	add	eax, edx
	mov	ecx, DWORD PTR -8[ebp]
	mov	edx, DWORD PTR 12[ebp]
	add	edx, ecx
	mov	al, BYTE PTR [eax]
	mov	BYTE PTR [edx], al
	mov	eax, DWORD PTR -4[ebp]
	sub	eax, DWORD PTR -8[ebp]
	lea	edx, -1[eax]
	mov	eax, DWORD PTR 12[ebp]
	add	edx, eax
	mov	al, BYTE PTR -10[ebp]
	mov	BYTE PTR [edx], al
	inc	DWORD PTR -8[ebp]
.L16:
	mov	eax, DWORD PTR -4[ebp]
	mov	edx, eax
	shr	edx, 31
	add	eax, edx
	sar	eax
	cmp	DWORD PTR -8[ebp], eax
	jl	.L17
	nop
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE6:
	.size	fmtbyte, .-fmtbyte
	.globl	read_cluster
	.type	read_cluster, @function
read_cluster:
.LFB7:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	push	esi
	push	ebx
	sub	esp, 32
	.cfi_offset 6, -12
	.cfi_offset 3, -16
	call	__x86.get_pc_thunk.cx
	add	ecx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR 12[ebp]
	mov	WORD PTR -28[ebp], ax
	mov	eax, DWORD PTR -28[ebp]
	sub	eax, 2
	mov	WORD PTR -10[ebp], ax
	mov	eax, DWORD PTR NumberRootEntries@GOT[ecx]
	mov	ax, WORD PTR [eax]
	movzx	eax, ax
	sal	eax, 5
	mov	ebx, eax
	mov	eax, DWORD PTR BytesPerSector@GOT[ecx]
	mov	ax, WORD PTR [eax]
	movzx	esi, ax
	mov	eax, ebx
	cdq
	idiv	esi
	mov	WORD PTR -12[ebp], ax
	mov	eax, DWORD PTR NumberFATs@GOT[ecx]
	mov	al, BYTE PTR [eax]
	movzx	edx, al
	mov	eax, DWORD PTR SectorsPerFAT@GOT[ecx]
	mov	ax, WORD PTR [eax]
	imul	ax, dx
	mov	WORD PTR -14[ebp], ax
	mov	eax, DWORD PTR HiddenSectors@GOT[ecx]
	mov	eax, DWORD PTR [eax]
	mov	edx, eax
	mov	ax, WORD PTR -10[ebp]
	add	edx, eax
	mov	eax, DWORD PTR ReservedSectors@GOT[ecx]
	mov	ax, WORD PTR [eax]
	add	edx, eax
	mov	eax, DWORD PTR -12[ebp]
	add	edx, eax
	mov	ax, WORD PTR -14[ebp]
	add	eax, edx
	mov	WORD PTR -16[ebp], ax
	movzx	eax, WORD PTR -16[ebp]
	sub	esp, 4
	push	1
	push	eax
	push	DWORD PTR 8[ebp]
	mov	ebx, ecx
	call	read_sectors@PLT
	add	esp, 16
	nop
	lea	esp, -8[ebp]
	pop	ebx
	.cfi_restore 3
	pop	esi
	.cfi_restore 6
	pop	ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE7:
	.size	read_cluster, .-read_cluster
	.globl	str_ncomp
	.type	str_ncomp, @function
str_ncomp:
.LFB8:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	sub	esp, 16
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	DWORD PTR -4[ebp], 0
	jmp	.L21
.L24:
	mov	edx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR 8[ebp]
	add	eax, edx
	mov	dl, BYTE PTR [eax]
	mov	ecx, DWORD PTR -4[ebp]
	mov	eax, DWORD PTR 12[ebp]
	add	eax, ecx
	mov	al, BYTE PTR [eax]
	cmp	dl, al
	je	.L22
	mov	eax, 0
	jmp	.L23
.L22:
	inc	DWORD PTR -4[ebp]
.L21:
	mov	eax, DWORD PTR -4[ebp]
	cmp	eax, DWORD PTR 16[ebp]
	jl	.L24
	mov	eax, 1
.L23:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE8:
	.size	str_ncomp, .-str_ncomp
	.globl	find_file_first_cluster
	.type	find_file_first_cluster, @function
find_file_first_cluster:
.LFB9:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	push	ebx
	sub	esp, 16
	.cfi_offset 3, -12
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	eax, DWORD PTR rootdir@GOTOFF[ebx]
	mov	DWORD PTR -12[ebp], eax
	mov	WORD PTR -6[ebp], 0
	jmp	.L26
.L30:
	mov	eax, DWORD PTR rootdir@GOTOFF[ebx]
	movzx	edx, WORD PTR -6[ebp]
	sal	edx, 5
	add	eax, edx
	mov	DWORD PTR -16[ebp], eax
	push	11
	push	DWORD PTR -16[ebp]
	push	DWORD PTR 8[ebp]
	call	str_ncomp
	add	esp, 12
	test	eax, eax
	je	.L32
	mov	eax, DWORD PTR -16[ebp]
	add	eax, 26
	mov	al, BYTE PTR [eax]
	movzx	eax, al
	mov	edx, DWORD PTR 12[ebp]
	mov	WORD PTR [edx], ax
	jmp	.L25
.L32:
	nop
	inc	WORD PTR -6[ebp]
.L26:
	mov	eax, DWORD PTR NumberRootEntries@GOT[ebx]
	mov	ax, WORD PTR [eax]
	cmp	WORD PTR -6[ebp], ax
	jb	.L30
	mov	DWORD PTR 12[ebp], 0
	nop
.L25:
	mov	ebx, DWORD PTR -4[ebp]
	leave
	.cfi_restore 5
	.cfi_restore 3
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE9:
	.size	find_file_first_cluster, .-find_file_first_cluster
	.globl	print_quad
	.type	print_quad, @function
print_quad:
.LFB10:
	.cfi_startproc
	push	ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	mov	ebp, esp
	.cfi_def_cfa_register 5
	push	ebx
	sub	esp, 24
	.cfi_offset 3, -12
	call	__x86.get_pc_thunk.ax
	add	eax, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	mov	edx, DWORD PTR 8[ebp]
	mov	eax, DWORD PTR 12[ebp]
	mov	BYTE PTR -24[ebp], dl
	mov	BYTE PTR -28[ebp], al
	mov	DWORD PTR -8[ebp], 0
	jmp	.L34
.L37:
	movzx	eax, BYTE PTR -28[ebp]
	lea	edx, -20[ebp]
	push	edx
	push	eax
	call	fmtbyte
	add	esp, 8
	mov	DWORD PTR -16[ebp], 0
	jmp	.L35
.L36:
	mov	eax, DWORD PTR -12[ebp]
	lea	edx, 1[eax]
	mov	DWORD PTR -12[ebp], edx
	movsx	ecx, BYTE PTR -24[ebp]
	lea	ebx, -20[ebp]
	mov	edx, DWORD PTR -16[ebp]
	add	edx, ebx
	mov	dl, BYTE PTR [edx]
	movsx	edx, dl
	push	eax
	push	ecx
	push	edx
	call	putc
	add	esp, 12
	inc	DWORD PTR -16[ebp]
.L35:
	cmp	DWORD PTR -16[ebp], 2
	jle	.L36
	shr	BYTE PTR -28[ebp], 4
	inc	DWORD PTR -8[ebp]
.L34:
	cmp	DWORD PTR -8[ebp], 3
	jle	.L37
	nop
	nop
	mov	ebx, DWORD PTR -4[ebp]
	leave
	.cfi_restore 5
	.cfi_restore 3
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE10:
	.size	print_quad, .-print_quad
	.section	.rodata
.LC0:
	.string	"LINUX      "
.LC1:
	.string	"ERROR: FILE NOT FOUND"
	.text
	.globl	main
	.type	main, @function
main:
.LFB11:
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
	call	set_text_mode@PLT
	call	clear
	lea	eax, .LC0@GOTOFF[ebx]
	mov	DWORD PTR -12[ebp], eax
	sub	esp, 8
	lea	eax, -16[ebp]
	push	eax
	push	DWORD PTR -12[ebp]
	call	find_file_first_cluster
	add	esp, 16
	mov	eax, DWORD PTR -16[ebp]
	cmp	ax, 1
	ja	.L39
	mov	BYTE PTR -13[ebp], 4
	movsx	eax, BYTE PTR -13[ebp]
	sub	esp, 8
	push	eax
	lea	eax, .LC1@GOTOFF[ebx]
	push	eax
	call	print
	add	esp, 16
	jmp	.L40
.L39:
	mov	eax, DWORD PTR -16[ebp]
	movzx	edx, ax
	mov	eax, DWORD PTR kernlreal@GOTOFF[ebx]
	sub	esp, 8
	push	edx
	push	eax
	call	read_cluster
	add	esp, 16
.L40:
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
.LFE11:
	.size	main, .-main
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB12:
	.cfi_startproc
	mov	eax, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE12:
	.section	.text.__x86.get_pc_thunk.cx,"axG",@progbits,__x86.get_pc_thunk.cx,comdat
	.globl	__x86.get_pc_thunk.cx
	.hidden	__x86.get_pc_thunk.cx
	.type	__x86.get_pc_thunk.cx, @function
__x86.get_pc_thunk.cx:
.LFB13:
	.cfi_startproc
	mov	ecx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE13:
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB14:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE14:
	.ident	"GCC: (GNU) 15.2.1 20260209"
	.section	.note.GNU-stack,"",@progbits
