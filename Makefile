#  first tests - DIDN'T WORK
base: asm
	qemu-system-i386 ./drive/boot
run2: asm
	qemu-system-i386 ./drive/boot -fda fat:floopy:rw:./drive/

# second tests - DIDN'T WORK
img:
	qemu-img create -f raw ./drive/floppy 1.44M
fs: img
	mkfs.vfat -c -v -F 12 -M 0xF0 -g 1/18 -D 0 ./drive/floppy
cpboot:
	cp ./drive/boot /mnt/floppy
ddboot:
	dd if=./drive/boot of=./drive/floppy bs=512 count=1 conv=nocreat,notrunc



fat:
	nasm -o drive/fat fat.asm 
	dd if=/dev/zero of=drive/fat bs=512 count=2880

mkfs: fat
	mkfs.vfat -F 12 -n "CARRBOOT" drive/fat

game:
	nasm -o drive/game game.asm

boot:
	nasm -o drive/boot boot.asm

drive: mkfs game boot 
	dd if=drive/boot of=drive/fat bs=512 count=1 conv=nocreat,notrunc

files: drive
	mcopy -i drive/fat dump/other.txt "::other.txt"
	mcopy -i drive/fat dump/file.txt "::file.txt"
	mcopy -i drive/fat drive/game "::game"

run: files 
	qemu-system-i386 -drive file=drive/fat,if=floppy,media=disk,format=raw,index=0

DRIVE_FILE = fat
mount:
	mount drive/$(DRIVE_FILE) /mnt/carrboot -t vfat -o loop 
unmount:
	umount /mnt/carrboot



