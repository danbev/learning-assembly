// clang -g -o inline inline.c
#include "inline.h"

static inline void doit(int k) {
  int i = k;
}

int main(int argc, char** argv) {
  int i = 8;
  doit(i);
}
