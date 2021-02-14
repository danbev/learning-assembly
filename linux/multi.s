
.text
.global _start

_start:
  mov $8, %ax
  mov $4, %bx
  mul %bx

  mov $60, %rax
  mov $0, %rdi
  syscall
