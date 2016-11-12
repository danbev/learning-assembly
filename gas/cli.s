.section __DATA, __data
argc:
  .asciz "There are %d parameters\n"

.section __TEXT, __text
.globl _main

_main:
   pushq %rbp
   movq %rsp,%rbp
   movq +24(%rbp), %rsi
   movq argc@GOTPCREL(%rip), %rdi
   call _printf
   movl $0x2000001, %eax # exit code
   movq $0, %rdi # return code
   syscall
