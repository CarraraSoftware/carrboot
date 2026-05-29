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
    mov AX, 0xB000
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

    mov AX, 0xFF
    call print_byte

    mov AX, 0xA2
    call print_byte

    mov AX, 0x8
    call print_byte

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
    inc CX

    mov SI, BX
    add BX, 0x20
    cmp [SI], 0
    jz .loop

    call print_str
    mov AL, 0x0D
    call print_chr
    mov AL, 0x0A
    call print_chr

    jmp .loop
.end:

    mov SI, endstr
    call print_str

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
    mov SI, log
    call print_str

    ; AH = status
    ; AL = nsect


    xor CX, CX
    mov CL, AH

    xor AH, AH
    call print_byte

    mov SI, status
    call print_str

    mov AX, CX
    call print_byte

    mov AL, 0x0D
    call print_chr
    mov AL, 0x0A
    call print_chr

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
printbytebuf: TIMES 3 db 0
log: db "Sectors Read: ", 0x00
status: db " | Status: ", 0x00
endstr: db "EOP.", 0x0D, 0x0A, 0x00 
nullstr: db "\0", 0
errmsg: db "err", 0x00

TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA
