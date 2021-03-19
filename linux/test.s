.data
zero: .ascii "zero\n"
zero_len: .int . - zero

.global _start
.text

_start:
  nop
  mov $1, %rax
  test $2, %rax     # test will perform 0010 & 0001 = 0000 
  jz _zero
  jmp _exit

_zero:
  mov $1, %rax
  mov $1, %rdi
  lea zero, %rsi
  mov zero_len, %dx
  syscall

_exit:
  mov $60, %rax
  mov $1, %rdi
  syscall


