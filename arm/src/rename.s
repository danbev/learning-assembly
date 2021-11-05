ZEROR .req r0
/* .equ does not work for registers which is the reason for .req */

.global _start

.text

_start:
  mov ZEROR, #4

stop:
  b stop


