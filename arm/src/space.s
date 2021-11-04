
.text
.global _start

_start:
  ldr r0, =A
  mov r1, #2
  str r1, [r0]
  //mov r0, #1

stop:
  b   stop

.data
A: .space 4
