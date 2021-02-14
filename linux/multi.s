
.text
.global _start

_start:
  mov $4, %ax
  mov $2, %bx
  mul %bx
  add $48, %rax /* add ascii '0' which is decimal 48 so  we can print it */
  push %rax

  mov $1, %rax
  mov $1, %rdi
  lea (%rsp), %rsi
  mov $1, %dx
  syscall

  mov $60, %rax
  mov $0, %rdi
  syscall
