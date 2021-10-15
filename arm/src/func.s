.text

.global _start

_start:
  mov x0, #1
  mov x1, #2
  bl func

  mov x8, #93
  svc #1

func:
  mov x0, #3
  ret
