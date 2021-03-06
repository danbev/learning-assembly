cdecl: cdecl.c
	${CC} -m32 -o $@ $<

stdcall: stdcall.c
	${CC} -m32 -o $@ $<

fastcall: fastcall.c
	${CC} -m32 -o $@ $<
	#${CC} -m32 -s $<

cache: cache.c
	${CC} -g -O0 -o $@ $<

.PHONY: clean
clean:
	${RM} -f cdecl stdcall fastcall.s
