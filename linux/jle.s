
.data
msg: .ascii "bajja\n"
len: .int . - msg

.text
.global _start

_start:
  push %rbp
  mov %rsp, %rbp

  xor %rcx, %rcx
  mov $1, %rdx
lp: 
  lea msg(,%rcx), %rsi
  inc %rcx
  push %rcx
  call print
  pop %rcx
  cmp len, %rcx
  jle lp
  
  mov $60, %rax 
  xor %rdi, %rdi
  syscall

print:
  push %rbp
  mov %rsp, %rbp
  mov $1, %rax
  mov $1, %rdi
  syscall
  leave
  ret
