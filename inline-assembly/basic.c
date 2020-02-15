#include <stdio.h>

int main(int argc, char** argv) {
    printf("main...\n");

    int x = 10;
    int y = 20;
    int z;
    asm("mov %1, %0\n\t"
        "add %2, %0"
        : "=r" (z)
        : "r" (x), "r" (y));

    printf("x=%d, y=%d, z=%d\n", x, y, z);
    return 0;
}
