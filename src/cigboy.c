__attribute__((naked)) 
int _start(void)
{
    __asm__("call main\n");
    __asm__("_halt_forever: jmp _halt_forever\n");
}

#include "../include/carrsys.h"
extern byte* kernlreal;


int main(void)
{    
    set_text_mode();
    clear();

    byte* memory_address = (byte*)0x1000000;
    char* name = "LINUX      "; 
    byte n = read_file_clusters(name, memory_address, 10);

    char attr = ATTR(GREEN, BLACK);
    byte* b = memory_address + 0x202;
    printn((char*)b, attr, 4);

    return 0;
}
