### ARM Assembly
ARM is a Reduced Instruction Set Computing (RISC) processor which is different
from Intel which are Complex Instruction Set Computing (CISC) processors.
Simpler instructions tend to consume less power and is a reason for ARM being
used in smaller embedded devices.

It has more general purpose registers than CISC processors and have around 100
instructions.

ARM uses a LOAD/STORE memory model for memory access so an operation will first
have to load a value into a register, operate on that value, and then store it
back to memory.

ARM has two modes, ARM mode and Thumb mode. 

Before version 3 ARM processors were little-endian but after that the ARM
processors have become BI-endian which allows the endienness to be toggled.

### ARM mode
This is the traditional instructions set where instructions are 32-bits long.

### Thumb mode
This mode supports higher code density where instructions can be either 16-bits
and some are still 32-bits long.

### Thumb2 mode
My understanding of this is that you have to choose if you use ARM mode or
Thumb mode when writing code. Thumb2 adds more instructions to Thumb mode so
that it is almost on par with ARM mode, but also adds a new assembly syntax
to allow for writing code in a unified way and then deciding on the mode at
assemble time. The is called Unified Assembly Language (UAL).

### ARM versions
```
ARM Family                ARM architecture
--------------------------------------------------------
ARM7                      ARM v4
ARM9                      ARM v5
ARM11                     ARM v6
Cortex-A                  ARM v7-A   (A=Application)
Cortex-R                  ARM v7-R   (R=Realtime)
Cortex-M                  ARM v7-M   (M=Microcontroller)
```

### ARMv8
Introduced AArch64, which is a new instruction set (64 bit support).

### Container for assembly development
```console
$ docker build -t arm-assembly .
```

### Run the container
```console
$ docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -ti -v${PWD}/src:/src:Z -w="/src" arm-assembly sh
```

### Compiling and linking
```console
/src # as first.s -o first.o
/src # ld -o first first.o 
/src # ./first
Hello, ARM64!
```

### objdump (arch64-linux-gnu)
```console
$ aarch64-linux-gnu-objdump -s -d first

first:     file format elf64-littleaarch64

Contents of section .text:
 4000b0 200080d2 e1000058 02010058 080880d2   ......X...X....
 4000c0 010000d4 000080d2 a80b8052 010000d4  ...........R....
 4000d0 e0004100 00000000 06000000 00000000  ..A.............
Contents of section .data:
 4100e0 42616a6a 610a                        Bajja.          

Disassembly of section .text:

00000000004000b0 <_start>:
  4000b0:	d2800020 	mov	x0, #0x1                   	// #1
  4000b4:	580000e1 	ldr	x1, 4000d0 <_start+0x20>
  4000b8:	58000102 	ldr	x2, 4000d8 <_start+0x28>
  4000bc:	d2800808 	mov	x8, #0x40                  	// #64
  4000c0:	d4000001 	svc	#0x0
  4000c4:	d2800000 	mov	x0, #0x0                   	// #0
  4000c8:	52800ba8 	mov	w8, #0x5d                  	// #93
  4000cc:	d4000001 	svc	#0x0
  4000d0:	004100e0 	.word	0x004100e0
  4000d4:	00000000 	.word	0x00000000
  4000d8:	00000006 	.word	0x00000006
  4000dc:	00000000 	.word	0x00000000
```
Notice that:
```assembly
    ldr     x1, =msg    /* buf */
```
got assembled into:
```
  4000b4:	580000e1 	ldr	x1, 4000d0 <_start+0x20>
```
The max size of an immediate value is 16-bits, and that becomes an issue when
we need use 64 bit addresses and move them into registers. The register can
handle 64 bits but not the opcode parameter. But what is can do is use a value
relative to the current instruction pointer and this is what is happening here.
We are telling the processor to use the value at 4000d0 which contains a pointer
to the data, in this case the string 'bajja'.
Notice that this is in the .text segment following the code of the function.

### Instructions
Are 32 bits in size (for both 32 and 64 bit processors).

### Registers
A64 provides 31 general purpose registers and each can be used as a 64-bit
register in which case the name of the register starts with an `x`. So we have
x0-x30 (can be upper or lower case) to use.
These register can also be used as 32-bit register and the one uses `w` as the
name of them.

Note that the type of register used will impact the instruction in which the
register is used.

```
x0-x7                Arguments to functions and return values.
x8                   For syscalls the number goes into this register.
x9-x15               For local variable.
x16-x18              Used for IPC and platform values.
x19-x28              Callee saved
x29                  Frame register (like rbp I think)
x30                  Link Register (return address for function calls)
SP/XZR               The stack pointer for instruction dealing with the stack
                     and zero register otherwise.
PC                   The program counter.
```


### Calling conventions
```
             syscall nr  return  arg0  arg1  arg2  arg3 arg4 arg5
arm          r7          r0      r0    r1    r2    r3   r4   r5
arm64        x8          x0      x0    x1    x2    x3   x4   x5
```

### System calls
See [64-bit table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#tables)
for system call numbers.

The instruction for system calls, system interrupt is `svc`
(system service perhaps) which takes a system call number for the table above.
The arguments the system call takes can also be see in the table above in the
additional columns for each call.

### mov
Apperently mov is not an arm instruction but an alias. So when we write
```assembly
  mov   x0, #4
  mov   x1, x0
```
The assembler will expand that to:
```asssembly
  4000c4:	d2800080 	movz	x0, #0x4
  4000c8:	aa0003e1 	orr	x1, xzr, x0
```

### load address (ldr)
This is used to load the address, like leaq in x86_64. The `=` sign is used
in this case:
```assembly
    ldr     x1, =msg
```

The following example loads the value found in the memory location in r0 into
ra:
```assembly
    ldr     ra, [r0]
```

### QEMU
Machine emulator.

#### Setup
```console
$ sudo cp fedora_aarch64.repo /etc/yum.repos.d/
$ dnf install aarch64-linux-gnu-{binutils,gcc,glibc}
```

#### Compiling and linking
```console
$ aarch64-linux-gnu-as -o first.o src/first.s
$ aarch64-linux-gnu-ld -o first first.o
$ file first
first: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, not stripped
```

#### Run using QEMU
```console
$ $ qemu-aarch64 first
Hello, ARM64!
```

### Microprocessor without Interlocked Pipelined Stages (MIPS)
Is a RISC instruction set architecture (ISA).
