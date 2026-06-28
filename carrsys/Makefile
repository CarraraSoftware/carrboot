# Simple example on how to link asm and c together.

carrsys:
	nasm -f elf32 -o carrsys_core.o carrsys_core.asm
	nasm -f elf32 -o carrsys_utils.o carrsys_utils.asm

main:
	gcc -m32 -o main main.c carrsys_core.o carrsys_utils.o

run: carrsys main
	./main
	
