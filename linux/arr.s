.text
  .global _start
  .type _start, @function

_start:
  nop
  movb $4, 0(%rsp)
  movb $2, -8(%rsp)

  mov $60, %rax
  xor %rdi, %rdi
  syscall
