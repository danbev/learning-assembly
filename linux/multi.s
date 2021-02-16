
.text
.global _start

_start:
  mov $28, %rax
  mov $2, %rbx
  mul %rbx

  xor %rcx, %rcx

loop:
  xor %rdx, %rdx
  mov $10, %rbx
  div %rbx        /* divides what is in %rax */
  add $48, %rdx   /* add ascii 48 to the remainder which is in rdx */
  push %rdx       /* push to the right most digit onto the stack */
  inc %rcx        /* number of digits counter */
  cmp $0, %rax    /* continue as long as there the value in %rax is on 0*/
  jz next         /* jz wil jump if the zero flag is set, so if %rax is 0 */
  jmp loop        /* else continue loop */

next:
  cmp $0, %rcx    /* check that are numbers to print, %rsi is the counter */
  jz  exit        /* if there are not jump to exit */
  dec %rcx

  mov $1, %rax     /* syscall 1 write                  */
  mov $1, %rdi     /* fd                               */
  lea (%rsp), %rsi /* current number on stack to print */
  mov $1, %dx      /* number of characters to print    */
  push %rcx        /* save the value of rcx on the stack as it may be clobbered by the syscall */
  syscall
  pop %rcx         /* restore rcx */
  add $8, %rsp     /* move rsp backward */
  jmp next

exit:
  mov $1, %rax
  mov $1, %rdi
  push $10
  lea (%rsp), %rsi
  syscall
  
  mov $60, %rax
  mov $0, %rdi
  syscall
