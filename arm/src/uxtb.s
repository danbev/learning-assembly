.text

.global _start

_start:
  ldr r0, =#0xFFFFFF65
  uxtb r1, r0
  uxth r1, r0
  b .

