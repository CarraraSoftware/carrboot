#include "../include/carrsys.h"


byte* GRAPHICS_VRAM = (byte*)0xA0000;
byte* TEXT_VRAM     = (byte*)0xB8000;
byte* ivt           = (byte*)0x0000;
byte* bios_data     = (byte*)0x0400;
byte* alberto       = (byte*)0x1000;
byte* kernlreal     = (byte*)0x1000;
byte* ivtsave       = (byte*)0x5000;
byte* rstackend     = (byte*)0x6000;
byte* rstackini     = (byte*)0x7000;
byte* diskbuf       = (byte*)0x7000;
byte* boot          = (byte*)0x7C00;
byte* bigboy        = (byte*)0x8000;
byte* rootdir       = (byte*)0xB400;
byte* fatsecs       = (byte*)0xD000;

void assert(bool cond, char* msg)
{
    if (!cond) {
        print(msg, ATTR(RED, WHITE));
        halt();
    }
}


void halt(void)
{
    for(;;);
}

/*******************************************************************************
* MEMORY
*******************************************************************************/


void memcopy(byte* src, byte* dst, int n)
{
    for (int i = 0; i < n; ++i) dst[i] = src[i];
}

bool str_ncomp(char* a, char* b, int n)
{
    for (int j = 0; j < n; ++j) {
        if (a[j] != b[j]) return false;
    }
    return true;
}

/*******************************************************************************
* TEXT MODE
*******************************************************************************/

void clear() 
{
    char attr;
    int i;

    attr = 0x00;
    for (i = 0; i < TEXT_COLS; i++) {
        TEXT_VRAM[i * 2] = ' ';
        TEXT_VRAM[i * 2 + 1] = attr;
    }
}

void putc(char ch, char attr, int idx)
{
    TEXT_VRAM[2*idx  ]  = ch; 
    TEXT_VRAM[2*idx+1]  = attr;
}

void print(char* str, char attr)
{
    int i;
    for (i = 0; str[i] != '\0'; i++) putc(str[i], attr, i);
}

void printn(char* str, char attr, int n)
{
    int i;
    for (i = 0; i < n; i++) putc(str[i], attr, i);
}

void fmtbyte(byte value, char out[4])
{
    int i;
    byte ch;

    i = 0;
    do { 
        ch = '0' + value % 10;
        out[i++] = ch;
        value = value / 10;
    } while(value != 0);

    for (int j = 0; j < i / 2; ++j) {
        byte a = out[j];
        out[j] = out[i - j - 1];
        out[i - j - 1] = a;
    }

}


void print_quad(char attr, byte b)
{
    int i;
    int index;
    // b = (long int)fatsecs % 16;
    for (i = 0; i < 4; i++) {
        char str[4];
        int j;

        fmtbyte(b, str);

        for (j = 0; j < 3; j++)
            putc(str[j], attr, index++);

        b = b / 16;
    }
}


/******************************************************************************
 * FAT12                                                                       
 ******************************************************************************/                                                                            

void read_cluster(byte* buffer, word cluster_number)
// NOTE: first cluster => cluster_number = 0x02
{
    // cluster_number - 2 => offset from RootDirectory
    word offset = cluster_number - 2;
    // Sectors in Root
    word root_sectors = (NumberRootEntries * 0x20) / BytesPerSector;
    // SectorsInFat
    word fat_sectors = SectorsPerFAT * NumberFATs;
    // HiddenSectors + ReservedSectors + SectorsInFat + SectorsInRoot + cluster_number - 2
    word lba = offset + HiddenSectors + ReservedSectors + root_sectors + fat_sectors;
    read_sectors(buffer, lba, SectorsPerCluster);
    return;
}


void find_file_next_cluster(word current, word* next)
{
    const byte* entry = fatsecs + ( current * 3 / 2 );
    word bs = *(word*)entry;

    if (bs == 0x0FFF || bs == 0x0000) {
        *next = 0;
        return;
    }

    if ((current * 3) % 2 == 0) {
        *next = 0x0FFF & bs;
        return;
    }
    *next = bs >> 4;
    return;
}


void find_file_first_cluster(char* name, word* out)
{
    // rootdir
    const byte* cur = rootdir;
    // rootdir+32*0   rootdir+32*1   rootdir + 32 * 2  rootdir + 32 * 3
    // v              v              v                 v
    // [   32 bits   ][   32 bits   ][   32 bits   ]   [   32 bits   ]
    // ^              ^              ^
    // i = 0          i = 1          i = 2           ...
    for (word i = 0; i < NumberRootEntries; ++i) {
        const byte* cur = rootdir + 32*i;
        if (!str_ncomp(name, (char*)cur, 11)) {
            // not found;
            continue;
        }

        // found! cur contains the root entry for the file
        // cur + 0x1A => file's first cluster
        // *out = cur[0x1A] << 8 | cur[0x1B];
        *out = *(cur + 0x1A);
        return;
    }
    out = 0;
    return;
}


#define DISK_BUFFER_SECTORS 8

byte read_file_clusters(char* name, byte* buf, int num_clusters)
{

    assert(
        SectorsPerCluster <= DISK_BUFFER_SECTORS,
        "ERROR: FILE CLUSTER IS BIGGER THAN DISK BUFFER"
    );

    byte count;
    word cluster;
    find_file_first_cluster(name, &cluster);

    while (num_clusters > 0) {

        int clusters_to_read = MIN(8, num_clusters * SectorsPerCluster);
        num_clusters = MAX(0, num_clusters - clusters_to_read);

        byte* disk_buffer = diskbuf;
        for (int i = 0; i < clusters_to_read; ++i) {
            if (cluster < 2) {
                clusters_to_read = i;
                num_clusters = 0;
                break;
            }
            read_cluster(disk_buffer, cluster);
            disk_buffer += SectorsPerCluster * BytesPerSector;
            find_file_next_cluster(cluster, &cluster);
            count++;
        };
        
        int num_bytes = (clusters_to_read * SectorsPerCluster * BytesPerSector);
        memcopy(diskbuf, buf, num_bytes);
        buf += num_bytes;
    }

    return count;
}

/*******************************************************************************
 * GRAPHICS MODE
********************************************************************************/

byte get_pixel(byte* buf, int col, int row)
{
    if (col >= GRAPHICS_COLS) error();
    if (row >= GRAPHICS_ROWS) error();
    return buf[row * GRAPHICS_COLS + col];
}


void put_pixel(byte* buf , int col, int row, byte clr)
{
    if (col >= GRAPHICS_COLS) error();
    if (row >= GRAPHICS_ROWS) error();
    buf[row * GRAPHICS_COLS + col] = clr;
}

void buffer_blip(byte* buffer)
{
    for (int i = 0; i < GRAPHICS_COLS * GRAPHICS_ROWS; i++) 
        GRAPHICS_VRAM[i] = buffer[i];
}

void buffer_fill(byte* buffer, byte clr)
{
    for (int row = 0; row < GRAPHICS_ROWS; row++)
        for (int col = 0; col < GRAPHICS_COLS; col++)
            put_pixel(buffer, col, row, clr);
}


void error()
{
    for (int row = 0; row < GRAPHICS_ROWS; row++)
        for (int col = 0; col < GRAPHICS_COLS; col++)
            put_pixel(GRAPHICS_VRAM, col, row, RED);
    halt();
}
