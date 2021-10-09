first: first.o
	aarch64-linux-gnu-ld -g -o $@ $<

first.o: src/first.s
	aarch64-linux-gnu-as -g -o $@ $<

add: add.o
	aarch64-linux-gnu-ld -g -o $@ $<

add.o: src/add.s
	aarch64-linux-gnu-as -g -o $@ $<

.PHONY: run-first
run-first: first
	qemu-aarch64 $<

.PHONY: run-add
run-add: add
	qemu-aarch64 $<


.PHONY: clean
clean:
	${RM} first *.o


