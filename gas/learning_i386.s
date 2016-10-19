# Mach-O has segments that contain sections
# __TEXT is a segment and __text a section
.section __TEXT, __text
.globl _main

_main:
    push %ebp
    mov %esp, %ebp
    
    sub $0x4, %esp
    push $msg
    call _puts
    add $0x8, %esp
    
    mov $1, %eax
    pop %ebp
    ret

.data
msg:
    .ascii "Learning Assembler\0"
