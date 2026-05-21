%define ORIGIN 
bits 16
org 0x1000

times 100 nop
jmp main

times 600 db 0

%define WIDTH  0x140
%define HEIGHT 0x0C8

%define PLAYER_WIDTH  0x10
%define PLAYER_HEIGHT 0x20
; %define PLAYER_BASE_HEIGHT HEIGHT / 2

%define BG_COLOR      0x0B
%define GROUND_COLOR  0x08
%define PLAYER_COLOR  0x0F

hello: db "HELLO FROM GAME", 0x0D, 0x0A, 0x00 
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
    mov AH, byte 0x0E 
    mov BH, byte 0x00
    mov BL, byte 0x00
    int 0x10
    ret

main:
    ; init stack
    cli
    mov AX, 0x600
    mov SS, AX
    mov BP, 0x0
    mov SP, 0x1000
    sti
    call init

    mov SI, hello
    call print_str


.loop:
    ; call busy
    call background
    call ground
    ; call clear
    call player
    jmp .loop
    call halt

init:
    call clear
    ; cursor to (0,0)
    mov AH, byte 0x02
    xor BX, BX
    xor DX, DX
    int 0x10

    ; vga mode
    mov AH, byte 0x00
    mov AL, byte 0x13
    int 0x10
    ; set DataSegment to point to vga's frame buffer
    mov BX, 0xA000 
    mov DS, BX
    ; wtf
    ; mov BX, ORIGIN
    ; mov CS, BX
    ret


%define GRAVITY 0x02
%define PLAYER_JUMP -10
%define PLAYER_START_Y 0x44
px: dw 0x20
py: dw 0x00
vx: dw 0x00
vy: dw 0x00
player:
    push BX

    xor BX, BX

    ; RENDER
    mov AL, PLAYER_COLOR
    mov BX, [CS:px]
    mov CX, BX
    mov SI, BX
    add SI, PLAYER_WIDTH

    xor BX, BX
    mov BX, [CS:py]
    mov DX, BX
    mov DI, BX
    add DI, PLAYER_HEIGHT
    call fillrect

    ; UPDATE
    xor BX, BX

    ; handle space bar = jump
    mov AH, 0x01
    int 0x16
    jz .after_key
    mov  AH, 0x00
    int  0x16
    cmp AH, 0x39
    je .handle_space
    jmp .after_key
.handle_space:
    cmp [CS:py], PLAYER_START_Y
    jl .after_key
    mov BX, -10
    mov [CS:vy], BX
    xor BX, BX
.after_key:

    ; mov BX, [CS:px]
    ; add BX, [CS:vx]
    ; mov [CS:px], BX

    mov BX, [CS:vy]
    add BX, GRAVITY
    add BX, [CS:py]
    cmp BX, PLAYER_START_Y
    jg .player_floor
    cmp BX, 0
    jle .player_ceil
    mov [CS:py], BX
    mov BX, [CS:vy]
    add BX, GRAVITY
    mov [CS:vy], BX
    xor BX, BX
    jmp .after_update
.player_ceil:
    mov [CS:px], 0x20
    mov [CS:py], 0x00
    mov [CS:vy], 0x00
    mov [CS:vx], 0x00
    jmp .after_update
.player_floor:
    mov [CS:px], 0x20
    mov [CS:py], PLAYER_START_Y
    mov [CS:vy], 0x00
    mov [CS:vx], 0x00
    jmp .after_update
.after_update:
    pop BX
    ret

ground:
    mov AL, GROUND_COLOR
    mov CX, 0x00
    mov DX, HEIGHT / 2 
    mov SI, WIDTH
    mov DI, HEIGHT
    call fillrect
    ret

background:
    mov AL, BG_COLOR
    mov CX, 0x00
    mov DX, 0x00 
    mov SI, WIDTH
    mov DI, HEIGHT / 2
    call fillrect
    ret

busy:
    push DX
    mov DX, 0xFFFF
.keep_busy:
    cmp DX, 0
    jle .busy_end
    call wait_
    dec DX
    jmp .keep_busy
.busy_end:
    pop DX
    ret

wait_:
    push DX
    mov DX, 0xFFFF
.keep_waiting:
    cmp DX, 0
    jle .wait_end
    dec DX
    jmp .keep_waiting
.wait_end:
    pop DX
    ret

halt:
    jmp $
    ret



clear:
    mov AH, byte 0x06
    mov AL, byte 0x00
    mov BH, byte 0x04
    mov BL, byte 0x00
    mov CH, byte 0x00
    mov CL, byte 0x00
    mov DH, byte 0xFF
    mov DL, byte 0xFF
    int 0x10
    ret

index:
; params:
; mov SI, { x }
; mov DI, { y }
; return:
; SI = { idx }
    push DI
    mul DI, WIDTH
    add SI, DI
    pop DI
    ret

fillrect:
; x1, x2
; y1, y2
; params:
; mov AL, { COLOR        }
; mov CX, { COLUMN_START }
; mov DX, { ROW_START    }
; mov SI, { COLUMN_MAX   }
; mov DI, { ROW_MAX      }
    push DX
.fillrect_loop:
    cmp DX, DI
    jge .fillrect_end
    call hline
    inc DX
    jmp .fillrect_loop
.fillrect_end:
    pop DX
    ret

hline:
; params:
; mov AL, { COLOR }
; mov CX, { COLUMN_START }
; mov DX, { ROW }
; mov SI, { COLUMN_MAX }
    push CX
    mov AH, byte 0x0C
.hline_loop:
    cmp CX, SI
    jge .hline_end
    push SI
    push DI
    mov SI, CX
    mov DI, DX
    call index
    mov [SI], AL
    pop DI
    pop SI
    inc CX
    jmp .hline_loop
.hline_end:
    pop CX
    ret

vline:
; params:
; mov AL, { COLOR}
; mov CX, { COLUMN }
; mov DX, { ROW_START }
; mov SI, { ROW_MAX   }
    push DX
    mov AH, byte 0x0C
.vline_loop:
    cmp DX, SI
    jge .vline_end
    int 0x10
    inc DX
    jmp .vline_loop
.vline_end:
    pop DX
    ret

checkcf:
    push SI
    jc .cferror
    mov SI, cfnoerrormsg
    jmp .cfend
.cferror:
    mov SI, cferrormsg
.cfend:
    call print_str
    pop SI
    ret


cfnoerrormsg: db "No error in CF.", 0x0D, 0x0A, 0x00
cferrormsg:   db "An error was detected in CF.", 0x0D, 0x0A, 0x00
