#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <x86intrin.h>

int main(int argc, char** argv) {
  int cache_line_size = 64;
  size_t cache_size = 256 * cache_line_size;;
  printf("256 array/64 bytes: %d\n", cache_size);

  register uint64_t start, end;
  int core_id = 0;

  int array[cache_size];
  for (int i = 0; i < cache_size; i++) {
    start = __rdtscp(&core_id);
    array[i] = 1;
    end = __rdtscp(&core_id);
    unsigned long duration = end - start;
    printf("Duration of set operation: %u core_id: %x\n", duration, core_id);
  }
  for (int i = 0; i < cache_size; i+=cache_line_size) {
    //printf("clflush array[%d]\n", i);
    _mm_clflush(&array[i]);
  }

  for (int i = 0; i < cache_size; i++) {
    start = __rdtscp(&core_id);
    array[i]++;
    end = __rdtscp(&core_id);
    unsigned long duration = end - start;
    //printf("Duration of increment operation: %u core_id: %x\n", duration, core_id);
  }
  return 0;
}
