// @TODO: decide if I should delete this or actually develop it further
//        so far, it just checks for the magic bytes that indicates it is indeed multiboot.             
//        this was just some preliminary tests for bootign linux, but it turns out that linux doesn't   use multiboot (apparently?).          

#include <stdio.h>

#define CARR_SV_IMPLEMENTATION
#include "../vendor/sv.h"

static const unsigned char multiboot_magic_byte[] = {
  0x1B, 0xAD, 0xB0, 0x02,
};

static const unsigned char multiboot2_magic_byte[] = { 
  0xE8, 0x52, 0x50, 0xD6,
};



int main(void)
{
    StringBuilder bytes;
    StringView view;
    size_t i;
    size_t j;
    int hdidx = -1;
    int isit = 0;
    unsigned char byte;


    // bytes = sb_from_file("./bin/LINUX");
    bytes = sb_from_file("memory.txt");
    for (i = 0; i <= bytes.len - 4; ++i) {
        printf("%c", bytes.data[i]);

        continue;
        isit = 1;

        for (j = 0; j < 4; ++j) {
            byte = *(unsigned char*)(bytes.data + i + j);
            if (byte != multiboot2_magic_byte[j]) {
                isit = 0;
                break;
            }
        }

        if (isit) {
            hdidx = i;
            break;
        }

    }

    return 0;


    if (hdidx == -1) { 
        printf("header not found\n");
        return 1;
    } 

    printf("found header at %d\n", hdidx);

    view.data = bytes.data + hdidx;
    view.len  = 4;

    printf("[ 0x");
    for (i = 0; i < view.len; ++i)
        printf("%X", view.data[i]);
    printf(" ]\n"); 

    return 0;
}
