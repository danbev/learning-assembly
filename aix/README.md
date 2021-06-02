### AIX Assembler/Assembly notes
Advanced Interactive executive (AIX) is a proprietery UNIX operating system sold
by IBM and introduced in 1986.

Servers that run this OS are AS/400, later known as iSeries, System i, OS/400
later known as i5/OS and now IBMi. And also IBM POWER and POWERPC in the
RS/600 later known as pSeries, then System p


#### Assembly syntax
Being a RISC processor all instructions take a register as its first operand.
And unlike CISC processors the registers use number instead of names. For
general purpose data there are 32 registers.

Because there are so many registers all arguments to functions can be passed
in registers, starting from register 3 which would be the first argument for
a function call.
For system calls the syscall number goes into gpr0 and the args begin in
gpr3.

#### or 
```assembly
or rA, rS, rB
```
This will register S with register B and then store the result in register A.
There is also an simplified memonic named `mr` (memonic or?):
```assembly
mr rA,sA
```
Which is the same as:
```assembly
or rA, rS, rS
```

Example:
```assembly
mr 9,3
```
So this would or the contents of gpr3 is or:ed with itself and the the result
is stored in gpr9. Is this some sort of way to move the contents between
registers? I mean or with itself will not alter the content (not like xor which
would be the same thing as setting it to zero.


