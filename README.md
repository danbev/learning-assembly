## Assembler
The project only contains small programs to help me learn assembler.

[gas](./gas) Contains examples using the GNU Assembler.  
[nasm](./nasm) Contains examples using the Netwide Assembler.  
[c](./c) C programs used for viewing the generated assembler code.  

### Registers
ebp     The stack base pointer
esp     The stack pointer

### The Stack
The stack consists of memory locations reserved at the end of the memory area allocated to the program. 
The ESP register is used to point to the top of the stack in memory.
When PUSH is used it places data on the bottom of this memory area and decreases the ESP (stack pointer).

When POP is used it moves data to a register or a memory location and increases the ESP.

When a c-style function call is made it places the required arguments on the stack and the call
instruction places the return address onto the stack aswell.

        param2           8(%esp)
        param1           4(%esp)
        return address <- (%esp)

So ESP points to the top of the stack where the return address is. If we used the POP instruction to get the
parameters as the return address might be lost in the process. This can be avoided using indirect addressing, 
as in using 4(%esp) to access the parameters and avoid ESP to be incremented. But what if the function itself
needs to push data onto the stack, this would also change the value of ESP and it would throw off the indirect
addressing. Instead what is common practice is to store the current value of ESP (which is pointing to the 
return address) in EBP. Then use indirect addressing with EBP which will no change if the PUSH/POP instructions
are used. The calling function might also be using the EBP for the same reason so we first PUSH that value
onto the stack, decreasing the ESP. So the value of EBP is first pushed onto the stack and then we store
the current ESP value in EBP to enable indirect addressing.

          param2            12(%esp)
          param1            8(%esp)
          return address <- 4(%esp)
    esp ->old EBP        <-  (%esp)


    _main:
        pushl %ebp
        mov %esp, %ebp
        ....
        movl %ebp, %esp
        popl %ebp
        ret

Resetting the ESP register value ensures that any data placed on the stack within the function but not 
cleaned off will be discarded when execution returns to the main program (otherwise, the RET instruction could return to the wrong memory location).

Now, since we are using EBP we can place additional data on the stack without affecting how input parameters values are accessed. We can used EBP with indirect addressing to create local variables:

          param2            12(%esp)
          param1            8(%esp)
          return address    4(%esp)
    esp ->old EBP           (%esp)
          local var1       -4(%esp)
          local var2       -8(%esp)
          local var3       -12(%esp)

But what would happen if the function now uses the PUSH instruction to push data onto the stack?  
Well, it would overrwrite one or more local variables since ESP was not affected by the usage of EBP.
We need some way of reserving space for these local variables so that ESP points to -12(%esp) in our
case.

    _main:
        pushl %ebp
        mov %esp, %ebp
        subl $12, %esp            ; reserv 8 bytes to local variables.
   

Also, when the function returns the parameters are still on the stack which might not be expected
but the calling function. What you should do it reset the stack to the state before the call, when
there were now parameters on the stack. You can do this by adding 4,8,12 (what ever the size and number
of parameters are).

### Compare while(flat) to while(flag == true)
(while flag == true) :

    while`main:
    0x100000f70 <+0>:  pushq  %rbp
    0x100000f71 <+1>:  movq   %rsp, %rbp
    0x100000f74 <+4>:  movl   $0x0, -0x4(%rbp) ## padding?
->  0x100000f7b <+11>: movb   $0x1, -0x5(%rbp) ## flag = true
    0x100000f7f <+15>: movl   $0x5, -0xc(%rbp)
    0x100000f86 <+22>: cmpl   $0x5, -0xc(%rbp)
    0x100000f8a <+26>: jne    0x100000f94               ; <+36> at while.cc:10
    0x100000f90 <+32>: movb   $0x0, -0x5(%rbp)
    0x100000f94 <+36>: movl   -0xc(%rbp), %eax ## move a into eax
    0x100000f97 <+39>: addl   $0x1, %eax ## increment a
    0x100000f9a <+42>: movl   %eax, -0xc(%rbp) ## move incremented value back into a

    0x100000f9d <+45>: movb   -0x5(%rbp), %al ## move flat into al
    0x100000fa0 <+48>: andb   $0x1, %al ## AND 1 and flag
    0x100000fa2 <+50>: movzbl %al, %ecx ## conditionally move al into ecx if zero
    0x100000fa5 <+53>: cmpl   $0x1, %ecx ## flat == true
    0x100000fa8 <+56>: je     0x100000f86               ; <+22> at while.cc:7

    0x100000fae <+62>: xorl   %eax, %eax
    0x100000fb0 <+64>: popq   %rbp
    0x100000fb1 <+65>: retq

Compared to using while(flag):

    while`main:
    0x100000f70 <+0>:  pushq  %rbp
    0x100000f71 <+1>:  movq   %rsp, %rbp
    0x100000f74 <+4>:  movl   $0x0, -0x4(%rbp) ## padding?
->  0x100000f7b <+11>: movb   $0x1, -0x5(%rbp) ## flag = true
    0x100000f7f <+15>: movl   $0x5, -0xc(%rbp) ## a = 5
    0x100000f86 <+22>: cmpl   $0x5, -0xc(%rbp) ## a == 5
    0x100000f8a <+26>: jne    0x100000f94               ; <+36> at while.cc:10
    0x100000f90 <+32>: movb   $0x0, -0x5(%rbp) ## flag = false
    0x100000f94 <+36>: movl   -0xc(%rbp), %eax ## move a into eax
    0x100000f97 <+39>: addl   $0x1, %eax ## increment a
    0x100000f9a <+42>: movl   %eax, -0xc(%rbp) ## move incremented value back into a

    0x100000f9d <+45>: testb  $0x1, -0x5(%rbp) ## AND 1 and flag
    0x100000fa1 <+49>: jne    0x100000f86               ; <+22> at while.cc:7 ## branch if not equal

    0x100000fa7 <+55>: xorl   %eax, %eax
    0x100000fa9 <+57>: popq   %rbp
    0x100000faa <+58>: retq

