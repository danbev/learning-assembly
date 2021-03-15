.data
v1: .float 1.0, 2.0, 3.0, 4.0  # .float is 4 bytes. 32 bytes in total
v2: .float 5.0, 6.0, 7.0, 8.0  

v3: .double 1.0, 2.0
v4: .double 3.0, 4.0

i1: .int 1, 2, 3, 4
i2: .int 5, 6, 7, 8

i3: .byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

.global _start

.text
_start:
  nop
  movaps v1, %xmm0    # move aligned packed single precision
  movaps v2, %xmm1    # move aligned packed single precision
  addps %xmm1, %xmm0  # add packed single precision src, dest (result in dest)

  xorps %xmm0, %xmm0   # xor packed single precision
  xorps %xmm1, %xmm1   # xor packed single precision

  movapd v3, %xmm0    # move aligned packed double precision
  movapd v4, %xmm1    # move aligned packed double precision
  addpd %xmm1, %xmm0  # add packed double precision src, dest (result in dest)

  xorps %xmm0, %xmm0   # xor packed single precision
  movapd i1, %xmm0
  addps i2, %xmm0  # add packed double precision src, dest (result in dest)

  xorps %xmm0, %xmm0   # xor packed single precision
  movapd i3, %xmm0
  paddb i3, %xmm0
  
  mov $60, %rax
  mov $0, %rdi
  syscall
