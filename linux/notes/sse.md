### Streaming SIMD Extension (SSE)
This makes it possible to perform arithmetic operations on four pairs of 32-bit
floating point numbers at a time. This is done with 16 128 bit registers:
```
XMM0...XMM15

  127                   0
   +--------------------+
   |      XMM0          |
   +--------------------+
   ...
```
So each register can hold 128 bits which means we can store one 128 bit value,
or 2 64-bit values, or 4 32-bit values, or 8 16-bit values, or 16 8 bit values.


SSE was introduces in 1998, SSE2 in 1999, and SSE3 in 2004.

Advanced Vector Extension (AVX) was introduced in 2011 and expanded the
16 registers to 256 bits and then names for them are
```
XMM0...XMM15  128-bits
YMM0...YMM15  256-bits

255                    127                    0
   +------------------------------------------+
   |      YMM0          |     XMM0            |
   +------------------------------------------+
   ...
```
Now, these registers can store 8 32-bit floating point values, or 4 64-bit
values.
In 2013 Intel released AVX-2 which also allowed the values to be integers in
addition to floating point values.

AVX-512 increased the number of registers to 32 and also increased the size of
the registers to 512.
```
XMM0...XMM15  128-bits
YMM0...YMM15  256-bits
ZMM1...ZMM31  512-bits

 512                   255                    127                    0
   +------------------------------------------+----------------------+
   |      ZMM1          |        YMM0         |          XMM0        |
   +------------------------------------------+----------------------+
   ...
```

### Scalar operations
Only operate on the least significant data elements. So if we have a 64-bit
floating point value a scalar operation only operates on the bits 0-31, and
for a 128 bit value only on the bits 0-64.

### Packed operations
The operate on the whole register bits in parallel..


### Single Instruction Multiple Data (SIMD)
Is what is says on the box, a single instructions (add, sub, mul, div, shift,
compares, datals
) on
multiple data elements during the same instruction. So one instruction can
replace multiple.

### MOVQ
So lets start very simple and see how we can place data in a register.
```assembly
.data
v1: .float 1.0, 2.0, 3.0, 4.0 
...
  movaps v1, %xmm0
```
```console
(lldb) expr -f float32 -- $xmm0
(unsigned char __attribute__((ext_vector_type(16)))) $2 = (1, 2, 3, 4)
```
So that looks like what we expect. We have declared v1 to be the address where
there will be four floats which each are 4 bytes. 
Just printing the register `xmm0` will give us:
```console
(lldb) register read xmm0
    xmm0 = {0x00 0x00 0x80 0x3f 0x00 0x00 0x00 0x40 0x00 0x00 0x40 0x40 0x00 0x00 0x80 0x40}
```
Notice that this showing the data in this register as 16 bytes (8x16=128), but
we specified that our data is a float which is 4 bytes each. 128/4=32.
Next we can add these two vector together:
```assembly
  addps %xmm1, %xmm0
```
This is using add packad (the p) single precision (the s which is 32 bits). This
is a destructive operation and add the values in source xmm1 with the values
in destination xmm0 and then overrite the values in the destination register.
We can inspect the values in xmm0 after this operation:
```console
(lldb) expr -f float32 -- $xmm0
(unsigned char __attribute__((ext_vector_type(16)))) $15 = (2, 4, 6, 8)
```

