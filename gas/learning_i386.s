.text
.globl _main

_main:
    nop
    push %ebp
    mov %esp, %ebp
    
    sub $0x4, %esp
    push $msg
    call _puts
    add $0x8, %esp
    
    #clr %eax
    mov $1, %eax
    pop %ebp
    ret

.data
msg:
    .ascii "Learning Assembler\0"
    len = . - msg
