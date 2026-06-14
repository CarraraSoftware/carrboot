__attribute__((naked))
int _start(void)
{
    __asm__("call main\n");
}

#include "cigboy.h"
volatile unsigned char* const VRAM = (unsigned char*)0xB8000;

// @BUG: if we remove the const for this msg, it just doesn't work.
//       it has something to do with the sections defined in the linker script,
//       because if we use linker.full.ld which defines a bunch of sections, it never works.
//       but with linker.ld, which just defines the origin for the .text section, 
//       it works with the const keyword.
//       so i guess it's due to some kind of difference between the sections
//       .data and .rodata, but what exactly i don't know
volatile char* const msg = "EH HORA DE RODAR ISSO AQUI NO TOSHIBAO";

#define COLS 80
#define ROWS 25

void halt() { 
    for (;;) { } 
}

int main(void)
{    
    int s;
    int a;
    int b;
    short i;

    for (i = 0; i < COLS; i++) {
        VRAM[i * 2] = ' ';
        VRAM[i * 2 + 1] = 0x00;
    }
    
    i = 0;
    for (;;) {
        if (msg[i] == '\0') break;
        VRAM[2*i]    = msg[i]; 
        VRAM[2*i+1]  = 0x0F;
        i++;
    }

    i = 2 * COLS;

    a = 26;
    b = 64;
    s = add(26, 64);
    VRAM[i]   = (char)s;
    VRAM[i+1] = 0x0F;

    halt();
    return 0;
}
