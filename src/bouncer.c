__attribute__((naked))
int _start(void)
{
    __asm__("call main\n");
}

#include "../include/bouncer.h"

byte CURCOLOR = CYAN;
byte buffer[GRAPHICS_COLS * GRAPHICS_ROWS] = {0};

bool is_above_threshold(byte* buffer)
{
    int total = GRAPHICS_COLS * GRAPHICS_ROWS;
    int colored = 0;
    for (int row = 0; row < GRAPHICS_ROWS; row++)
        for (int col = 0; col < GRAPHICS_COLS; col++) {
            byte pix = get_pixel(buffer, col, row);
            if (pix == CURCOLOR) colored++;
        }
    return (colored * 100 / total)  > THRESHOLD;
}

void rect_draw(byte* buffer, Rect* r)
{
    for (int y = r->y; y < r->y + r->h; y++)
        for (int x = r->x; x < r->x + r->w; x++)
            put_pixel(buffer, x, y, CURCOLOR);
}

void rect_update(Rect* r)
{
    if (r->x + r->vx > GRAPHICS_COLS - r->w ||r->x + r->vx < 0) {
        r->vx *= -1;
    } else {
        r->x += r->vx;
    }

    if (r->y + r->vy > GRAPHICS_ROWS - r->h ||r->y + r->vy < 0) {
        r->vy *= -1;
    } else {
        r->y += r->vy;
    }
}

int main(void) 
{
    set_graphics_mode();

    buffer_fill(buffer, BLACK);
    buffer_blip(buffer);

    Rect r = (Rect) {
        .x  = 10, .y  = 10,
        .w  = 20, .h  = 20,
        .vx = 2,  .vy = 2,
    };

    for (;;) {
        if (is_above_threshold(buffer)) {
            CURCOLOR = (CURCOLOR + 1) % 0x0F;
        };

        rect_update(&r);
        rect_draw(buffer, &r);
        buffer_blip(buffer);
        // buffer_fill(BLACK);
    }

    return 0;
}
