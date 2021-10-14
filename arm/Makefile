first: first.o
	aarch64-linux-gnu-ld -g -o $@ $<

first.o: src/first.s
	aarch64-linux-gnu-as -g -o $@ $<

add: add.o
	aarch64-linux-gnu-ld -g -o $@ $<

add.o: src/add.s
	aarch64-linux-gnu-as -g -o $@ $<

branch: branch.o
	aarch64-linux-gnu-ld -g -o $@ $<

branch.o: src/branch.s
	aarch64-linux-gnu-as -g -o $@ $<

xzr: xzr.o
	aarch64-linux-gnu-ld -g -o $@ $<

xzr.o: src/xzr.s
	aarch64-linux-gnu-as -g -o $@ $<

ldr: ldr.o
	aarch64-linux-gnu-ld -g -o $@ $<

ldr.o: src/ldr.s
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


