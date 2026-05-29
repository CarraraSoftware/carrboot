# #  first tests - DIDN'T WORK
# base: asm
# 	qemu-system-i386 ./drive/boot
# run2: asm
# 	qemu-system-i386 ./drive/boot -fda fat:floopy:rw:./drive/
# 
# # second tests - DIDN'T WORK
# img:
# 	qemu-img create -f raw ./drive/floppy 1.44M
# fs: img
# 	mkfs.vfat -c -v -F 12 -M 0xF0 -g 1/18 -D 0 ./drive/floppy
# cpboot:
# 	cp ./drive/boot /mnt/floppy
# ddboot:
# 	dd if=./drive/boot of=./drive/floppy bs=512 count=1 conv=nocreat,notrunc
# 
# debug:
# 	qemu-system-i386 -s -S -drive file=drive/fat,if=floppy,media=disk,format=raw,index=0


# FDEV = dev/fat
FDEV = /dev/sdc
FBOOT = boot

fat:
	nasm -o $(FDEV) fat.asm 
	dd if=/dev/zero of=dev/fat bs=512 count=2880

fs: # fat
	mkfs.fat -v -f 2 -F 12 -M 0xF0 -g 2/18 -D 0 -R 1 -s 1 $(FDEV)

bigboy:
	nasm -g -o bin/bigboy run/bigboy.asm

cigboy:
	gcc -O0 -fno-pie -masm=intel -m32 -nostartfiles -nostdlib -ffreestanding -o bin/cigboy run/cigboy.c -Wl,--oformat=binary
# ld -A pentium -nostdlib -O0 -o bin/cigboy --oformat=binary run/cigboy.o
# nasm -g -o bin/cigboy run/cigboy.asm

game:
	nasm -g -o bin/game run/game.asm

alberto:
	nasm -g -o bin/alberto run/alberto.asm

boot:
	nasm -g -o bin/$(FBOOT) boot/$(FBOOT).asm

bootsector: fs alberto game boot bigboy cigboy
	dd if=/dev/zero of=$(FDEV) bs=512 count=1
	dd if=bin/$(FBOOT) of=$(FDEV) bs=512 count=1 conv=nocreat,notrunc

files: bootsector
	mcopy -i $(FDEV) dump/other.txt "::other.txt"
	mcopy -i $(FDEV) dump/file.txt "::file.txt"
	mcopy -i $(FDEV) bin/alberto "::alberto"
	mcopy -i $(FDEV) bin/bigboy "::bigboy"
	mcopy -i $(FDEV) bin/game "::game"
	mcopy -i $(FDEV) bin/cigboy "::cigboy"

files2: bootsector
	cp bin/game /mnt/fdd/
	cp dump/other.txt /mnt/fdd/
	cp dump/file.txt /mnt/fdd/
	cp bin/alberto /mnt/fdd/
	cp bin/bigboy /mnt/fdd/
	cp bin/cigboy /mnt/fdd/
	sync

run: files
	qemu-system-i386 -cpu pentium -m 32 -drive file=$(FDEV),if=floppy,media=disk,format=raw,index=0

mount: bootsector
	mount $(FDEV) /mnt/fdd/

finish:
	sync
	umount /mnt/fdd/




