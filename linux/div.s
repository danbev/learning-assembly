.text
.global _start

_start:
  mov $23, %rax
  mov $2, %rbx
  div %rbx

  add $48, %rax
  push %rax

  mov $1, %rax
  mov $1, %rdi
  lea (%rsp), %rsi
  mov $1, %dx
  syscall

  mov $60, %rax
  mov $1, %rdi
  syscall
