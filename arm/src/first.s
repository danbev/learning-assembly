.data

msg:
    .ascii        "Bajja\n"
len = . - msg

.text

.globl _start
_start:
    /* syscall write(int fd, const void *buf, size_t count) */
    mov     x0, #1      /* fd */
    ldr     x1, =msg    /* buf */
    ldr     x2, =len    /* count */
    mov     w8, #64     /* write syscall #64 */
    svc     #0          

    /* syscall exit(int status) */
    mov     x0, #0      /* status */
    mov     w8, #93     /* exit syscall #93 */
    svc     #0          
