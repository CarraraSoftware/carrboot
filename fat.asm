; partially copied from: (https://board.flatassembler.net/topic.php?p=65958)
; MINIMAL FAT12 BOOTABLE DISK!
; By: Rhyno_DaGreat (Ryan Lloyd)
; Description: A tutorial on how to hardcode a FAT12 Header for a bootdisk.

; another FAT12 reference: (https://elm-chan.org/docs/fat_e.html)

BITS 16
ORG  0x7C00

jmp start
nop

db "CARRBOOT"   ; OEM Name
dw 512          ; Bytes Per Sector
db 1            ; Sectors Per Cluster
dw 1            ; Reserved Sector Count - 1 For BootSector
db 2            ; Number of File Allocation Tables
dw 512          ; Max number of Root Entries 
dw 80 * 1 * 18  ; Total Sectors
db 0xF0         ; Media Descriptor
dw 3            ; Sectors Per FAT
dw 18           ; Sectors Per Track
dw 1            ; Number of Heads
dd 0            ; Number of Hidden Sectors
                ; Serial Number 0x22e1e419 (Got it from 'file <name>'. wtf?) 
start:
TIMES 510 - ($ - $$) db 0
db 0x55
db 0xAA


fat1:                             ; Hardcoding the first File Allocation Table
db 0xF0, 0xFF, 0xFF               ; First byte is same as Media Descriptor Byte, all other bits are set to one in (For the first cluster)
db "this is just some data random in the middle of some sector"
TIMES 1536-($-fat1) db 0          ; Sectors Per FAT * Size Of Sector

fat2:                             ; Backup copy of FAT
db 0xF0, 0xFF, 0xFF
TIMES 1536-($-fat2) db 0

root_dir:                         ; Begining of Root Directory
db "KERNEL  ", "COM", 0x04, 0, 0
dw 0x0, 0x0, 0x0, 0x0, 0x0, 0x0   ; UNFINISHED, see Wikipedia FAT under "Directory Table"
TIMES 1536-($-root_dir) db 0      ; Root Directory is 5120 bytes big also

TIMES 1456128-($-$$) db 0         ; Size of a floppy
