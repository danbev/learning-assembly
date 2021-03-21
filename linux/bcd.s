.data

unpacked1: .byte 8
unpacked2: .byte 4

.global _start

.text
_start: 
  mov unpacked1, %al
  mov unpacked2, %bl
  add %bl, %al
  aaa

  mov $1, %eax
  mov $0, %ebx
  int $0x80
