BITS 16
ORG  0x7C00

jmp main
nop

%ifndef BIGBOY
%define BIGBOY "BIGBOY     "
%endif

;; list of ascii error codes, as printed on the tty when things go wrong
;; (note: print_str was removed to fit this mf in 512 bytes)
;; 01 = file not found
;; 02 = failed to execute file
;; 03 = read sectors failed after 3 attempts


%define FAT_BPB_
%include "include/fat.asm"
%undef FAT_BPB_

main:
    cli
    xor AX, AX
    mov SS, AX
    mov DS, AX
    mov ES, AX
    mov SP, rstackini
    mov BP, SP
    sti

    mov [DRIVE_NUMBER], DL
    call disk_reset

    mov AL, 'C'
    call print_chr
    mov AL, 'B'
    call print_chr
    mov AL, 0x0A
    call print_chr
    mov AL, 0x0D
    call print_chr

    call readfat
    call readroot

    ; readfile(alberto, albertoname)
    mov BX, alberto
    mov DI, albertoname
    call readfile

    ; readfile(bigboy, bigboyname)
    mov BX, bigboy
    mov DI, bigboyname
    call readfile


    ; run(alberto)
    jmp alberto

%define FAT_CODE_
%include "include/fat.asm"
%undef FAT_CODE_


%include "include/mem.asm"

nullstr: db "\0", 0
albertoname: db "ALBERTO    "
bigboyname:  db BIGBOY
errmsg: db "err", 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
