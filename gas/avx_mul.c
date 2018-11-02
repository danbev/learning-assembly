#include <immintrin.h>
#include <stdio.h>

int main() {

  // set as big endian (r = revers of default little endian)
  __m256d evens = _mm256_setr_pd(1.0, 2.0, 3.0, 4.0);
  __m256d odds = _mm256_setr_pd(1.0, 2.0, 3.0, 4.0);

  __m256d result = _mm256_mul_pd(evens, odds);

  double* d = (double*)&result;
  printf("%f %f %f %f\n", d[0], d[1], d[2], d[3]);

  return 0;
}
