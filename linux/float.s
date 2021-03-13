.global _start

.data
  radius: .float 3.14   # .float is 64 bits
  m: .float 2.1
  result: .float 0
  s: .short             # .short is 32 bits
  age: .word 46

.text
_start:
  nop
  mov %rsp, %rbp

  fld radius    # load onto the FPU stack
  fld m         # load onto the FPU stack
  fmulp         #
  fstp result   # store floating point value in result and pop the stack

  fild age      # load integer and convert to floating point, then push onto the stack

  mov $60, %rax
  mov $1, %rdi
  syscall
