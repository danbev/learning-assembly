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
```
mov $59, %rax
```

The first argument which is the file name is passed in `%rdi`.
```
```

The second argument which is argv is passed in `%rsi%`.
```
```
And the last argument which is envp is passed in `%rdx`.
```
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


Notice that we are using `%rsp` 
