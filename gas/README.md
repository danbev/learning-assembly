## GNU Assembler examples
Somethings...
Somethings...2

### Building

    make

All binaries will be placed in the `out` directory.


### arch type
When using `as` you can specify the architecture type using `-arch`

    man 3 arch

If no target architecture is specified, it defaults to the architecture of the host it is running on.



### Segments
In Mach-O sections are segments that contains sections, for example:

    .section __TEXT, __text

`__TEXT` is the segment and `__text` the section.


### System calls
This is done using the `syscall` instruction.

/usr/include/sys/syscall.h

### learning_i386
Just a hello world example that prints something to standard out.

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

### Instruction Pointer Relative addressing (RIP)
RIP addressing is a mode where an address references are provided as a 32-bit displacements from the current instruction pointer. 
One of the advantages os RIP is that is makes it easier to generate PIC, which is code that is not dependent upon where the code
is loaded. This is important for shared objects as they don't know where they will be loaded. 
In x64 references to code and data are done using instruction pointer relative (RIP) addressing modes.

### Position Independant Code (PIC)
When the linker creates a shared library it does not know where in the process's address space it might be loaded. This causes a problem for code and data references which need to point to the correct memory locations.

My view of this is that when the linker takes multiple object files and merges the sections, like .text, .data etc, merge might not be a good
description but rather adds them sequentially to the resulting object file. If the source files refer to absolut
locations in it's .data section these might not be in the same place after linking ito the resulting object file.
Solving this problem can be done using position independant code (PIC) or load-time relocation.

There is an offset between the text and data sections. The linker combines all the text and data sections from all the object files and therefore knows the sizes of these sections. So the linker can rewrite the instructions using offsets and the sizes of the sections.

But x86 requires absolute addressing does it not?  
If we need a relative address (relative to the current instruction pointer which there is no operation for) a way to get this is to use the `CALL some_label` like this:

      call some_label
    some_label: 
      pop eax

`call` causes the address of the next instruction to be saved on the stack and then it will jump to some_label. `pop eax` pops the address into eax which is now the value of the instruction pointer.

PIC are implemented using Global Offset Table (GOT) which is a table of addresses in the .data section. When an instruction referres to a variable it does not use an absolute address (would require relocation) but instead referrs to an entry in the GOT which is located at a well known place in the data section. The entry in the GOT referrs to an absolut address.
So this is a sort of relocation but in the data section instead of in the code section which is what was done for load-time relocation. But doing this in the data section, which is not shared and is writable does not cause any issues.
Also relocations in the code section have to be done per variable reference and not per variable as is the case when using a GOT.

So that covers variables but for function calls a Procedure Linkage Table (PLT) is used. This is part of the text section. Instead of calling a function directly a call is made to an entry in the PLT which performs the actual call. This is sometimes called `trampoline` which I've seen on occasions when inspecting/dumping in lldb but did not know what it meant. This allows for lazy resolution of functions calls.Also every PLT entry as an entry in the GOT.


Only position independent code is supposed to be included into shared objects (SO) as they should have an ability to dynamically change their 
location in RAM.

### Load-time relocation
This process might take some during loading which might be an performance hit depending on the type of program being written.
Since the text section needs to be modified during loading (needs to do the actual relocations) it is not possible to have it shared by multiple processes.

### Instruction Pointer Relative addressing (RIP)
References to code and data in x64 are done with instruction relative pointer addressing. So instructions can use references that are relative to the current instruction (or the next one) and don't require them to be absolute addresses. This works for offsets of up to 32bits but for programs that are larger than that this offset will not be enough. One could use absolute 64 bit addresses for everything but more instructions are required to perform simple operations and most programs will not require this.
The solution is to introduce code models to cater for all needs. The compiler should be able to take an option where the programmer can say that this object file will not be lined into a large program. And also that this compilation unit will be included in a huge library and that 64-bit addressing should be used.

In (64-bit mode), the encoding for the old 32-bit immediate offset addressing mode, is now a 32-bit offset 
from the current RIP, not from 0x00000000 like before. 
You only need to know how far away it is from the currently executing instruction (technically the next instruction)


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

    


### otool
Dump sections:

    $ otool -s __TEXT __text jump.o
    $ otool -s __DATA __data jump.o
    

