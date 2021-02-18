

all: kasir

kasir.o: kasir.asm
	nasm -O3 -Wall -felf64 -g kasir.asm -o kasir.o

kasir: kasir.o
	ld kasir.o -o kasir

clean:
	rm -vf kasir kasir.o
