.global _start

.text
_start:
  mov $1, %rax
  mov $2, %rbx
  cmp %rbx, %rax
  setne %cl

  xor %rax, %rax
  xor %rbx, %rbx
  xor %cl, %cl
  mov $1, %rbx
  cmp %rbx, %rax
  setnz %cl

  mov $60, %rax
  mov $0, %rdi
  syscall
