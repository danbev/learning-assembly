ZEROR .req r0

.global _start

.text

_start:
  mov ZEROR, #4

stop:
  b stop


