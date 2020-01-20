hello: hello.o
	gcc -o $@ $< -no-pie

hello.o: hello.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

printf: printf.o
	gcc -o $@ $< -no-pie

printf.o: printf.asm
	nasm -f elf64 -g -F dwarf -o $@ $<

clean:
	$(info "cleaning...")
	rm -rf hello printf

