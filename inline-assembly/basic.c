#include <stdio.h>

int main(int argc, char** argv) {
    printf("main...\n");

    int x = 10;
    int y;
    asm("mov %1, %0\n\t"
        "add $3, %0"
        : "=r" (y)
        : "r" (x));

    printf("x=%d, y=%d\n", x, y);
    return 0;
}
