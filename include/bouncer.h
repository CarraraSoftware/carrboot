// #define CARRSYS_IMPLEMENTATION
#include "carrsys.h"

#define SW 320
#define SH 200
#define THRESHOLD 50

typedef int bool;
#define true 1
#define false 0

typedef unsigned char byte;

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

const byte BLACK         = 0x00;
const byte BLUE          = 0x01;
const byte GREEN         = 0x02;
const byte CYAN          = 0x03;
const byte RED           = 0x04;
const byte MAGENTA       = 0x05;
const byte BROWN         = 0x06;
const byte LIGHT_GRAY    = 0x07;
const byte DARK_GRAY     = 0x08;
const byte LIGHT_BLUE    = 0x09;
const byte LIGHT_GREEN   = 0x0A;
const byte LIGHT_CYAN    = 0x0B;
const byte LIGHT_RED     = 0x0C;
const byte LIGHT_MAGENTA = 0x0D;
const byte YELLOW        = 0x0E;
const byte WHITE         = 0x0F;
                  
byte CURCOLOR = CYAN;
