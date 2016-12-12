## Assembler
The project only contains small programs to help me learn assembler.

[gas](./gas) Contains examples using the GNU Assembler.  
[nasm](./nasm) Contains examples using the Netwide Assembler.  
[c](./c) C programs used for viewing the generated assembler code.  

### Registers
rax     caller saved.
rbx     caller saved.

rdi     callee saved. Used to pass 1st argument to functions
rsi     caller saved. Used to pass 2nd argument to functions
rdx     caller saved. Used to pass 3rd argument to functions
rcx     caller saved. Used to pass 4th argument to functions
r8      caller saved. Used to pass 5th argument to functions
r9      caller saved. Used to pass 6th argument to functions

rbp     caller saved. The stack base pointer
rsp     caller saved. The stack pointer

r10     caller saved
r11     caller saved 
r12     callee saved 
r13     callee saved
r14     callee saved 
r15     callee saved

#### Caller saved
These registers might be changed when making function calls and it is the callers responsibility to save them.

#### Callee saved
These registers are preserved/saved accross function calls.


### The Stack
The stack consists of memory locations reserved at the end of the memory area allocated to the program. 
The ESP register is used to point to the top of the stack in memory.
When PUSH is used it places data on the bottom of this memory area and decreases the ESP (stack pointer).

When POP is used it moves data to a register or a memory location and increases the ESP.

When a c-style function call is made it places the required arguments on the stack and the call
instruction places the return address onto the stack aswell.

        param2           8(%esp)
        param1           4(%esp)
        return address <- (%esp)

So ESP points to the top of the stack where the return address is. If we used the POP instruction to get the
parameters as the return address might be lost in the process. This can be avoided using indirect addressing, 
as in using 4(%esp) to access the parameters and avoid ESP to be incremented. But what if the function itself
needs to push data onto the stack, this would also change the value of ESP and it would throw off the indirect
addressing. Instead what is common practice is to store the current value of ESP (which is pointing to the 
return address) in EBP. Then use indirect addressing with EBP which will no change if the PUSH/POP instructions
are used. The calling function might also be using the EBP for the same reason so we first PUSH that value
onto the stack, decreasing the ESP. So the value of EBP is first pushed onto the stack and then we store
the current ESP value in EBP to enable indirect addressing.

          param2            12(%esp)
          param1            8(%esp)
          return address <- 4(%esp)
    esp ->old EBP        <-  (%esp)


    _main:
        pushl %ebp
        mov %esp, %ebp
        ....
        movl %ebp, %esp
        popl %ebp
        ret

Resetting the ESP register value ensures that any data placed on the stack within the function but not 
cleaned off will be discarded when execution returns to the main program (otherwise, the RET instruction could return to the wrong memory location).

Now, since we are using EBP we can place additional data on the stack without affecting how input parameters values are accessed. We can used EBP with indirect addressing to create local variables:

          param2            12(%esp)
          param1            8(%esp)
          return address    4(%esp)
    esp ->old EBP           (%esp)
          local var1       -4(%esp)
          local var2       -8(%esp)
          local var3       -12(%esp)

But what would happen if the function now uses the PUSH instruction to push data onto the stack?  
Well, it would overrwrite one or more local variables since ESP was not affected by the usage of EBP.
We need some way of reserving space for these local variables so that ESP points to -12(%esp) in our
case.

    _main:
        pushl %ebp
        mov %esp, %ebp
        subl $12, %esp            ; reserv 8 bytes to local variables.
   

Also, when the function returns the parameters are still on the stack which might not be expected
but the calling function. What you should do it reset the stack to the state before the call, when
there were now parameters on the stack. You can do this by adding 4,8,12 (what ever the size and number
of parameters are).

### Inspecting the stack
When you start a program in `lldb` you can take a look at the stack pointer memory location using:

    $ lldb ./out/cli 10 20
    (lldb) breakpoint set  --file cli.s --line 9
    (lldb) run
    (lldb) register read rsp
     rsp = 0x00007fff5fbfeb98

    (lldb) memory read --size 4 --format x 0x00007fff5fbfeb98
0x7fff5fbfeb98: 0x850125ad 0x00007fff 0x850125ad 0x00007fff
0x7fff5fbfeba8: 0x00000000 0x00000000 0x00000002 0x00000000

What I'm trying to figure out is where `argc` might be. We can see that `0x7fff5fbfeba8` has `2` which matches our two parameters (the program name and the argument).
What I was missing was that when using a C runtime argc is passed in rdi and not on the stack. I was looking for the value on the stack which.

### Compare while(flat) to while(flag == true)
(while flag == true) :

    while`main:
    0x100000f70 <+0>:  pushq  %rbp
    0x100000f71 <+1>:  movq   %rsp, %rbp
    0x100000f74 <+4>:  movl   $0x0, -0x4(%rbp) ## padding?
    0x100000f7b <+11>: movb   $0x1, -0x5(%rbp) ## flag = true
    0x100000f7f <+15>: movl   $0x5, -0xc(%rbp)
    0x100000f86 <+22>: cmpl   $0x5, -0xc(%rbp)
    0x100000f8a <+26>: jne    0x100000f94               ; <+36> at while.cc:10
    0x100000f90 <+32>: movb   $0x0, -0x5(%rbp)
    0x100000f94 <+36>: movl   -0xc(%rbp), %eax ## move a into eax
    0x100000f97 <+39>: addl   $0x1, %eax ## increment a
    0x100000f9a <+42>: movl   %eax, -0xc(%rbp) ## move incremented value back into a

    0x100000f9d <+45>: movb   -0x5(%rbp), %al ## move flat into al
    0x100000fa0 <+48>: andb   $0x1, %al ## AND 1 and flag
    0x100000fa2 <+50>: movzbl %al, %ecx ## conditionally move al into ecx if zero
    0x100000fa5 <+53>: cmpl   $0x1, %ecx ## flat == true
    0x100000fa8 <+56>: je     0x100000f86               ; <+22> at while.cc:7

    0x100000fae <+62>: xorl   %eax, %eax
    0x100000fb0 <+64>: popq   %rbp
    0x100000fb1 <+65>: retq

Compared to using while(flag):

    while`main:
    0x100000f70 <+0>:  pushq  %rbp
    0x100000f71 <+1>:  movq   %rsp, %rbp
    0x100000f74 <+4>:  movl   $0x0, -0x4(%rbp) ## padding?
    0x100000f7b <+11>: movb   $0x1, -0x5(%rbp) ## flag = true
    0x100000f7f <+15>: movl   $0x5, -0xc(%rbp) ## a = 5
    0x100000f86 <+22>: cmpl   $0x5, -0xc(%rbp) ## a == 5
    0x100000f8a <+26>: jne    0x100000f94               ; <+36> at while.cc:10
    0x100000f90 <+32>: movb   $0x0, -0x5(%rbp) ## flag = false
    0x100000f94 <+36>: movl   -0xc(%rbp), %eax ## move a into eax
    0x100000f97 <+39>: addl   $0x1, %eax ## increment a
    0x100000f9a <+42>: movl   %eax, -0xc(%rbp) ## move incremented value back into a

    0x100000f9d <+45>: testb  $0x1, -0x5(%rbp) ## AND 1 and flag
    0x100000fa1 <+49>: jne    0x100000f86               ; <+22> at while.cc:7 ## branch if not equal

    0x100000fa7 <+55>: xorl   %eax, %eax
    0x100000fa9 <+57>: popq   %rbp
    0x100000faa <+58>: retq

### Inspecting images
To list the current executable and its dependant images:

    $ target modules list
    or
    $ image list

You can dump the object file using:

    (lldb) target modules dump objfile /Users/danielbevenius/work/assembler/gas/out/cli

## Linking and Loading
Using `chmod +x` any file can be set to be an executable, but this only tells the kernel to
read the file into memory and to look for a header to determine the executable format. This header
is often referred to as `magic` which is a know digit identifying a certain type of executable format.

Magic's:
\x7FELF      Executable and Library Format. Native in Linux and UNIX though not supported by OS X
#!           Script. The kernel looks for the string following #! and executes it as a command passing
             the rest of the file to the process through stdin
0xcafebabe   Multi-arch binaries for OS X only
0xfeedface   OS X native binary format 32 bit
0xfeedfacf   OS X native binary format 64 bit

### Mach-Object Binaries
Mach-Object (Mach-O) is a legacy of its NeXTSTEP origins. The header can be found in /usr/include/mach-o/loader.h

    struct mach_header {
        uint32_t        magic;          /* mach magic number identifier */
        cpu_type_t      cputype;        /* cpu specifier */
        cpu_subtype_t   cpusubtype;     /* machine specifier */
        uint32_t        filetype;       /* type of file */
        uint32_t        ncmds;          /* number of load commands */
        uint32_t        sizeofcmds;     /* the size of all the load commands */
        uint32_t        flags;          /* flags */
    };

    struct mach_header_64 {
        uint32_t        magic;          /* mach magic number identifier */
        cpu_type_t      cputype;        /* cpu specifier */
        cpu_subtype_t   cpusubtype;     /* machine specifier */
        uint32_t        filetype;       /* type of file */
        uint32_t        ncmds;          /* number of load commands */
        uint32_t        sizeofcmds;     /* the size of all the load commands */
        uint32_t        flags;          /* flags */
        uint32_t        reserved;       /* reserved */
   };

The two are in fact mostly identical besides the `reserved` field which is unused in mach_header_64.

You can find the filetypes in the same header:
    #define MH_OBJECT       0x1             /* relocatable object file */
    #define MH_EXECUTE      0x2             /* demand paged executable file */
    #define MH_FVMLIB       0x3             /* fixed VM shared library file */
    #define MH_CORE         0x4             /* core file */
    #define MH_PRELOAD      0x5             /* preloaded executable file */
    #define MH_DYLIB        0x6             /* dynamically bound shared library */
    #define MH_DYLINKER     0x7             /* dynamic link editor */
    #define MH_BUNDLE       0x8             /* dynamically bound bundle file */
    #define MH_DYLIB_STUB   0x9             /* shared library stub for static */
                                        /*  linking only, no section contents */
    #define MH_DSYM         0xa             /* companion file with only debug */
                                        /*  sections */

I think MH simply stands for Mach Header.

You can inspect the header of a file using:

    $ otool -hV out/loop
    Mach header
      magic        cputype  cpusubtype  caps    filetype ncmds sizeofcmds   flags
      MH_MAGIC_64  X86_64   ALL         LIB64   EXECUTE     15       1200   NOUNDEFS DYLDLINK TWOLEVEL PIE

Load commands:


    $ otool -l out/loop


The kernel is responsible for allocating virtual memory (LC_SEGMENT_64), creating the main thread, and code signing and encryption. 

    Load command 1
      cmd LC_SEGMENT_64
      cmdsize 392
      segname __TEXT
      vmaddr 0x0000000100000000
      vmsize 0x0000000000001000
      fileoff 0
      filesize 4096
      maxprot 0x00000007
      initprot 0x00000005
      nsects 4
      flags 0x0

So this will load filesize 4096 from fileoff 0.

Sections:
__text                  main prog code
__stubs, __stub_helper  subs used in dynamic linking


LC_MAIN
Replaces LC_UNIXTHREAD from Montain Lion onward and is responsible for starting the binaries
main thread. For example, using `out/loop` once again:

    Load command 11
        cmd   LC_MAIN
    cmdsize   24
    entryoff  3929
    stacksize 0

For dynamically linked executables the loading of libraries and the resolving of symbols
is done in user mode by the LC_LOAD_DYLINKER command. 

OS X uses .dylib wheras Linux uses .so for dynamic libraries.
DYLD uses segments and in them sections.
The dynamic linker is started by the kernel following an LC_DYLINKER load command:
 
   $ otool -l out/loop
   ...
   Load command 7
          cmd LC_LOAD_DYLINKER
      cmdsize 32
         name /usr/lib/dyld (offset 12)

The dynamic linker is started by the kernel by following the LC_LOAD_DYLINKER load command.
The default being dyld (dynamik link editor) and this is a user mode process.
http://www.opensource.apple.com/source/dyld.

    $ otool -tV out/loop
    out/loop:
    (__TEXT,__text) section
    _main:
    0000000100000f59    subq    $0x8, %rsp
    0000000100000f5d    movabsq    $0x0, %r12
    0000000100000f67    leaq    values(%rip), %r13
    0000000100000f6e    movq    (%r13,%r12,4), %rsi
    0000000100000f73    leaq    val(%rip), %rdi
    0000000100000f7a    callq    0x100000f96 ## symbol stub for: _printf
    0000000100000f7f    incq    %r12
    0000000100000f82    cmpq    $0x5, %r12
    0000000100000f86    jne    0x100000f6e
    0000000100000f88    movl    $0x2000001, %eax
    0000000100000f8d    movq    $0x0, %rdi
    0000000100000f94    syscall 

Now, notice the `callq` operation which is our call to `_printf`. The comment says that this is a symbol stub, so what are these?  
This is an external undefined symbol and the code is generated with a call to the symbol stub section.

    $ dyldinfo -lazy_bind out/loop
    lazy binding information (from lazy_bind part of dyld info):
    segment section          address    index  dylib            symbol
    __DATA  __la_symbol_ptr  0x100001010 0x0000 libSystem        _printf

So lets take a look at the sections again and look at the __stubs section:

    $ otool -l out/loop
    Section
      sectname __stubs
       segname __TEXT
          addr 0x0000000100000f96
          size 0x0000000000000006
        offset 3990
         align 2^1 (2)
        reloff 0
        nreloc 0
         flags 0x80000408
     reserved1 0 (index into indirect symbol table)
     reserved2 6 (size of stubs)

And recall that the call to the stub looked like this:
    0000000100000f7a    callq    0x100000f96 ## symbol stub for: _printf

We can see that `addr` matched the address of the `callq` operation.

    $ lldb out/loop
    (lldb) breakpoint set --name main
Now, we want to follow the code when we callq (the first time that is)
dyld_stub_binder is called the first time and does the symbol binding


    ->  0x100000f96 <+0>: jmpq   *0x74(%rip)               ; (void *)0x0000000100000fac
        0x100000f9c:      leaq   0x65(%rip), %r11          ; (void *)0x0000000000000000
        0x100000fa3:      pushq  %r11
        0x100000fa5:      jmpq   *0x55(%rip)               ; (void *)0x00007fff8eca4148: dyld_stub_binder

So we will be in libdyld.dylib`dyld_stub_binder

There is a cache for dynamic libraries that can be found in:
/private/var/db/dyld/


Print the symbols of an object file:

    $ nm -m out/loop
    0000000100000000 (__TEXT,__text) [referenced dynamically] external __mh_execute_header
    0000000100000f59 (__TEXT,__text) external _main
                     (undefined) external _printf (from libSystem)
                     (undefined) external dyld_stub_binder (from libSystem)
    0000000100001018 (__DATA,__data) non-external val
    0000000100001025 (__DATA,__data) non-external values




Make the linker trace SEGMENTS:
    $ export DYLD_PRINT_SEGMENTS=1
For more environment variables see `man ldld`.


## Signals
/usr/include/sys/signal.h

## Show info about a raw address

    (lldb) image lookup --address 0x100000f78
      Address: overflow[0x0000000100000f78] (overflow.__TEXT.__stubs + 12)
      Summary: overflow`symbol stub for: printf

## Break point using address

    (lldb) breakpoint set --addresu 0x100000f47

## Displaying the stack
The equivalent of `x/20x $rsp` would be:

    (lldb) memory read --count 20 --size 4 --format x $rsp


## printf
Print with zero padding instead of blank

    $ printf "%010x" 3
    0000000003$

The first zero after the procent sign is the padding which can either be 0 or 
if left out blank padding will be added. 10 is the number of the padding and
x is for signed hexadecimal. 
