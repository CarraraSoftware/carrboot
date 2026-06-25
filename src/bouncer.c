__attribute__((naked))
int _start(void)
{
    __asm__("call main\n");
}

#include "../include/bouncer.h"

byte* VRAM = (byte*)0xA0000;

void halt() 
{
    for (;;);
}

byte get_pixel(byte* buf, int col, int row)
{
    if (col >= SW) error();
    if (row >= SH) error();
    return buf[row * SW + col];
}


void put_pixel(byte* buf , int col, int row, byte clr)
{
    if (col >= SW) error();
    if (row >= SH) error();
    buf[row * SW + col] = clr;
}

void buffer_blip(byte* buffer)
{
    for (int i = 0; i < SW * SH; i++) 
        VRAM[i] = buffer[i];
}

void buffer_fill(byte* buffer, byte clr)
{
    for (int row = 0; row < SH; row++)
        for (int col = 0; col < SW; col++)
            put_pixel(buffer, col, row, clr);
}

bool buffer_is_above_threshold(byte* buffer)
{
    int total = SW * SH;
    int colored = 0;
    for (int row = 0; row < SH; row++)
        for (int col = 0; col < SW; col++) {
            byte pix = get_pixel(buffer, col, row);
            if (pix == CURCOLOR) colored++;
        }
    return (colored * 100 / total)  > THRESHOLD;
}

void error()
{
    for (int row = 0; row < SH; row++)
        for (int col = 0; col < SW; col++)
            put_pixel(VRAM, col, row, RED);
    halt();
}

void rect_draw(byte* buffer, Rect* r)
{
    for (int y = r->y; y < r->y + r->h; y++)
        for (int x = r->x; x < r->x + r->w; x++)
            put_pixel(buffer, x, y, CURCOLOR);
}

void rect_update(Rect* r)
{
    if (r->x + r->vx > SW - r->w ||r->x + r->vx < 0) {
        r->vx *= -1;
    } else {
        r->x += r->vx;
    }

    if (r->y + r->vy > SH - r->h ||r->y + r->vy < 0) {
        r->vy *= -1;
    } else {
        r->y += r->vy;
    }
}

int main(void) 
{
    char* a = (char*)0xB8000;
    a[0] = '$';
    a[1] = 0x0A;

    set_graphics_mode();

    byte buffer[SW * SH] = {0};

    buffer_fill(buffer, BLACK);
    buffer_blip(buffer);

    Rect r = (Rect) {
        .x  = 10, .y  = 10,
        .w  = 20, .h  = 20,
        .vx = 2,  .vy = 2,
    };

    for (;;) {
        if (buffer_is_above_threshold(buffer)) {
            CURCOLOR = (CURCOLOR + 1) % 0x0F;
        };

        rect_update(&r);
        rect_draw(buffer, &r);
        buffer_blip(buffer);
        // buffer_fill(BLACK);
    }

    return 0;
}
