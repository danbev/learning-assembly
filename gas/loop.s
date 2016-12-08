.section __DATA, __data
val:
  .asciz "Value =  %d\n"
values:
  .int 10, 20, 30, 40, 50
.section __TEXT, __text
.globl _main

_main:
  subq $8, %rsp
  movabsq $0, %r12
  leaq values(%rip), %r13
loop:
  movq (%r13, %r12, 4), %rsi
  movq val@GOTPCREL(%rip), %rdi
  callq _printf
  incq %r12
  cmpq $5, %r12
  jne loop
  movl $0x2000001, %eax # exit code
  movq $0, %rdi # return code
  syscall
