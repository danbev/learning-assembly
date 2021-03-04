
.global _start

.text
_start:
  mov $10, %rax
  mov $10, %rcx
  mov $3, %rsi
  cmovae %rsi, %rdi

  mov $60, %rax
  mov $1, %rdi
  syscall
