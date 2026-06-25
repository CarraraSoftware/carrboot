typedef enum {
    SYS_GRAPHICS = 0x13,
    SYS_TEXT     = 0x02,
} SysMode;

extern int add(int a, int b);
extern void set_text_mode(void);
extern void set_graphics_mode(void);

