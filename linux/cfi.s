.data
msg: .ascii "cfi example\n"
.set len, . - msg

.text
  .globl _start
  .type	_start, @function

_start:
  .cfi_startproc
  push %rbp 
  /* Document that Common Frame Address will be stored on the stack */
  .cfi_def_cfa_offset 16
  /* Document that the value of register 6 (rbp) is saved on the stack */
  .cfi_offset 6, -16
  mov %rbp, %rsp
  /* Document that rbp will be used as the CFA from this point onwards */
  .cfi_def_cfa_register 6
  mov $1, %rax   /* syscall number */
  mov $1, %rdi   /* file descriptor (stdout) */
  lea msg, %rsi  /* load the address of msg into rsi */
  mov $len, %rdx /* length to write */
  syscall

  mov $60, %rax
  xor %rdi, %rdi
  syscall
  pop %rbp
  /* Document that CFA is now rsp and at offset 8 */
  .cfi_def_cfa 7, 8
  .cfi_endproc
