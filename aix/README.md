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

#### load immediate (li)
Loads a constant into a register, similar to `mov $1, %rax` one would do:
```assembly
.data 
message:
  .string 'Bajja\n'
  len = . - message

.global _start

.text
_start:
   li 0, 1           # load constant 1 into register 0 (syscall number)
```
This is actually not an instruction but a memonic which can be though of as a
preprocessor macro. The assembler will interpret it and generate the correct
instructions for the memonic. For example the `li` instruction above will
become:
```assembler
addi 0, 0, 1
```
This might look like it is adding 1 to register 0 and then storing that in
register 0 but gpr0 is sometimes read as 0 depending on the context and in the
case of addi the spec says that it is 0 in this case.

#### add
```assembly
addi 4, 3, 5
```
The above will add the value of register 5 to the contents of register 3 and
then store the result in register 4.

#### addi
Add immediate
```assembly
addi 4, 3, 5
```
The above will add 5 to the contents of register 3 and then store the result
in register 4. Notice that we are adding the constant 5 and not the contents of
register 5.

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


#### mtvsrd
```assembly
mtvsrd  32,14
```

