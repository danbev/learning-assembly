.global _start

.text

_start:
  mov $2, %rax
  mov $2, %rcx
  sub %rax, %rcx

  mov $60, %rax
  mov $0, %rdi
  syscall
