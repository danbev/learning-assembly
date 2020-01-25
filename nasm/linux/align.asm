section .data
  dummy db 3
  nr dw 10

section .bss
section .text
  global main

main: 
  push rbp
  mov rbp, rsp
  mov ax, [nr]
  leave
  ret
