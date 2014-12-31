#as -g -arch x86_64 64bit.s -o 64bit.o
#ld -e _start -macosx_version_min 10.8 -lSystem -arch x86_64 64bit.o -o 64bit

.data  
msg:
 .ascii "Assembly x86_64!\n" 
len:
 .long . - msg  

.text  
.globl _start 

_start:
 movq $0x2000004, %rax   # write call (see SYSCALL_CONSTRUCT_UNIX). 
 movq $1, %rdi   # file descriptior (stdout). rdi is used for the first argument to functions in x86_64
 movq msg@GOTPCREL(%rip), %rsi # string to print. rsi is used for the second argument to functions in x86_64
 movq len(%rip), %rdx  # length of string. rdx is used for the third argument to functions in x86_64
 syscall    # call write

 movq $0x2000001, %rax  # exit call
 movq $0, %rdi   # return code
 syscall    # call exit
