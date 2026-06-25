__attribute__((naked)) 
int _start(void)
{
    __asm__("jmp main\n");
}

#include "../include/cigboy.h"
volatile unsigned char* const VRAM = (unsigned char*)0xB8000;

// @BUG: if we remove the const for this msg, it just doesn't work.
//       it has something to do with the sections defined in the linker script,
//       because if we use linker.full.ld which defines a bunch of sections, it never works.
//       but with linker.ld, which just defines the origin for the .text section, 
//       it works with the const keyword.
//       so i guess it's due to some kind of difference between the sections
//       .data and .rodata, but what exactly i don't know
const char* msg = "HOJE EU VOU DORMIR TRANQUILAÇO MEU BROTHER";

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
    char attr;

    set_text_mode(); // defined in assembly

    for (i = 0; i < COLS; i++) {
        attr = 0x00;
        VRAM[i * 2] = ' ';
        VRAM[i * 2 + 1] = attr;
    }
    
    attr = 0x0A;
    VRAM[0] = '*';
    VRAM[1] = attr;

    i = 0;
    for (;;) {
        if (msg[i] == '\0') break;
        VRAM[2*COLS + 2*i]    = msg[i]; 
        VRAM[2*COLS + 2*i+1]  = attr;
        i++;
    }


    i = 4 * COLS;
    a = 26;
    b = 64;
    s = add(26, 64);
    VRAM[i]   = (char)s;
    VRAM[i+1] = attr;

    halt();
    return 0;
}
