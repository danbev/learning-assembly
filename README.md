## Assembler
This project only contains small programs to help me learn assembler.

[gas](./gas) Contains examples using the GNU Assembler.  
[nasm](./nasm) Contains examples using the Netwide Assembler.  
[c](./c) C programs used for viewing the generated assembler code.  

### Registers
```console
* rax     Accumlator register. Caller saved. Used for return values from functions. 
* rbx     Base register. Caller saved.  
* rdi     Destination Index pointer. Callee saved. Used to pass 1st argument to functions  
* rsi     Source Index pointer. Caller saved. Used to pass 2nd argument to functions  
* rdx     Data register. Caller saved. Used to pass 3rd argument to functions  
* rcx     Counter register. Caller saved. Used to pass 4th argument to functions  
* r8      caller saved. Used to pass 5th argument to functions  
* r9      caller saved. Used to pass 6th argument to functions  
* rbp     Stack Base pointer. Caller saved.
* rsp     Stack pointer. Caller saved.
* r10     caller saved  
* r11     caller saved   
* r12     callee saved   
* r13     callee saved  
* r14     callee saved   
* r15     callee saved  

ax  = 16-bit mode
eax = 32-bit mode
rax = 64-bit mode

64-bit register | Lower 32 bits | Lower 16 bits | Lower 8 bits
==============================================================
rax             | eax           | ax            | al
rbx             | ebx           | bx            | bl
rcx             | ecx           | cx            | cl
rdx             | edx           | dx            | dl
rsi             | esi           | si            | sil
rdi             | edi           | di            | dil
rbp             | ebp           | bp            | bpl
rsp             | esp           | sp            | spl
r8              | r8d           | r8w           | r8b
r9              | r9d           | r9w           | r9b
r10             | r10d          | r10w          | r10b
r11             | r11d          | r11w          | r11b
r12             | r12d          | r12w          | r12b
r13             | r13d          | r13w          | r13b
r14             | r14d          | r14w          | r14b
r15             | r15d          | r15w          | r15b
```

#### Caller saved
These registers might be changed when making function calls and it is the callers responsibility to save them.

#### Callee saved
These registers are preserved/saved accross function calls.

### Instructions
Just to make sure that we are clear on this is that instructions are stored in memory and the processor runs by reading these
instructions. Any data required by the instructions is also read/stored from memory. To keep these separate there are two pointers
to help, the instruction pointer, and the data pointer.

`instruction pointer` is used to keep track of the instructions already executed and the next instruction. Instructions can alter
this indirectly by jumping which causes this pointer to move.

`data pointer` is used to keep track of where the data in memory starts. This is what is referred to as the stack. When you push
a new data element onto this stack the pointer moves down in memory.
 
Each processor family has its own predefined opcodes that define all of the functions available.

When you see a `q` appended to an instruction that indicated a full quadword (64bits), an `l` means a longword (only 32bits).

#### Intel Instruction format

    Instruction Prefix    Opcode       ModR/M      SIB         Displacement  Data elements
    0-4 bytes             1-3 bytes    0-1 bytes   0-1 bytes   0-4 bytes     0-4 bytes

Opcode is the only required part.

##### Instruction Prefixes
* Lock and repeat  
Indicates that any shared memory areas will be used exclusively by the instruction (multiprocessor systems)
* Segment override and branch hint  
Segement overrides defines that instructions can override defined segment registers.
The branch hint attempt to give the processor a clue as to the most likely path the program will take in a conditional jump statement.
* Operand size override  
The operand size override prefix informs the processor that the program will switch between 16-bit and 32-bit operand sizes within the instruction code. 
This enables the program to warn the processor when it uses larger-sized operands, helping to speed up the assignment of data to register
* Address size  
The address size override prefix informs the processor that the program will switch between 16-bit and 32-bit memory addresses.


##### Modifiers
* ModeR/M 
This byte tells the processor which registers or memory locations to use as the instruction's operands
```console
7     6 5    3 2     0
+------+------+------+
| mod  | reg2 | reg1 |
+------+------+------+
```

Both the reg1 and reg2 fields take three-bit register codes, indicating which registers to use as the instruction's operands. 
By default, reg1 is the source operand and reg2 is the destination. 
Mod field
```console
00          [reg1]       operand's address is in register reg1
01          [reg1+byte]  operand's memory address is reg1 plus a byte-sized displacement
10          [reg1+word]  operand's memory address is reg1 plus a word-sized displacement
11          reg1         operand is reg1
```

* SIB (Scale*Index+Base)
Only available in 32-bit mode.


### REX prefix
You may come across instructions using a REX prefix which are necessary if an instruction references one of the
extended registers or uses a 64-bit operand. It is ignored if used where it does not have any meaning.

For example:

    REX.W addq rsp,0x38

#### Assembly Instruction format

### The Stack
The stack consists of memory area for parameters, local variables, and the return address (sometimes return values depending
on the calling conventions which might dictate that return values be passed in registers.

System V AMD64 calling conventions:
```
1 in rdi
2 in rsi
3 in rdx
4 in rcx
5 in r8
6 in r9
```
Floating-point args are passed in:
```
1 in xmm0
2 in xmm1
3 in xmm2
4 in xmm3
5 in xmm4
6 in xmm5
7 in xmm6
```

`rax` is used for return values from functions.

When a process is started the stack is allocated with a fixed size in virtual memory by the OS. The area is released when
the process terminates. Each thread as its own stack.

The memory location for the stack is set aside when the program starts. Notice that
this is a continous memory area but still just memory. It is special since there is
a register that points to the top of the stack and there are operations that increment
the stack pointer regiser (rsp). 
It is important to remember this as getting something off the stack still requires
a memory read (since this is a continous memory it should be in the cache) and then
storing that in a register to use.

When a c-style function call is made it places the required arguments on the stack and the `call`
instruction places the return address onto the stack aswell.

```c
int doit(int i) {
  return i;
}

int main(int argc, char** argv) {
  int i = doit(6);
}
```

```console
(lldb) br s -a 0x100000f90
(lldb) r
(lldb) dis
func`doit:
    0x100000f80 <+0>:  pushq  %rbp
    0x100000f81 <+1>:  movq   %rsp, %rbp
    0x100000f84 <+4>:  movl   %edi, -0x4(%rbp)
    0x100000f87 <+7>:  movl   -0x4(%rbp), %eax
    0x100000f8a <+10>: popq   %rbp
    0x100000f8b <+11>: retq
    0x100000f8c <+12>: nopl   (%rax)

func`main:
--> 0x100000f90 <+0>:  pushq  %rbp
    0x100000f91 <+1>:  movq   %rsp, %rbp
    0x100000f94 <+4>:  subq   $0x20, %rsp
    0x100000f98 <+8>:  movl   $0x6, %eax
    0x100000f9d <+13>: movl   %edi, -0x4(%rbp)
    0x100000fa0 <+16>: movq   %rsi, -0x10(%rbp)
    0x100000fa4 <+20>: movl   %eax, %edi
    0x100000fa6 <+22>: callq  0x100000f80               ; doit at func.c:2
    0x100000fab <+27>: xorl   %edi, %edi
    0x100000fad <+29>: movl   %eax, -0x14(%rbp)
    0x100000fb0 <+32>: movl   %edi, %eax
    0x100000fb2 <+34>: addq   $0x20, %rsp
    0x100000fb6 <+38>: popq   %rbp
    0x100000fb7 <+39>: retq
(lldb)
```
We can inspect the current values of rsp and rbp:
```console
(lldb) register read $rsp $rbp
     rsp = 0x00007fff5fbfeea8
     rbp = 0x00007fff5fbfeeb8
```
Lets take a look at `0x00007fff5fbfeeb8`:
```console
(lldb) dis -s 0x00007fff8ab865ad
libdyld.dylib`start:
    0x7fff8ab865ad <+1>: movl   %eax, %edi
    0x7fff8ab865af <+3>: callq  0x7fff8ab865e0            ; symbol stub for: exit
    0x7fff8ab865b4 <+8>: hlt
    0x7fff8ab865b5:      nop
libdyld.dylib`OSAtomicCompareAndSwapPtrBarrier:
    0x7fff8ab865b6 <+0>: jmpq   *-0x116c63e4(%rip)        ; (void *)0x00007fff923209dc: OSAtomicCompareAndSwapPtrBarrier$VARIANT$mp

libdyld.dylib`free:
    0x7fff8ab865bc <+0>: jmpq   *-0x12b9c562(%rip)        ; (void *)0x00007fff951f3e98: free

libdyld.dylib`malloc:
    0x7fff8ab865c2 <+0>: jmpq   *-0x12b9c560(%rip)        ; (void *)0x00007fff951f10a2: malloc
```

After `pushq %rbp` we can again inspect the stack:
```console
(lldb) memory read -f x -c 4 -s 8 `$rsp`
0x7fff5fbfeea0: 0x00007fff5fbfeeb8 0x00007fff8ab865ad
0x7fff5fbfeeb0: 0x00007fff8ab865ad 0x0000000000000000
```
We can see that `0x00007fff5fbfeeb8` has been pushed onto the stack (written to the memory location pointed
to by register rsp, and rsp has been decremented by 8 (8 bytes, 64 bit operating system):
```console
(lldb) memory read -f x -c 1 -s 8 `$rsp`
0x7fff5fbfeea0: 0x00007fff5fbfeeb8
(lldb) memory read -f x -c 1 -s 8 `$rsp + 8`
0x7fff5fbfeea8: 0x00007fff8ab865ad
```

`subq   $0x20, %rsp` is making room for 32 bytes on the stack. This is used to store local variables argc, argv
`movl   $0x6, %eax` move the value 6 into eax
`movl   %edi, -0x4(%rbp)` save value in edi. This is argc:

```console
(lldb) settings show target.run-args
target.run-args (array of strings) =
  [0]: "5"
(lldb) register read -f d $edi
     edi = 2
(lldb) memory read -f x -s 4 -c 1 `$rbp - 4`
0x7fff5fbfee9c: 0x00000002
```

`movq   %rsi, -0x10(%rbp)` is saving the pointer to char** on the stack. This and the previous call
are setting up the local variables `argc` and `argv`.
```console
(lldb) register read $rsi
     rsi = 0x00007fff5fbfeec8
(lldb) memory read -f x -c 1 -s 8 `$rbp - 16`
0x7fff5fbfee90: 0x00007fff5fbfeec8
(lldb) memory read -f p -c 1 0x00007fff5fbfeec8
0x7fff5fbfeec8: 0x00007fff5fbff140
(lldb) memory read -f s -c 1 0x00007fff5fbff140
0x7fff5fbff140: "/Users/danielbevenius/work/assembler/c/func"
```
Remeber that `-0x10` is hex so that which means we have to subtract 16 to find the location on the stack.
 get the second argument:
```console
(lldb) memory read -f p -c 1 `0x00007fff5fbfeec8 + 8`
0x7fff5fbfeed0: 0x00007fff5fbff16c
(lldb) memory read -f s -c 1 0x00007fff5fbff16c
0x7fff5fbff16c: "5"
```

`movl   %eax, %edi` moves 6 into edi which is the argument for `doit`

So, this is our stack (for main that is):
```console
       +--------------------------+
       |    0x00007fff5fbfeea8    |  // return address placed by call operator
       +--------------------------+
       |            |     2       |  // argc
       +--------------------------+
       |                          |  
       +--------------------------+
       |    0x00007fff5fbfeec8    |  // argv
       +--------------------------+
rbp--> |                          |  
       +--------------------------+
```

```console
(lldb) dis -s  0x100000f80
func`doit:
    0x100000f80 <+0>:  pushq  %rbp
    0x100000f81 <+1>:  movq   %rsp, %rbp
    0x100000f84 <+4>:  movl   %edi, -0x4(%rbp)
    0x100000f87 <+7>:  movl   -0x4(%rbp), %eax
    0x100000f8a <+10>: popq   %rbp
    0x100000f8b <+11>: retq
    0x100000f8c <+12>: nopl   (%rax)
```

```console
       +--------------------------+
       |    0x00007fff5fbfeea8    |  // return address placed by call operator
       +--------------------------+
       |            |     2       |  // argc
       +--------------------------+
       |                          |  
       +--------------------------+
       |    0x00007fff5fbfeec8    |  // argv
       +--------------------------+
rbp--> |       0x100000fab        |  // callq 0x100000f80 : doit(6) will push the return address onto the stack
       +--------------------------+
```

```console
(lldb) register read rbp
     rbp = 0x00007fff5fbfeea0
```

       +--------------------------+
       |    0x00007fff5fbfeea8    |  // return address placed by call operator
       +--------------------------+
       |            |     2       |  // argc
       +--------------------------+
       |                          |  
       +--------------------------+
       |    0x00007fff5fbfeec8    |  // argv
       +--------------------------+
       |       0x100000fab        |  // callq 0x100000f80 : doit(6) will push the return address onto the stack
       +--------------------------+
       |    0x00007fff5fbfeea0    |  // store the value of main's rbp
       +--------------------------+

Next, set doit's base pointer to the currentl value of rsp. 

```console
(lldb) dis -f
func`doit:
->  0x100000f80 <+0>:  pushq  %rbp
```
Just to verify my own understanding that the this is just continuous memory and "stack frames" are just sections
of this memory. So we should be able, from within doit, to access local variables of the main function. rbp till
points to base of main's stack. Lets try to get the value of argc:
```console
(lldb) memory read -f x -c 1 -s 4 `$rbp - 4`
0x7fff5fbfee9c: 0x00000002
```
And how about the name of the executable:
```console
(lldb) memory read -f x -c 1 -s 8 `$rbp - 16`
0x7fff5fbfee90: 0x00007fff5fbfeec8
(lldb) memory read -f x -c 1 -s 8 0x00007fff5fbfeec8
0x7fff5fbfeec8: 0x00007fff5fbff140
(lldb) memory read -f s -c 1 0x00007fff5fbff140
0x7fff5fbff140: "/Users/danielbevenius/work/assembler/c/func"
```

    
The Stack Pointer register (rsp) is used to point to the top of the stack in memory. 

    p2           8(%esp)
    p1           4(%esp)
    return address <- (%esp)

     88                  92                  96                  100
     +-----------------------------------------------------------+
     | rt | rt | rt | rt | p1 | p1 | p1 | p1 | p2 | p2 | p2 | p2 |
     +-----------------------------------------------------------+
    /\   
    ESP

When PUSH is used it places data on the bottom of this memory area and decreases the stack pointer.

     84                 88                   92                  96                   100
     +--------------------------------------------------------------------------------+
     | v1 | v1 | v1 | v1 | rt | rt | rt | rt | p1 | p1 | p1 | p1 | p2 | p2 | p2 | p2  |
     +--------------------------------------------------------------------------------+
    /\   
    ESP

Notice that the value or SP went from 88 to 84 (-4).

When POP is used it moves data to a register or a memory location and increases the stack pointer.

So SP points to the top of the stack where the return address is. If we used the POP instruction to get the
parameters to the function, the return address might be lost in the process. This can be avoided using indirect addressing, 
as in using 4(%esp) to access the parameters and avoid ESP to be incremented. 

But what if the function itself needs to push data onto the stack, this would also change the value of ESP and it would throw off the indirect
addressing. Instead what is common practice is to store the current value of ESP (which is pointing to the 
return address) in EBP. Then use indirect addressing with EBP which will not change if the PUSH/POP instructions
are used. The calling (the callee) function might also be using the EBP for the same reason, so we first PUSH that value
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

Now, since we are using EBP we can place additional data on the stack without affecting how input parameters values are accessed. 
We can used EBP with indirect addressing to create local variables:

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
but the calling function. What you should do is reset the stack to the state before the call, when
there were now parameters on the stack. You can do this by adding 4,8,12 (what ever the size and number
of parameters are).

### Inspecting the stack
When you start a program in `lldb` you can take a look at the stack pointer memory location using:

    $ lldb ./out/cli 10 20
    (lldb) br s  -f cli.s -l 9
    (lldb) r
    (lldb) register read rsp
     rsp = 0x00007fff5fbfeb98

    (lldb) memory read --size 4 --format x 0x00007fff5fbfeb98
    0x7fff5fbfeb98: 0x850125ad 0x00007fff 0x850125ad 0x00007fff
    0x7fff5fbfeba8: 0x00000000 0x00000000 0x00000002 0x00000000

What I'm trying to figure out is where `argc` might be. We can see that `0x7fff5fbfeba8` has `2` which matches our two parameters (the program name and the argument).
What I was missing was that when using a C runtime argc is passed in rdi and not on the stack: 

    (lldb) register read edi
     edi = 0x00000003

### Compare while(flag) to while(flag == true)
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

You can show the sections using:

   (lldb) image dump sections

## Linking and Loading
Using `chmod +x` any file can be set to be an executable, but this only tells the kernel to
read the file into memory and to look for a header to determine the executable format. This header
is often referred to as `magic` which is a know digit identifying a certain type of executable format.

Magic's:  
```console
\x7FELF      Executable and Library Format. Native in Linux and UNIX though not supported by OS X  
\#!           Script. The kernel looks for the string following #! and executes it as a command passing  
             the rest of the file to the process through stdin  
0xcafebabe   Multi-arch binaries for OS X only  
0xfeedface   OS X native binary format 32 bit  
0xfeedfacf   OS X native binary format 64 bit  
```

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


### func.c
```c++
int doit() {
  return 22;
}

int main(int argc, char** argv) {
  int i = doit();
}
```

    $ clang -g -o func func.c
    $ lldb func
    (lldb) br s -n main
    (lldb) dis

```console
(lldb) dis
func`main:
    0x100000f90 <+0>:  pushq  %rbp
    0x100000f91 <+1>:  movq   %rsp, %rbp
    0x100000f94 <+4>:  subq   $0x20, %rsp
    0x100000f98 <+8>:  movl   %edi, -0x4(%rbp)
    0x100000f9b <+11>: movq   %rsi, -0x10(%rbp)
->  0x100000f9f <+15>: callq  0x100000f80               ; doit at func.c:2
    0x100000fa4 <+20>: xorl   %edi, %edi
    0x100000fa6 <+22>: movl   %eax, -0x14(%rbp)
    0x100000fa9 <+25>: movl   %edi, %eax
    0x100000fab <+27>: addq   $0x20, %rsp
    0x100000faf <+31>: popq   %rbp
    0x100000fb0 <+32>: retq
```
First thing to notice is the operations that are performed before we come to the
call to `doit`.

```console
    0x100000f90 <+0>:  pushq  %rbp
    0x100000f91 <+1>:  movq   %rsp, %rbp
```
This is preserving the old value of rbp and moving the current value of 
rsp into rbp so that we can use rbp as an offset which will not be affected by push/pop
operation on the stach which increment rsp.

```console
    0x100000f94 <+4>:  subq   $0x20, %rsp
```
This is making room for variables on the stack by subtracting 20 from rsp.

    0x100000f98 <+8>:  movl   %edi, -0x4(%rbp)
    0x100000f9b <+11>: movq   %rsi, -0x10(%rbp)

These are storing the arguments to main on the stack:

    (lldb) memory read --size 4 -format x --count 1 `$rbp - 4`
    0x7fff5fbfee9c: 0x00000001


### Read a pointer to pointer as c-string
Lets say you want to find the first value of argv. You can do this by inspecting the value in rsi:

    (lldb) register read $rsi
     rsi = 0x00007fff5fbfeec0

We know that this is a pointer to a pointer so we want to read the memory address contained in `0x00007fff5fbfeec0`:

    (lldb) memory read -f p -c 1 0x00007fff5fbfeec0
     0x7fff5fbfeec0: 0x00007fff5fbff130

Notice the usage of `-f p` which is to format ass a pointer. Next, we can use that address and the `-f s` to 
print the c-string:

    (lldb) memory read -f s -c 1 0x00007fff5fbff130
      0x7fff5fbff130: "/Users/danielbevenius/work/assembler/c/func"


### memory read format values
The following are the supported values for the -f <format> argument: 
```console
'B' or "boolean"
'b' or "binary"
'y' or "bytes"
'Y' or "bytes with ASCII"
'c' or "character"
'C' or "printable character"
'F' or "complex float"
's' or "c-string"
'd' or "decimal"
'E' or "enumeration"
'x' or "hex"
'X' or "uppercase hex"
'f' or "float"
'o' or "octal"
'O' or "OSType"
'U' or "unicode16"
"unicode32"
'u' or "unsigned decimal"
'p' or "pointer"
"char[]"
"int8_t[]"
"uint8_t[]"
"int16_t[]"
"uint16_t[]"
"int32_t[]"
"uint32_t[]"
"int64_t[]"
"uint64_t[]"
"float16[]"
"float32[]"
"float64[]"
"uint128_t[]"
'I' or "complex integer"
'a' or "character array"
'A' or "address"
"hex float"
'i' or "instruction"
'v' or "void"
```

### movzx
If you try to move a value using:
```assembler
movw %ax, %bx
```
The upper part of ebx might contain non-zero value. You have to set them to zero to not get an incorrect
value. Or you can use `movzx` which will do that for you.

### Processing
Try to remember that what you see as function calls are just setting up registers/stack with the values that the function expects and then jumping to that address.
The `call` operator is used to it will also store the return address, the address
of the instruction following the call operator instruction. This allows us to use 
the `ret` instruction. 

        address      +------------------------+    data
      +--------------|        RAM             |----------------+
      |+-------------|                        |---------------+|
      ||+------------|                        |--------------+||
      |||+-----------|                        |-------------+|||
      ||||+----------|                        |------------+||||
      |||||+---------|                        |-----------+|||||
      ||||||+--------|                        |----------+||||||
      |||||||+-------|                        |---------+|||||||
      ||||||||       +------------------------+         ||||||||
                         set |      | enable            
      
     +--------+                                        +--------+
     |00000001|                                        |10101010|
     +--------+                                        +--------+
     |00000010|                                        |11101011|
     +--------+                                        +--------+
     ...                                               ...

Now, data can be both instructions for the processor to perfom or it can be 
data like numbers, addresses, etc.

When the CPU needs to process an instruction it will set that address on the address bus and set enable wire and RAM will send back whatever data is at that address on the data bus.
To store data in RAM the CPU need to set the address on the address bus, put the data on the databus and set the `set` wire.

Take the output you see in lldb when you disassemble a function:
```
(lldb) dis -n main -b
stack-alloc`main:
    0x100000f80 <+0>:  55                    pushq  %rbp
    0x100000f81 <+1>:  48 89 e5              movq   %rsp, %rbp
    0x100000f84 <+4>:  31 c0                 xorl   %eax, %eax
    0x100000f86 <+6>:  c7 45 fc 00 00 00 00  movl   $0x0, -0x4(%rbp)
    0x100000f8d <+13>: 89 7d f8              movl   %edi, -0x8(%rbp)
    0x100000f90 <+16>: 48 89 75 f0           movq   %rsi, -0x10(%rbp)
->  0x100000f94 <+20>: 8b 3d 0e 00 00 00     movl   0xe(%rip), %edi
    0x100000f9a <+26>: 89 7d e8              movl   %edi, -0x18(%rbp)
    0x100000f9d <+29>: c7 45 e4 06 00 00 00  movl   $0x6, -0x1c(%rbp)
    0x100000fa4 <+36>: 5d                    popq   %rbp
    0x100000fa5 <+37>: c3                    retq
```
Take `55 pushq %rbp`, 55 is 1010101 in binary. If we read `0x100000f80` that should match I think:
```console
(lldb) memory read -f b -c 1 -s 1 0x100000f80
0x100000f80: 0b01010101

(lldb) memory read -f x -c 1 -s 1 0x100000f80
0x100000f80: 0x55
```
For the second instruction, `movq`: 
```console
(lldb) memory read -f x -c 3 -s 1 0x100000f81
0x100000f81: 0x48 0x89 0xe5
```
It looks like there are differnt opcodes depending on the type of operands. I was expecting `movl` to all have the same
opcode but they don't in this example. But I did notice that two do that move a value from a register to the stack (89).

I know I'm probaly repeating myself but we can see that our program has been loaded into RAM and the instructions are
just opcodes in memory.

### Returning

### jnz

### test
```
  movq $1, %rax
  movq $2, %rbx
  testq %rax, %rbx
```

```
temp = 0001 & 0010
if (temp = 0) 
  ZF = 1
elese 
  ZF = 0
```

### jne
```
  movq $1, %rax
  movq $2, %rbx
  testq %rax, %rbx
  jne not_equal
```
Think jump if ZF = 0. If the two values compared don't have the same bits in common the will 
not and to zero, so temp > 0 and ZF will be set to 0.


### Processor architectures
IBM Power architecture is a reduced instruction set computing (RISC). It includes POWER, PowerPC and Cell processors.

Advanded RISC Machines (ARM) design RISC processors.

Intel use complex instruction set computer (CISC)


### Single Instruction Multiple Data (SIMD)
We know we can add two numbers together using the add operator. We can consider this a Single Instruction Single Data (SISD).
```
int a[] = {0, 1, 2, 3, 4, 5, 6, 7}
int b[] = {0, 1, 2, 3, 4, 5, 6, 7}
int sum = a[1] + b[1] + a[2] + b[2] ...
```
So we want a single instruction to operate on multiple data (the arrays), so an instruction could be
add a, b
And would operator on the entire a and b and sum them.
SIMD computing element performs the same operation on multiple data items simultaneously.
x86’s first SIMD extension, which is called MMX technology.

MMX technology adds eight 64-bit registers to the core x86-32 platform:
```
63                  0
+-------------------+
|     MM7           |
--------------------|
|     MM6           |
--------------------|
|     MM5           |
--------------------|
|     MM4           |
--------------------|
|     MM3           |
--------------------|
|     MM2           |
--------------------|
|     MM1           |
--------------------|
|     MM0           |
+-------------------+
```

These registers can be used to perform SIMD operations using eight 8-bit integers, four 16-bit integers, 
or two 32-bit integers. Both signed and unsigned integers are supported.
The MMX registers cannot be used to perform floating-point arithmetic or address operands located in memory.

pmaddwd
Performs a packed signed-integer multiplication followed by a signed-integer addition that uses 
neighboring data elements within the products. This instruction can be used to calculate an integer dot product.


SSE performed up to four operations at a time. AVX-512 performs up to 16 operations at a time.

Use SIMD intrinsics. It’s like assembly language, but written inside your C/C++ program. 
SIMD intrinsics actually look like a function call, but generally produce a single instruction (a vector operation instruction, also known as a SIMD instruction).

#### Streaming SIMD Extensions (SSE)
SSE is a set of instructions supported by Intel processors that perform high-speed operations on large chunks of data.

#### Advanced Vector Extensions (AVX)
They perform many of the same operations as SSE instructions, but operate on larger chunks of data at higher speed.
Intel has released additional instructions in the AVX2 and AVX512 sets.


### Intrinsics
An AVX instruction is an assembly command that performs an indivisible operation. For example, the AVX instruction vaddps adds two operands and places the result in a third.
To perform the operation in C/C++, the intrinsic function _mm256_add_ps() maps directly to vaddps, combining the performance of assembly with the convenience of a high-level function.
An intrinsic function doesn't necessarily map to a single instruction, but AVX/AVX2 intrinsics provide reliably high performance compared to other C/C++ functions.

Here are the CPUs that support AVX:

Intel's Sandy Bridge/Sandy Bridge E/Ivy Bridge/Ivy Bridge E
Intel's Haswell/Haswell E/Broadwell/Broadwell E
AMD's Bulldozer/Piledriver/Steamroller/Excavator
Every CPU that supports AVX2 also supports AVX. Here are the devices:

Intel's Haswell/Haswell E/Broadwell/Broadwell E
AMD's Excavator

Find the model of my processor:
```console
$ sysctl -n machdep.cpu.brand_string
Intel(R) Core(TM) i7-4960HQ CPU @ 2.60GHz
```
Sandy Bridge is the codename for the microarchitecture used in the "second generation" of the Intel Core processors (Core i7, i5, i3) 

Most of the intrinsic functions use specific data types.
__m128	128-bit vector containing 4 floats
__m128d	128-bit vector containing 2 doubles
__m128i	128-bit vector containing integers
__m256	256-bit vector containing 8 floats
__m256d	256-bit vector containing 4 doubles​
__m256i	256-bit vector containing integers

AVX512 supports 512-bit vector types that start with _m512, but AVX/AVX2 vectors don't go beyond 256 bits
If the type does not have suffix (like d or i then it is a float)
A _m256i may contain 32 chars, 16 shorts, 8 ints, or 4 longs. These integers can be signed or unsigned.

The intrinsic function names have the following format:
_mm<bit width>_<name>_<data type>

The bit width is the size of the returned vector. Just empty for 128 bit vectors.
The name is just the name of the function and the datatype is the type of the functions arguments.
The data type can be set to one of the following values:
- ps                                  packed single precision floats
- pd                                  packed double precision doubles
- epi8/epi16/epi32/epi64              vector containing signed int 8/16/32/64
- epu8/epu16/epu32/epu64              vector containing unsigned int 8/16/32/64
- si128/si256                         unspecified 128-bit vector or 256-bit vector
- m128/m128i/m128d/m256/m256i/m256d   


Saturation arithmetic is like normal arithmetic except that when the result of the operation that would 
overflow or underflow an element in the vector, that is clamped at the end of the range and not allowed
to wrap around. This can make sense for things like pixels where if the value exceeds the max value
allowed for that pixel is should simply use the largest possible value and not wrap around.


### Function calls
When our main function calls a function it will push an 8 byte address onto the
stack. This is the address of the instruction to be executed after the called
function completes. So this is pushed onto the stack by the `call` instruction
and the function calls `ret` which will pop that value off the stack and will
jmp to that instruction. These addresses will be 8-bytes.
Inside the function we often need to use the stack so we have to be careful and
clean up (pop) off any values we have pushed before the `ret` instruction is
called or we will jmp to different value/address (?).
This is also true for our main function, before it is called an 8-byte return
address is pushed onto the stack.

The stack has to have a 16-byte alignment when you call a function. This requirement
comes from SIMD that operate of larger blocks of data (in parallel). These operations
might require that the memory addresses are multiples of 16 bytes.
What does that mean. 
```
       0+----------+
	| ret addr |
	+----------+
```

### Function vs Prodedure
A function returns a value whereas a prodedure does not.


### gdb
```console
(gdb) info registers 
rax            0x400540            4195648
rbx            0x0                 0
rcx            0x7ffff7dce738      140737351837496
rdx            0x7fffffffd6e8      140737488344808
rsi            0x7fffffffd6d8      140737488344792
rdi            0x1                 1
rbp            0x400570            0x400570 <__libc_csu_init>
rsp            0x7fffffffd5f0      0x7fffffffd5f0
r8             0x7ffff7dcfda0      140737351843232
r9             0x7ffff7dcfda0      140737351843232
r10            0x7                 7
r11            0x2                 2
r12            0x400450            4195408
r13            0x7fffffffd6d0      140737488344784
r14            0x0                 0
r15            0x0                 0
rip            0x400541            0x400541 <main+1>
eflags         0x246               [ PF ZF IF ]
cs             0x33                51
ss             0x2b                43
ds             0x0                 0
es             0x0                 0
fs             0x0                 0
gs             0x0                 0
```
Note that the third column is the registers value in decimal where that makes
sense. In cases where it does not make sense, like for registers `rsp`, `rip`,
and `rbp` the are only for storing addresses which is why these registers
are just shoing the same values.

```console
(gdb) p  $rsp
$2 = (void *) 0x7fffffffd5f0
```
We can examine the memory that `rsp` is pointing to using:
```console
(gdb) x/1xw $rsp
0x7fffffffd5f0:	0x00400570
```
Which we can verify is the same as:
```console
(gdb) x/1xw 0x7fffffffd5f0
0x7fffffffd5f0:	0x00400570
```
```console
(gdb) x/1xw 0x400570
0x400570 <__libc_csu_init>:	0xfa1e0ff3
```
```console
(gdb) disassemble 
Dump of assembler code for function main:
=> 0x0000000000400540 <+0>:	push   %rbp
   0x0000000000400541 <+1>:	mov    %rsp,%rbp
   0x0000000000400544 <+4>:	callq  0x40054b <doit>
   0x0000000000400549 <+9>:	leaveq 
   0x000000000040054a <+10>:	retq   
End of assembler dump.
(gdb) i r rsp rbp
rsp            0x7fffffffd5f8      0x7fffffffd5f8
rbp            0x400570            0x400570 <__libc_csu_init>
```
So after pushing rpb onto the stack we should be able to see the same value
as above at the top of the stack:
```console
(gdb) x/1xg $rsp
0x7fffffffd5f0:	0x0000000000400570
```
So I mainly did this to make sure that I can examine (x) the contents of the
stack (I'm used to using lldb and some things are different and I'm trying to
get used to them).
```console
LD_SHOW_AUXV=1 gdb --args ./function bajja
AT_SYSINFO_EHDR: 0x7ffd05f63000
AT_HWCAP:        bfebfbff
AT_PAGESZ:       4096
AT_CLKTCK:       100
AT_PHDR:         0x562afc5d4040
AT_PHENT:        56
AT_PHNUM:        10
AT_BASE:         0x7f66c06cb000
AT_FLAGS:        0x0
AT_ENTRY:        0x562afc7327b0
AT_UID:          12974
AT_EUID:         12974
AT_GID:          12974
AT_EGID:         12974
AT_SECURE:       0
AT_RANDOM:       0x7ffd05e246c9
AT_HWCAP2:       0x0
AT_EXECFN:       /usr/bin/gdb
AT_PLATFORM:     x86_64
```
```console
(gdb) x/10xg $rsp
0x7fffffffd6b0:	0x0000000000000002	0x00007fffffffda14
0x7fffffffd6c0:	0x00007fffffffda58	0x0000000000000000
0x7fffffffd6d0:	0x00007fffffffda5e	0x00007fffffffe15c
0x7fffffffd6e0:	0x00007fffffffe173	0x00007fffffffe19a
0x7fffffffd6f0:	0x00007fffffffe1ab	0x00007fffffffe1c0
```
In this case `argc` is on top of the stack, we have two as the first is the
name of the executable.
```console
(gdb) x/s 0x00007fffffffda14
0x7fffffffda14:	"/home/dbeveniu/work/assembler/learning-assembly/nasm/linux/function"
(gdb) x/s 0x00007fffffffda58
0x7fffffffda58:	"bajja"
```
Following that are the environment variables.


### start up
```console
$ size function
   text	   data	    bss	    dec	    hex	filename
   1157	    485	      8	   1650	    672	function
$ file function
function: ELF 64-bit LSB executable, x86-64, version 1 (SYSV),
dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0,
BuildID[sha1]=a4151387be0b5a64a852e5890a27e09c3b48994d, with debug_info, not stripped
```
```console
$ readelf -h function
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x400450
  Start of program headers:          64 (bytes into file)
  Start of section headers:          9688 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         9
  Size of section headers:           64 (bytes)
  Number of section headers:         35
  Section header string table index: 34
```
We can see that our entry point is `0x400450`:
```console
0000000000400450 <_start>:
  400450:	f3 0f 1e fa          	endbr64 
  400454:	31 ed                	xor    %ebp,%ebp
  400456:	49 89 d1             	mov    %rdx,%r9
  400459:	5e                   	pop    %rsi
  40045a:	48 89 e2             	mov    %rsp,%rdx
  40045d:	48 83 e4 f0          	and    $0xfffffffffffffff0,%rsp
  400461:	50                   	push   %rax
  400462:	54                   	push   %rsp
  400463:	49 c7 c0 e0 05 40 00 	mov    $0x4005e0,%r8
  40046a:	48 c7 c1 70 05 40 00 	mov    $0x400570,%rcx
  400471:	48 c7 c7 40 05 40 00 	mov    $0x400540,%rdi
  400478:	ff 15 6a 0b 20 00    	callq  *0x200b6a(%rip)        # 600fe8 <__libc_start_main@GLIBC_2.2.5>
  40047e:	f4                   	hlt    
```
So lets set a break point in `_start` and take a look at the registers, in 
particular I'd like to see the value of `rip` and `rsp`:
```console
(gdb) br _start
(gdb) r
(gdb) disassemble 
Dump of assembler code for function _start:
=> 0x0000000000400450 <+0>:	endbr64 
   0x0000000000400454 <+4>:	xor    %ebp,%ebp
   0x0000000000400456 <+6>:	mov    %rdx,%r9
   0x0000000000400459 <+9>:	pop    %rsi
   0x000000000040045a <+10>:	mov    %rsp,%rdx
   0x000000000040045d <+13>:	and    $0xfffffffffffffff0,%rsp
   0x0000000000400461 <+17>:	push   %rax
   0x0000000000400462 <+18>:	push   %rsp
   0x0000000000400463 <+19>:	mov    $0x4005e0,%r8
   0x000000000040046a <+26>:	mov    $0x400570,%rcx
   0x0000000000400471 <+33>:	mov    $0x400540,%rdi
   0x0000000000400478 <+40>:	callq  *0x200b6a(%rip)        # 0x600fe8
   0x000000000040047e <+46>:	hlt    
End of assembler dump.
```
The `__libc_start_main` function looks like this:
```c
int __libc_start_main(  int (*main) (int, char * *, char * *),
			    int argc, char * * ubp_av,
			    void (*init) (void),
			    void (*fini) (void),
			    void (*rtld_fini) (void),
			    void (* stack_end));
```
After clearing the base pointer, which is something specified in the ABI, we
move the content of `rdx` into r9:
```console
(gdb) x/x $rdx
$ 0x7ffff7de3f00 <_dl_fini>:	0xf3
```
This is the sixth argument to __libc_start_main.
Next we pop the top value of the stack into `rsi`. the value is:
```console
(gdb) x/1xg $rsp
0x7fffffffd6b0:	0x0000000000000002
```
This is `argc` which is now stored in rsi.
Next, the stack pointer is copied into rdx.
After this I think we have a stack alignement operation, the `and`. TODO: verify this!
```
   0x000000000040045d <+13>:	and    $0xfffffffffffffff0,%rsp
```
This operation will leave all the bytes in rsp intact except for the last four
bits which will be changed to 0.


After that we are going to copy `__libc_csu_fini` into r8, `__libc_csu_init` into
rcx, and `main` into rdi:
```console
(gdb) x/x 0x4005e0
0x4005e0 <__libc_csu_fini>:	0xf3
(gdb) x/x 0x400570
0x400570 <__libc_csu_init>:	0xf3
(gdb) x/x 0x400540
0x400540 <main>:	0x55
```
Finally we have the `call` to:
```console
(gdb) x/1xg (0x600fe8)
0x600fe8:	0x00007ffff7a33720
(gdb) x/1xg 0x00007ffff7a33720
0x7ffff7a33720 <__libc_start_main>:	0xc0315641fa1e0ff3
```
So, that is all that the `_start` function does. 

Just a note about `csu` which I think stands for `c start up`.

We saw that the address to our `main` function was passed in the `rdi` register,
so how does it get used in [__libc_start_main](https://code.woboq.org/userspace/glibc/csu/libc-start.c.html#111)?  
We can see main getting called [here](https://code.woboq.org/userspace/glibc/csu/libc-start.c.html#339).


So lets show the registers:
```console
(gdb) info registers 
rax            0x7ffff7ffdfa0      140737354129312
rbx            0x0                 0
rcx            0x7fffffffd6e8      140737488344808
rdx            0x7ffff7de3f00      140737351925504
rsi            0x1                 1
rdi            0x7ffff7ffe150      140737354129744
rbp            0x0                 0x0
rsp            0x7fffffffd6d0      0x7fffffffd6d0
r8             0x7ffff7ffe6e8      140737354131176
r9             0x0                 0
r10            0x7                 7
r11            0x2                 2
r12            0x400450            4195408
r13            0x7fffffffd6d0      140737488344784
r14            0x0                 0
r15            0x0                 0
rip            0x400450            0x400450 <_start>
eflags         0x202               [ IF ]
cs             0x33                51
ss             0x2b                43
ds             0x0                 0
es             0x0                 0
fs             0x0                 0
gs             0x0                 0
```
So notice that `rbp` is `0x0` and the `rip` points to the first instruction
Tin _start.
