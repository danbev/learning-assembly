.text

.global _start

_start:
  mov x0, #3
  str x0, [SP, #-16]!
  ldr x0, [SP], #16

  mov x8, #93
  svc #0
