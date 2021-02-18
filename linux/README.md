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

Now, when I first saw this I was surprised to see the opcodes. I only thought
that this would contain a value. The value value 02 is an opcode in the
`ADD` x86 instruction set. 

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
```

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
```
```assembly
```

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
So this is interesting, we are just place the 1 on the stack relative to the
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
Next this value is stored in location `%rsp - 8`. 
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
create an array on the stack in assembler without having to first disassemble
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
Now, lets say we want to see the the stack from the current rsp and 64 bytes
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
The background here is that linux as allowed the stack to be executable in the
past, for example for nested functions and trampoline code. I think this was
before exploits were a real issue. But nowadays this is something that is
prevented and linkers will add a section in the exectable. But if this section
is missing the stack is executable. 

When the ld does its linking linking, it will mark the stack as executable based
if a single object file is not marked as non-executable. So one object file
for example an assembly source that does is not marked as non-executable would
make the entire library/executable become marked as having an executable stack.

When assembling this can be specified using:
```
--execstack or --noexecstack assembler options 
```

The following tool can be used to check if stack execution is required:
```console
$ sudo dnf install execstack
```

Example, [exec-stack.s](./exec-stack.s) without and `.not.GNU-stack` section:
```console
$ make exec-stack
$ execstack exec-stack
? exec-stack
$ ./exec-stack 
Trace/breakpoint trap (core dumped)
```
And with the section:
```console
$ execstack exec-stack
- exec-stack
$ ./exec-stack 
Segmentation fault (core dumped)
```

`PT_GNU_STACK` program header entry.  If the marking is missing, kernel or
dynamic linker need to assume it might need executable stack.

The most common reason that this fails these days is that part of the program
is written in assembler, and the assembler code does not create a
`.note.GNU_stack section`. If you write assembler code for GNU/Linux, you must
always be careful to add the appropriate line to your file.

For most targets, the line you want is:
```assembly
.section .note.GNU-stack,"",@progbits
```


