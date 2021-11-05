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
Notice the `=mesg` here:
```assembly
    ldr     x1, =msg    /* buf */
```
The `=` sign in this case indicates an LDR pseudo instruction. msg is defined
in first.s as:
```assembler
msg:
    .ascii        "Bajja\n"
```
And `msg` is a label which is an address so it would be 64 bits when using a
64-bit processor. So without the `=` sign the compiler would see a value that
is not a 16-bit immediate value trying to be loaded into x1. But with the `=`
sign the compiler will change this instruction to :
```
  4000b4:	580000e1 	ldr	x1, 4000d0 <_start+0x20>
```
The max size of an immediate value is 16-bits, and that becomes an issue when
we need use 64 bit addresses and move them into registers. The register can
handle 64 bits but not the opcode parameter. But what it can do is use a value
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
(supervisor call) which takes a system call number for the table above.
The arguments the system call takes can also be see in the table above in the
additional columns for each call.


### xzr register
Is a register and it's value is always zero.
```console
Disassembly of section .text:

0000000000400078 <_start>:
  400078:	d2800000 	mov	x0, #0x0                   	// #0
  40007c:	aa1f03e0 	mov	x0, xzr
  400080:	aa1f03e0 	mov	x0, xzr
  400084:	d2800ba8 	mov	x8, #0x5d                  	// #93
  400088:	d4000001 	svc	#0x0
```
Note that `movz` will move the immediate and then zero out the rest of the bits
are set to zero in the destination register.
And without aliases we get:
```console
$ aarch64-linux-gnu-objdump -d -M no-aliases xzr

xzr:     file format elf64-littleaarch64


Disassembly of section .text:

0000000000400078 <_start>:
  400078:	d2800000 	movz	x0, #0x0
  40007c:	aa1f03e0 	orr	x0, xzr, xzr
  400080:	aa1f03e0 	orr	x0, xzr, xzr
  400084:	d2800ba8 	movz	x8, #0x5d
  400088:	d4000001 	svc	#0x0
```

### svc (supervisor call)
This is used for system interrupt, for example calling exit:
```assembly
    mov     x0, #0      /* status */
    mov     x8, #93     /* exit syscall #93 */
    svc     #0          
```
To me it makes sense that the exist status code is passed ion register x0, but
it is not clear to me why the system call number, #93 above, is passed in
register x8. This is just a calling convention and we can see the conventions
in the syscall man page:
```console
Arch/ABI    Instruction           System  Ret  Ret  Error    Notes
                                         call #  val  val2
       ───────────────────────────────────────────────────────────────────
       alpha       callsys               v0      v0   a4   a3       1, 6
       arc         trap0                 r8      r0   -    -
       arm/OABI    swi NR                -       r0   -    -        2
       arm/EABI    swi 0x0               r7      r0   r1   -
       arm64       svc #0                w8      x0   x1   -
       blackfin    excpt 0x0             P0      R0   -    -
       i386        int $0x80             eax     eax  edx  -
       ia64        break 0x100000        r15     r8   r9   r10      1, 6
       m68k        trap #0               d0      d0   -    -
       microblaze  brki r14,8            r12     r3   -    -
       mips        syscall               v0      v0   v1   a3       1, 6
       nios2       trap                  r2      r2   -    r7
       parisc      ble 0x100(%sr2, %r0)  r20     r28  -    -
       powerpc     sc                    r0      r3   -    r0       1
       powerpc64   sc                    r0      r3   -    cr0.SO   1
       riscv       ecall                 a7      a0   a1   -
       s390        svc 0                 r1      r2   r3   -        3
       s390x       svc 0                 r1      r2   r3   -        3
       superh      trap #0x17            r3      r0   r1   -        4, 6
       sparc/32    t 0x10                g1      o0   o1   psr/csr  1, 6
       sparc/64    t 0x6d                g1      o0   o1   psr/csr  1, 6
       tile        swint1                R10     R00  -    R01      1
       x86-64      syscall               rax     rax  rdx  -        5
       x32         syscall               rax     rax  rdx  -        5
       xtensa      syscall               a2      a2   -    -
```


The argument to `svc` is mandatory but is up to the handler how to use it (I
think).


### mov
```
mov{S}{cond} Rd, Operand2
mov{cond} Rd, #imm16
```
If `S` is specified then the conditional flags are updated as part of the
operation.


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

### add
A very basic [add](./src/add.s):
```
$ make add
$ qemu-aarch64 add
$ echo $?
5
```

### load address (ldr)
This is used to load the address, like leaq in x86_64. The `=` sign is used
in this case:
```assembly
    ldr     x1, =msg
```
The `=` sign in this case means to use the LDR pseudo instruction.

The following example loads the value found in the memory location in r0 into
ra:
```assembly
    ldr     ra, [r0]
```

### branch
An example of conditional branching can be found in [branch](../src/branch.s).

### Store Register (STR)
This command stores the contents of a register into memory:
```assembly
  str x0, [SP, #-16]!
```
Notice the `!` which is the for register write-back. So SP is used as the base
register and 16 is subtracted from that, and SP is also updated with that value.

So what this is doing is substracting 16 from SP and updating SP, then
copying x0 into that location.


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


### armasm
Needs to be [downloaded](https://developer.arm.com/tools-and-software/embedded/arm-compiler/downloads/version-6)
and installed.

To start using Arm Compiler for Embedded 6.17:
```console
- Create a suite sub-shell using /home/danielbevenius/ArmCompilerforEmbedded6.17/bin/suite_exec bash
```


#### Directives
Just keep in mind that these are directives that the specific assembler uses
and are not part of the instructions set. So we can choose use either armasm or
or as (GNU assembler) to write our programs and they only understand their own
directives.

armasm and GNU as directives:
```
ASM                    GNU
AREA                   .sect
EQU                    .equ
DCB                    .byte
DCW                    .half
DCD                    .word
SPACE                  .space
END                    .end
RN                     .asg
```
EQU comes from equate directive.


### arm-none-eabi-as
This can be used to cross compilation of arm assembly programs and allows for
exploring 32 bit arm code.

For example, there is a [space.s](./src/space.s) program that we can compile
using:
```console
$ make space
arm-none-eabi-as -g -o space.o src/space.s
arm-none-eabi-ld -g -o space space.o
```
This can then be run using:
```console
$ qemu-arm ./space
```
That is not very helpful though as nothing will happen. What we can do instead
is specify that the emulator should halt:
```console
$ qemu-arm -singlestep -g 7777 space
```
`7777` is the port that we can then use to connector using gdb:
```console
$ arm-none-eabi-gdb
(gdb) file space
(gdb) target remote localhost:7777
Remote debugging using localhost:7777
_start () at src/space.s:6
6	  ldr r0, =A

// stepping/inspecting...

(gdb) disassemble 
Dump of assembler code for function _start:
   0x00008000 <+0>:	ldr	r0, [pc, #8]	; 0x8010 <_start+16>
   0x00008004 <+4>:	mov	r1, #2
   0x00008008 <+8>:	str	r1, [r0]
=> 0x0000800c <+12>:	b	0x8000 <_start>
   0x00008010 <+16>:	andeq	r8, r1, r4, lsl r0
End of assembler dump.

(gdb)
(gdb) x $r0
0x18014:	0x00000002

(gdb) kill
```

### ldr (arm)
Takes a value in memory and writes it to a regiser:
```
LDR{size}{cond} <Rd>, <addressing mode>
```
Without a size specified the will be a 32-bit write.
Size can also be `LDRB` for a 8-bits, `LDRH` for 16-bits (Halfword), `LDRSB`
for signed byte, `LDRSH` signed halfword, and `LDM` for multiple words.
The addressing modes can have a base register, and offset, and a shift
operation:
```assembly
    dest           base     shift operation
       ↓             ↓       ↓
  ldr r9,         [r12, r8, LSR #2]
                         ↑       ↑
                       offset   immediate value
```
The shifted offset is added to the base, so r12 + r8 * 4 and this is called the
effective address. So lets say the base address contains the address to a
struct, r8 is a member of the struct which is an array, then we could index
values in the array using the shift I think.

### str (arm)
Takes a value from a register and stores i in memory.
```assembly

  str r0, [r1]

r0: 0xaabbccdd             r1: 0x00008000 ------> 0x0000800: 0xdd
                                                  0x0000801: 0xcc
                                                  0x0000802: 0xbb
                                                  0x0000803: 0xaa
```
We can also add an increment operand to the str instruction:
```
  str r0, [r1], #4

r0: 0xaabbccdd             r1: 0x00008004 --+     0x0000800: 0xdd
                                            |     0x0000801: 0xcc
                                            |     0x0000802: 0xbb
                                            |     0x0000803: 0xaa
                                            +---→ 0x0000804: 0x00
```
Notice that after the instruction completes r1 has now been incremented.

```assembly
  r1, [r0, #4]!
```
r1 will contain the value or r0+4, and r0 will be updated to contain r0+4.

```assembly
  r1, [r0], #4
```
r1 will contain the value or r0, and r0 will be updated to contain r0+4.

### pre-indexed addressing
```
  ldr{size}{cond} <Rd>, [<Rn>, <offset>] {!}
                         {effecitve addr}

! = should the effective address be written back into Rn, without this Rn will
    be unchanged.
```

### post-indexed addressing
This is the same as we saw previously where after the str (or ldr) completes
Rn is incremented. Notice that this only says incremented, and this differs
from `!` where the effective address is written back into `Rn`.
```
  str{size}{cond} <Rd>, [<Rn>], <offset>

  str r0, [r1], #4

r0: 0xaabbccdd             r1: 0x00008000 ------> 0x0000800: 0xdd
                                                  0x0000801: 0xcc
                                                  0x0000802: 0xbb
                                                  0x0000803: 0xaa
```

### instruction encoding

The instruction encoding for a 32-bit instruction looks like this:
```
 31   29  27  25  23  21  19  17  15  13  11  9  7  5  3  1
 +---------------------------------------------------------+
 | Cond  |0|0|I| opcode|S| Op1 | Dest |   Operand 2        |
 +---------------------------------------------------------+
    30  28  26  24  22  20  18 16  14  12  10  8  6  4  2  0

Data processing instruction: bit 26 and 27: 00
opcode: the instruction, add, sub, mov, cmp etc.
I: is the immediate bit. If this is 0 then Operand 2 is a register, and if this
   bit is 1 Operand 2 is an immediate value.
Operand 2: 12-bits. 2¹²=4096, so we only have values in the range 0-4096 but
ARM does not use this value as an 12-bit number!
Instead what is does is that it uses an 8bit value with a 4-bits rotate value
2⁴ = 16.

 11   9   7   5   3   1
 +-----------------------+
 |Rotate| Immediate      |
 +-----------------------+
   10   8   6   4   2   0

11-8 Rotate bits
7-0  Immediate bits
```
For example:
```
                        mov r0, #3, 2

3 = 0000 0000 0000 0000 0000 0000 0000 0011
Rotate that binary 2 give us:
1100 0000 0000 0000 0000 0000 0000 0000
which is -1073741824 decimal
```
And we can inspect the generated instruction using objdump:

800c:	e3a00103 	mov	r0, #-1073741824	; 0xc0000000
```
