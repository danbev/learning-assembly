first: first.o
	${LD} -o $@ $<

first.o: first.s
	${AS} -g -o $@ $<

check_zero: check_zero.o
	${LD} -o $@ $<

check_zero.o: check_zero.s
	${AS} -g -o $@ $<

.PHONY: clean
clean:
	${RM} -f first check_zero
