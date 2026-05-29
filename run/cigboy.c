__attribute__((naked))
int _start(void)
{
    __asm__(
        "mov AX, 0x10\n"
        "mov DS, AX\n"
        "mov SS, AX\n"
        "mov ES, AX\n"
        "mov ESP, 0x90000\n"
        "mov EAX, 0x10\n"
        "call main\n"
    );
}

#include "cigboy.h"
volatile unsigned char* const VRAM = (unsigned char*)0xB8000;
char* msg = "EAE S2";

#define COLS 80
#define ROWS 25

void halt() { 
    for (;;) {
    } 
}

int main(void)
{    
    short i = 0;

    for (i = 0; i < COLS; i++) {
        VRAM[i * 2] = ' ';
        VRAM[i * 2 + 1] = 0x00;
    }
    
    VRAM[0]  = 'E'; VRAM[1]  = 0x0F;
    VRAM[2]  = 'A'; VRAM[3]  = 0x0F;
    VRAM[4]  = 'E'; VRAM[5]  = 0x0F;
    VRAM[6]  = ' '; VRAM[7]  = 0x0F;
    VRAM[8]  = 'S'; VRAM[9]  = 0x0F;
    VRAM[10] = '2'; VRAM[11] = 0x0F;

    halt();
    return 0;
}
