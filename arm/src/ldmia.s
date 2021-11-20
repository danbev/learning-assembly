.data

.text
array:
  .word 0x000000000 /* 4 bytes */
  .word 0x000000001 /* 4 bytes */
  .word 0x000000010 /* 4 bytes */
  .word 0x000000011 /* 4 bytes */
  .word 0x000000100 /* 4 bytes */

.global _start

_start:
  adr r0, array
  ldmia r0, {r1, r2, r3, r4, r5}
  b .
