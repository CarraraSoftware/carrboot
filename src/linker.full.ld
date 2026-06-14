OUTPUT_FORMAT("elf32-i386")

ENTRY("_start")

MEMORY {
  rom (rx)   : ORIGIN = 0x8000,  LENGTH = 16K
  ram (rw!x) : ORIGIN = 0x10000, LENGTH = 256M
}

SECTIONS {
   . = 0x8000;

   .text : {
     *(.text)
     *(.text.*)
   } > rom

   .bss : { 
       *(.bss)
       *(.bss.*) 
   } > ram

   .data : { 
       *(.data)
       *(.data.*) 
   } > ram AT> rom

   .rodata : { 
       *(.rodata)
       *(.rodata.*) 
   } > rom 

}

