__attribute__((naked)) 
int _start(void)
{
    __asm__("jmp main\n");
}

#include "../include/cigboy.h"
byte* VRAM = (byte*)0xB8000;



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

void fmtbyte(byte value, char out[3])
{
    int i;
    byte ch;

    i = 0;
    do { 
        ch = '0' + value % 10;
        out[i++] = ch;
        value = value / 10;
    } while(value != 0);
}


void readcluster(byte* buffer, word cluster_number)
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
    read_sectors(buffer, lba, 1);
    return;
}


void print_quad(char attr)
{
    int i;
    int index;
    byte b;
    b = (long int)fatsecs % 16;
    for (i = 0; i < 4; i++) {
        char str[3];
        int j;

        fmtbyte(b, str);    

        for (j = 0; j < 3; j++)
            putc(str[j], attr, index++);

        b = b / 16;
    }

}


int main(void)
{    
    short i;
    byte ch;
    char out[3];
    char attr; 
    char* buf;
    char* name;


    set_text_mode();
    clear();

    // buf = (char*)0x1000;
    // name = "LINUX      "; 
    // read_file((char*)name, (char*)buf);
    // read_file_clusters(name, buf, 31);

    attr = ATTR(BLACK, GREEN);
    print("OK", attr);

    // print("OK", attr);

    // printn((char*)buf, attr, 80);
    halt();
    return 0;
}
