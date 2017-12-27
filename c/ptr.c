#include <stdio.h>

int main (int argc, char **argv) {
  int* p = new int(10);
  printf ("%p\n", p);
  return 0;
}
