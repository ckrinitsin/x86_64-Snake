main: src/main.asm src/border.asm src/utils.asm src/input.asm src/fruit.asm
	mkdir -p build/
	nasm -f elf64 -g src/main.asm -o build/main.o
	nasm -f elf64 -g src/border.asm -o build/border.o
	nasm -f elf64 -g src/utils.asm -o build/utils.o
	nasm -f elf64 -g src/input.asm -o build/input.o
	nasm -f elf64 -g src/fruit.asm -o build/fruit.o
	ld build/main.o build/border.o build/utils.o build/input.o build/fruit.o -o main

.PHONY:
clean:
	rm -r main build/
