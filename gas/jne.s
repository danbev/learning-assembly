.section __DATA, __data
res:
  .asciz "Equal\n"
.section __TEXT, __text
.globl _main

_main:
  pushq %rbp
  movq %rsp,%rbp

  # move the value of rdi (argc) into rsi which is used pass 2nd argument to functions  
  movq $10, %rax
  movq $10, %rbx
  cmpq %rax, %rbx
  jne end
  movq res@GOTPCREL(%rip), %rdi
  callq _printf

end:
  movl $0x2000001, %eax # exit code
  movq $0, %rdi # return code
  syscall
