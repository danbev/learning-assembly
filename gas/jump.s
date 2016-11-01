.section __TEXT, __text
.globl _main

_main:
   jmp overhere
   mov $0x2000001, %eax
   mov $0, %rdi
   syscall
overhere:
   mov $0x2000001, %eax
   mov $2, %rdi
   syscall
