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
    ; mov AX, 0x07C0
    ; mov DS, AX
    ; mov ES, AX
    ; mov FS, AX
    ; mov GS, AX

    mov AX, 0x0000
    mov SS, AX
    mov SP, 0xFFFF
    mov AX, DS
    mov ES, AX
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

    ; readfile(buffer, albertoname)
    mov BX, buffer
    mov DI, albertoname
    call readfile

    ; mov BX, 0x1000
    ; mov BX, buffer
    ; jmp BX     ; // doesn't work at all, wtf?
    
    ; readfile(bigboy, bigboyname)
    mov BX, bigboy
    mov DI, bigboyname
    call readfile


    jmp buffer ; // works fine
    ; jmp 0x1000


    ; call execfile
    ; jmp halt


readfile:
; mov BX, { buffer }
; mov DI, { filename }
    pusha

    mov AX, [NumberRootEntries]
    mov DX, bufoot
.search:
    test AX, AX
    jz .notfound

    push DI
    mov CX, 11
    mov SI, DX
    rep cmpsb
    pop DI
    je .found

    add DX, 0x20
    dec AX
    jmp .search

.found:
    mov SI, DX
    mov CX, [SI + 0x1A]
    mov [filecluster], CX
    mov SI, BX
.load:
    cmp [filecluster], 0x0FFF
    je .end

    cmp [filecluster], 0x0
    je .end

    mov DI, [filecluster]
    call read_cluster

    ; nextcluster = *(buffat + curcluster)
    mov BX, buffat
    mov AX, [filecluster]
    mul AX, 0x03
    mov CX, 0x02
    xor DX, DX
    div CX ; AX => Q | DX => R
    add BX, AX
    mov CX, word [BX]
    test DX, DX
    jz .even
    ; and CX, word 0xFFF0
    shr CX, 4
    jmp .after
.even:
    and CX, word 0x0FFF
    jmp .after
.after:
    mov [filecluster], CX

    ; buffer += bytespersec * secspercluster
    mov BX, word [BytesPerSector]
    mul BX, word [SectorsPerCluster]
    add SI, BX
    jmp .load
.notfound:
    mov AL, 49
    call print_chr
.end:
    popa
    ret

execfile:
; mov AX, { *FILE_BUFFER }

    ; TODO: setar registradores de segmento corretamente?
    ; mov AX, bufseg
    ; mov DS, AX
    ; mov ES, AX
    ; mov FS, AX
    ; mov GS, AX
    ; mov SI, FS:buffer
    mov DL, [DRIVE_NUMBER]
    jmp AX
.error:
    mov AL, 50
    call print_chr
    jmp halt

read_cluster:
; params:
; mov SI, { buffer         }
; mov DI, { cluster_number } // NOTE: first cluster => cluster_number = 0x02
    pusha
    
    ; cluster_number - 2 => offset from RootDirectory
    sub DI, 0x2

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

    ; HiddenSectors + ReservedSectors + SectorsInFat + SectorsInRoot + cluster_number - 2
    add AX, word [ReservedSectors]
    add AX, word [HiddenSectors]
    add AX, DI

    mov BX, SI
    mov DI, word 0x01
    call read_sectors 
    popa
    ret


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

readfat:
    pusha
    mov AX, [ReservedSectors]
    add AX, [HiddenSectors]
    mov DI, [SectorsPerFAT]
    mul DI, [NumberFATs]
    mov BX, buffat
    call read_sectors
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
    mov BX, bufoot
    call read_sectors 
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
bufoot equ 0x4000
bigboy equ 0x8000
buffat equ 0xD000
nullstr: db "\0", 0
albertoname: db "ALBERTO    "
bigboyname:  db "BOUNCER    "
filecluster: dw 0
errmsg: db "err", 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
