# Linux assembly language exploration

The examples here are sometimes not really useful except for inspecting
object code and understanding how things get linked.

## Variables in data section

Take `first.s` as an example and look at the variable that is defined in the
.data section:

```
.data
something:
  .byte 2
```

If we use objdump to inspect the data section we find:

```console
$ objdump -d -j .data first

first:     file format elf64-x86-64


Disassembly of section .data:

0000000000402000 <something>:
  402000:	02 00                	.byte 0x2
	...
```

## Check if zero/null
[check_zero.s](./check_zero.s) contains an example of checking a register if
it is zero by using the `test` opcode:
```
  test %rcx, %rcx
  je zero_func
``` 
So I'm thinking that this would be similar to a checking that there is a value
or not.


## Load Effective Address

Take the following instructions:
```
.data
msg:
   .ascii "bajja\n"
...

  mov msg, %rsi
  lea msg, %rsi
```

Now, if we take a look at `msg` it contains:
```console
(lldb) expr msg
(void *) $5 = 0x00000a616a6a6162
```

This looked a little strange to me at first, but this is actually the value
contained in the memory location:

```console
(lldb) memory read -f x -s 8 -c 1 0x0000000000402000
0x00402000: 0x00000a616a6a6162

(lldb) memory read -c 5 0x0000000000402000
0x00402000: 62 61 6a 6a 61                                   bajja
```
And remember memory is read using little endian `00000a616a6a6162` which
would then become `00000a62616a6a61`.

Using mov with `msg` will only copy the value `00000a616a6a6162` into a register
for example. But to pass the msg to a function like write we would need to
pass a pointer. For this we use the command lea which is like `&` in c/c++
to get the address:
```
(lldb) expr (char*)&msg
(char *) $26 = 0x0000000000402000 "bajja\n"
```

### .set directive
Can be used to set a memory location to a value.
```
done: .ascii "done...\n"
.set done_len, . - done
```
If we take a look at the binary we will find:
```
  40102e:	48 c7 c2 08 00 00 00 	mov    $0x8,%rdx
```
So this works sort of like a `#define` in C/C++ which would be replaced by the
preprocessor (not that there is one when using as). There won't be any symbol
for msg_len.

This can also be written as:
```
msg_len = . - msg
```

### GAS section directive
This directive has the following format:
```
.section name [, "flags"[, @type[, flag_specific_args]]]
```

### syscall
syscall is used to make an indirect system call and has the following signature:
```
     long syscall(long number, ...);
```
And example is when calling exit which has sys number 60:
```
  mov $60, %rax
  xor %rdi, %rdi
  syscall
```
The system calls can be found using `man syscalls` and the actual numbers can
be found in `/usr/include/asm/unistd_64.h`

So the system call number is passed in rax, and the following arguments to the
actual system call are passed in rdi, rsi, rdx, r10, r8, r9. And the result is
stored in rax.

### execve
This section will look closer at the execve system call and calling it from
assembly code.

```c
#include <unistd.h>

int execve(const char *pathname, char *const argv[],
           char *const envp[]);
```

System call nr is `59` which is the value that does into `%rax`.
```assembly
mov $59, %rax
```

The first argument which is the file name is passed in `%rdi`.
```assembly
  lea msg, %rdi  
```

The second argument which is argv is passed in `%rsi%`. Now this is an array
of char pointers which we need to create.
```assembly
```
And the last argument which is envp is passed in `%rdx`.

### array on the stack
So it was not obvious to me how to create an array on the stack in assembly and
adding elements to it.
```c
int main() {                                                                       
  int array[2] = {1, 2};                                                           
  int* ptr = array;
} 
```

```console
$ gcc -o arr arr.c -fomit-frame-pointer
```

```console
$ objdump --disassemble=main arr

arr:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .text:

0000000000401106 <main>:
  401106:	c7 44 24 f0 01 00 00 	movl   $0x1,-0x10(%rsp)
  40110d:	00 
  40110e:	c7 44 24 f4 02 00 00 	movl   $0x2,-0xc(%rsp)
  401115:	00 
  401116:	48 8d 44 24 f0       	lea    -0x10(%rsp),%rax
  40111b:	48 89 44 24 f8       	mov    %rax,-0x8(%rsp)
  401120:	b8 00 00 00 00       	mov    $0x0,%eax
  401125:	c3                   	retq   

Disassembly of section .fini:
```
So this is interesting, we are just placing the 1 on the stack relative to the
stack pointer (now remember that the position is given in hex! I keep forgetting
this when debugging):
```console
(lldb) memory read -f x -c 1 -s 4 '$rsp - 16'
0x7fffffffd0e8: 0x00000001
```
So the whole array would be at:
```console
(lldb) memory read -f x -c 2 -s 4 '$rsp - 16'
0x7fffffffd0e8: 0x00000001 0x00000000
```
And we can verify this by stepping over the next instruction using si
```console
(lldb) si
(lldb) memory read -f x -c 2 -s 4 '$rsp - 16'
0x7fffffffd0e8: 0x00000001 0x00000002
```
Now, we have the `ptr` local variable which is loading the effective address
of `%rsp - 16` into rax, which is the address of the first entry of the array.
Next, this value is stored in location `%rsp - 8`. 
```console
(lldb) register read rax
     rax = 0x0000000000401106  arr`main at arr.c:2:7
(lldb) register read rax
     rax = 0x00007fffffffd0e8
(lldb) memory read -f x -c 1 -s 4 '$rsp - 8'
0x7fffffffd0f0: 0x00000000
(lldb) si
(lldb) memory read -f x -c 1 -s 4 '$rsp - 8'
0x7fffffffd0f0: 0xffffd0e8
```
Now this might seem really trivial but it can be good to know how to actually
create an array on the stack in assembly without having to first disassemble
c code.

### Stack addressing
I need to remind myself that the stack is just a part of memory, but handled
in a different way. The stack is there in the allocated memory for the process
and we can use memory locations below the stack pointer value (rsp). Remember
that rsp just points to a memory location that happens to be what some
instructions update when the are executed, for example, push/pop will subtract
and add to value in rsp. But if we don't use those instructions we are free
to just store values by using mov and placing values in specific locations
relative to rsp (if rsp moves we would be in trouble which in those cases we
would use a base pointer/frame pointer in rbp).

We have to know what size of the data we are going to move so that move
instruction will know.
```
movb     1 bytes (8 bits)
movs     single (32-bit floating point)
movw     word (16 bits)
movl     long (32-bit integer or 64-bit floating point)
movq     quad (64-bit)
movt     ten bytes (80-bit floating point)
```
Lets explore this a little using [arr.s](./arr.s):
```console
(lldb) br s -n _start
```
Now, lets say we want to see the stack from the current rsp and 64 bytes
down which is the stack where we can place values.
To do this we have to remember that the stack grows downward, so we want to
look at from the current rsp down 64 bytes which means subtracting 64 from rsp:
```console
(lldb) memory read -f x -c 10 -s 8 '$rsp - 64'
0x7fffffffd190: 0x0000000000000000 0x0000000000000000
0x7fffffffd1a0: 0x0000000000000000 0x0000000000000000
0x7fffffffd1b0: 0x0000000000000000 0x0000000000000000
0x7fffffffd1c0: 0x0000000000000000 0x0000000000000000

(lldb) memory read -f x -c 10 -s 8 '$rsp - 64'
0x7fffffffd190: 0x0000000000000000 0x0000000000000000
0x7fffffffd1a0: 0x0000000000000000 0x0000000000000000
0x7fffffffd1b0: 0x0000000000000000 0x0000000000000000
0x7fffffffd1c0: 0x0000000000000000 0x0000000000000000
0x7fffffffd1d0: 0x0000000000000001 0x00007fffffffd5a1
```

Now, depending on the data stored we might be interested in looking at bytes, 
words, etc. So we need to adjust the `size` `-s` and also the `count` `-c`.
The size is the size of the memory granuality that we be displayed which makes
it easier to see what belongs to which memory locations.
```console
(lldb) memory read -f x -c 20 -s 4 '$rsp - 64'
0x7fffffffd190: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffd1a0: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffd1b0: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffd1c0: 0x00000000 0x00000000 0x00000002 0x00000000
0x7fffffffd1d0: 0x00000004 0x00000000 0xffffd5a1 0x00007fff
```
```
Bytes: size: 1 count: 64/1 = 64  (add one for rsp)
Word:  size: 2 count: 64/2 = 32  (add one for rsp)
Quad:  size: 4 count: 64/4 = 16  (add one for rsp)

```
Byte example
```console
(lldb) memory read -f x -c 65 -s 1 '$rsp - 64'
0x7fffffffd190: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd198: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1a0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1a8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1b0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1b8: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1c0: 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1c8: 0x02 0x00 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffffd1d0: 0x04
```


Word example:
```console
(lldb) memory read -f x -c 33 -s 2 '$rsp - 64'
0x7fffffffd190: 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
0x7fffffffd1a0: 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
0x7fffffffd1b0: 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000 0x0000
0x7fffffffd1c0: 0x0000 0x0000 0x0000 0x0000 0x0002 0x0000 0x0000 0x0000
0x7fffffffd1d0: 0x0004
```

Quad example:
```console
(lldb) memory read -f x -c 17 -s 4 '$rsp - 64'
0x7fffffffd190: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffd1a0: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffd1b0: 0x00000000 0x00000000 0x00000000 0x00000000
0x7fffffffd1c0: 0x00000000 0x00000000 0x00000002 0x00000000
0x7fffffffd1d0: 0x00000004
```

Now, if we specify addressing relative to a register we use an number before
the register and use parentheses:
```
  movb $4, 0(%rsp)
  movb $2, -1(%rsp)
  movb $3, -2(%rsp)
```
Doing this this
```console
(lldb) memory read -f x -c 4 -s 1 '$rsp - 3'
0x7fffffffd1cd: 0x00 0x03 0x02 0x01
```

And we can use the address from rsp to address the different values, just
like an array of ints:
```console
(lldb) register read rsp
     rsp = 0x00007fffffffd1d0
(lldb) memory read -f x -c 1 -s 1 '0x00007fffffffd1d0 - 2'
0x7fffffffd1ce: 0x03
(lldb) memory read -f x -c 1 -s 1 '0x00007fffffffd1d0 - 1'
0x7fffffffd1cf: 0x02
(lldb) memory read -f x -c 1 -s 1 '0x00007fffffffd1d0 - 0'
0x7fffffffd1d0: 0x01
```

One thing to note is that when we run the example program this it will be invoked
by `execve`:
```console
$ strace ./arr 
execve("./arr", ["./arr"], 0x7fffde884fb0 /* 74 vars */) = 0
exit(0)                                 = ?
+++ exited with 0 +++
```
And when we break in the debugger we can inspect the existing stack:
```console
(lldb) memory read -f x -c 8 -s 8 '$rsp'
0x7fffffffd1d0: 0x0000000000000001 0x00007fffffffd5a1
0x7fffffffd1e0: 0x0000000000000000 0x00007fffffffd5e0
0x7fffffffd1f0: 0x00007fffffffd5f4 0x00007fffffffd62a
0x7fffffffd200: 0x00007fffffffd641 0x00007fffffffd660
(lldb) memory read -f s 0x00007fffffffd5a1
0x7fffffffd5a1: "/home/danielbevenius/work/assembly/learning-assembly/linux/arr"
```
The value in top most position on the stack is argc which above is 1. So really
our program should not overwrite that value but instead substract the size of
an int (32-bits/4-bytes) and then add our values.
```assembly
  sub  $1, %rsp
```
Notice that the register we have specified is a 64 bit register

```
(lldb) register read rsp
     rsp = 0x00007fffffffd1b0
(lldb) si
(lldb) register read rsp
     rsp = 0x00007fffffffd1af
```
140737488343472 140737488343471

Try to add an alias for this which will take the size of the stack to show:
```
(lldb) command alias showstack memory read -f x -c 10 -s 8 `$rsp - 64`
```

### mov label 
When you move something you need to think about how much you data you are
moving. For example, take the following:
```assembly
.data
msg: .ascii "something\n"
len: .int . - msg
...

  mov len, %rdx
```
This is moving 64 bits into rdx starting from the memory location len. In our
case the first 32 bits of len contain our message length which is 10 (a in hex)
and the rest is whatever follows in the data section.
If we only want to move our int we can use:
```assembly
mov len %edx
```
or 
```assembly
mov len %dl
```

### mul
Take the [example](./multi.s) and if we run this in the debugger we find:
```console
$ lldb -- ./multi 
(lldb) target create "./multi"
Current executable set to './multi' (x86_64).
(lldb) br s -n _start
(lldb) r
(lldb) register read rax rbx
     rax = 0x0000000000000008
     rbx = 0x0000000000000004
(lldb) si
(lldb) register read rax rbx
     rax = 0x0000000000000020
     rbx = 0x0000000000000004
(lldb) register read -f d rax rbx
     rax = 32
     rbx = 4
```
Notice that the result of the multiplication is placed in `rax`.

### div
This operaton generates two output values, the quotient and a remainder.

Take the [example](./div.s) and if we run this in the debugger we find:
```console
   4   	_start:
   5   	  mov $21, %ax
   6   	  mov $2, %bx
-->7   	  div %bx
(lldb) register read -f d al ah bx
      al = 21
      ah = 0
      bx = 2
(lldb) si
(lldb) register read -f d al ah dx
      al = 10
      ah = 0
      dx = 1
```
Notice the quotent is in `al` and the remainder is in `dx`. 

### integer to string
To do this in assembly we need to take a look at how this is done.
We have an integer which is a number of digits. We divide take the remainder of
dividing the number by 10 to get the right most digit, and then continue
dividing until there are no more digits.

```
234 % 10 = 4-------------+
234 / 10 = 23            |
                         |
           +------------↓↓
23 % 10  = 3           234
23 / 10  = 2           ↑
                       |
2  % 10  = 2-----------+
2  / 10  = 0
```
So when we get 0 as the quotient (the result of dividing the number by 10) we
are finished, and if we take the remainders (shown as separate operations above
but the `div` operation in assembly produces both), we have the number if the
reverse order (432 instread of 234). Now we still want to print these and that
will be done with ascii. In ascii the zero digit has the value 48:
```console
$ man ascii
Oct   Dec   Hex   Char                        Oct   Dec   Hex   Char
────────────────────────────────────────────────────────────────────────
000   0     00    NUL '\0' (null character)   100   64    40    @
...
012   10    0A    LF  '\n' (new line)         112   74    4A    J
...
060   48    30    0                           160   112   70    p
061   49    31    1                           161   113   71    q
062   50    32    2                           162   114   72    r
063   51    33    3                           163   115   73    s
064   52    34    4                           164   116   74    t
065   53    35    5                           165   117   75    u
066   54    36    6                           166   118   76    v
067   55    37    7                           167   119   77    w
070   56    38    8                           170   120   78    x
071   57    39    9                           171   121   79    y
```
So if we take our digit `4` and add `48` we get `52`. And if we do that will
all the digits and arrage them after each other in memory we can then pass
a pointer to that memory to the write system call.


### executable stack
The background here is that linux has allowed the stack to be executable in the
past, for example for nested functions and trampoline code. I think this was
before exploits were a real issue but nowadays this is something that is
prevented as allowing the programs data or stack to be executable allows for
code to be placed in these regions of memory and then jumped to which can be
used in exploits.

The solution is that compilers can add a section to the object file which the
linker can then detect to make the data/stack non-executable. But if this
section is missing the data/stack area will be executable. Remember that the
assembler will create an object file which contains information for the linker,
and the linker will create an object file that is used by the operating system
to load it into memory. If I recall the permission for memory is set in the page
table so this would have to some information in the object file created by the
linker that causes the OS to make the stack be executable.

When the ld does its linking linking, it will not add a specific program header
if a single object file is not marked as non-executable. So an object file
, for example an assembly source that is not marked as non-executable,
would make the entire library/executable become marked as having an executable
stack.

For an executable file (or a shared object file) this information is in the
program header, which is an array of structures that describes a segment that
the system needs to handle to make a process for the program. The program
header is only meaningful for executable and shared object files.
This struct looks like this:
```c
typedef struct {
        Elf64_Word      p_type;
        Elf64_Word      p_flags;
        Elf64_Off       p_offset;
        Elf64_Addr      p_vaddr;
        Elf64_Addr      p_paddr;
        Elf64_Xword     p_filesz;
        Elf64_Xword     p_memsz;
        Elf64_Xword     p_align;
} Elf64_Phdr;
```
Notice the `p_flags` which can be:
```
PF_X         0x1          Execute 
PF_W         0x2          Write
PF_R         0x4          Read
PF_MASKPROC  0xf000000    Unspecified
```
`PT_GNU_STACK` is a p_flags member specifies the permissions on the segment
containing the stack and is used to indicate wether the stack should be
executable. `The absense of this header indicates that the stack will be
executable`. This is not exactly true and the value of the p_flags entry might
not be `PF_X` in which case the program header will still be there.
For example:
Using the example without the section in the source we compile and like this:
```console
$ as -o exec-stack.o exec-stack.s 
$ ld -z execstack -o exec-stack exec-stack.o
$ readelf -l exec-stack | grep -A1 GNU_STACK
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RWE    0x10
```
Notice that we have the program header but the flags are `RWE`. 
```console
$ ld -z noexecstack -o exec-stack exec-stack.o
$ readelf -l exec-stack | grep -A1 GNU_STACK
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
```

When assembling with as (gnu assembler) this can be specified using:
```
--execstack or --noexecstack assembler options 
```
Or you can add the section to the assembly source file:
```assembly
```assembly
.section .note.GNU-stack,"",@progbits
```
Specifying `--noexecstack` would be the same as adding the section to the
assembly source code.

It is also possible to specify this flag to the linker:
```console
$ as -o exec-stack.o exec-stack.s
$ ld -z noexecstack -o exec-stack exec-stack.o
```
So if we have a source file without the .note.GNU-stack section this would add
the section to the program header of the generated object file.

The example  [exec-stack.s](./exec-stack.s) will be used below and if we take
a look at the program headers for it without the section `.note.GNU-stack` added
we see:
```console
$ readelf -w --program-headers exec-stack
Elf file type is EXEC (Executable file)
Entry point 0x401000
There are 3 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x00000000000000e8 0x00000000000000e8  R      0x1000
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x0000000000000015 0x0000000000000015  R E    0x1000
  LOAD           0x0000000000002000 0x0000000000402000 0x0000000000402000
                 0x0000000000000004 0x0000000000000004  RW     0x1000
```
Notice that there are only three Program Headers!

And if we add the section we can find:
```console
$ readelf -w --program-headers exec-stack
Elf file type is EXEC (Executable file)
Entry point 0x401000
There are 4 program headers, starting at offset 64

Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000000000 0x0000000000400000 0x0000000000400000
                 0x0000000000000120 0x0000000000000120  R      0x1000
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x0000000000000015 0x0000000000000015  R E    0x1000
  LOAD           0x0000000000002000 0x0000000000402000 0x0000000000402000
                 0x0000000000000004 0x0000000000000004  RW     0x1000
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
```
So when have the secion there will be a program header named `GNU_STACK` and
this executable will not be allowed to execute code in the data or stack
section.

This program header will be checked when the binary is loaded in 
[load_elf_binary](https://elixir.bootlin.com/linux/latest/source/fs/binfmt_elf.c#L929):
```c
for (i = 0; i < elf_ex->e_phnum; i++, elf_ppnt++)
		switch (elf_ppnt->p_type) {
		case PT_GNU_STACK:
			if (elf_ppnt->p_flags & PF_X)
				executable_stack = EXSTACK_ENABLE_X;
			else
				executable_stack = EXSTACK_DISABLE_X;
			break;

...

if (elf_read_implies_exec(*elf_ex, executable_stack))
		current->personality |= READ_IMPLIES_EXEC;
...
```
Notice that we only enter this if `PT_GNU_STACK` is present. So that should
be enough to determine if an executable has a non-exeutable stack is that
there is no PT_GNU_STACK.

For example, without the section added:
```console
$ readelf -w -l exec-stack | grep GNU_STACK
```
And with it added:
```console
$ readelf -w -l exec-stack | grep GNU_STACK
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
```

We can also inspect the object file using:
```console
$ readelf -WS exec-stack.o | grep .note.GNU-stack
  [ 5] .note.GNU-stack   PROGBITS        0000000000000000 000059 000000 00      0   0  1
```
And without the section in the source this would not match.
```console
$ as --noexecstack -o exec-stack.o exec-stack.s
$ readelf -WS exec-stack.o | grep .note.GNU-stack
  [ 5] .note.GNU-stack   PROGBITS        0000000000000000 000059 000000 00      0   0  1
```

## No Execute (NX)
The no execute bit is used in CPUs to separate memory areas for either data
storage or instructions storage. An operating system with NX support will mark
certain areas of memory as non-exeutable.


### sections
We can add section as we wish:
```assembly
.section bajja_section
```
```console
$ objdump -h tmp.o

tmp.o:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000030  0000000000000000  0000000000000000  00000040  2**0
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         0000000a  0000000000000000  0000000000000000  00000070  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  0000000000000000  0000000000000000  0000007a  2**0
                  ALLOC
  3 bajja_section 00000000  0000000000000000  0000000000000000  0000007a  2**0
                  CONTENTS, READONLY
```

### cmp and sub
The cmp instruction will take a source and destination and subtract the
destination with the source:
```assembly
  mov $11, %rax
  mov $10, %rsi
  cmp %rax, %rsi
```
This similar to `sub %rax, %rsi` only the destination %rsi will not be modfied.
So the source is subtracted from the destination, so this will perform
`%rsi - %rax = 10 - 11 = -1`.

Remember to display rflags using `--binary or -b`:
```console
(lldb) expr -f b -- $rflags
(unsigned long) $11 = 0b0000000000000000000000000000000000000000000000000000001010010111
```
Using `expr` allows us to use a mask to find the values that we might be
interested in. For example, to see only the value of the carry flag:
```console
(lldb) expr -f b -- $rflags & 0x0001
(unsigned long) $11 = 0b0000000000000000000000000000000000000000000000000000000000000001
```
When subtracting, and hence this is also true for cmp, the carry flag is set
when the result becomes too large of a negative value. For example
```
0000 - 0001 = 1111 = -1
```

The flags affected by cmp/sub are CF, OF, SF, ZF, AF, and PF.

The carry flag is used to determine when subtracting unsigned integers produce
a negative value.
How about signed integers and subtracting them, these could have valid negative
numbers. In this case the carry flag is not useful. Instread one has to use
the overflow flag.

### test
This instruction is very similar to `cmp` and affects the same flags in almost
the same way with the execption of `AF`.

### rflags

```
                                           11 10 9  8  7  6  5  4  3  2  1  0
+-----------------------------------------------------------------------------+
|                                         |OF|DF|IF|TF|SF|ZF|  |AF|  |PF|  |CF|
+-----------------------------------------------------------------------------+

CF = Carry        0x0001   00000000000000000000000000000001
PF = Parity       0x0004   00000000000000000000000000000100
AF = Adjust       0x0010   00000000000000000000000000010000
ZF = Zero         0x0040   00000000000000000000000001000000
SF = Sign         0x0080   00000000000000000000000010000000
TF = Trap         0x0100   00000000000000000000000100000000
IF = Interrupt    0x0200   00000000000000000000001000000000
DF = Direction    0x0400   0000000000000000000001000000000
OF = Overflow     0x0800   0000000000000000000010000000000
```
The above masks can be used to AND the rflags register to check values:
```console
(lldb) expr -f b -- $rflags & 0x0001
```

### Parity Flag
The parity flags on x86 only looks at one byte, the least significant, and if
the bits set are even the parity flags is set, and if it is odd then it is 0.

### Adjust/Auxiliary/Auxilary Carry Flag
The adjust flag is also called the Auxiliary flag or Auxilariy Carray flag. This
is set if an arithmetic operation causes a borrow to occur in the four least
significant bits. This was used for EBCDIC and is not really used anymore, but
the cmp/sub instructions can affect these flags.

### Zero flag 
```
$ lldb -- zero-flag
(lldb) target create "zero-flag"
Current executable set to 'zero-flag' (x86_64).
(lldb) br s -n _start
(lldb) disassemble 
zero-flag`_start:
    0x401000 <+0>:  mov    rax, 0x2
->  0x401007 <+7>:  mov    rcx, 0x2
    0x40100e <+14>: sub    rcx, rax
(lldb) expr -f b -- $rflags & 0x0040
(unsigned long) $0 = 0b0000000000000000000000000000000000000000000000000000000000000000
(lldb) si
(lldb) expr -f b -- $rflags & 0x0040
(unsigned long) $5 = 0b0000000000000000000000000000000000000000000000000000000001000000
```

### Direction flag

## conditional set instruction (setcc)
This instruction will conditionally set the destination operand to 0 or 1
depending on the status flags (CF, SF, OF, ZF, and PF).

An example can be found in [setne.s](./setne.s).

For a real example this usage can be found in Node.js:
```console
  a4c1f3:	e8 58 ab fd ff       	callq  a26d50 <getauxval@plt>
  a4c204:	48 85 c0             	test   %rax,%rax
  a4c207:	0f 95 05 73 c8 ba 03 	setne  0x3bac873(%rip)        # 45f8a81 <_ZN4node11per_process15linux_at_secureE>
```
Notice that are calling `getauxval` and it returns a values which on x64 will
be in register rax. The test is anding that regiser with itself, if the result
is not zero then we set the value at the address relative to the value in the
instruction pointer registry.


### Conditional mov
TODO: add an example of this.

### dereferencing
```assembly
  mov msg, %rcx
```
This will move the contents located at the address msg, the size of the data
will be 64-bits as we are moving into rax.
```console
(lldb) disassemble -F att
0x401000 <+0>:  movq   0x402000, %rcx
```

We can put parentheses around it which is the same thing as saying that we
want to copy the data located at the address msg.
```assembly
  mov (msg), %rax
```
A reason for doing this is perhaps we want to add an offset to the address:
```assembly
  mov (msg+0), %rcx
```
But that is actually possible without the parenthesis.
```console
    0x401011 <+17>: movq   0x402000, %rcx
```
But this can be useful when we want to specify an offset for a register perhaps
like :
```assembly
  0x4016cd <+11>: movq   %rsi, -0x20(%rbp)
```

Now if we use `$` which is also use $ immediate valus like $4 would be the
constant 4 and remember that msg is just an address and we are specifying that
as an immediate value.
```assembly
  mov $msg, %rcx
```
We also use $ with constants, like $4 would be the constant 4 and remember
that msg is just an address 
```console
0x401008 <+8>:  movq   $0x402000, %rax           ; imm = 0x40200
```

And this is the same as using `lea` to load the effective address.
```assembly
  lea msg, %rbx
```
```console
    0x401020 <+32>: leaq   0x402000, %rbx
```

### .p2align directive
This directive is used to pad the location counter
```assembly
.p2align 5,,31
```
This pads to align on a 32-byte boundry.

