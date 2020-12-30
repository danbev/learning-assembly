cdecl: cdecl.c
	${CC} -m32 -o $@ $<

stdcall: stdcall.c
	${CC} -m32 -s $<

.PHONY: clean
clean:
	${RM} -f cdecl stdcall
