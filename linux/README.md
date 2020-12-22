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
