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

%.o: %.s
	${AS} -g -o $@ $<

.PHONY: clean
clean:
	${RM} -f first check_zero jle write *.o
