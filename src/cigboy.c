__attribute__((naked)) 
int _start(void)
{
    __asm__("call main\n");
    __asm__("_halt_forever: jmp _halt_forever\n");
}

#include "../include/cigboy.h"
byte* VRAM      = (byte*)0xB8000;
byte* ivt       = (byte*)0x0000;
byte* bios_data = (byte*)0x0400;
byte* alberto   = (byte*)0x1000;
byte* kernlreal = (byte*)0x1000;
byte* ivtsave   = (byte*)0x5000;
byte* rstackend = (byte*)0x6000;
byte* rstackini = (byte*)0x7000;
byte* boot      = (byte*)0x7C00;
byte* bigboy    = (byte*)0x8000;
byte* rootdir   = (byte*)0xB400;
byte* fatsecs   = (byte*)0xD000;

#define COLS 80
#define ROWS 25


void halt() { 
    for (;;) { } 
}

void clear() 
{
    char attr;
    int i;

    attr = 0x00;
    for (i = 0; i < COLS; i++) {
        VRAM[i * 2] = ' ';
        VRAM[i * 2 + 1] = attr;
    }
}

void putc(char ch, char attr, int idx)
{
    VRAM[2*idx  ]  = ch; 
    VRAM[2*idx+1]  = attr;
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

void find_file_next_cluster(word current, word* next)
{
    byte* entry = fatsecs + ( current * 3 / 2 );
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
    byte* cur = rootdir;
    // rootdir+32*0   rootdir+32*1   rootdir + 32 * 2  rootdir + 32 * 3
    // v              v              v                 v
    // [   32 bits   ][   32 bits   ][   32 bits   ]   [   32 bits   ]
    // ^              ^              ^
    // i = 0          i = 1          i = 2           ...
    for (word i = 0; i < NumberRootEntries; ++i) {
        byte* cur = rootdir + 32*i;
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


byte read_file_clusters(char* name, byte* buf, int num_clusters)
{
    byte count;
    word cluster;
    find_file_first_cluster(name, &cluster);
    for (int i = 0; i < num_clusters; ++i) {
        if (cluster < 2) return count;
        read_cluster(buf, cluster);
        buf += SectorsPerCluster * BytesPerSector;
        find_file_next_cluster(cluster, &cluster);
        count++;
    };
    return num_clusters;
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


int main(void)
{    
    char out[4];
    char attr = ATTR(GREEN, BLACK);

    set_text_mode();
    clear();

    // buf = (char*)0x1000;
    // read_file((char*)name, (char*)buf);

    char* name = "LINUX      "; 
    byte n = read_file_clusters(name, kernlreal, 31);
    // fmtbyte(n, out);
    // print(out, attr);

    // byte one = *(kernlreal + 0x1FE);
    // byte two = *(kernlreal + 0x1FF);
    // byte three = *(kernlreal + 0x202);
    // fmtbyte(three, out);
    // print(out, attr);

    byte* b = kernlreal + 0x202;
    printn((char*)b, attr, 4);
    // printn((char*)kernlreal, attr, 80);



end:
    return 0;
}
