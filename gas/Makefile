MACOSX := 10.11
OUT := out

SRC_FILES := $(filter-out func.s, $(wildcard *.s))
OBJ_FILES := $(filter-out out/func.o, $(addprefix out/,cli.o cli_lea.o loop.o, 64bit.o, jump.o, jne.o, jz.o, jnz.o, test.o,))

$(OUT)/%.o : %.s | out
	@echo "compile " $@
	as -g -W -arch x86_64 -o $@ $(*F).s
	ld -e _main -macosx_version_min $(MACOSX) -lc -lSystem -arch x86_64 $@ -o $*

$(OUT)/func.o : func.s | out
	as -g -W -arch x86_64 -o $@ $<

$(OUT)/func: func.cc $(OUT)/func.o | out
	clang++ -std=c++11 -O0 -g $(OUT)/func.o func.cc -o $(OUT)/func

out:
	mkdir $(OUT)

$(OUT)/avx_mul : avx_mul.c | out
	clang -mavx -o $@ $<

.PHONY: clean

clean: 
	@rm -fr $(OUT)
