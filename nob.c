#define NOB_IMPLEMENTATION
#define NOB_EXPERIMENTAL_DELETE_OLD
#include "vendor/nob.h"


#define BIGBOY_IDX 2
#define BIGBOY (FILES[(BIGBOY_IDX)])
char BBNAME[11];

typedef enum {
    C,
    ASM,
} FileType;


// @TODO: automate this? maybe transfer all files in bin/ dir?
const char* FILES [] = {
    [0] = "alberto",
    [1] = "bouncer",
    [2] = "cigboy",
    [3] = "teste",
    [4] = "shifter",
    [5] = "carrsys",
};

const FileType FTYPES [] = {
    [0] = C,
    [1] = C,
    [2] = C,
    [3] = C,
    [4] = ASM,
    [5] = ASM,
};


void cc_flags(Cmd* cmd)
{
    cmd_append(cmd, "-O0");
    cmd_append(cmd, "-fno-stack-protector");
    cmd_append(cmd, "-ffreestanding");
    cmd_append(cmd, "-masm=intel");
    cmd_append(cmd, "-m32");
    cmd_append(cmd, "-march=i386");
    cmd_append(cmd, "-nostdlib");
    cmd_append(cmd, "-nostartfiles");
    cmd_append(cmd, "-std=c11");
    cmd_append(cmd, "-ggdb");
}

void cc_asm_flags(Cmd* cmd) 
{
    cmd_append(cmd, "-Wa,--32");
}

void cc_linker_flags(Cmd* cmd)
{
    cmd_append(cmd, "-Wl,--no-dynamic-linker");
    cmd_append(cmd, "-Wl,-no-pie");
    cmd_append(cmd, "-Wl,-melf_i386");
    cmd_append(cmd, "-Wl,-T,src/linker.ld");
    cmd_append(cmd, "-Wl,--oformat=elf32-i386");
}

void ld_flags(Cmd* cmd) {
    cmd_append(cmd, "--no-dynamic-linker");
    cmd_append(cmd, "-no-pie");
    cmd_append(cmd, "-melf_i386");
    cmd_append(cmd, "-T");
    cmd_append(cmd, "src/linker.ld");
    cmd_append(cmd, "--oformat=elf32-i386");
};

bool bbname(void)
{
    size_t n = strlen(BIGBOY);

    if  (n > 11) {
        printf("ERROR: BIGBOY is bigger than 11 chars: %s\n", BIGBOY);
        return false;
    }
 
    for (int i = 0; i < 11; ++i)
        if (i < n) BBNAME[i] = toupper(BIGBOY[i]); 
        else       BBNAME[i] = ' '; 

    return true;
}

bool bootloader(Cmd* cmd)
{
    cmd->count = 0;
    Procs ps = {0};

    cmd_append(cmd, "nasm");
    cmd_append(cmd, "-g");
    cmd_append(cmd, "-f", "bin");
    cmd_append(cmd, "-o", "bin/boot");
    cmd_append(cmd, "boot/boot.asm");
    cmd_append(cmd, temp_sprintf("-DBIGBOY=\"%s\"", BBNAME));
    if (!cmd_run(cmd, .async = &ps)) return false;

    cmd->count = 0;
    cmd_append(cmd, "nasm");
    cmd_append(cmd, "-g");
    cmd_append(cmd, "-f", "bin");
    cmd_append(cmd, "-o", "bin/alberto");
    cmd_append(cmd, "src/alberto.asm");
    if (!cmd_run(cmd, .async = &ps)) return false;

    return procs_flush(&ps);
}

bool carrsys(Cmd *cmd)
{
    cmd->count = 0;
    cmd_append(cmd, "nasm");
    cmd_append(cmd, "-g");
    cmd_append(cmd, "-f", "elf32");
    cmd_append(cmd, "-o", "obj/carrsys.o");
    cmd_append(cmd, "carrsys/carrsys.asm");
    if (0 == strcmp(BIGBOY, "carrsys")) cmd_append(cmd, "-DCARRSYS_EXEC");

    return cmd_run(cmd);
}

bool bigboy(Cmd *cmd)
{
    if (!bbname()) return false;
    bool is_cfile = FTYPES[BIGBOY_IDX] == C;
    cmd->count = 0;

    if (is_cfile) {

        cmd_append(cmd, "gcc");
        cc_flags(cmd);
        cmd_append(cmd, "-c");
        cmd_append(cmd, "-o", temp_sprintf("obj/%s.o", BIGBOY));
        cmd_append(cmd, temp_sprintf("src/%s.c", BIGBOY));
        cc_asm_flags(cmd);
        if (!cmd_run(cmd)) return false;

        cmd_append(cmd, "ld");
        ld_flags(cmd);
        cmd_append(cmd, temp_sprintf("obj/%s.o", BIGBOY));
        cmd_append(cmd, "obj/carrsys.o");
        cmd_append(cmd, "-o", temp_sprintf("bin/%s", BIGBOY));
        if (!cmd_run(cmd)) return false;

    } else {

        cmd_append(cmd, "ld");
        ld_flags(cmd);
        cmd_append(cmd, temp_sprintf("obj/%s.o", BIGBOY));
        cmd_append(cmd, "-o", temp_sprintf("bin/%s", BIGBOY));
        if (!cmd_run(cmd)) return false;

    }

    return true;
}

bool bigasm(Cmd *cmd)
{
    cmd->count = 0;
    cmd_append(cmd, "gcc");
    cmd_append(cmd, "-S");
    cc_flags(cmd);
    cmd_append(cmd, "-o", temp_sprintf("dump/%s.asm", BIGBOY));
    cmd_append(cmd, temp_sprintf("src/%s.c", BIGBOY));
    return cmd_run(cmd);
}

bool bin(Cmd *cmd)
{
    if (!bootloader(cmd))  return false;
    if (!carrsys(cmd)) return false;  
    if (!bigboy(cmd))      return false;
    return true;
}


const char* FLOPPY = "dev/floppy.img";  // fake floppy
// const char* FLOPPY = "/dev/sdc"; // real floppy

bool floppy(Cmd* cmd)
{
    cmd->count = 0;

 	// zero out exactly 1.44Mb for the floppy
    cmd_append(cmd, "dd");
    cmd_append(cmd, "if=/dev/zero");
    cmd_append(cmd, temp_sprintf("of=%s", FLOPPY));
    cmd_append(cmd, "bs=1474560");
    cmd_append(cmd, "count=1");
    if (!cmd_run(cmd)) return false;


    // format it for FAT12 file system
	cmd_append(cmd, "mkfs.fat");
	cmd_append(cmd, "-v");          // verbose 
	cmd_append(cmd, "-f", "2");     // 2 FAT tables
	cmd_append(cmd, "-F", "12");    // FAT 12 file system
	cmd_append(cmd, "-M", "0xF0");  // Media Type for floppy disk
	cmd_append(cmd, "-g", "2/18");  // Geometry = 2 Heads; 18 tracks per Head
	cmd_append(cmd, "-D", "0");     // Drive number = 0
	cmd_append(cmd, "-R", "1");     // Just one Reserved sector for the bootsector
	cmd_append(cmd, "-s", "1");     // 1 sector per cluster
	cmd_append(cmd, FLOPPY);
    if (!cmd_run(cmd)) return false;

	// transfer the bootsector
	cmd_append(cmd, "dd");
	cmd_append(cmd, "if=bin/boot");
	cmd_append(cmd, temp_sprintf("of=%s", FLOPPY));
	cmd_append(cmd, "bs=512");
	cmd_append(cmd, "count=1");
	cmd_append(cmd, "conv=nocreat,notrunc");
    if (!cmd_run(cmd)) return false;


    // and then all the files
    int n = ARRAY_LEN(FILES);
	for (int i = 0; i < n; ++i) {
        const char* file = FILES[i];
        cmd_append(cmd, "mcopy");
        cmd_append(cmd, "-i", FLOPPY);
        cmd_append(cmd, temp_sprintf("bin/%s", file));
        cmd_append(cmd, temp_sprintf("::%s", file));
        if (!cmd_run(cmd)) return false;
    }

    return true;
}

bool bochs(Cmd* cmd)
{
    // generate bochsrc.txt file with the emulator's settings
    String_Builder sb = {0};
    sb_append_cstr(&sb, "megs:            32\n");
    sb_append_cstr(&sb, "boot:            floppy\n");
    sb_appendf(&sb,     "floppya:         1_44=%s, status=inserted\n", FLOPPY);
    sb_append_cstr(&sb, "log:             .bochslog\n");
    sb_append_cstr(&sb, "clock:           sync=realtime, time0=local\n");
    sb_append_cstr(&sb, "cpu:             model=pentium, count=1, ips=1000000\n");
    // sb_append_cstr(&sb, "debug:           action=ignore, pic=report, cpu0=report\n");
    const char* path = ".bochsrc";
    if (!nob_write_entire_file(path, sb.items, sb.count)) return false;
    sb_free(sb);

    // run it
    cmd->count = 0;
    cmd_append(cmd, "bochs");
    cmd_append(cmd, "-f", path); // settings file
    cmd_append(cmd, "-q");       // quick start = no prompts
    // cmd_append(cmd, "-debugger");// in case of sudden need of debugging
    return cmd_run(cmd);
}

bool qemu(Cmd* cmd)
{
    cmd->count = 0;

	cmd_append(cmd, "qemu-system-i386");
	cmd_append(cmd, "-cpu", "pentium");
	cmd_append(cmd, "-m", "32");
	cmd_append(cmd, "-drive", temp_sprintf("file=%s,if=floppy,media=disk,format=raw,index=0", FLOPPY));
    // cmd_append(cmd, "-enable-kvm");
    // cmd_append(cmd, "-no-reboot");
    // cmd_append(cmd, "-d", "int"); // log all interrupt calls
    // cmd_append(cmd, "-s", "-S"); // debug flags

    return cmd_run(cmd);
}


bool objdump(Cmd* cmd)
{
	cmd_append(cmd, "objdump");
	cmd_append(cmd, "-D");
	cmd_append(cmd, "-b", "binary");
	cmd_append(cmd, "--architecture=i386:intel");
	cmd_append(cmd, temp_sprintf("bin/%s", BIGBOY));
    return cmd_run(cmd, .stdout_path = "dump/dump.bin");
}

bool main(int argc, char* argv[])
{
    GO_REBUILD_URSELF(argc, argv);    

    Cmd cmd = {0};
    // if (!bigasm(&cmd))     return false;

    if (!bbname())         return !false;
    if (!bin(&cmd))        return !false;
    if (!floppy(&cmd))     return !false;

    // if (!objdump(&cmd))    return !false;

    if (!qemu(&cmd))       return false;
    // if (!bochs(&cmd))      return !false;

    return !true;
}
