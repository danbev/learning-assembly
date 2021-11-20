first: first.o
	aarch64-linux-gnu-ld -g -o $@ $<

first.o: src/first.s
	aarch64-linux-gnu-as -g -o $@ $<

add: add.o
	aarch64-linux-gnu-ld -g -o $@ $<

add.o: src/add.s
	#aarch64-linux-gnu-as -g -o $@ $<
	armasm -g -o $@ $<

branch: branch.o
	aarch64-linux-gnu-ld -g -o $@ $<

branch.o: src/branch.s
	aarch64-linux-gnu-as -g -o $@ $<

xzr: xzr.o
	aarch64-linux-gnu-ld -g -o $@ $<

xzr.o: src/xzr.s
	aarch64-linux-gnu-as -g -o $@ $<

stack: stack.o
	aarch64-linux-gnu-ld -g -o $@ $<

stack.o: src/stack.s
	aarch64-linux-gnu-as -g -o $@ $<

ldr: ldr.o
	aarch64-linux-gnu-ld -g -o $@ $<

ldr.o: src/ldr.s
	aarch64-linux-gnu-as -g -o $@ $<

func: func.o
	aarch64-linux-gnu-ld -g -o $@ $<

func.o: src/func.s
	aarch64-linux-gnu-as -g -o $@ $<

space: space.o
	arm-none-eabi-ld -g -o $@ $<

space.o: src/space.s
	arm-none-eabi-as -g -o $@ $<

rename: rename.o
	arm-none-eabi-ld -g -o $@ $<

rename.o: src/rename.s
	arm-none-eabi-as -g -o $@ $<

mov: mov.o
	arm-none-eabi-ld -g -o $@ $<

mov.o: src/mov.s
	arm-none-eabi-as -g -o $@ $<

ldmia: ldmia.o
	arm-none-eabi-ld -g -o $@ $<

ldmia.o: src/ldmia.s
	arm-none-eabi-as -g -o $@ $<

.PHONY: run-first
run-first: first
	qemu-aarch64 $<

.PHONY: run-add
run-add: add
	qemu-aarch64 $<


.PHONY: clean
clean:
	${RM} first *.o


