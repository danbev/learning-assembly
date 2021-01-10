#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <x86intrin.h>

int main(int argc, char** argv) {
  int cache_line_size = 64;
  size_t cache_size = 256 * cache_line_size;;
  printf("256 array/64 bytes: %d\n", cache_size);

  int array[cache_size];
  for (int i = 0; i < cache_size; i++) {
    array[i] = 1;
  }
  for (int i = 0; i < cache_size; i+=cache_line_size) {
    //printf("clflush array[%d]\n", i);
    _mm_clflush(&array[i]);
  }

  register uint64_t start, end;
  int dummy = 0;
  for (int i = 0; i < cache_size; i++) {
    start = __rdtscp(&dummy);
    array[i]++;
    end = __rdtscp(&dummy);
    unsigned long duration = end - start;
    printf("%u\n", duration);
  }
  return 0;
}
