MACOSX := 10.11
OUT := out

.DEFAULT_GOAL := learning_i386

out: 
	mkdir out

cpuid: cpuid.s out
	as -W -arch x86_64 $(OUT)/$@.s -o $@.o
	ld -e _start -macosx_version_min $(MACOSX) -lSystem -arch x86_64 $@.o -o $@

learning_i386: learning_i386.s out
	as -W -g -arch i386 -o $(OUT)/$@.o $@.s
	ld -arch i386 -macosx_version_min $(MACOSX) -o $(OUT)/$@ $(OUT)/$@.o -lSystem

.PHONY: clean

clean: 
	rm -fr out
