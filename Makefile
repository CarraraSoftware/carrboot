#######################################
# compile all the binaries and objects
#######################################
#
# @TODO: do some more tests to be able to link with ld, because I wanna learn it more
#        now, all the c files are being compiled and linked with just gcc,
#        but I want to be able to compile just the object files and then link them all together.
#        something like:
# bigboy:
#   gcc $(CFLAGS) -c -o obj/bouncer.o src/bouncer.c  generates just the object file
# 	ld --no-dynamic-linker -no-pie -melf_i386 -T src/linker.ld -o src/$(SRC) obj/$(SRC).o

BIGBOY ?= cigboy
CFLAGS ?= -O0 -fno-stack-protector -ffreestanding -masm=intel -m32 -nostdlib -nostartfiles -std=c11
LFLAGS ?= -Wl,--no-dynamic-linker -Wl,-no-pie -Wl,-melf_i386 -Wl,-T,src/linker.ld -Wl,--oformat=elf32-i386
FILES  ?= alberto bouncer cigboy teste

bootloader: boot alberto

boot:
	nasm -o bin/boot boot/boot.asm

alberto:
	nasm -o bin/alberto src/alberto.asm

carrsys:
	nasm -f elf32 carrsys/carrsys.asm -o carrsys/carrsys.o

bigboy: carrsys
	gcc $(CFLAGS) -o bin/$(BIGBOY) src/$(BIGBOY).c carrsys/carrsys.o $(LFLAGS)
		
bigasm: 
	gcc -S $(CFLAGS) -o dump/$(BIGBOY).asm src/$(BIGBOY).c

bin: bootloader carrsys bigboy



#######################################
# format and ready out the floppy disk
#######################################
# fake floppy
FLOPPY ?= floppy.img
# real floppy
# FLOPPY ?= /dev/sdc 

floppy:
 	# zero out exactly 1.44Mb for the floppy
	dd if=/dev/zero of=$(FLOPPY) bs=1474560 count=1 
    # format it for FAT12 file system
	mkfs.fat -v -f 2 -F 12 -M 0xF0 -g 2/18 -D 0 -R 1 -s 1 $(FLOPPY) 
	# transfer the bootsector
	dd if=bin/boot of=$(FLOPPY) bs=512 count=1 conv=nocreat,notrunc 
    # and then all the files (I hate putting a damn for loop in a makefile, this is horrible)
	for file in $(FILES); do                    \
     	mcopy -i $(FLOPPY) bin/$$file "::$$file";  \
	done


#######################################
# run emulators
#######################################

# @TODO: figure out how to use the correct floppy disk for bochs,
# 	     I didn't find the corresponding command line flag for the field
# 	     `floppya: 1_44=floppy.img, status=inserted` which is present in bochsrc.txt
# 	     and I don't want to make some freaky config text generator just for this.
bochs: bin floppy
	bochs -f bochsrc.txt -q

qemu: bin floppy
	qemu-system-i386 -cpu pentium -m 32 -drive file=$(FLOPPY),if=floppy,media=disk,format=raw,index=0

