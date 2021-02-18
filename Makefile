
all: cashier

const.S: const.c
	$(CC) const.c -o const
	./const > const.S

cashier: cashier.S const.S
	$(CC) -static -nostdlib -nostartfiles -ggdb3 -O3 -fPIC -o $@ cashier.S

clean:
	rm -vf cashier const const.S
