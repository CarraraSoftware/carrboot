// #define CARRSYS_IMPLEMENTATION
#include "carrsys.h"

#define SW 320
#define SH 200
#define THRESHOLD 50


typedef struct {
    int x,  y;
    int vx, vy;
    int w,  h;
} Rect;


void halt();
void error();
void put_pixel(byte* buf , int col, int row, byte clr);
void rect_draw(byte* buffer, Rect* r);
void rect_update(Rect* r);

                  
