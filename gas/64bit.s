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
 # You can find the system calls inhttp://www.opensource.apple.com/source/xnu/xnu-1504.3.12/bsd/kern/syscalls.master:
 # ...
 # 4    AUE_NULL    ALL { user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte); } 
 # But why 0x2000004 instead of simply 4? 
 # The reason for this can be found in http://www.opensource.apple.com/source/xnu/xnu-792.13.8/osfmk/mach/i386/syscall_sw.h, which
 # is not a public header so it will probably not be available on your system. In XNU, the POSIX system calls make up only of four
 # system call classes:
 # UNIX (1)
 # MACH (2)
 # MDEP (3)
 # DIAG (4)
 # In 64-bit, all call types are positive, but the most significant byte contains the value of SYSCALL_CLASS from the preceding table. 
 # The value is checked by shifting the system call number SYSCALL_CLASS_SHIFT (=24) bits.
 # 2 << 24 = 2000000 hex

 movq $1, %rdi   # file descriptior (stdout). rdi is used for the first argument to functions in x86_64
 movq msg@GOTPCREL(%rip), %rsi # string to print. rsi is used for the second argument to functions in x86_64
 movq len(%rip), %rdx  # length of string. rdx is used for the third argument to functions in x86_64
 syscall    # call write

 movq $0x2000001, %rax  # exit call
 movq $0, %rdi   # return code
 syscall    # call exit
