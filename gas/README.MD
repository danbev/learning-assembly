## GNU Assembler examples


### 64Bit.s
This is a example of using system calls in a x86_64 arch. There are a few interesting/different things that I ran into 
when trying to get this working. The first was the way a system call is specified. 

You can find the system calls [syscalls.master](inhttp://www.opensource.apple.com/source/xnu/xnu-1504.3.12/bsd/kern/syscalls.master):

    ...
    4    AUE_NULL    ALL { user_ssize_t write(int fd, user_addr_t cbuf, user_size_t nbyte); }

We can see that ```write``` has the value ```4```, but when we specify this in [64bit.s](./64bit.s) we use:

    movq $0x2000004, %rax

Why ```0x2000004``` instead of simply ```4```?  
The reason for this can be found in [syscall_sw.h]( http://www.opensource.apple.com/source/xnu/xnu-792.13.8/osfmk/mach/i386/syscall_sw.h).
This is not a public header so it will probably not be available on your system. 

In XNU, the POSIX system calls make up only of four system call classes (SYSCALL_CLASS): 

1. UNIX (1)
2. MACH (2)
3. MDEP (3)
4. DIAG (4) 

In 64-bit, all call types are positive, but the most significant byte contains the value of SYSCALL_CLASS from the preceding table.
The value is checked by shifting the system call number 

	SYSCALL_CLASS_SHIFT (=24) bits.
	2 << 24 = 2000000 hex


The next thing that I did not understand was this line:

    movq msg@GOTPCREL(%rip), %rsi # string to print. rsi is used for the second argument to functions in x86_64

GOTPCEL is short for Global Offset Table and Procedure Linkage Table (I think). From what I understand this has to do with relocations. So lets look
what relocation information can be found in the mach object file:

    $ otool -r 64bit.o
    64bit.o:
    Relocation information (__TEXT,__text) 2 entries
    address  pcrel length extern type    scattered symbolnum/value
    00000018 1     2      1      1       0         1
    00000011 1     2      1      3       0         0
    Relocation information (__DATA,__data) 2 entries
    address  pcrel length extern type    scattered symbolnum/value
    00000011 0     2      1      5       0         0
    00000011 0     2      1      0       0         1
    Relocation information (__DWARF,__debug_line) 3 entries
    address  pcrel length extern type    scattered symbolnum/value
    0000002b 0     3      0      0       0         1
    00000006 0     2      0      5       0         3
    00000006 0     2      0      0       0         3
    Relocation information (__DWARF,__debug_info) 4 entries
    address  pcrel length extern type    scattered symbolnum/value
    000000a4 0     3      0      0       0         1
    0000009c 0     3      0      0       0         1
    00000018 0     3      0      0       0         1
    00000010 0     3      0      0       0         1
    Relocation information (__DWARF,__debug_aranges) 1 entries
    address  pcrel length extern type    scattered symbolnum/value
    00000010 0     3      0      0       0         1

#### Assemble 64Bit.s

    as -g -arch x86_64 64bit.s -o 64bit.o

#### Link 64Bit.s

    ld -e _start -macosx_version_min 10.8 -lSystem -arch x86_64 64bit.o -o 64bit

### Mach Object file (mach-o)

    otool -h 64bit.o
    64bit.o:
    Mach header
           magic cputype cpusubtype  caps    filetype ncmds sizeofcmds      flags
     0xfeedfacf 16777223          3  0x00          1     3        656 0x00000000

The magic number can be found in ```/usr/include/mach-o/loader.h```:

    #define MH_MAGIC_64 0xfeedfacf /* the 64-bit mach magic number */
    
The ```cputype``` can be located in ```/usr/include/mach/machine.h```:

    



    

