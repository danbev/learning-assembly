hello: hello.o
	ld $@.o -o $@

hello.o: hello.asm
	nasm -f macho64 -o $@.o $<

clean:
	$(info "cleaning...")
	rm -rf hello

