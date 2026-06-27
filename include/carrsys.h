typedef int bool;
#define true 1
#define false 0

typedef unsigned char byte;
typedef unsigned short int word;
typedef unsigned int dword;
typedef unsigned long int qword;


typedef enum {
    SYS_GRAPHICS = 0x13,
    SYS_TEXT     = 0x02,
} SysMode;

extern int add(int a, int b);
extern void set_text_mode(void);
extern void set_graphics_mode(void);
extern void read_file(char* name, char* buffer);
extern void read_sectors(byte* buffer, word lba, word num_sectors);

// extern ivt;
// extern bios_data;
// extern alberto;
extern byte* kernlreal;
// extern byte* ivtsave;
// extern byte* rstackend;
// extern byte* rstackini;
// extern byte* boot;
extern byte* bigboy;
extern byte* rootdir;
extern byte* fatsecs;

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
