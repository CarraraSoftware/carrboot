# Simple example on how to link asm and c together.

carrsys:
	nasm -f elf32 -o carrsys.o carrsys.asm

main:
	gcc -m32 -o main main.c carrsys.o

run: carrsys main
	./main
	
