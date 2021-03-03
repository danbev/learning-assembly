.global _start

.text
_start:
  // set the direction flag
  std
  // clear the direction flag
  cld

  nop

  mov $60, %rax
  mov $0, %rdi
  syscall
