; partially copied from: (https://board.flatassembler.net/topic.php?p=65958)
; MINIMAL FAT12 BOOTABLE DISK!
; By: Rhyno_DaGreat (Ryan Lloyd)
; Description: A tutorial on how to hardcode a FAT12 Header for a bootdisk.

; another FAT12 reference: (https://elm-chan.org/docs/fat_e.html)

BITS 16
ORG  0x00
jmp main
nop

OEMName                     db "CARRBOOT"
BytesPerSector:             dw 512
SectorsPerCluster:          db 1
ReservedSectors:            dw 1
NumberFATs:                 db 2
NumberRootEntries:          dw 224
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

BufferStart   dw 0x0500
DRIVE_NUMBER: db 0

main:
    cli
    mov AX, 0x07C0
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX

    mov AX, 0x0000
    mov SS, AX
    mov SP, 0xFFFF
    sti 

    mov [DRIVE_NUMBER], DL
    call cursorhome
    call clear
    call disk_reset
    call readroot


    xor DI, DI
    xor SI, SI
    mov DI, [NumberRootEntries]
    mov SI, [BufferStart]
.outer:
    test DI, DI
    jz .end

    cmp [SI], 0
    je .skip
    call print_str
    mov AL, " " 
    call print_chr
    
    xor BX, BX
    mov BX, 0x06
    add SI, 0x1A
.inner:
    test BX, BX 
    jz .addlast

    xor AX, AX
    mov AX, [SI]
    call print_byte
    mov AL, " " 
    call print_chr
    inc SI
    dec BX
    jmp .inner


.addlast:
    call newline
    ;inc SI
    jmp .nextouter
.skip:
    add SI, word 0x20
.nextouter:
    dec DI
    jmp .outer

.end:
    jmp halt    

lba_to_chs:
; params: 
; mov AX, { LBA_Sector }
;
; return:
; mov CX[0-5],  { sector         }   Sector   = (LBA % SectorsPerTrack) + 1        
; mov CX[6-15], { cylinder       }   Cylinder = (LBA / SectorsPerTrack) / NumHeads   
; mov DH,       { head           }   Head     = (LBA / SectorsPerTrack) % NumHeads 
; CX
; [........  ........]
; [CCCCCCCC][CCSSSSSS]
; CH        CL

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
; params:
; mov AX, { LBA_Sector } NOTE: LBA starts at 0
; mov DI, { number_sectors } 
    pusha

    call lba_to_chs
    mov AX, DI                     ; number_sectors
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
    xor AH, AH
    call print_byte ; AL contains the number of sectors read
    mov SI, sectors_read
    call print_str
    call newline
    popa
    ret


readroot:
    ; NumberRootEntries * 32 bytes ------ n sectors?
    ; BytesPerSector         bytes ------ 1 sector
    ; AX: n = NumberRootEntries * 32 / BytesPerSector
    mov AX, 0x20
    mul word [NumberRootEntries]
    div word [BytesPerSector]
    mov DI, AX

    xor DX, DX
    xor AX, AX
    mov AX, word [SectorsPerFAT]
    mov BL, byte [NumberFATs]
    xor BH, BH
    mul BX
    add AX, word [ReservedSectors]
    add AX, word [HiddenSectors]
    call read_sectors 
    ret


disk_reset:
    pusha
    mov AH, byte 0x00
    mov DL, byte [DRIVE_NUMBER]
    int 0x13
    popa
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
    pusha
    mov AH, byte 0x06
    mov AL, byte 0x00
    mov BH, byte 0x0F
    mov CH, byte 0x00
    mov CL, byte 0x00
    mov DH, byte 0xFF
    mov DL, byte 0xFF
    int 0x10
    popa
    ret

cursorhome:
    pusha
    mov AH, byte 0x02
    mov BH, byte 0x00
    mov DX, word 0x00
    int 0x10
    popa
    ret


print_byte:
; expects byte AX
; do { printf('0' + v%10); v = v / 10 } while(v!=0);
    pusha
    xor SI, SI
    xor CX, CX
    xor AH, AH
    mov CH, byte 0x0A
.loop:
    div CH ; AL = quot. | AH = remain.
    mov [printbytebuf + SI], AH
    inc SI
    xor AH, AH
    test AL, AL
    jz .print
    jmp .loop
.print:
    dec SI
    xor AX, AX
    mov AL, [printbytebuf + SI] 
    call print_digit
    test SI, SI
    jnz .print
.end:
    popa
    ret

print_digit:
; expects digit 0-9 at AL
    push AX
    xor AH, AH
    add AL, '0'
    call print_chr
    pop AX
    ret


print_strn:
; expects string at SI, n at AH
    pusha

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
    popa
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
    pusha
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
    popa
    ret

halt:
    jmp halt

printbytebuf: TIMES 3 db 0
nullstr: db "<NULL>", 0x00
read_sector_failed: db "rdsec fail", 0x00
sectors_read: db " secs read", 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
