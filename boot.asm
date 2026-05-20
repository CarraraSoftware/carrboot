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

DRIVE_NUMBER: db 0
buffer EQU 0x1000

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

    xor DX, DX
    xor AX, AX
    xor BX, BX
    
    ; SectorsInRoot
    mov AX, 0x20
    mul word [NumberRootEntries]
    div word [BytesPerSector]

    ; SectorsInFat
    mov DX, word [SectorsPerFAT]
    xor BH, BH
    mov BL, byte [NumberFATs]
    mul DX, BX

    ; SectorsInFat + SectorsInRoot
    add AX, DX

    ; HiddenSectors + ReservedSectors + SectorsInFat + SectorsInRoot
    add AX, word [ReservedSectors]
    add AX, word [HiddenSectors]
    mov DI, word 0x01
    call read_sectors 

    ; 0xJKLM
    ; 0x0JKL
    mov AX, buffer
    mov DS, AX
    mov ES, AX
    mov FS, AX
    mov GS, AX

    ; [buffer_seg:buffer_off]
    ; mov AX, word buffer
    ; mov AX, 
    jmp buffer

    
    mov SI, boot_failed
    call print_str


    ; xor DI, DI
    ; xor SI, SI
    ; mov DI, [NumberRootEntries]
    ; mov SI, [BufferStart]
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
    mov AX, DI                      ; number_sectors
    mov AH, byte 0x02               ; subfunction = 2
    mov BX, buffer                  ; buffer
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
boot_failed: db "boot failed", 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
