.text
.global _start

_start:
  mov r2, #4
  mov r3, #2
  subs r1, r3, r2
  bne negative
positive:
  mov r0, #1
  b end

negative:
  mov r0, #-1
  b end

end:

  b .
