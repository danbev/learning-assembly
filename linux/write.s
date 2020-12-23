.data
msg:
   .ascii "bajja\n"
  len = . - msg

.text
  .global _start

_start:
  /*
     long syscall(long number, ...);
     ssize_t write(int fd, const void* buf, size_t nbytes)
  */
  mov $1, %rax   /* syscall number */
  mov $1, %rdi   /* file descriptor (stdout) */
  lea msg, %rsi  /* load the address of msg into rsi */
  mov $len, %rdx /* lenght to write */
  syscall

  mov $60, %rax
  xor %rdi, %rdi
  syscall
