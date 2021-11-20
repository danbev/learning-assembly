.text

.global _start

_start:
  mov r0, #15
  bic r1, r0, #4
  bic r1, r0, #12
  b .
