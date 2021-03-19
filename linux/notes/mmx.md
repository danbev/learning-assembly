### Multimedia Media Extension (MMX)
Introduced new instructions and data types.

There are 8 new registers, 57 new instructions four new data types.

#### Registers
```
MM0...MM7

   64                   0
   +--------------------+
   |      MM0           |
   +--------------------+
   ...
```
This is done by still mainting compability with existing operating systems by
mapping these new register to the ones in the FPU (see notes
[float.md](./float.md)) which if we recall were 8 80-bit registers. So these new
register map to those but only to the 64-bits. If one wants to mix FPU and MMX
one needs to be careful and call the emms instruction before switching.

#### Data types
So we saw above that the registers are 64 bits in size. So we can place one
64-bit value (Quadword) in a register, or 2 32-bit (Packed doubleword), or
4 16-bit values (Packed word), or 8 8-bit (Packed byte).

Each value is a separate fixed point integer.

