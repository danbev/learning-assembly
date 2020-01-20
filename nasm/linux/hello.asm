section .data
  msg db "hello world",10,0
  ; note that 10 is the new line character in decimal
  len equ $-msg-1
  ; not that $ is the current address, we substract the address
  ; of msg and then take that value -1 to ignore the 0/null byte

section .bss 
section .text
  global main

main:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, len
  syscall

  mov rax, 60
  mov rdi, 0
  syscall
