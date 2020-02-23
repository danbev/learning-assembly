.global _start
.data

.text
_start:
  movl  $1, %eax
  REX.W movl  $1, %eax
  movl  $0, %ebx
  int   $0x80
