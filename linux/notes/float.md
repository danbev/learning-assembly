## Floating points in assembly
The Floating Point Unit (FPU) is a decicated hardware component that implements
operations like addition, subtraction, multiplication and division on floating
point numbers. There are also instructions for more advanced operations like
square root, trig funtions, logarithm functions.
It supports multiple data types including single/double precision
floating-point, signed integers, and BCD.

This unit has its own registers:
```
  79                                   0
   +-----------------------------------+
R7 |                                   |
   +-----------------------------------+
R6 |                                   |
   +-----------------------------------+
R5 |                                   |
   +-----------------------------------+
R4 |                                   |
   +-----------------------------------+
R3 |                                   |
   +-----------------------------------+
R2 |                                   |
   +-----------------------------------+
R1 |                                   |
   +-----------------------------------+
R0 |                                   |
   +-----------------------------------+
```
These 8 registers make up a stack. Data that can be pushed onto this stack
are signed integers of sizes 16, 32, or 64 bits. Floating point values of sizes
32, 64, or 80 bits. BCD packed quantities.
There is no way to transfer data from one of these registers to the general
purpose x86 registers.

ST(0) denotes the top of the stack. ST(i) denotes the i-th register from the
current top. Most of the instructions use ST(0) as an implicit operand.

There are also registers for general purpose in this unit. These are 16-bit
registers.

### Control register
```
             Control register
  15                                         0
   +-----------------------------------------+
   |                                         |
   +-----------------------------------------+
```

### Status/Word register
The status register is sometimes called the 
```
             Status register
  15                                         0
   +-----------------------------------------+
   |B|C3|TOP|C2|C1|C0|ES|SF|PE|UE|OE|ZE|DE|IE|
   +-----------------------------------------+
```
These values are cleared using `fclex` or `fnclex` (Clear Exceptions)
instructions.
The values cannot be used directly but instead one has to copied to memory
or to register `ax` using `fstsw` or `fnstsw` (Store FPU status word)

### Tag register
This register describes the content of the data on the stack registers.
```
             Tag register
  15                                         0
   +-----------------------------------------+
   |                                         |
   +-----------------------------------------+
```


### Defining a float
```assembly
.data
  radius: .float 3.14
  m: .float 2.2
```
A float is a 64 bit value. A short is a 32 bit value.

### Data transfer
These instruction deal with pushing and poping values to/from the stack
These instructions are named differently depending on the data being
pushed/poped (floating-point, signed integer, or packed BCD).

`fld` (floating point unit load) pushed a floating point value onto the register
stack. The operand can be a memory location but it can also be st(0) (the value
on the top of the stack)

`fild` (float point unit Integer Load) reads a signed integer from memory and
converts it to a double extended precision value and then pushes that value onto
the register stack.

`fst` (floating point unit store) copies st(0) to st(i) or a memory location.
`fstp` (floating point unit store and pop) copies st(0) to st(i) or a memory
location and also pops the stack (removes the entry or perhaps just adjusts
the stack pointer to the slot before it).

`fist` floating point unit convert to Integer and store the result in a memory
location.
`fistp` floating point unit convert to Integer and store the result in a memory
location and pops the stack.
`fisttp` converts the value in st(0) to an integer using truncation, and saves
the result in the specified memory location and then pops the stack. This
instruction is only available on processors that support SSE3.

`fxch` exchanges the content of register st(0) and st(i).

`fcmovcc` conditionally copies the content of st(i) to st(0) if the condition
is true.

### Push a float onto the FPU stack
```assembly
  fld radius
```
We can inspect this by using:
```console
(lldb) expr -f b -- radius
(void *) $2 = 0b0000000000000000000000000000000001000000010010001111010111000011
(lldb) register read st0
```

###  Copy value st(0)
Floating point store and then pop (the FPU stack that is):
```console
  fstp result
```

### Multiplication
```assembly
  fld radius
  fld m
  fmulp

(lldb) expr -f f -- result
(void *) $2 = 5.3733119381271126E-315
```
