.data
something:
  .long 2

.text
.globl _start
_start:
  movl $something, %eax
  mov $60, %rax
  xor %rdi, %rdi
  syscall
