.text
.global _start

_start:
  mov $33, %al
  mov $2, %dl
  imul %dl

  push %rax

  mov $1, %rax
  mov $1, %rdi
  lea (%rsp), %rsi
  mov $1, %dx
  syscall         # Will print B which is the ascii character for 66

  mov $60, %rax
  mov $1, %rdi
  syscall
