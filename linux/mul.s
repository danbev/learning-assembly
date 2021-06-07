.text
.global _start

_start:
  mov $33, %rax
  mov $2, %rbx
  imul %rax, %rbx

  push %rbx

  mov $1, %rax
  mov $1, %rdi
  lea (%rsp), %rsi
  mov $1, %dx
  syscall         // will bring B which is the ascii character for 66

  mov $60, %rax
  mov $1, %rdi
  syscall
