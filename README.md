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
These registers might be changed when making function calls and it is the
callers responsibility to save them.
The registers are `rax`, `rcx`, `edx`. So when calling a function if the current
function depends on these values to. rax is used for the return value of the
function being called, and the function being called might use rcx as a counter. 

#### Callee saved
These registers are preserved/saved accross function calls so if the called
function needs to uses these registers it has to store and the restore them.

### Calling Conventions
The C calling conventions used on 32-bit x86 processor are the following:
CDECL, STDCALL, and FASTCALL. There is additional one named THISCALL which is
used sometimes for C++.

#### CDECL
By default this is the default C calling convention used (on 32-bit systems that
is).
Arguments are passed on the stack, pushed from right to left and the calling
function is responsible for cleaning up the stack.
For example:
```console
$ objdump --disassemble=main cdecl

cdecl:     file format elf32-i386


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0804916c <main>:
 804916c:	55                   	push   %ebp
 804916d:	89 e5                	mov    %esp,%ebp
 804916f:	6a 03                	push   $0x3
 8049171:	6a 02                	push   $0x2
 8049173:	6a 01                	push   $0x1
 8049175:	e8 ec ff ff ff       	call   8049166 <something>
 804917a:	83 c4 0c             	add    $0xc,%esp
 804917d:	b8 00 00 00 00       	mov    $0x0,%eax
 8049182:	c9                   	leave  
 8049183:	c3 
```
We can see that the arguments are indeed pushed onto the stack, and we add 12
(3*4) to the stack to remove the three arguments pushed.

### STDCALL
This similar to to CDECL convention but here the callee is responsible for
cleaning up the stack:
```console
$ objdump --disassemble=main stdcall

stdcall:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .text:

0000000000401116 <main>:
  401116:	55                   	push   %rbp
  401117:	48 89 e5             	mov    %rsp,%rbp
  40111a:	48 83 ec 10          	sub    $0x10,%rsp
  40111e:	89 7d fc             	mov    %edi,-0x4(%rbp)
  401121:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  401125:	ba 03 00 00 00       	mov    $0x3,%edx
  40112a:	be 02 00 00 00       	mov    $0x2,%esi
  40112f:	bf 01 00 00 00       	mov    $0x1,%edi
  401134:	e8 cd ff ff ff       	callq  401106 <something>
  401139:	b8 00 00 00 00       	mov    $0x0,%eax
  40113e:	c9                   	leaveq 
  40113f:	c3                   	retq   

Disassembly of section .fini:
```

### FASTCALL
This convention allows parameters to be passed the two registers `rcx`, and
`rdx`:
```console
$ objdump --disassemble=main fastcall

fastcall:     file format elf32-i386


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

08049177 <main>:
 8049177:	55                   	push   %ebp
 8049178:	89 e5                	mov    %esp,%ebp
 804917a:	6a 03                	push   $0x3
 804917c:	ba 02 00 00 00       	mov    $0x2,%edx
 8049181:	b9 01 00 00 00       	mov    $0x1,%ecx
 8049186:	e8 db ff ff ff       	call   8049166 <something>
 804918b:	b8 00 00 00 00       	mov    $0x0,%eax
 8049190:	c9                   	leave  
 8049191:	c3                   	ret    

Disassembly of section .fini:
```

### x86_64 calling conventions
The caller should save the contents of r10, r11, and any registers that need to
be used for passing arguments to the function being called. This is done by
pushing them onto the stack.

Registers parameters (in order):
```
rdi
rsi
rdx
rcx
r8
r9
```
Any additional parameters are pushed onto the stack in right to left order.
The return value will be placed in rax. The caller should then pop the any
values that it saved on the stack before calling the function.


### Instructions
Just to make sure that we are clear on this is that instructions are stored in
memory and the processor runs by reading these instructions. Any data required
by the instructions are also read/stored from memory. To keep these separate
there are two pointers to help, the instruction pointer (rip), and the data/stack
pointer (rsp).

The `instruction pointer` is used to keep track of the instructions already executed
and the next instruction. Instructions can alter this indirectly by jumping
which causes this pointer to move.

The `data/stack pointer` is used to keep track of where the data in memory starts. This
is what is referred to as the stack. When you push a new data element onto this
stack the pointer moves down in memory.
 
Each processor family has its own predefined opcodes that define all of the
functions available.

When you see a `q` appended to an instruction that indicated a full quadword
(8 bytes, 64bits), an `l` means a longword (only 4 bytes, 32bits).

#### Intel Instruction format
The size of instructions is variable, from 1 byte to a maximum size of an 15 bytes.

```
Instruction Prefix    Opcode       ModR/M      SIB         Displacement  Data elements
0-4 bytes             1-3 bytes    0-1 bytes   0-1 bytes   0-4 bytes     0-4 bytes
```
Opcode is the only mandatory part.

##### Instruction Prefix
Are divided into 4 groups:
###### Group 1
* Lock and repeat  
Indicates that any shared memory areas will be used exclusively by the
instruction (multiprocessor systems).

###### Group 2
* Segment override and branch hint  
Segement overrides defines that instructions can override defined segment registers.
The branch hint attempts to give the processor a clue as to the most likely path
the program will take in a conditional jump statement.

###### Group 3
* Operand size override  
The operand size override prefix informs the processor that the program will
switch between 16-bit and 32-bit operand sizes within the instruction code. 
This enables the program to warn the processor when it uses larger-sized operands,
helping to speed up the assignment of data to register

* Address size  
The address size override prefix informs the processor that the program will
switch between 16-bit and 32-bit memory addresses.

###### Group 4
* REX prefix
You may come across instructions using a REX prefix which are necessary if an
instruction references one of the extended registers or uses a 64-bit operand.
It is ignored if used where it does not have any meaning.

For example:
```
REX.W addq rsp,0x38
```

##### Modifiers
* ModeR/M 
This byte tells the processor which registers or memory locations to use as the
instruction's operands
```console
7     6 5    3 2     0
+------+------+------+
| mod  | reg2 | reg1 |
+------+------+------+
```

Both the reg1 and reg2 fields take three-bit register codes, indicating which
registers to use as the instruction's operands. 
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

Lets take a very simple example to understand what we are talking about:
```
movl  $1, %eax
```

```console
$ objdump -d instructions
0000000000000000 <_start>:
   0:	b8 01 00 00 00       	mov    $0x1,%eax
   5:	bb 00 00 00 00       	mov    $0x0,%ebx
   a:	cd 80                	int    $0x80
```
The first column indicates the start byte of a row, followed by the instruction
also in hex.
Notice that `movl` became [mov](http://ref.x86asm.net/coder32.html#xB8) and
that even though the instructions mnemonic are the same the instructions are
different. So this must mean that there are different instructions for different
registers as both of these instructions are using immediate instructions. And
what about the empty bytes, what are they about?

In this case, even though we have a 64-bit mode the immediate operand, `0x1` in
this case, is a 32 bit value. So the movl will become mov?


#### Assembly Instruction format

### The Stack
The stack consists of memory area for parameters, local variables, and the
return address (sometimes return values depending on the calling conventions
which might dictate that return values be passed in registers.
But this is still just ram memory, like the heap, the .data section, and the
.text/code section. 

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

When a process is started the stack is allocated with a fixed size in virtual
memory by the OS. The area is released when the process terminates. Each thread
has its own stack.

The memory location for the stack is set aside when the program starts. Notice that
this is a continous memory area but still just memory. It is special since there is
a register that points to the top of the stack and there are operations that increment
the stack pointer regiser (rsp). 
It is important to remember this as getting something off the stack still requires
a memory read (since this is a continous memory it should be in the cache) and then
storing that in a register to use.

When a c-style function call is made it places the required arguments on the
stack and the `call` instruction places the return address onto the stack as well.

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
```
p2           8(%esp)
p1           4(%esp)
return address <- (%esp)

88                  92                  96                  100
+-----------------------------------------------------------+
| rt | rt | rt | rt | p1 | p1 | p1 | p1 | p2 | p2 | p2 | p2 |
+-----------------------------------------------------------+
/\   
ESP
```

When PUSH is used it places data on the bottom of this memory area and decreases
the stack pointer.
```
84                 88                   92                  96                   100
+--------------------------------------------------------------------------------+
| v1 | v1 | v1 | v1 | rt | rt | rt | rt | p1 | p1 | p1 | p1 | p2 | p2 | p2 | p2  |
+--------------------------------------------------------------------------------+
/\   
ESP
```

Notice that the value or SP went from 88 to 84 (-4).

When POP is used it moves data to a register or a memory location and increases
the stack pointer.

So SP points to the top of the stack where the return address is. If we used the
POP instruction to get the parameters to the function, the return address might
be lost in the process. This can be avoided using indirect addressing, as in
using 4(%esp) to access the parameters and avoid ESP to be incremented. 

But what if the function itself needs to push data onto the stack, this would
also change the value of ESP and it would throw off the indirect addressing.
Instead what is common practice is to store the current value of ESP (which is
pointing to the return address) in EBP. Then use indirect addressing with EBP
which will not change if the PUSH/POP instructions are used. The calling
(the callee) function might also be using the EBP for the same reason, so we
first PUSH that value onto the stack, decreasing the ESP. So the value of EBP
is first pushed onto the stack and then we store the current ESP value in EBP
to enable indirect addressing.
```
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
```
Resetting the ESP register value ensures that any data placed on the stack
within the function but not cleaned off will be discarded when execution returns
to the main program (otherwise, the RET instruction could return to the wrong
memory location).

Now, since we are using EBP we can place additional data on the stack without
affecting how input parameters values are accessed. 
We can used EBP with indirect addressing to create local variables:
```
          param2            12(%esp)
          param1            8(%esp)
          return address    4(%esp)
    esp ->old EBP           (%esp)
          local var1       -4(%esp)
          local var2       -8(%esp)
          local var3       -12(%esp)
```
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

### NASM
Has pseudo instructions to declare initialized data in the output file.
```
DB (define byte) 1 byte  (8 bits)
DW (define word) 2 bytes (16 bits)
DD               4 bytes (32 bits)
DQ               8 bytes (64 bits)
DT              10 bytes (80 bits)
DO              16 bytes (128 bits)             
DY              32 bytes (256 bits)
DZ              64 bytes (512 bits)
```

To declare uninitialized data, which ends up in the .bss section there are
RESB, RESW, RESW, etc just like for initialized data above.

### Single Instruction Multiple Data (SIMD)
We know we can add two numbers together using the add operator. We can consider
this a Single Instruction Single Data (SISD).
```
int a[] = {0, 1, 2, 3, 4, 5, 6, 7}
int b[] = {0, 1, 2, 3, 4, 5, 6, 7}
int sum = a[1] + b[1] + a[2] + b[2] ...
```
So we want a single instruction to operate on multiple data (the arrays), so an
instruction could be `add a, b`.
And would operate on the entire a and b and sum them.

Think about this situation. We can copy (mov) a value of a specific size to
a memory location:
```asm

```


SIMD computing element performs the same operation on multiple data items
simultaneously.  x86’s first SIMD extension, which is called MMX technology.

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



### Alignment
This section tries to explain the need for memory alignment. Different computer
architectures have different requirements and some might not even be able to
handle unaligned memory accesses, while others might have to perform inefficient
operations to handle them which incurs a performance penaltiy.

So for a word size (2 bytes, 16 bits):
```
Address hex    binary    
0000 0000    0000 0000      Divisable by 2    
0000 0001    0000 0001      Hex values: 0, 4, 8, a, c, e
----------------------      Bin value: least significant bit 0
0000 0002    0000 0010
0000 0003    0000 0011
----------------------
0000 0004    0000 0100
0000 0005    0000 0101
----------------------
0000 0006    0000 0110
0000 0007    0000 0111
----------------------
0000 0008    0000 1000
0000 0009    0000 1001
----------------------
0000 000a    0000 1010
0000 000b    0000 1011
----------------------
0000 000c    0000 1100
0000 000d    0000 1101
----------------------
0000 000e    0000 1110
0000 000f    0000 1111
----------------------
0000 0010    0001 0000
0000 0011    0001 0001
```
So some architectures might crash or handle a memory access inefficiently if
we were to store a value on an unaligned memory address.

Lets say we have data type of double word, which will take up 2 bytes:
```
section .data
  nr dw 10
...

  push rbp
  mov rbp, rsp
  mov ax, [nr]
```
The above example can be found in [align.asm](./nasm/linux/align.asm).
Notice that the instruction is `mov` and it operates on a specific size, the
size of register `ax` is 16 bits which matches our variable `nr` size.

The instruction to read the value will look like this:
```
0x0000000000400544 <+4>:	mov    0x60101c,%ax
``
```console
(gdb) x/x 0x60101c
0x60101c <nr>:	0x0000000a
```
Notice that the address `0x60101c` least significant bit is `c` which we 
saw above means that it is aligned. What if we add a single byte value, 
before it? 
```console
section .data
  dummy db 3
  nr dw 10
```
```console
=> 0x0000000000400544 <+4>:	mov    0x60101d,%ax
(gdb) x/x 0x60101d
0x60101d <nr>:	0x0000000a
```
So we can see that this is no longer aligned.

The CPU always reads using its word size, so on a 64 bit system that would be
word size of 8 bytes.

So `0x60101c` this will be a virtual memory address which will be translated
into a physical address (using page tables, and translation lookaside buffer)
and then the memory controller selects the RAM chip corresponding to that
address.

I've had some trouble actually understanding this alignment requirement when
reading various resources on the internet. Some sound like the CPU is trying to
read a certain data type, like it is actually trying to read 1, 2, 3, or 4 bytes,
but the size of data read is always the size of the data bus. On my system that
would be 8 bytes (64 bits). 64 bits will always read. But the address we put
on the address bus is the start of the memory location that we want to read from
and then a number of following bytes (unless we are only requesting a single byte)
In the case above we are reading one more byte. Now, if it happens that our
address is the last byte of an address row the CPU would have to read another
row and then shift the bits into the value placed on the data bus. But if we
place the value on a starting address that is divisable by the type's size then
the above situation will not happen.
be read but this 

When we want to read the value of this memory location into a register, the
cpu must take the virtual address to look up the physical address. This does
not happen directly but goes through the OS and its page tables and the also
via the hardware's lookaside table (TLB). But I think the main concern here
is that if we place data starting a memory locations that are evenly divisable
by the size of the type we are storing, the types will fit 

The stack pointer must be aligned to a 16-byte boundry before making a call. When
the `call` instructions is executed it will push the return address (value in rip)
onto the stack. This will be 8 bytes that are on the stack after which the stack
is not alligned. We can either subtract 8 bytes from rsp, or we can push rbp which
will also subtract 8 from rsp making it aligned.

Random-access memory (RAM) is a well-known type of memory and is so-called
because of its ability to access any location in memory with roughly the same
time delay.
Dynamic Random Access Memory (DRAM) is a specific type of random access memory
that allows for higher densities at a lower cost. 

The storage cell in DRAM consists of two components, a transistor and a capacitator.
The capacitator leaks and needs to be refreshed which is called dynamic which
is where the `D` comes from.
```
TODO
```

### Load Affective Address (lea)
```console
section .data
  msg db "hello world",0
  fmt db "Using printf to write: %s", 10, 0

section .text
  mov rdi, fmt
  lea rdi, [fmt]
```
The `mov` and the `lea` instruction above are equivalent. lea loads the address
instead of the value, like `&` in c/c++.
```console
(gdb) disassemble 
Dump of assembler code for function main:
   0x00000000004005a0 <+0>:	push   %rbp
   0x00000000004005a1 <+1>:	mov    %rsp,%rbp
   0x00000000004005a4 <+4>:	movabs $0x601030,%rdi
=> 0x00000000004005ae <+14>:	lea    0x601030,%rdi
```

### Global Offset Table (GOT)
Sections starting with `.got` contains tables.

### Proceedure Linkage Table (PLT)


Sections starting with `.plt` contains stubs.

```console
40063f:       e8 fc fe ff ff          callq  400540 <lib_doit@plt>            
```
```console
0000000000400540 <lib_doit@plt>:                                                
  400540:       ff 25 d2 0a 20 00       jmpq   *0x200ad2(%rip)        # 601018 <lib_doit>
  400546:       68 00 00 00 00          pushq  $0x0                             
  40054b:       e9 e0 ff ff ff          jmpq   400530 <.plt>                    
```
So notice that we are jumping to *0x200ad2(%rip) 
```console
$ readelf -r main
Relocation section '.rela.plt' at offset 0x4f8 contains 1 entry:                
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000601018  000400000007 R_X86_64_JUMP_SLO 0000000000000000 lib_doit + 0   
```
R_X86_64_JUMP_SLO is a jump slot type and the offset gives an address in the
PLT where the effective address of the function will be.


### libsample
```console
$ gcc -m64 -no-pie -g -o libsample libsample.c
```
```console
$ readelf --section-headers libsample.o -W
[12] .plt              PROGBITS        00000000004004c0 0004c0 000030 10  AX  0   0 16

[21] .got              PROGBITS        0000000000600fe0 000fe0 000020 08  WA  0   0  8
[22] .got.plt          PROGBITS        0000000000601000 001000 000028 08  WA  0   0  8
```

```console
$ gdb libsample
(gdb) disass main
(gdb) disassemble main
Dump of assembler code for function main:
   0x00000000004005d6 <+0>:	push   %rbp
   0x00000000004005d7 <+1>:	mov    %rsp,%rbp
   0x00000000004005da <+4>:	sub    $0x10,%rsp
   0x00000000004005de <+8>:	mov    %edi,-0x4(%rbp)
   0x00000000004005e1 <+11>:	mov    %rsi,-0x10(%rbp)
   0x00000000004005e5 <+15>:	mov    $0x400698,%edi
   0x00000000004005ea <+20>:	callq  0x4004d0 <puts@plt>
   0x00000000004005ef <+25>:	mov    $0x0,%edi
   0x00000000004005f4 <+30>:	callq  0x4004e0 <exit@plt>
End of assembler dump.
(gdb) break *0x00000000004005ea 
(gdb) si
0x00000000004004d0 in puts@plt ()
(gdb) x/i $pc
=> 0x4004d0 <puts@plt>:	jmpq   *0x200b42(%rip)        # 0x601018 <puts@got.plt>

(gdb) x/dx 0x601018
0x601018 <puts@got.plt>:	0x004004d6
```
So we can see that this will jump to an entry in the .got.plt section.
```console
(gdb) info symbol 0x004004d6
puts@plt + 6 in section .plt of libsample
```

```console
(gdb) disassemble 
Dump of assembler code for function puts@plt:
=> 0x00000000004004d0 <+0>:	jmpq   *0x200b42(%rip)        # 0x601018 <puts@got.plt>
   0x00000000004004d6 <+6>:	pushq  $0x0
   0x00000000004004db <+11>:	jmpq   0x4004c0
End of assembler dump.
```
Lets take a look at what the address of the function in 0x601018 is:
```console
(gdb) x/xg 0x601018
0x601018 <puts@got.plt>:	0x00000000004004d6
```
Notice that the address is the line following the current instruction: 
```console
   0x00000000004004d0 <+0>:	jmpq   *0x200b42(%rip)        # 0x601018 <puts@got.plt>
=> 0x00000000004004d6 <+6>:	pushq  $0x0
   0x00000000004004db <+11>:	jmpq   0x4004c0
```
So, that will be the function(address) that will be jumped to. Later, this entry
will be patched/updated to contain the address of the puts function once it has
been resolved.

Lets step into this function and see what happens
```console
(gdb) si
0x00000000004004d6 in puts@plt ()
(gdb) disassemble 
Dump of assembler code for function puts@plt:
   0x00000000004004d0 <+0>:	jmpq   *0x200b42(%rip)        # 0x601018 <puts@got.plt>
=> 0x00000000004004d6 <+6>:	pushq  $0x0
   0x00000000004004db <+11>:	jmpq   0x4004c0
End of assembler dump.
```
Alright, so we jumped to the next line. 
This is first time this program calls `puts` so there is no entry in the got
for it, it has to be resolved. This is handled by a resolver. First the slot
in the got is pushed onto the stack and then we jump to the resolver code.
```console
=> 0x00000000004004d6 <+6>:	pushq  $0x0
   0x00000000004004db <+11>:	jmpq   0x4004c0
(gdb) si
(gdb) si
(gdb) x/2i $pc
=> 0x4004c0:	pushq  0x200b42(%rip)        # 0x601008
   0x4004c6:	jmpq   *0x200b44(%rip)        # 0x601010
```
So we can see that we are pushing the address 0x601008 onto the stack:
```console
(gdb) info symbol 0x601008
_GLOBAL_OFFSET_TABLE_ + 8 in section .got.plt of libsample
````
So this is an entry in the global offset table.
Then we jump to `0x601010`:
```console
(gdb) x/wg 0x601010
0x601010:	0x00007ffff7dea140
(gdb) si
(gdb) si
0x00007ffff7dea140 in _dl_runtime_resolve_xsavec () from /lib64/ld-linux-x86-64.so.2
(gdb) disassemble
Dump of assembler code for function _dl_runtime_resolve_xsavec:
=> 0x00007ffff7dea140 <+0>:	endbr64 
   0x00007ffff7dea144 <+4>:	push   %rbx
   0x00007ffff7dea145 <+5>:	mov    %rsp,%rbx
   0x00007ffff7dea148 <+8>:	and    $0xffffffffffffffc0,%rsp
   0x00007ffff7dea14c <+12>:	sub    0x2125f5(%rip),%rsp        # 0x7ffff7ffc748 <_rtld_local_ro+168>
   0x00007ffff7dea153 <+19>:	mov    %rax,(%rsp)
   0x00007ffff7dea157 <+23>:	mov    %rcx,0x8(%rsp)
   0x00007ffff7dea15c <+28>:	mov    %rdx,0x10(%rsp)
   0x00007ffff7dea161 <+33>:	mov    %rsi,0x18(%rsp)
   0x00007ffff7dea166 <+38>:	mov    %rdi,0x20(%rsp)
   0x00007ffff7dea16b <+43>:	mov    %r8,0x28(%rsp)
   0x00007ffff7dea170 <+48>:	mov    %r9,0x30(%rsp)
   0x00007ffff7dea175 <+53>:	mov    $0xee,%eax
   0x00007ffff7dea17a <+58>:	xor    %edx,%edx
   0x00007ffff7dea17c <+60>:	mov    %rdx,0x250(%rsp)
   0x00007ffff7dea184 <+68>:	mov    %rdx,0x258(%rsp)
   0x00007ffff7dea18c <+76>:	mov    %rdx,0x260(%rsp)
   0x00007ffff7dea194 <+84>:	mov    %rdx,0x268(%rsp)
   0x00007ffff7dea19c <+92>:	mov    %rdx,0x270(%rsp)
   0x00007ffff7dea1a4 <+100>:	mov    %rdx,0x278(%rsp)
   0x00007ffff7dea1ac <+108>:	xsavec 0x40(%rsp)
   0x00007ffff7dea1b1 <+113>:	mov    0x10(%rbx),%rsi
   0x00007ffff7dea1b5 <+117>:	mov    0x8(%rbx),%rdi
   0x00007ffff7dea1b9 <+121>:	callq  0x7ffff7de33b0 <_dl_fixup>
   0x00007ffff7dea1be <+126>:	mov    %rax,%r11
   0x00007ffff7dea1c1 <+129>:	mov    $0xee,%eax
   0x00007ffff7dea1c6 <+134>:	xor    %edx,%edx
   0x00007ffff7dea1c8 <+136>:	xrstor 0x40(%rsp)
   0x00007ffff7dea1cd <+141>:	mov    0x30(%rsp),%r9
   0x00007ffff7dea1d2 <+146>:	mov    0x28(%rsp),%r8
   0x00007ffff7dea1d7 <+151>:	mov    0x20(%rsp),%rdi
   0x00007ffff7dea1dc <+156>:	mov    0x18(%rsp),%rsi
   0x00007ffff7dea1e1 <+161>:	mov    0x10(%rsp),%rdx
   0x00007ffff7dea1e6 <+166>:	mov    0x8(%rsp),%rcx
   0x00007ffff7dea1eb <+171>:	mov    (%rsp),%rax
   0x00007ffff7dea1ef <+175>:	mov    %rbx,%rsp
   0x00007ffff7dea1f2 <+178>:	mov    (%rsp),%rbx
   0x00007ffff7dea1f6 <+182>:	add    $0x18,%rsp
   0x00007ffff7dea1fa <+186>:	bnd jmpq *%r11
End of assembler dump.
```
[_dl_runtime_resolve_xsavec](https://github.molgen.mpg.de/git-mirror/glibc/blob/master/sysdeps/x86_64/dl-trampoline.h) is where I think this code if coming from. 
TODO: figure out how this works.
Remember that we pushed `0x601008` onto the stack
```console
(gdb) x/wg 0x601008
0x601008:	0x00007ffff7ffe150
(gdb) x/wg $rsp
0x7fffffffd4b8:	0x00007ffff7ffe150
```

The `endbr64` instruction is used for branch protection. TOOD: add section about
this.


byte             8   bits    char 
word             16  bits    short
double word      32  bits    int/long
quad word        64  bits    double/long long
double quad word 128 bits    

x86_64 is because Intel has had a number of chips like 8086, 80186, 80286, 80386
etc.  So this is just a naming convention.

A single hexadecimal character is essentially a nibble (4 bits)
0000  0x0
0001  0x1
0010  0x2
0011  0x3
0100  0x4
0101  0x5
0110  0x6
0111  0x7
1000  0x8
1001  0x9
1010  0xa
1011  0xb
1100  0xc
1101  0xd
1110  0xe
1111  0xf

Upon entering a function the topmost entry in the stack will be the return
address
```console
10    +----------+  
      | ret addr |
08    +----------+
      | [rbp]    | the base pointer of the previous function
06    +----------+ <-- rsp <-- rbp (after moving the current rsp into it
      |          |
04    +----------+
      |          |
02    +----------+
      |          |
00    +----------+
```

Now, if we push two local variable it would be pushed onto the stack and rsp
would be incremented:
```console
10    +----------+  
      | ret addr |
08    +----------+
      | [rbp]    | the base pointer of the previous function
06    +----------+ <-- rbp (after moving the current rsp into it
      |    5     |
04    +----------+ 
      |    6     |
02    +----------+ <-- rsp
      |          |
00    +----------+
```
Now, we can see that if we want to refer to the local variable containing 6 we
can use rbp-4.
If we wanted to inspect the return address that would be rbp+4.
I'm just trying to build some intuition around how the stack is organized as I
still find I have stop and think about this when reading assembly code.


### stackover flow
```console
$ gcc -g -o stacko stackoverflow
```

Just a note about this example and trying this out. We need to invoke the
program in the same way in both the terminal and from gdb. Things like environ
variable differences, and the path of the executable will affect the addresses
in the running program. 

The environment can be unset using:
```console
$ env - ./stacko bajja
```
And when using gdb:
```consle
$ env - gdb --args
(gdb) show env
(gdb) show env
LINES=48
COLUMNS=94
(gdb) unset env LINES
(gdb) unset env COLUMNS
```


Lets go over generated assembly code to fully understand what is happening:
```console
$ gdb --args stacko bajja
(gdb)  disassemble main
Dump of assembler code for function main:
   0x000000000040060e <+0>:	push   %rbp
   0x000000000040060f <+1>:	mov    %rsp,%rbp
   0x0000000000400612 <+4>:	sub    $0x10,%rsp
   0x0000000000400616 <+8>:	mov    %edi,-0x4(%rbp)
   0x0000000000400619 <+11>:	mov    %rsi,-0x10(%rbp)
=> 0x000000000040061d <+15>:	mov    -0x10(%rbp),%rax
   0x0000000000400621 <+19>:	add    $0x8,%rax
   0x0000000000400625 <+23>:	mov    (%rax),%rax
   0x0000000000400628 <+26>:	mov    %rax,%rdi
   0x000000000040062b <+29>:	callq  0x4005d6 <func>
   0x0000000000400630 <+34>:	mov    $0x0,%eax
   0x0000000000400635 <+39>:	leaveq
   0x0000000000400636 <+40>:	retq
```
First we have the prolouge which I think we understand by now.

```assembly
  sub    $0x10,%rsp
```
This subtracting rsp by 16 making room for local variables.

```assembly
  mov    %edi, -0x4(%rbp)
```
Notice that this is edi, so this is moving a word (16 bits) from edi into
the local variable.
```console
(gdb) x/xw $rbp-4
   0x7fffffffd3ec:	0x00000002
```
So edi contained the number of arguments. Note that I started this
with `gdb --args stacko bajja`.`
This will move the contents of edi into the local variables on the stack.
```assembly
   mov    %rsi, -0x10(%rbp)
```
Remember that ths size of the register in this case is a quad word/giant
word which is 64 bits. And also note that 10 is 16 in dec which we will use
below:
```console
(gdb) x/xg $rbp-16
  0x7fffffffd3e0:	0x00007fffffffd4d8
(gdb) x/xg 0x00007fffffffd4d8
  0x7fffffffd4d8:	0x00007fffffffd865
(gdb) x/b 0x00007fffffffd865
  0x7fffffffd865:	"/home/dbeveniu/work/assembler/learning-assembly/nasm/linux/stacko"
```
So we can see that this is the char** and the first pointer is the name of the
executable. We should also be able to see the argument we passed:
```console
(gdb) x/xg 0x00007fffffffd4d8+8
  0x7fffffffd4e0:	0x00007fffffffd8a7
(gdb) x/s 0x00007fffffffd8a7
  0x7fffffffd8a7:	"bajja"
```

```assembly
  mov    -0x10(%rbp),%rax
```
This is argv that we are copying into the rax register.
```assembly
  add    $0x8,%rax
```
This is adding to the value in rax so that is is pointing to the second 
char* in argv:
```console
(gdb) x/xg $rbp - 16
    0x7fffffffd3e0:	0x00007fffffffd4d8
(gdb) x/xg 0x00007fffffffd4d8
    0x7fffffffd4d8:	0x00007fffffffd865
(gdb) x/xg 0x00007fffffffd4d8 + 8
    0x7fffffffd4e0:	0x00007fffffffd8a7
(gdb) x/s 0x00007fffffffd8a7
    0x7fffffffd8a7:	"bajja"
```
```assembly
  mov    (%rax),%rax
```
This is moving the value contained in rax into rax, it is dereferencing 
the pointer and placing the address to the value in rax.
```console
(gdb) i r rax
    rax            0x7fffffffd8a7      140737488345255
(gdb) x/s 0x7fffffffd8a7
    0x7fffffffd8a7:	"bajja"
```
```assembly
  mov    %rax,%rdi
```
Remember that rdi is used as the register for first arguments so we copy
rax into rdi.

After this we have the `callq` instruction which will call `func`.
```console
(gdb) br *0x00000000004005da
```
Notice the `*` that we use to set a break point on an address.

```console
(gdb) si
   Dump of assembler code for function func:
   0x00000000004005d6 <+0>:	push   %rbp
   0x00000000004005d7 <+1>:	mov    %rsp,%rbp
=> 0x00000000004005da <+4>:	add    $0xffffffffffffff80,%rsp
```
0xffffffffffffff80 is -128 in hex, so this is making room for 128 bytes of
local variables.
So after this instruction rsp will have been subtracted by 128 bytes.
```
0x7fffffffd4b0  - 128 = 0x7fffffffd430 
140737488344240 - 128 = 140737488344112
```
At the moment there is only garbage in this space but lets list it so we know
how:
```console
(gdb) x/130b $rsp
0x7fffffffd430:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd438:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd440:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd448:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd450:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd458:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd460:	0x09	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd468:	0xff	0xb5	0xf0	0x00	0x00	0x00	0x00	0x00
0x7fffffffd470:	0xc2	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd478:	0xa6	0xd4	0xff	0xff	0xff	0x7f	0x00	0x00
0x7fffffffd480:	0x01	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd488:	0x85	0x4a	0xab	0xf7	0xff	0x7f	0x00	0x00
0x7fffffffd490:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd498:	0x8d	0x06	0x40	0x00	0x00	0x00	0x00	0x00
0x7fffffffd4a0:	0x00	0x3f	0xde	0xf7	0xff	0x7f	0x00	0x00
0x7fffffffd4a8:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd4b0:	0xd0	0xd4
```
We are using 130 as the length just so that we can see that we are showing all
bytes from the current rsp (0x7fffffffd430) to the old rsp (0x7fffffffd4b0).

```assembly
  mov    %rdi,-0x78(%rbp)
```
Now, rpb is `0x7fffffffd4b0` which is the value of the old rsp which makes sense.
And we can see that if we subtract 120 from rp
140737488344240 - 120 = 140737488344120 (hex 7FFFFFFFD438)
So after that instruction we can see the stack again
```console
  0x7fffffffd430:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
+→0x7fffffffd438:	0x75	0xd9	0xff	0xff	0xff	0x7f	0x00	0x00
| 0x7fffffffd440:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd448:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd450:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd458:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd460:	0x09	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd468:	0xff	0xb5	0xf0	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd470:	0xc2	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd478:	0xa6	0xd4	0xff	0xff	0xff	0x7f	0x00	0x00
| 0x7fffffffd480:	0x01	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd488:	0x85	0x4a	0xab	0xf7	0xff	0x7f	0x00	0x00
| 0x7fffffffd490:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd498:	0x8d	0x06	0x40	0x00	0x00	0x00	0x00	0x00
| 0x7fffffffd4a0:	0x00	0x3f	0xde	0xf7	0xff	0x7f	0x00	0x00
| 0x7fffffffd4a8:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
+-0x7fffffffd4b0:	0xd0	0xd4
```
And we can read that location using:
```console
(gdb) x/xg 0x7fffffffd438
0x7fffffffd438:	0x00007fffffffd975
(gdb) x/s 0x00007fffffffd975
0x7fffffffd975:	"bajja"
```
So we can see that we have placed a pointer to `bajja` onto that stack location.

```assembly
  mov    -0x78(%rbp),%rdx
```
So now we copy that value into rdx.

```assembly
  lea    -0x70(%rbp),%rax
```
And then we store the address in rax.
```console
(gdb) i r rax
  rax            0x7fffffffd360      140737488343904
```
```assembly
  mov %rax, %rdi    this is the first argument to strcpy  (dst)
  mov %rdx, %rsi    this is the second argument to strcpy (src)
```
Just recall the the signature of `strcpy` is :
```c
  char *strcpy(char* dest, const char* src);
```
Next, we have our call to strcpy which is using the plt which we've gone through
above.
```assembly
  callq  0x4004d0 <strcpy@plt>
```

Now, lets change the argument to the program from `bajja` to a few longer strings
and try to overwrite the return address on the stack.
```console
$ env - gdb --args stacko $(python3 -c 'print("\x41" * 100 + "\x42" * 8 + "\x43" * 8)')
(gdb) unset env LINES
(gdb) unset env COLUMNS
```

Now, we need to look at what happens in this case...

When we perform 
```console
  mov %rdi,-0x78(%rbp)
```

```console
(gdb) x/b $rbp - 120
0x7fffffffd3c8:	0x0e
```
And we can dereference this using:
```console
(gdb) x/xg 0x7fffffffd3c8
0x7fffffffd3c8:	0x00007fffffffd90e
(gdb) x/s 0x00007fffffffd90e
0x7fffffffd90e:	'A' <repeats 100 times>, "BBBBCCCC"
```

So the second argument to strcpy which is the source to copy from:
```console
(gdb) x/s $rsi
0x7fffffffd90e:	'A' <repeats 100 times>, "BBBBCCCC"
```
And rdi, the first argument which is the destination of the copy:
```console
(gdb) i r $rdi
rdi            0x7fffffffd3d0      140737488344016
```
Lets see where this address is:
```console
(gdb) x/130x $rsp
0x7fffffffd3c0:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd3c8:	0x0e	0xd9	0xff	0xff	0xff	0x7f	0x00	0x00
0x7fffffffd3d0:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x7fffffffd3d8:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
```
Notice this is on the stack, just after the address (pointer) to the string
to copy.

Lets find the return address, which remember is on the stack. This is the 
value we want to overwrite.
If we disassemble main we can see that the address of the instruction following
the call to `func`:
```console
(gdb) disassemble main
Dump of assembler code for function main:
   0x000000000040060e <+0>:	push   %rbp
   0x000000000040060f <+1>:	mov    %rsp,%rbp
   0x0000000000400612 <+4>:	sub    $0x10,%rsp
   0x0000000000400616 <+8>:	mov    %edi,-0x4(%rbp)
   0x0000000000400619 <+11>:	mov    %rsi,-0x10(%rbp)
   0x000000000040061d <+15>:	mov    -0x10(%rbp),%rax
   0x0000000000400621 <+19>:	add    $0x8,%rax
   0x0000000000400625 <+23>:	mov    (%rax),%rax
   0x0000000000400628 <+26>:	mov    %rax,%rdi
   0x000000000040062b <+29>:	callq  0x4005d6 <func>
   0x0000000000400630 <+34>:	mov    $0x0,%eax
   0x0000000000400635 <+39>:	leaveq 
   0x0000000000400636 <+40>:	retq   
End of assembler dump.
```
`0x0000000000400630` is that address. And we can get to the arguments to our
function using rbp:
```console
(gdb) x/2xg $rbp
0x7fffffffec30:	0x00007fffffffec50	0x0000000000400630
```

### jumps
Note that when you have a label you need to use `disassemble label` to see
the code. If you just disassemble main you will not see the code.


### GDB
Run make and reload file from inside gdb:
```console
(gdb) make jnz
(gdb) r
```

Run shell command:
```console
(gdb) !ls
```

Break on the first instruction:
```console
(gdb) starti
```

Break on _start:
```console
(gdb) b _start
```
This is really just breaking on a label.

### Memory

#### AND-OR Latch
```
     +---+       +---+
-----|OR |-------|AND|-------*---- output
     +---+       +---+
          +---+
----------|NOT|
          +---+
```
#### Half adder


### Time Stamp Counter
The `rdtsc` instruction returns the Time Stamp Count (TSC) in EDX:EAX.


### Call Frame Information (cfi)                                                
This is a GNU AS extension to manage call frames. I some cases a function
prologue and epilog are added to the functions stack. In these cases a debugger
, or exception handling, or perhaps a performance tool will be able to unwind
stack frames, that is be able to find where the call frame for the current
function is, and also be able to go up/down the call stack.

There are cases when a function prologue/epilog may not be desirable, for small
functions it might be a performance cost, or code could be compiled with
`-fomit-frame-pointer`.
The compiler generates table to help with this when the prologue/epilog don't
exist. There can be sections for this named, '.eh_frame` which is the table
used for exception handling, `.debug_frame`. These tables are called call frame
information tables.

Canonical Frame Address(CFA) is the value of the pointer just before the `call`
instruction in the parent frame/function. We need to be able to calculate the
CFA for every instruction.

Upon entering a function the CFA is $rsp + 8, since the call instruction pushed
the return address (the value in $rip) onto the stack. This works when entering
the function but as things are pushed/poped onto/off the stack rsp changes.
So the CFA is a pair, register and an offset.

Lets take a simple example to understand how this works.

```console
$ gcc -S -o simple.s -g simple.c
```
So since we are using gcc it will be the GNU assembler that will be used so
the output will be in that format.

```
        .file   "simple.c"
        .text
        .globl  main
        .type   main, @function
main:
.LFB0:
        .cfi_startproc
        pushq   %rbp
        .cfi_def_cfa_offset 16
        .cfi_offset 6, -16
        movq    %rsp, %rbp
        .cfi_def_cfa_register 6
        movl    %edi, -4(%rbp)
        movq    %rsi, -16(%rbp)
        movl    $0, %eax
        popq    %rbp
        .cfi_def_cfa 7, 8
        ret
        .cfi_endproc
.LFE0:
        .size   main, .-main
        .ident  "GCC: (GNU) 8.2.1 20180905 (Red Hat 8.2.1-3)"
        .section        .note.GNU-stack,"",@progbits
```
A local label is any symbol beginning with a certain local label prefix.
For ELF systems the prefix is `.L`. We can see above that we have local labels
named `.LFB0`

`.cfi_startproc` is used in the beginning of each function that should have
a new CFI table.

```
        pushq   %rbp
        .cfi_def_cfa_offset 16
```                                                                             
`cfi_def_cfa_offset` modifies a rule for computing CFA. Register remains the
same, but offset is new. Is the default `rsp`?  I've found information that
says that $rsp + 8 is the default so I'm going to assume that `rsp` is the default
register which makes sense to me.

The call frame is identified by an address on the stack. We refer to this          
address as the Canonical Frame Address or CFA. In our case the return address was
pushed by the caller and we have now pushed rbp so that means 8+8 bytes (16 above)
has changed the.

Next we have:
```
        .cfi_offset 6, -16
```
This is creating an entry that the register $rbp (see register number mapping
below) at the offset -16 (it was just pushed onto the stack).

Next, we have:
```
        movq    %rsp, %rbp
        .cfi_def_cfa_register 6
```
`cfi_def_cfa_register` will make the register used for CFA register 6 (rbp) 
from now on.

```
        ...
        popq    %rbp
        .cfi_def_cfa 7, 8
```
Notice that we pop rbp and then we set CFA to use register 7 (rsp) and offset
8 from now on.

And finally we have:
```
        ret
        .cfi_endproc
```
If we forget to specify `.cfi_endproc` the following error will be displayed:
```console
$ make cfi
as -g -o cfi.o cfi.s
cfi.s: Assembler messages:
cfi.s: Error: open CFI at the end of file; missing .cfi_endproc directive
make: *** [Makefile:20: cfi.o] Error 1
```
And here we have the instruction to have the table emitted.

We can inspect the tables using:
```console
$ objdump -W simple
```

Register number mapping:
```
$rax		0
$rdx		1
$rcx		2
$rbx		3
$rsi		4
$rdi		5
$rbp		6
$rsp		7
$r8-$r15	8-15
```

### Near/Far jumps
A near jump is where a jump/call is relative to the current segment, that is
it stays inside of the current segment. You just write jmp address

When you do a far jump you specify the jmp segment:address


## CPU Hardware
This section aims to look into how the cpu actually works and what tools
are available to log what is going on inside the processor (x86_64).

### lscpu
Get information about the cpu.
```console
$ lscpu 
Architecture:                    x86_64
CPU op-mode(s):                  32-bit, 64-bit
Byte Order:                      Little Endian
Address sizes:                   39 bits physical, 48 bits virtual
CPU(s):                          8
On-line CPU(s) list:             0-7
Thread(s) per core:              2
Core(s) per socket:              4
Socket(s):                       1
NUMA node(s):                    1
Vendor ID:                       GenuineIntel
CPU family:                      6
Model:                           142
Model name:                      Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz
Stepping:                        10
CPU MHz:                         800.116
CPU max MHz:                     4200.0000
CPU min MHz:                     400.0000
BogoMIPS:                        4199.88
Virtualization:                  VT-x
L1d cache:                       128 KiB
L1i cache:                       128 KiB
L2 cache:                        1 MiB
L3 cache:                        8 MiB
NUMA node0 CPU(s):               0-7
Vulnerability Itlb multihit:     KVM: Mitigation: Split huge pages
Vulnerability L1tf:              Mitigation; PTE Inversion; VMX conditional cache flushes, SMT vulnerable
Vulnerability Mds:               Mitigation; Clear CPU buffers; SMT vulnerable
Vulnerability Meltdown:          Mitigation; PTI
Vulnerability Spec store bypass: Mitigation; Speculative Store Bypass disabled via prctl and seccomp
Vulnerability Spectre v1:        Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerability Spectre v2:        Mitigation; Full generic retpoline, IBPB conditional, IBRS_FW, STIBP conditional, RSB filling
Vulnerability Tsx async abort:   Mitigation; Clear CPU buffers; SMT vulnerable
Flags:                           fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse s
                                 se2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtop
                                 ology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma c
                                 x16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_
                                 lm abm 3dnowprefetch cpuid_fault epb invpcid_single pti ssbd ibrs ibpb stibp tpr_shadow vnmi flexpriori
                                 ty ept vpid ept_ad fsgsbase tsc_adjust bmi1 hle avx2 smep bmi2 erms invpcid rtm mpx rdseed adx smap clf
                                 lushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window h
                                 wp_epp md_clear flush_l1d
```
So I have one socket, and it has 4 cpu chips (cores) on this single socket.
A core is the processing unit that reads and executes instructions. Intel
introduced hyper threading which enables each core to have two threads instead
of one to enable the core to be able to process . 
To the operating system it will look like my machine has 8 cores/cpus but there
are only 4 actual cores in the socket and the OS schedular will be able to
process tasks on any of these. Hyperthreading increases the amount of independent
instructions in the pipeline. So there is no difference in how these logical/
virtual cores operate, the OS will just treat them as normal physical cores.

To get information about the caches:
```console
$ lscpu --caches
NAME ONE-SIZE ALL-SIZE WAYS TYPE        LEVEL
L1d       32K     128K    8 Data            1
L1i       32K     128K    8 Instruction     1
L2       256K       1M    4 Unified         2
L3         8M       8M   16 Unified         3
```

### lstopo
```console
$ sudo dnf install -y hwloc hwloc-libs hwloc-gui
```

```console
$ lstopo --no-io
```

Then we can use lstop-no-graphics to see details:
```console
$ lstopo-no-graphics
Machine (31GB total)
  Package L#0
    NUMANode L#0 (P#0 31GB)
    L3 L#0 (8192KB)
      L2 L#0 (256KB) + L1d L#0 (32KB) + L1i L#0 (32KB) + Core L#0
        PU L#0 (P#0)
        PU L#1 (P#4)
      L2 L#1 (256KB) + L1d L#1 (32KB) + L1i L#1 (32KB) + Core L#1
        PU L#2 (P#1)
        PU L#3 (P#5)
      L2 L#2 (256KB) + L1d L#2 (32KB) + L1i L#2 (32KB) + Core L#2
        PU L#4 (P#2)
        PU L#5 (P#6)
      L2 L#3 (256KB) + L1d L#3 (32KB) + L1i L#3 (32KB) + Core L#3
        PU L#6 (P#3)
        PU L#7 (P#7)
  HostBridge
    PCI 00:02.0 (VGA)
    PCIBridge
      PCI 04:00.0 (Network)
        Net "wlp4s0"
    PCIBridge
      PCI 40:00.0 (NVMExp)
        Block(Disk) "nvme0n1"
    PCI 00:1f.6 (Ethernet)
      Net "enp0s31f6"
```

### perf
TODO: add notes
```console
$ perf stat ./cfi
cfi example

 Performance counter stats for './cfi':

              0.07 msec task-clock:u              #    0.116 CPUs utilized
                 0      context-switches:u        #    0.000 K/sec
                 0      cpu-migrations:u          #    0.000 K/sec
                 1      page-faults:u             #    0.015 M/sec
             2,452      cycles:u                  #    0.036 GHz
                11      instructions:u            #    0.00  insn per cycle
                 3      branches:u                #    0.044 M/sec
                 0      branch-misses:u           #    0.00% of all branches

       0.000582347 seconds time elapsed

       0.000659000 seconds user
       0.000000000 seconds sys
```

### CPU Caches
There are different types of caches, for data, for instructions, the
translation lookaside buffer (tlb) etc.


Below is a rough latencies in clockcycles that different caches have:
```
Register 0
L1 Cache 3  (per core)
L2 Cache 9  (per core)
L3 Cache 21 (shared with all cores)
Main memory 150-400
```

Recall that data is moved in sizes of cache lines. To get the size of caches:
```console
$ getconf -a | grep CACHE
LEVEL1_ICACHE_SIZE                 32768
LEVEL1_ICACHE_ASSOC                8
LEVEL1_ICACHE_LINESIZE             64
LEVEL1_DCACHE_SIZE                 32768
LEVEL1_DCACHE_ASSOC                8
LEVEL1_DCACHE_LINESIZE             64
LEVEL2_CACHE_SIZE                  262144
LEVEL2_CACHE_ASSOC                 4
LEVEL2_CACHE_LINESIZE              64
LEVEL3_CACHE_SIZE                  8388608
LEVEL3_CACHE_ASSOC                 16
LEVEL3_CACHE_LINESIZE              64
LEVEL4_CACHE_SIZE                  0
LEVEL4_CACHE_ASSOC                 0
LEVEL4_CACHE_LINESIZE              0
```
And notice that there is a L1 instruction cache and an L1 data cache both which
are of size 32 KB. 
And also notice that the L2 cache is for both instructions and data which is
also true for the L3 cache. The L2 cache size is 2MB and L3 8MB.

So we can see that the L1 cache line size is 64 bytes which is 512 bits and
if we are storing 32 bit values that would mean 16 entries (512/32)
```
[0000 0000 0000 0000] 0
[0000 0000 0000 0000] 1
[   ...             ]
[0000 0000 0000 0000] 15
```
This is mainly to get a feel for how much/many data/instructions we can fetched
each time. 
And if we are storing 64 bit values we would only be able to store 8 entries.

When thinking about instructions and cache keep in mind that the instructions
are also stored and retreived from main memory. The will be fetched one
cache line at a time. So if our code is just linear and only contains jumps
that are in that same cache line things will be efficient. But if there are
jumps outside of the cache line the instructions specified in the jump
instruction must be fetched. So we want to keep the jumps local or avoid them
if possible.

When accessing data the hardware will speculatively fetch the next or previous
cache line from memory so if we are traversing sequentially over an array the
next data element will almost always already be in the cache (prefetched).
This holds for both instruction and data access. It actually does not have to
be accessing every single element as long as there is some predictability, like
every second, or every third for example this will also hold true (predictable
stride).


Now we have to remember that the L1 and L2 are local to each core, and the
L3 cache is shared between all cores:
```
                                                                 +-------------+
                                                +-----------+    | Main Memory |
+-------------------------------------------+   | L3 cache  |    |             |
| Core 0  +----------+      +----------+    |   |           |    |             |
| T0      |L1 I cache|      | L2 cache |    |   |           |    |             |
|         +----------+      |          |    |   |           |    |             |
| T1      |L1 D cache|      |          |    |   |           |    |             |
|         +----------+      +----------+    |   |           |    |             |
+-------------------------------------------+   |           |    |             |
                                                |           |    |             |
                                                |           |    |             |
+-------------------------------------------+   |           |    |             |
| Core 1  +----------+      +----------+    |   |           |    |             |
| T0      |L1 I cache|      | L2 cache |    |   |           |    |             |
|         +----------+      |          |    |   |           |    |             |
| T1      |L1 D cache|      |          |    |   |           |    |             |
|         +----------+      +----------+    |   |           |    |             |
+-------------------------------------------+   |           |    |             |
                                                +-----------+    |             |
                                                                 +-------------+
```

Each core has two thread which are named T0/T1 above. So to the computer it will
look like there are 4 cores available to this system. And each core is what
has an instruction pipeline which can process instructions that use data. 
Now, imaging that T0 is working on a piece of data, which means that the
cache line that contains this data will be in L1 cache. Now, say that T1 in
Core 1 is working on another piece of data that happens to be close to the
piece of data that L0 is working on. This would mean that both Core 0 and
Core 1 have the same cache line loaded into its cache. Even though they are not
working on the exact same piece of data they will still need to the cache lines
to synchronized. This is called false sharing.
But if we can make sure they don't work on the same cache line this would not be
needed.
So how this works is when a write happens to the cache line the hardware will
invalidate Core 1's cache line by marking the cache line as dirty in all of
the other caches (L1, L2, L3, L4). What this means is that the cache line need
to be read from main memory by Core 1 to get the new value which takes time. Now
if Core 1 also updates/writes to the piece of data it is working on this will
invalidate the cache line for Core 0. This could make things very slow if this
continues back and forth.

Keep in mind that the caches are just static ram and have memory addresses as
well just like dynamic main memory.
When space is needed from L1, the cache line will be moved into L2 which is
called eviction. L2 might also need more space in which case it an evict into
L3 and so on.

Now, simply searching through the entire L1 cache to find which cache line
a memory address belongs to would take too much time. Instead, information
is used from the memory address to speed this up.
The memory address is split into three parts:
```
63             6+S         6 5       0
 +--------------+----------+----------+
 |     Tag      | Set      |  Offset  |
 +--------------+----------+----------+
   64-6-S bits    S bits      6 bits
```
A cache line of size 64 (2⁶=64) will have 6 bits offset.
Offset is an offset into the cache line.

The Set bits (S) will specify the cache set which is a slice or range of the
caches memory. In this range there are different "ways".
2⁵ = 32, 32*1024=32768, 
```
L1 will have 8 ways.
L2 will have 8 ways.
L3 will have 12 ways.
```

Lets use a small system to try to visualize this...
Our system will have 256 bytes of RAM main memory (16 x 16 = 256 bytes of RAM).
The address size will be 8 bits (255 = 1111 1111 (8 bits to address 0-256 memory
locations).
So our addresses in this system will be 8 bits long and each entry will be one
byte. And the cache line size is 4.

2 bits identify the set so that means we have 00, 01, 10, and 11, so 4 sets,
256/4=64, so each set is 64 bytes, and there are 16 cache lines per set:
```
   Main Memory (16x16=256 bytes of RAM)
  +------0--------+-------1-------+-------2-------+-------3-------+-------4-------+-------5-------+-------6-------+-------7-------+-------8-------+-------9-------+------10-------+------11-------+------12-------+------13-------+------14-------+------15-------+
  |  0|  1|  2|  3|  4|  5|  6|  7|  8|  9| 10| 11| 12| 13| 14| 15| 16| 17| 18| 19| 20| 21| 22| 23| 24| 25| 26| 27| 28| 29| 30| 31| 32| 33| 34| 35| 36| 37| 38| 39| 40| 41| 42| 43| 44| 45| 46| 47| 48| 49| 50| 51| 52| 43| 54| 55| 56| 57| 58| 59| 60| 61| 62| 63|
00|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  | 64| 65| 66| 67| 68| 69| 70| 71| 72| 73| 74| 75| 76| 77| 78| 79| 80| 81| 82| 83| 84| 85| 86| 87| 88| 89| 90| 91| 92| 93| 94| 95| 96| 97| 98| 99|100|101|102|103|104|105|106|107|108|109|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|
01|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  |128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|
10|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  |192|193|194|195|196|197|198|199|200|201|202|203|204|205|206|207|208|209|210|211|212|213|214|215|216|217|218|219|220|221|222|223|224|225|226|227|228|229|230|231|232|233|234|235|236|237|238|239|240|241|242|243|244|245|246|247|248|249|250|251|252|253|254|255|
11|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
```
The above is supposed to show our main memory, the top numbers are the cache
lines which are 16 per set. When we read or write we do so in units of cache
lines. The offset part of the address is then used to identify the individual
byte that the address is pointing to.

So lets take a look at the following address and see where it would be located:
```
Address: C1   Binary: 1100001

Address format: [Tag Set Offset]
Tag = 1100 (Hex C, Dec 12)  position: 4*12=48
Set = 00 
Offset = 01 (column in the cache line)
Cache line: 0 * 64 + 4 * 12 = 48


   Main Memory (16x16=256 bytes of RAM)

  +------0--------+-------1-------+-------2-------+-------3-------+-------4-------+-------5-------+-------6-------+-------7-------+-------8-------+-------9-------+------10-------+------11-------+------12-------+------13-------+------14-------+------15-------+
  |  0|  1|  2|  3|  4|  5|  6|  7|  8|  9| 10| 11| 12| 13| 14| 15| 16| 17| 18| 19| 20| 21| 22| 23| 24| 25| 26| 27| 28| 29| 30| 31| 32| 33| 34| 35| 36| 37| 38| 39| 40| 41| 42| 43| 44| 45| 46| 47| 48| 49| 50| 51| 52| 43| 54| 55| 56| 57| 58| 59| 60| 61| 62| 63|
00|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   | 3 | 6 | 9 | 7 |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  | 64| 65| 66| 67| 68| 69| 70| 71| 72| 73| 74| 75| 76| 77| 78| 79| 80| 81| 82| 83| 84| 85| 86| 87| 88| 89| 90| 91| 92| 93| 94| 95| 96| 97| 98| 99|100|101|102|103|104|105|106|107|108|109|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|
01|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  |128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|
10|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  |192|193|194|195|196|197|198|199|200|201|202|203|204|205|206|207|208|209|210|211|212|213|214|215|216|217|218|219|220|221|222|223|224|225|226|227|228|229|230|231|232|233|234|235|236|237|238|239|240|241|242|243|244|245|246|247|248|249|250|251|252|253|254|255|
11|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+

              offset (01)
               ↓
Cache line: [3 6 9 7]
Data for address C1: 6
```

And lets take a second example where the data is in a different set:
```
Address: FF Binary 1111 1111
Tag = 1111 (Hex F, Dec 15) (row)
Set = 11 3 (@)
Offset = 11 (3 which is the column in that cache line)
Cache line: 3 * 64 + 4 * 15 = 192 + 60 = 252

   Main Memory (16x16=256 bytes of RAM)
  +------0--------+-------1-------+-------2-------+-------3-------+-------4-------+-------5-------+-------6-------+-------7-------+-------8-------+-------9-------+------10-------+------11-------+------12-------+------13-------+------14-------+------15-------+
  |  0|  1|  2|  3|  4|  5|  6|  7|  8|  9| 10| 11| 12| 13| 14| 15| 16| 17| 18| 19| 20| 21| 22| 23| 24| 25| 26| 27| 28| 29| 30| 31| 32| 33| 34| 35| 36| 37| 38| 39| 40| 41| 42| 43| 44| 45| 46| 47| 48| 49| 50| 51| 52| 43| 54| 55| 56| 57| 58| 59| 60| 61| 62| 63|
00|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  | 64| 65| 66| 67| 68| 69| 70| 71| 72| 73| 74| 75| 76| 77| 78| 79| 80| 81| 82| 83| 84| 85| 86| 87| 88| 89| 90| 91| 92| 93| 94| 95| 96| 97| 98| 99|100|101|102|103|104|105|106|107|108|109|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|
01|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  |128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|
10|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  |192|193|194|195|196|197|198|199|200|201|202|203|204|205|206|207|208|209|210|211|212|213|214|215|216|217|218|219|220|221|222|223|224|225|226|227|228|229|230|231|232|233|234|235|236|237|238|239|240|241|242|243|244|245|246|247|248|249|250|251|252|253|254|255|
11|   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   | 4 | 1 | 2 | 5 |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+

                   offset (11)
                   ↓
Cache line: [3 6 9 7]
Data for address FF: 7
```

Now, the L1 cache would looks something like this:
```
Cache:
           Tag  Data   Tag  Data
Set 00 [1100 3697] [0000 0000] 
Set 01 [0000 0000] [0000 0000]
Set 10 [0000 0000] [0000 0000]
Set 11 [1111 2697] [0000 0000]
```

### Micro operations
These are operations that the cpu uses to split assembler operations into
smaller units. For example, take the following code:
```assembly
  push eax
  call something
```
This can be split into two operations:
```
  sub esp, 4
  mov [esp], eax
```
Here the first operation can be performed even if the value of eax is not 
ready yet. And since these operations are now split the call operation can
proceed which would not be possible otherwise (if there was only a single
non-divisable push operation that is).
Not all assembly language operations can be divided into micro operations, like
simple add with only registers would not be. But if there is a memory fetch it
would be split.


### _mm_clflush
Is declared in `emmintrin.h`:
```
void _mm_clflush(void const* p)
```
Calling this function will invalidate (marks the cacheline as invalid so that
future reads go to main memory), and flush (write the contents back to
main memory). The cacheline is the cacheline that contains p.

There is an example in [cache.c](./cache.c)

### __rdtscp

```c
#include <immintrin.h>
unsigned __int64 __rdtscp (unsigned int * mem_addr)
```
This function will copy the the current 64 bit value of the processors time
stamp counter into dst?

