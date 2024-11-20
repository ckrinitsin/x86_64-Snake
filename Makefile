main: main.asm border.asm utils.asm
	mkdir -p build/
	nasm -f elf64 -g main.asm -o build/main.o
	nasm -f elf64 -g border.asm -o build/border.o
	nasm -f elf64 -g utils.asm -o build/utils.o
	nasm -f elf64 -g input.asm -o build/input.o
	ld build/main.o build/border.o build/utils.o build/input.o -o main

clean:
	rm -r main build/
