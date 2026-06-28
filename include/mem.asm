%ifndef MEM_H_
%define MEM_H_

; @NOTE: all these memory addresses are for real mode usage and assume a segment 0.
;        i.e. before using these values, it's necessary to do something like:
;        xor AX, AX
;        mov DS, AX
;        mov ES, AX
;        to correctly access the linear addresses.
;
;            start     | end        | size
; 0000:
; global ivt
; global bios_data
; global alberto
; global kernlreal
; global ivtsave
; global rstackend
; global rstackini
; global boot
; global bigboy
; global rootdir
; global fatsecs

ivt       equ 0x0000 ; | 0x03FF     | 01024 bytes
bios_data equ 0x0400 ; | 0x04FF     | 00255 bytes
alberto   equ 0x1000 ; | 0x1378     | 00378 bytes
kernlreal equ 0x1000 ; | 0x4E00     | 15872 bytes (31 sectors of 512 bytes)
ivtsave   equ 0x5000 ; | 0x54FF     | 01280 bytes
rstackend equ 0x6000 ; | -----      | -----------
rstackini equ 0x7000 ; | -----      | -----------
boot      equ 0x7C00 ; | 0x7E00     | 00512 bytes
bigboy    equ 0x8000 ; | 0xAD50     | 11600 bytes (size of bouncer, the biggest bigboy)
rootdir   equ 0xB400 ; | 0xCFFF     | 07168 bytes (14 sectors of 512 bytes)
fatsecs   equ 0xD000 ; | 0xF400     | 09216 bytes (2 FATs * 9 sectors/FAT * 512 bytes/sector)

; teste     equ 0xB000 ; | 0xB06F     | 00111 bytes
; @TODO: where the fuck do i put the kernel?

%endif ; MEM_H_
