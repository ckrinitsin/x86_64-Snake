main: main.asm
	nasm -f elf64 -g main.asm -o main.o
	ld main.o -o main

clean:
	rm main main.o
