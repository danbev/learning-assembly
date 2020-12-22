.text
.globl _start

_start:
  mov $0, %rcx
  test %rcx, %rcx
  je _zero_func
  movq $60, %rax
  movq $1, %rdi
  syscall

_zero_func:
  movq $60, %rax
  movq $2, %rdi
  syscall

