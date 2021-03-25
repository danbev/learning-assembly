.data

v1: .quad 1              # 64-bit
v2: .double 1, 2         # 2 32-bit values
v3: .word 1, 2, 3, 4     # 4 16-bit values

.global _start

.text

_start:
  movq v1, %mm0
  movd v2, %mm1
  movq v3, %mm2
  paddw %mm2, %mm2

  mov $60, %rax
  mov $1, %rdi
  syscall
