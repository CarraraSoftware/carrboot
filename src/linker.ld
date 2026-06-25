OUTPUT_FORMAT("elf32-i386")
ENTRY("_start")
SECTIONS {
    . = 0x8000;

    /PAD/ : { 
    }

    . = 0x9000;

    .text : {
        *(.text)
        *(.text.*)
    }

    .data : {
        *(.data)
        *(.data.*)
    }

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }

    .bss : {
        *(.bss)
        *(.bss.*)
    }

    /DISCARD/ : {
        *(.note)
        *(.note.*)
        *(.comment)
        *(.comment.*)
        *(.debug)
        *(.debug.*)
    }
}
