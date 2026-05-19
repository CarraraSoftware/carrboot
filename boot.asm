; partially copied from: (https://board.flatassembler.net/topic.php?p=65958)
; MINIMAL FAT12 BOOTABLE DISK!
; By: Rhyno_DaGreat (Ryan Lloyd)
; Description: A tutorial on how to hardcode a FAT12 Header for a bootdisk.

; another FAT12 reference: (https://elm-chan.org/docs/fat_e.html)

BITS 16
ORG  0x00
jmp start
nop

OEMName                     db "CARRBOOT"
BytesPerSector:             dw 512
SectorsPerCluster:          db 1
ReservedSectors:            dw 1
NumberFATs:                 db 2
MaxNumberRootEntries:       dw 512
TotalSectors:               dw 80 * 2 * 18
MediaDescriptor:            db 0xF0
SectorsPerFAT:              dw 9
SectorsPerTrack:            dw 18
NumberHeads:                dw 2
HiddenSectors:              dd 0
TotalSectorsBig:            dd 0
DriveNumber: 	            db 0
Unused: 		            db 0
ExtBootSignature: 	        db 0x29
SerialNumber:	            dd 0xa0a1a2a3
VolumeLabel: 	            db "MOS FLOPPY "
FileSystem: 	            db "FAT12   "

TracksPerHead:              dw 80

BufferStart   dw 0x0500
BufferCurrent dw 0x0500
DRIVE_NUMBER: db 0

start:
    cli             ; disable interrupts
    mov AX, 0x07C0
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX

    ; create the stack
    mov AX, 0x0000  ; set the stack
    mov SS, AX
    mov SP, 0xFFFF
    sti 

    mov [DRIVE_NUMBER], DL
    call cursorhome
    call clear
    call disk_reset

    mov AX, word [SectorsPerFAT]
    mul word [NumberFATs]
    add AX, [ReservedSectors]
    add AX, [HiddenSectors]
    call read_sectors

    xor AH, AH
    call print_byte
    call newline

    mov SI, [BufferStart]
    mov AH, 0xFF
    call print_strn
    call newline

    jmp halt    


lba_to_chs:
; params: 
; mov AX, { LBA_Sector }
;
; return:
; mov CX[0-5],  { sector         }   Sector   = (LBA % SectorsPerTrack) + 1        
; mov CX[6-15], { cylinder       }   Cylinder = (LBA / SectorsPerTrack) / NumHeads   
; mov DH,       { head           }   Head     = (LBA / SectorsPerTrack) % NumHeads 

    push AX
    push DX

    xor DX, DX
    div word [SectorsPerTrack]
    inc DX
    mov CX, DX

    xor DX, DX
    div word [NumberHeads]

    xchg DL, DH

    mov CH, AL
    shl AH, 6
    or  CL, AH

    pop AX
    mov DL, AL
    pop AX
    
    ret

read_sectors:
    push BX
    push CX
    push DX
    push DI

    call lba_to_chs
    mov AL, byte 0x01              ; number_sectors
    mov AH, byte 0x02              ; subfunction = 2
    mov BX, [BufferStart]          ; buffer
    mov DL, byte [DRIVE_NUMBER]
    
    mov DI, 3
.retry:
    stc ; set carry in case BIOS only UNSETS the carry in success case
    int 0x13
    jnc .end
    call disk_reset
    dec DI
    test DI, DI
    jnz .retry
    mov SI, read_sector_failed
    call print_str
    jmp halt
.end:
    pop DI
    pop DX
    pop CX
    pop BX
    ret

disk_reset:
    push AX
    push DX
    mov AH, byte 0x00
    mov DL, byte [DRIVE_NUMBER]
    int 0x13
    pop DX
    pop AX
    ret

counter:
; counts down from n to 0, expects n on SI
    push AX
.loop:
    mov AX, SI
    call print_byte

    mov AL, 0x0D
    call print_chr

    mov AL, 0x0A
    call print_chr

    dec SI
    cmp SI, 0
    jne .loop
    pop AX
    ret

checkcf:
    push SI
    jc .err
    mov SI, success
    jmp .end
.err:
    mov SI, failure
.end:
    call print_str
    pop SI
    ret

newline:
    push AX
    mov AX, 0x0D ; CR
    call print_chr
    mov AX, 0x0A ; LF
    call print_chr
    pop AX
    ret


clear:
    push AX
    push BX
    push CX
    push DX
    mov AH, byte 0x06
    mov AL, byte 0x00
    mov BH, byte 0x0F
    mov CH, byte 0x00
    mov CL, byte 0x00
    mov DH, byte 0xFF
    mov DL, byte 0xFF
    int 0x10
    pop DX
    pop CX
    pop BX
    pop AX
    ret

cursorhome:
    push AX
    push BX
    push DX
    mov AH, byte 0x02
    mov BH, byte 0x00
    mov DX, word 0x00
    int 0x10
    pop DX
    pop BX
    pop AX
    ret


print_byte:
; expects byte AX
; while(v!=0) {print('0' + v%10); v = v / 10;
    push SI
    mov SI, 0
.loop:
    cmp AX, 0x00
    je .mid
    mov CX, 0x0A
    div CL
    mov [printbytebuf + SI], AH
    inc SI
    movzx AX, AL
    jmp .loop
.mid:
    cmp SI, 0
    jne .print
    mov AL, 0
    call print_digit
.print:
    dec SI
    mov AL, [printbytebuf + SI] 
    call print_digit
    cmp SI, 0
    jne .mid
.end:
    pop SI
    ret

print_digit:
; expects digit 0-9 at AL
    push AX
    add AL, '0'
    call print_chr
    pop AX
    ret


print_strn:
; expects string at SI, n at AH
    push AX
    push SI
    push BX

    mov BL, 0
.loop:
    cmp BL, AH
    jae .end
    mov AL, [SI]
    call print_chr
    inc SI
    inc BL
    jmp .loop
.end:
    pop BX
    pop SI
    pop AX
    ret

print_str:
; expects string at SI
    push AX
    push SI
.loop:
    lodsb ; == mov AL, [ES:SI];  SI++
    cmp AL, byte 0 
    je .end
    call print_chr
    jmp .loop
.end:
    pop SI
    pop AX
    ret

print_chr:
; expects char at AL
    push AX
    push BX
    push SI
    cmp AL, byte 0
    jnz .notnull
    mov SI, nullstr
    call print_str
    jmp .end
.notnull:
    mov AH, byte 0x0E 
    mov BH, byte 0x00
    mov BL, byte 0x00
    int 0x10
.end:
    pop SI
    pop BX
    pop AX
    ret

halt:
    jmp halt

printbytebuf: TIMES 3 db 0
; inside: db "inside read sectors function", 0x0D, 0x0A, 0x00 
; hello: db "hello world", 0x0D, 0x0A, 0x00
nullstr: db "<NULL>", 0x00
success: db "check success", 0x0D, 0x0A, 0x00
failure: db "check failure", 0x0D, 0x0A, 0x00
read_sector_failed: db "read sector failed 3 times", 0x0D, 0x0A, 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
