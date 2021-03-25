first: first.o
	${LD} -o $@ $<

check_zero: check_zero.o
	${LD} -o $@ $<

write: write.o
	${LD} -o $@ $<

jle: jle.o
	${LD} -o $@ $<

cfi: cfi.o
	${LD} -o $@ $<

arr: arr.o
	${LD} -o $@ $<

multi: multi.o
	${LD} -o $@ $<

div: div.o
	${LD} -o $@ $<

exec-stack: exec-stack.o
	${LD} -o $@ $<

carry: carry.o
	${LD} -o $@ $<

zero-flag: zero-flag.o
	${LD} -o $@ $<

direction-flag: direction-flag.o
	${LD} -o $@ $<

cmov: cmov.o
	${LD} -o $@ $<

function: function.o
	${LD} -o $@ $<


float: float.o
	${LD} -o $@ $<

sse: sse.o
	${LD} -o $@ $<

mmx: mmx.o
	${LD} -o $@ $<

test: test.o
	${LD} -o $@ $<

setne: setne.o
	${LD} -o $@ $<

bcd: bcd.o
	${LD} -melf_i386 -o $@ $<

bcd.o: bcd.s
	${AS} -g --32 -o bcd.o bcd.s

%.o: %.s
	${AS} -g -o $@ $<

.PHONY: clean
clean:
	${RM} -f first check_zero jle write *.o
