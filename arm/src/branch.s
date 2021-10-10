.text
.global _start

_start:
  mov x0, #10
  mov x1, #0
loop:
  add x1, x1, #1
  cmp x0, x1
  b.NE loop

  mov x0, x1
  mov x8, #93
  svc #0
