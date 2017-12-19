## GNU Assembler examples

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


### Pointers
When using parenthises around a register, for example (%eax) means to dereference the pointer in eax and use it.
To get the address of a label you can use $ before the label. If you are on a 64 bit machine you may have to load the
effective address instead (leaq label(%rip), %rdi) if direct addressing is not supported.

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

### Relocations
If you have multiple object files and want to link them together one options is to add the code sections together, then the 
data sections etc. But if you have a function at address 0 in both object files which one will get invoked? It would depend on 
which was linked first as the other would have it's address shifted.

* When you load/store data you need to know the location.
* When you branch/jump you need to be able to specify the location to branch/jump to.

Lets take a look at the following c program:

    extern int something;

    int function(void) {
      return something;
    }

Next, we can compile and then display the relocation section:

    $ clang -c rel.c
    $ otool -r rel.o
    RELOCATION RECORDS FOR [__text]:
    0000000000000007 X86_64_RELOC_GOT_LOAD _something@GOTPCREL

    RELOCATION RECORDS FOR [__compact_unwind]:
    0000000000000000 X86_64_RELOC_UNSIGNED __text

You can find information about [X86_64_RELOC_GOT_LOAD](https://opensource.apple.com/source/xnu/xnu-1699.22.73/EXTERNAL_HEADERS/mach-o/x86_64/reloc.h.auto.html).
During compilation _something is not known to the compiler so a relocation entry is left for the linker to resolve. The entry is specified as addredss `0000000000000007'

    $ objdump -disassemble rel.o

    rel.o:file format Mach-O 64-bit x86-64

    Disassembly of section __TEXT,__text:
    _function:
       0: 55                      pushq%rbp
       1: 48 89 e5                movq%rsp, %rbp
       4: 48 8b 05 00 00 00 00    movq(%rip), %rax
       b: 8b 00                   movl(%rax), %eax
       d: 5d                      popq%rbp
       e: c3                      retq

If we look at address 7:

       4: 48 8b 05 00 00 00 00    movq(%rip), %rax
                   /\

We can see that at address 7 there are four bytes that will be filled by the linker with the correct address.


GOTPCEL is short for Global Offset Table and Procedure Linkage Table (I think). From what I understand this has to do with relocations. So lets look what relocation information can be found in the mach object file:

    $ otool -r out/64bit.o
    $ otool -r out/cli.o
    RELOCATION RECORDS FOR [__text]:
    000000000000000f X86_64_RELOC_BRANCH _printf
    000000000000000a X86_64_RELOC_GOT_LOAD argc@GOTPCREL

    RELOCATION RECORDS FOR [__debug_info]:
    000000000000008b X86_64_RELOC_UNSIGNED __text
    0000000000000018 X86_64_RELOC_UNSIGNED __text
    0000000000000010 X86_64_RELOC_UNSIGNED __text

    RELOCATION RECORDS FOR [__debug_aranges]:
    0000000000000010 X86_64_RELOC_UNSIGNED __text

    RELOCATION RECORDS FOR [__debug_line]:
    0000000000000029 X86_64_RELOC_UNSIGNED __text

Relocation is the process of connecting symbolic referenses to symbolic definitions. For the _text segement we can find the following:

    000000000000000a X86_64_RELOC_GOT_LOAD argc@GOTPCREL

This maps to [cli.s](./cli.s):

    movq argc@GOTPCREL(%rip), %rdi

Recall that RIP is the instruction pointer
    
### Instruction Pointer Relative addressing (RIP)
RIP addressing is a mode where address references are provided as a 32-bit displacements from the current instruction pointer (RIP register value). 
One of the advantages of RIP is that is makes it easier to generate Position Independant Code, which is code that is not dependent upon where the 
code is loaded. This is important for shared objects as they don't know where they will be loaded. 
In x64, references to code and data are done using instruction pointer relative (RIP) addressing modes.

### Position Independant Code (PIC)
When the linker creates a shared library it does not know where in the process's address space it might be loaded. This causes a problem for code and data references which need to point to the correct memory locations.

My view of this is that when the linker takes multiple object files and merges the sections, like .text, .data etc, merge might not be a good
description but rather adds them sequentially to the resulting object file. If the source files refer to absolut
locations in it's .data section these might not be in the same place after linking into the resulting object file.
Solving this problem can be done using position independant code (PIC) or load-time relocation.

There is an offset between the text and data sections. The linker combines all the text and data sections from all the object files and therefore knows the sizes of these sections. So the linker can rewrite the instructions using offsets and the sizes of the sections.

But x86 requires absolute addressing does it not?  
You might come accross the following compilation error using as on Mac:

    32-bit absolute addressing is not supported in 64-bit mode

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
This process might take some time during loading which might be a performance hit depending on the type of program being written.
Since the text section needs to be modified during loading (needs to do the actual relocations) it is not possible to have it shared by multiple processes.

### Instruction Pointer Relative addressing (RIP)
References to code and data in x64 are done with instruction relative pointer addressing. So instructions can use references that are relative to the current instruction (or the next one) and don't require them to be absolute addresses. This works for offsets of up to 32bits but for programs that are larger than that this offset will not be enough. One could use absolute 64 bit addresses for everything but more instructions are required to perform simple operations and most programs will not require this.
The solution is to introduce code models to cater for all needs. The compiler should be able to take an option where the programmer can say that this object file will not be linked into a large program. And also that this compilation unit will be included in a huge library and that 64-bit addressing should be used.

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
    

### Redzone
Put simply, the red zone is an optimization. Code can assume that the 128 bytes below rsp will not be asynchronously clobbered 
by signals or interrupt handlers, and thus can use it for scratch data, without explicitly moving the stack pointer. The last 
sentence is where the optimization lays - decrementing rspand restoring it are two instructions that can be saved when using 
the red zone for data.

However, keep in mind that the red zone will be clobbered by function calls, so it's usually most useful in leaf functions 
(functions that call no other functions)

Preserving the base pointer
The base pointer rbp (and its predecessor ebp on x86), being a stable "anchor" to the beginning of the stack frame throughout
the execution of a function, is very convenient for manual assembly coding and for debugging [5]. However, some time ago it 
was noticed that compiler-generated code doesn't really need it (the compiler can easily keep track of offsets from rsp), 
and the DWARF debugging format provides means (CFI) to access stack frames without the base pointer.

This is why some compilers started omitting the base pointer for aggressive optimizations, thus shortening the function prologue 
and epilogue, and providing an additional register for general-purpose use (which, recall, is quite useful on x86 with its 
limited set of GPRs).

gcc keeps the base pointer by default on x86, but allows the optimization with the -fomit-frame-pointer compilation flag. 
How recommended it is to use this flag is a debated issue - you may do some googling if this interests you.

Anyhow, one other "novelty" the AMD64 ABI introduced is making the base pointer explicitly optional, stating:

The conventional use of %rbp as a frame pointer for the stack frame may be avoided by using %rsp (the stack pointer) to index into 
the stack frame. This technique saves two instructions in the prologue and epilogue and makes one additional general-purpose 
register (%rbp) available.
gcc adheres to this recommendation and by default omits the frame pointer on x64, when compiling with optimizations. It gives an 
option to preserve it by providing the -fno-omit-frame-pointer flag. For clarity's sake, the stack frames showed above were 
produced without omitting the frame pointer.


### Setting register to zero
My first thought would be using a mov instruction, like `movq $0, rax' for example.

You might come a cross something like the following:

    xorl  %eax, %eax

Which simply a way of setting the register to zero. The xorl instruction uses fewer bytes than the mov. I found suggestions that it 
migth be more performat that using mov $0, %eax

    100000f72:48 c7 c0 00 00 00 00 movq $0, %rax

    100000f79:48 31 c0             xorq %rax, %rax

Notice that the byte code for xorg are smaller than movq.
Reducing instruction sizes will reduce instruction-cache misses, and therefore improve performance.

### System calls
You can use dtruss to see what system call are being done:

    $ sudo dtruss `pwd`/malloc


