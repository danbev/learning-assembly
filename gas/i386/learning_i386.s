# Mach-O has segments that contain sections
# __TEXT is a segment and __text a section
.section __TEXT, __text
.globl _main

_main:
    pushl %ebp        # push the value of ebp onto the stack, to save 
    movl %esp, %ebp   # store the current stack pointer in ebp to we can use ebp
                      # with indirect addressing
    
    subl $0x4, %esp   # make room for a 32 bit value on the stack to avoid overwriting
                      # the return address on the stack
    pushl $msg        # push msg onto the stack (will increment esp but ebp will remain
    call _puts
    addl $0x8, %esp   # clean up the stack
    
    movl $1, %eax
    popl %ebp
    ret

.section __DATA, __data
msg:
    .ascii "Learning Assembler\0"
