hello: hello.o
	ld -no-pie -e main -o $@ $<

hello.o: hello.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

printf: printf.o
	gcc -o $@ $< -no-pie

printf.o: printf.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

function: function.o
	gcc -o $@ $< -no-pie

function.o: function.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

simd-intro: simd-intro.o
	gcc -o $@ $< -no-pie

simd-intro.o: simd-intro.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

align: align.o
	gcc -o $@ $< -no-pie

align.o: align.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

clean:
	$(info "cleaning...")
	rm -rf hello printf function

