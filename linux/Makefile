first: first.o
	${LD} -o $@ $<

first.o: first.s
	${AS} -g -o $@ $<

.PHONY: clean
clean:
	${RM} -f first
