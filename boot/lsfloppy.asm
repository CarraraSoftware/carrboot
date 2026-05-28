BITS 16
ORG  0x7C00

jmp main
nop

;; list of ascii error codes, as printed on the tty when things go wrong
;; (note: print_str was removed to fit this mf in 512 bytes)
;; 01 = file not found
;; 02 = failed to execute file
;; 03 = read sectors failed after 3 attempts


OEMName                     db "MSDOS5.0"
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
VolumeLabel: 	            db "BOOTDISK   "
FileSystem: 	            db "FAT12   "


main:
    cli
    mov AX, 0x0000
    mov SS, AX
    mov SP, 0xFFFF
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

    call readroot

    ; readfile(buffer, albertoname)
    mov BX, buffer
    mov CX, 0
.loop:
    cmp CX, [NumberRootEntries]
    jge .end

    mov SI, BX
    cmp [SI], 0
    jz .loop

    call print_str
    mov AL, 0x0D
    call print_chr
    mov AL, 0x0A
    call print_chr

    inc CX
    add BX, 0x20
    jmp .loop
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
; mov AX, { LBA_Sector     } // NOTE: LBA starts at 0
; mov DI, { number_sectors } 
; mov BX, { buffer         }
    pusha

    call lba_to_chs
    mov AX, DI                      ; number_sectors
    mov AH, byte 0x02               ; subfunction = 2
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
.error: ;; tried to read after disk reset 3 times and didn't work == error
    mov AL, 51
    call print_chr
    jmp halt
.end:
    popa
    ret

disk_reset:
    pusha
    mov AH, byte 0x00
    mov DL, byte [DRIVE_NUMBER]
    int 0x13
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
    mov BX, buffer
    call read_sectors 
    ret

print_str:
; expects string at SI
    push AX
    push SI
.print_strloop:
    lodsb ; == mov AL, SI;  SI++
    cmp AL, byte 0 
    je .print_strend
    call print_chr
    jmp .print_strloop
.print_strend:
    pop SI
    pop AX
    ret

print_chr:
; expects char at AL
    pusha
    test AL, AL
    jz .end
    mov AH, byte 0x0E 
    mov BH, byte 0x00
    mov BL, byte 0x00
    int 0x10
.end:
    popa
    ret

halt:
    jmp halt

DRIVE_NUMBER: db 0
buffer equ 0x1000
nullstr: db "\0", 0
errmsg: db "err", 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
