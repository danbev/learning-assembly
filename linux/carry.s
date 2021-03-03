.global _start

.text

_start:
  mov $10, %rax
  mov $9, %rsi
  // source, destination
  // sub destination source 11 - 10 = 1
  // (lldb) register read rflags -f b
  //rflags = 0b0000000000000000000000000000000000000000000000000000001010010111
  cmp %rax, %rsi
  sub %rax, %rsi

  // set the carry flag
  stc
  // clear the carry flag
  clc
  nop

  mov $60, %rax
  mov $0, %rdi
  syscall

