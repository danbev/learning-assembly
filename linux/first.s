.data
something:
  .byte 2

.text
.globl _start
_start:
  movl $something, %eax
  call _exit

_exit: 
  mov $60, %rax
  xor %rdi, %rdi
  syscall
