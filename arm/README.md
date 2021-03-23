### ARM Assembly
ARM is a Reduced Instruction Set Computing (RISC) processor which is different
from Intel which are Complex Instruction Set Computing (CISC) processors.

It as more general purpose registers than CISC processors and have around 100
instructions.

ARM uses LOAD/STORE memory model for memory access so an operation will first
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
that it is almost on par with Arm mode, but also adds a new assembly syntax
to allow for writing code in a unified way and then deciding on the mode at
assemble time. The is called Unified Assembly Language (UAL).

### ARM versions
```
ARM Family                ARM architecture
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
$ docker run -ti  -v${PWD}/src:/src:Z -w="/src" arm-assembly sh
```

### Compiling and linking
```console
/src # as first.s -o first.o
/src # ld -o first first.o 
/src # ./first
Hello, ARM64!
```

### Registers


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
(system service perhaps) which take a system call number for the table above.
The arguments the system call takes can also be see in the table above in the
additional columns for each call.



### load address (ldr)
This is used to load the address, like leaq in x86_64. The `=` sign is used
in this case:
```assembly
    ldr     x1, =msg
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

