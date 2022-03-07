#include "stdio.h"

#define STRING_SIZE 16

int main(int argc, char **argv) {
	char str[STRING_SIZE];
	fgets(str, STRING_SIZE-1, stdin);
	
	for (int i=0; i<STRING_SIZE-1; ++i) {
		str[i] = str[i] % 92 + 32;
	}
		
	str[STRING_SIZE-1] = 0;

	printf("input string: %s\n", str);
	return 0;
}
