__attribute__((section(".beginsec")))
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


static void halt();
static void error();
static void put_pixel(byte* buf , int col, int row, byte clr);
static void rect_draw(Rect* r);
static void rect_update(Rect* r);

static const byte BLACK         = 0x00;
static const byte BLUE          = 0x01;
static const byte GREEN         = 0x02;
static const byte CYAN          = 0x03;
static const byte RED           = 0x04;
static const byte MAGENTA       = 0x05;
static const byte BROWN         = 0x06;
static const byte LIGHT_GRAY    = 0x07;
static const byte DARK_GRAY     = 0x08;
static const byte LIGHT_BLUE    = 0x09;
static const byte LIGHT_GREEN   = 0x0A;
static const byte LIGHT_CYAN    = 0x0B;
static const byte LIGHT_RED     = 0x0C;
static const byte LIGHT_MAGENTA = 0x0D;
static const byte YELLOW        = 0x0E;
static const byte WHITE         = 0x0F;
                  
byte CURCOLOR = CYAN;

static byte* VRAM = (byte*)0xA0000;

static byte buffer[SW * SH] = {0};

static void halt() 
{
    for (;;);
}

static byte get_pixel(byte* buf, int col, int row)
{
    if (col >= SW) error();
    if (row >= SH) error();
    return buf[row * SW + col];
}


static void put_pixel(byte* buf , int col, int row, byte clr)
{
    if (col >= SW) error();
    if (row >= SH) error();
    buf[row * SW + col] = clr;
}

static void buffer_blip()
{
    for (int i = 0; i < SW * SH; i++) 
        VRAM[i] = buffer[i];
}

static void buffer_fill(byte clr)
{
    for (int row = 0; row < SH; row++)
        for (int col = 0; col < SW; col++)
            put_pixel(buffer, col, row, clr);
}

static bool buffer_is_above_threshold()
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

static void error()
{
    for (int row = 0; row < SH; row++)
        for (int col = 0; col < SW; col++)
            put_pixel(VRAM, col, row, RED);
    halt();
}

void rect_draw(Rect* r)
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
    buffer_fill(BLACK);
    buffer_blip();

    Rect r = (Rect) {
        .x  = 10, .y  = 10,
        .w  = 20, .h  = 20,
        .vx = 2,  .vy = 2,
    };

    int frames = 0;
    for (;;) {
        // if (frames > 1000) {
        //     frames = 0;
        //      CURCOLOR = (CURCOLOR + 1) % 0x0F;
        // }


        if (buffer_is_above_threshold()) {
            CURCOLOR = (CURCOLOR + 1) % 0x0F;
        };

        rect_update(&r);
        rect_draw(&r);
        buffer_blip();
        // buffer_fill(BLACK);
        // frames++;
    }

    halt();
    return 0;
}
