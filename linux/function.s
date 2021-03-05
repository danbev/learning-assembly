.global _start

.type print_msg, @function

.data

msg: .ascii "something\n"
len: .int . - msg

.text
_start:
  call print_msg
  mov $60, %rax
  mov $1, %rdi
  syscall

print_msg:
  mov $1, %rax
  mov $1, %rdi
  lea msg, %rsi
  mov len, %edx
  syscall
  ret
