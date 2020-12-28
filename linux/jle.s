
.data
msg: .ascii "bajja\n"
msg_len = . - msg

done: .ascii "done...\n"
done_end: .set done_len, done_end - done

.text
.global _start

_start:
  push %rbp
  mov %rsp, %rbp

  xor %rcx, %rcx
  mov $1, %rdx
lp: 
  lea msg(,%rcx), %rsi
  inc %rcx
  push %rcx
  call print
  pop %rcx
  cmp $msg_len, %rcx
  jl lp

  lea done, %rsi
  mov $done_len, %rdx
  call print

  mov $60, %rax 
  xor %rdi, %rdi
  syscall

print:
  push %rbp
  mov %rsp, %rbp
  mov $1, %rax
  mov $1, %rdi
  syscall
  leave
  ret
