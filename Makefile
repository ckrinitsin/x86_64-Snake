main: src/main.asm src/border.asm src/utils.asm
	mkdir -p build/
	nasm -f elf64 -g src/main.asm -o build/main.o
	nasm -f elf64 -g src/border.asm -o build/border.o
	nasm -f elf64 -g src/utils.asm -o build/utils.o
	nasm -f elf64 -g src/input.asm -o build/input.o
	ld build/main.o build/border.o build/utils.o build/input.o -o main

.PHONY:
clean:
	rm -r main build/
