.section __DATA, __data
argc:
  .asciz "Value =  %d\n"
values:
  .int 10, 20, 30, 40, 50
.section __TEXT, __text
.globl _main

_main:
   subq $8, %rsp
   movabsq $0, %rcx
   leaq values(%rip), %rax
loop:
   movq (%rax, %rcx, 8), %rsi
   movq argc@GOTPCREL(%rip), %rdi
   callq _printf
   inc %rcx
   movq (%rax, %rcx, 8), %rsi
   movq argc@GOTPCREL(%rip), %rdi
   callq _printf
   #addq $8, %rsp
   #inc %rcx
   #cmpq $3, %rcx
   #jne loop
   movl $0x2000001, %eax # exit code
   movq $0, %rdi # return code
   syscall
