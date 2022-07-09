AS=riscv64-linux-gnu-as
LD=riscv64-linux-gnu-ld
ASFLAGS=-g
OUT_DIR=out

out/hello: src/hello.s | $(OUT_DIR)
	$(AS) $(ASFLAGS) $< -o $@.o
	$(LD) $@.o -o $@

out:
	@mkdir $(OUT_DIR)

.PHONY: clean
clean: 
	@${RM} -rf $(OUT_DIR)
