#as -g -arch x86_64 64bit.s -o 64bit.o
#ld -e _start -macosx_version_min 10.8 -lSystem -arch x86_64 64bit.o -o 64bit

.data  
msg:
  .ascii "Assembly x86_64!\n" 
len:
  .long . - msg  

.text  
.globl _main 

_main:
  # write call (SYSCALL_CONSTRUCT_UNIX in /usr/include/sys/syscall.h).
  movq $0x2000004, %rax   
  # file descriptior (stdout). rdi is used for the first argument to functions
  movq $1, %rdi   
  # string to print. rsi is used for the second argument to functions in x86_64
  movq msg@GOTPCREL(%rip), %rsi 
  # length of string. rdx is used for the third argument to functions in x86_64
  movq len(%rip), %rdx  
  # call write
  syscall    

  # exit call
  movq $0x2000001, %rax  
  # return code
  movq $0, %rdi   
  # call exit
  syscall    
