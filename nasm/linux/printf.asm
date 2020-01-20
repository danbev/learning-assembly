extern printf

section .data
  msg db "hello world",0
  fmt db "Using printf to write: %s", 10, 0

section .bss 
section .text
  global main

main:
  push rbp
  mov rbp, rsp
  mov rdi, fmt
  mov rsi, msg
  mov rax, 0
  call printf

  mov rsp, rbp
  mov rax, 60
  mov rdi, 0
  syscall
