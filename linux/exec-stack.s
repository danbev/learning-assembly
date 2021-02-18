.data
code: .long 0xCC

.text
.global _start

_start:
  jmp code

  mov $60, %rax
  mov $0, %rdi
  syscall

/* Notice that with the following directive it is not possible to execute
   instructions in the data section */
#.section .note.GNU-stack,"",@progbits
