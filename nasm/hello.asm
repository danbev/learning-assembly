%define SYSCALL_WRITE 0x2000004
%define SYSCALL_EXIT  0x2000001

global start
start:
  mov rdi, 1
  mov rsi, str
  mov rdx, strlen
  mov rax, SYSCALL_WRITE
  syscall

  mov rax, SYSCALL_EXIT
  mov rdi, 0
  syscall

section .data
str:
  db `Hey, assembly!\n` 
strlen equ $ - str
