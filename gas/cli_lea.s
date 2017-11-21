.section __DATA, __data
msg:
  .asciz "There are %d parameters\n"

.section __TEXT, __text
.globl _main

_main:
  pushq %rbp
  movq %rsp,%rbp

  # move the value of rdi (argc) into rsi which is used pass 2nd argument to functions
  movq %rdi, %rsi
  # lea loads a pointer to a msg, mov would loads the actual value
  leaq msg(%rip), %rdi
  callq _printf

  movl $0x2000001, %eax # exit code
  movq $0, %rdi # return code
  syscall
