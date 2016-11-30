MACOSX := 10.11
OUT := out

PROGS := $(addprefix out/,learning_i386.o)

$(OUT)/%.o : %.s
	as -W -g -arch i386 -o $@ $<
	ld  -no_pie -arch i386 -macosx_version_min $(MACOSX) -o $(OUT)/$* $@ -lSystem

all: $(PROGS)

$(PROGS) : | out

out: 
	mkdir $(OUT)

.PHONY: clean

clean: 
	rm -fr $(OUT)
