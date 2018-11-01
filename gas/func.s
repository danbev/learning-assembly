.section __DATA, __data
.section __TEXT, __text
.globl _dot

_dot:
  pushq %rbp
  movq %rsp,%rbp

  addq $22, %rdi
  movq %rdi, %rax # return code
  popq %rbp
  retq
