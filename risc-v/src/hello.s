.global _start

_start:
  addi  a0, x0, 1      # 1 = standard out
  la    a1, msg        # load address of message
  addi  a2, x0, 8      # length of our string
  addi  a7, x0, 64     # linux write system call
  ecall                # Call linux to output the string

# Setup the parameters to exit the program
# and then call Linux to do it.

  addi    a0, x0, 0   # Use 0 return code
  addi    a7, x0, 93  # Service command code 93 terminates
  ecall               # Call linux to terminate the program

.data
msg:      .ascii "Bajja!\n"
