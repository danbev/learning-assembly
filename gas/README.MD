## GNU Assembler examples

### Assemble

    as -g -arch x86_64 64bit.s -o 64bit.o

### Link

    ld -e _start -macosx_version_min 10.8 -lSystem -arch x86_64 64bit.o -o 64bit

