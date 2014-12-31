## GNU Assembler examples


### 64Bit.s
This is a example of using system calls in a x86_64 arch. There are a few interesting/different things that I ran into 
when trying to get this working. The first was the way a system call is specified. 

You can find the system calls [syscalls.master](inhttp://www.opensource.apple.com/source/xnu/xnu-1504.3.12/bsd/kern/syscalls.master):

    ...
    4    AUE_NULL    ALL { user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte); }

We can see that ```write``` has the value ```4```, but when we specify this in [64bit.s](./64bit.s) we use:

    movq $0x2000004, %rax   # write call (see SYSCALL_CONSTRUCT_UNIX). 

Why ```0x2000004``` instead of simply ```4```?  
The reason for this can be found in [syscall_sw.h]( http://www.opensource.apple.com/source/xnu/xnu-792.13.8/osfmk/mach/i386/syscall_sw.h).
This is not a public header so it will probably not be available on your system. 

In XNU, the POSIX system calls make up only of four system call classes:
1. UNIX (1)
2. MACH (2)
3. MDEP (3)
4. DIAG (4)
In 64-bit, all call types are positive, but the most significant byte contains the value of SYSCALL_CLASS from the preceding table.
The value is checked by shifting the system call number SYSCALL_CLASS_SHIFT (=24) bits.
2 << 24 = 2000000 hex


#### Assemble

    as -g -arch x86_64 64bit.s -o 64bit.o

#### Link

    ld -e _start -macosx_version_min 10.8 -lSystem -arch x86_64 64bit.o -o 64bit

