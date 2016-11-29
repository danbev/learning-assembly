MACOSX := 10.11
OUT := out

.DEFAULT_GOAL := learning_i386

out: 
	mkdir $(OUT)

cpuid: cpuid.s out
	as -W -arch x86_64 $(OUT)/$@.s -o $@.o
	ld -e _start -macosx_version_min $(MACOSX) -lSystem -arch x86_64 $@.o -o $@

learning_i386: learning_i386.s out
	as -W -g -arch i386 -o $(OUT)/$@.o $@.s
	ld  -no_pie -arch i386 -macosx_version_min $(MACOSX) -o $(OUT)/$@ $(OUT)/$@.o -lSystem

jump: jump.s out
	as -W -g -arch x86_64 -o $(OUT)/$@.o $@.s
	ld -arch x86_64 -macosx_version_min $(MACOSX) -o $(OUT)/$@ $(OUT)/$@.o -lSystem

cli: cli.s out
	as -static -W -g -arch x86_64 -o $(OUT)/$@.o $@.s
	ld -e _main -arch x86_64 -lc -macosx_version_min $(MACOSX) -o $(OUT)/$@ $(OUT)/$@.o

loop: loop.s out
	as -static -W -g -arch x86_64 -o $(OUT)/$@.o $@.s
	ld -e _main -arch x86_64 -lc -macosx_version_min $(MACOSX) -o $(OUT)/$@ $(OUT)/$@.o

.PHONY: clean

clean: 
	rm -fr $(OUT)
