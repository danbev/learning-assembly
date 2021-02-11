.data
msg: .ascii "something something\n"
len: .int . - msg

.text
  .globl _start
  .type	_start, @function

_start:
  /*
     long syscall(long number, ...);
     ssize_t write(int fd, const void* buf, size_t nbytes)
  */
  mov $1, %rax   /* syscall number */
  mov $1, %rdi   /* file descriptor (stdout) */
  lea msg, %rsi  /* load the address of msg into rsi */
  mov len, %rdx /* length to write */
  syscall

  mov $60, %rax
  xor %rdi, %rdi
  syscall
