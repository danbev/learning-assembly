## RISC-V
RISC-V is open source and began its development in 2010 (ARM started in 1990) by
Berkely Parallel Computing Laboratory and later 36 tech companies came together
to form the RISC-V Foundation which was later renamed to RISV-V International in
2020. RISC-V seems to be pronounced as RISC-Five where the 5 comes from this
was Birkely's fifth RISC ISA design.

As the name hints as RISC-V is a reduced instruction set computer instruction
set architecture (ISA). ISA is perhaps simplified as the design of a computer
in terms of basic operations that it must support. It does not address impl
specific details of the computer so two even if you have 2 processors that
support the same ISA they can be implemented very differently.

### Background
Both ARM and RISC-V are instruction set architectures (ISA) and there are both
reduced instruction set computers (RISC).


### ISA Specification
https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf

### Hardware Thread
In the ISA they talk about Harts which is the same thing as a core in other
ISAs.

### Base Module
If I've understood this correclty the base modules are RV32I, RV64I, and RV128I
where RV stands for RISC-V, 32/64/128 the bus/register sized, and `I` stands for
integer which refers to the operations available. 

### Extension Modules
Extension modules add to the base and add more operations. For example, the `M`
extension stands for multiplication and adds multiply/divide instructions. I
thought this was a bit odd and that mul/div should be included in the base, but
there are many places  where only the simplest of operations are required, like
small "stupid" small gadgets/devices. So it allows the manufacturers to only
include what they actually will use.


### Install assembly/compiler tools
```console
$ sudo dnf install -y gcc-riscv64-linux-gnu
```

### Compiling
```
$ make out/hello
$ ./out/hello
Bajja!
```
