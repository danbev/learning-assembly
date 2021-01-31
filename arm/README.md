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
TODO:

### Thumb mode
In this mode instructions can be either 2 or 4 bytes long.


### ARM versions
```
ARM Family                ARM architecture
ARM7                      ARM v4
ARM9                      ARM v5
ARM11                     ARM v6
Cortex-A                  ARM v7-A
Cortex-R                  ARM v7-R
Cortex-M                  ARM v7-M
```

### Container for assembly development
```console
$ docker build -t arm-assembly .
$ docker run -ti arm-assembly sh
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
