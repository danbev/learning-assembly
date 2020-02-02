section .data
section .bss
section .text
  global main:

main:
  push rbp
  mov rbp, rsp
  mov eax, 4
  doit: 
    dec eax
    jnz doit

  mov rax, 60
  mov rdi, 0
  syscall
