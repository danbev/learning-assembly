.section __DATA, __data
res:
  .asciz "Zero \n"
.section __TEXT, __text
.globl _main

_main:
  pushq %rbp
  movq %rsp,%rbp

  movq $10, %rax
  movq $10, %rbx
  subq %rax, %rbx
  jz zero
  jmp end

zero:
  movq res@GOTPCREL(%rip), %rdi
  callq _printf

end: 
  movl $0x2000001, %eax # exit code
  movq $0, %rdi # return code
  syscall
  movq %rsp, %rbp
  popq %rbp
  ret
