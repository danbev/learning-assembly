.text
  .global _start
  .type _start, @function

_start:
  nop
  sub  $1, %rsp
  movb $1, 0(%rsp)
  movb $2, -1(%rsp)
  movb $3, -2(%rsp)

  mov $60, %rax
  xor %rdi, %rdi
  syscall
