cdecl: cdecl.c
	${CC} -m32 -o $@ $<

.PHONY: clean
clean:
	${RM} -f cdecl
