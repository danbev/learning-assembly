#include <stdio.h>

int main (int argc, char **argv, char **envp, char **apple)
{
    int i = 0;
    for (i=0; i < 4; i++)
        printf ("%s\n", apple[i]);

    return 0;
}
