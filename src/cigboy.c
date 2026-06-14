__attribute__((naked))
int _start(void)
{
    __asm__("call main\n");
}

#include "cigboy.h"
volatile unsigned char* const VRAM = (unsigned char*)0xB8000;
volatile char* const msg = "É HORA DE RODAR ISSO AQUI NO TOSHIBÃO";

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
