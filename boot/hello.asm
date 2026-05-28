bits 16
org  0x7c00

jmp main
nop

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
    mov SI, hellostr
    call print_str
    
    jmp halt
    

print_str:
; expects string at SI
    push AX
    push SI
.loop:
    mov AL, [SI]
    cmp AL, byte 0 
    je .end
    inc SI
    call print_chr
    jmp .loop
.end:
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


hellostr: db "ALO ALO ALO DO DISQUETE", 0x0D, 0x0A, 0x00
TIMES 510 - ($ - $$) db 0
db 0x55, 0xAA
