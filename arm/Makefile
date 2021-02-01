first: first.o
	aarch64-linux-gnu-ld -o $@ $<


first.o: src/first.s
	aarch64-linux-gnu-as -o $@ $<

.PHONY: run-first
run-first: first
	qemu-aarch64 first


.PHONY: clean
clean:
	${RM} first *.o


