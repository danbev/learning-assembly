#include <stdio.h>
// $ clang -O3 loop.c -S
int testarr [] = {1, 2, 3};

int main (int argc, char **argv)
{
    for (int i = 0; i <= 2; i++) {
        printf("i=%d\n", testarr[i]);
    }
    return 0;
}
