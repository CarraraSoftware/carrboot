#ifndef CARRSYS_H_
#define CARRSYS_H_

typedef int bool;
#define true 1
#define false 0
#ifndef NULL
#define NULL 0x0
#endif
typedef unsigned char byte;
typedef unsigned short int word;
typedef unsigned int dword;
typedef unsigned long int qword;

#define TEXT_COLS 80
#define TEXT_ROWS 25

#define GRAPHICS_COLS 320
#define GRAPHICS_ROWS 200

#define MIN(a, b) (a) < (b) ? (a) : (b)
#define MAX(a, b) (a) > (b) ? (a) : (b)


typedef enum {
    SYS_GRAPHICS = 0x13,
    SYS_TEXT     = 0x02,
} SysMode;


extern int add(int a, int b);
extern void set_text_mode(void);
extern void set_graphics_mode(void);
extern void read_file(char* name, char* buffer);
extern void read_sectors(byte* buffer, word lba, word num_sectors);

// text mode
void clear();
void putc(char ch, char attr, int idx);
void print(char* str, char attr);
void printn(char* str, char attr, int n);
void fmtbyte(byte value, char out[4]);
void print_quad(char attr, byte b);

// graphics mode
byte get_pixel(byte* buffer, int col, int row);
void put_pixel(byte* buffer, int col, int row, byte clr);
void buffer_blip(byte* buffer);
void buffer_fill(byte* buffer, byte clr);
void error();


// memory
void memcopy(byte* src, byte* dst, int n);
bool str_ncomp(char* a, char* b, int n);

// fat12
void read_cluster(byte* buffer, word cluster_number);
void find_file_next_cluster(word current, word* next);
void find_file_first_cluster(char* name, word* out);
byte read_file_clusters(char* name, byte* buf, int num_clusters);

// extern ivt;
// extern bios_data;
// extern alberto;
// extern byte* kernlreal;
// extern byte* ivtsave;
// extern byte* rstackend;
// extern byte* rstackini;
// extern byte* boot;
// extern byte* bigboy;
// extern byte* rootdir;
// extern byte* fatsecs;

extern byte OEMName;
extern word BytesPerSector;
extern byte SectorsPerCluster;
extern word ReservedSectors;
extern byte NumberFATs;
extern word NumberRootEntries;
extern word TotalSectors;
extern byte MediaDescriptor;
extern word SectorsPerFAT;
extern word SectorsPerTrack;
extern word NumberHeads;
extern dword HiddenSectors;
extern dword TotalSectorsBig;
extern byte DriveNumber;
extern byte Unused;
extern byte ExtBootSignature;
extern dword SerialNumber;
extern byte VolumeLabel;
extern byte FileSystem;


#define ATTR(bg, fg) (bg) << 4 | (fg)

#define BLACK         0x0
#define BLUE          0x1
#define GREEN         0x2
#define CYAN          0x3
#define RED           0x4
#define MAGENTA       0x5
#define BROWN         0x6
#define LIGHT_GRAY    0x7
#define DARK_GRAY     0x8
#define LIGHT_BLUE    0x9
#define LIGHT_GREEN   0xA
#define LIGHT_CYAN    0xB
#define LIGHT_RED     0xC
#define LIGHT_MAGENTA 0xD
#define YELLOW        0xE
#define WHITE         0xF

#endif // CARRSYS_H_
