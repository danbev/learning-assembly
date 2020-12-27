
.data
msg: .ascii "bajja\n"
len: .int . - msg


.text
.global _start

_start:
  push %rbp
  mov %rsp, %rbp

  mov $0, %rcx
lp: 
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
  lea msg, %rsi
  mov len, %rdx
  syscall
  leave
  ret
