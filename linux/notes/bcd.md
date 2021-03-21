### Binary Coded Decimal
This is where a decimal (base 10) is divided into individual bytes (so 8 bit. For example
123 would become:
```
  1         2        3
00000001 00000010 00000011
```
So we are representing on decimal digit, that is 0-9 as a byte. But we might
notice that we are using 4 bits to do this and 4 bits (1 nibble) can represent
0-15.

So what happens if we add two BCD numbers say 5 and 6:
```
 00000101
+00000110
-----
 00001011
```
That is 11 in decimal but notice that 11 in BCD is:
```
00000001 00000001
```
So there needs something to be done after the addition to bring the result into
BCD after adding.

### Unpacked BCD
Lets take our example 123:
```
  1         2        3
00000001 00000010 00000011
```
Notice that we are only using the lower nibble, the upper is left unused and
wasted.

### Packed BCD
Saves space by packing two digits into a byte.
```
  1         2 
00000001 00000010 Unpacked BCD
00010010          Packed BCD
```
So instead of two bytes we can fit the same information in a single byte.
Instructions need to understand if the data it is operating on is in unpacked
or packed format to be able to perform the correct operations.

So we would use a .byte type to store either a unpacked single BCD number or
the same .byte could be used to store two packed BCD numbers.

### Adjust After Addition (aaa)
This instruction adjusts the al register. It is added after an add instruction
which adds two unpacked bcd values together and places the sum in `al`.

Lets take a simple example where we add two unpacked values.
The examples can be found in [bcd.s](../bcd.s).
```console
3   	unpacked1: .byte 8
   4   	unpacked2: .byte 4
   5   	
   6   	.global _start
   7   	
   8   	.text
   9   	_start: 
   10  	  mov unpacked1, %al
   11  	  mov unpacked2, %bl
-> 12  	  add %bl, %al
   13  	  aaa
```
Now if we inspect the values before the addtion:
```console
(lldb) register read -f b al
      al = 0b00001000
(lldb) register read -f b bl
      bl = 0b00000100
```
And after the addition we have the value in `al`:
```console
(lldb) register read -f b al
      al = 0b00001100
```
Notice that this addition generated 1100 which is 12. But since we are working
with unpacked bcd values we want the result in that format. We can get that by
using the aaa instruction:

And after the addition the ascii adjust after addition (aaa):
```console
(lldb) register read -f b ax
      ax = 0b0000 0001 0000 0010
                    1         2
```


