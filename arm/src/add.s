.data

.text

.globl _start
_start:
  mov x1, #2
  mov x3, #3
  add x4, x1, x3

  /* syscall exit(int status) */
  mov     x0, x4      /* status */
  mov     w8, #93     /* exit syscall #93 */
  svc     #0          
