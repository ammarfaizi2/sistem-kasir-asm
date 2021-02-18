

all: kasir

kasir.o: kasir.asm
	nasm -fPIC -Wall -felf64 -g kasir.asm -o kasir.o

kasir: kasir.o
	ld -pic kasir.o -o kasir

clean:
	rm -vf kasir kasir.o
