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
msg_end: .set msg_len, msg_end - msg
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

