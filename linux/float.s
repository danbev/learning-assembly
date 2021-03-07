.global _start

.data
  radius: .float 3.14
  m: .float 2.1
  result: .float 0

.text
_start:
  nop
  mov %rsp, %rbp

  fld radius # load onto the FPU stack
  fld m # load onto the FPU stack
  fmulp
  fstpl result # store floating point value in result

  mov $60, %rax
  mov $1, %rdi
  syscall
