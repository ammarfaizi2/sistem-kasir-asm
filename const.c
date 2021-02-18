
#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>

#define PRINT_INT_MACRO(MACRO) printf("#define "#MACRO " (%d)\n", MACRO);

int main()
{
	printf("\n\n");
	PRINT_INT_MACRO(O_RDWR);
	PRINT_INT_MACRO(O_RDONLY);
	PRINT_INT_MACRO(O_CREAT);
	PRINT_INT_MACRO(MAP_PRIVATE);
	PRINT_INT_MACRO(PROT_READ);
	PRINT_INT_MACRO(PROT_WRITE);
	PRINT_INT_MACRO(PROT_EXEC);
	printf("\n");
}
