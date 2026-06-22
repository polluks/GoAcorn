# aC=orn for Commodore 128
# Build with ca65/ld65 (cc65 toolchain)
#
# Target: C128 native mode, 2 MHz, VDC 80-column only

CA65    := ca65
LD65    := ld65
CFG     := applecorn.cfg

# ca65 flags: target C128 (8502 CPU)
# 6502x enables 6502 + 65C02 + undocumented insns for compat during port
CA65FLAGS := -t c128 --cpu 65c02

SRCDIR  := src
INCDIR  := src

# Main source file (includes all others via .include)
MAIN    := $(SRCDIR)/applecorn.s

# All source files (for dependency tracking)
SRCS    := $(wildcard $(SRCDIR)/*.s)
OBJS    := $(SRCDIR)/applecorn.o

# Output files: loader at $2000, MOS code at $D000
LOADER_PRG := aC=orn.prg
MOS_PRG    := loadmos.prg

.PHONY: all clean check

all: $(LOADER_PRG) $(MOS_PRG)

# Assemble the main file
$(SRCDIR)/applecorn.o: $(MAIN) $(SRCS) $(CFG)
	$(CA65) $(CA65FLAGS) -I $(INCDIR) -o $@ $(MAIN)

# Link both output files from one ld65 invocation
# ld65 outputs raw binary; add PRG headers (2-byte load address)
$(LOADER_PRG) $(MOS_PRG): $(OBJS) $(CFG)
	$(LD65) -C $(CFG) -o $(LOADER_PRG) $(OBJS)
	printf '\x00\x20' | cat - $(LOADER_PRG) > $(LOADER_PRG).tmp && \
		mv $(LOADER_PRG).tmp $(LOADER_PRG)
	printf '\x00\xc0' | cat - $(MOS_PRG) > $(MOS_PRG).tmp && \
		mv $(MOS_PRG).tmp $(MOS_PRG)

# Update D64 disk image with built PRGs
d64: $(LOADER_PRG) $(MOS_PRG)
	c1541 -attach acorn.d64 -delete "aC=orn" -write $(LOADER_PRG) "aC=orn" 2>&1
	c1541 -attach acorn.d64 -delete "loadmos" -write $(MOS_PRG) "loadmos" 2>&1

# Quick test in x128 (if available)
run: $(LOADER_PRG) $(MOS_PRG)
	x128 -autostartprgmode 1 -autostart $(LOADER_PRG)

clean:
	rm -f $(OBJS) $(LOADER_PRG) $(MOS_PRG) *.o

check: all
	@echo "=== Build check ==="
	@filesize=$$(stat -c%s "$(LOADER_PRG)" 2>/dev/null || echo 0); \
	 if [ "$$filesize" -gt 512 ]; then echo "PASS: $(LOADER_PRG) = $$filesize bytes"; \
	 else echo "FAIL: $(LOADER_PRG) too small ($$filesize bytes)"; false; fi
	@filesize=$$(stat -c%s "$(MOS_PRG)" 2>/dev/null || echo 0); \
	 if [ "$$filesize" -gt 1024 ]; then echo "PASS: $(MOS_PRG) = $$filesize bytes"; \
	 else echo "FAIL: $(MOS_PRG) too small ($$filesize bytes)"; false; fi
	@headbytes=$$(xxd -l 2 -p "$(LOADER_PRG)" 2>/dev/null); \
	 if [ "$$headbytes" = "0020" ]; then echo "PASS: $(LOADER_PRG) load addr = \$$2000"; \
	 else echo "FAIL: $(LOADER_PRG) load addr is $$headbytes, expected 0020"; false; fi
	@headbytes=$$(xxd -l 2 -p "$(MOS_PRG)" 2>/dev/null); \
	 if [ "$$headbytes" = "00c0" ]; then echo "PASS: $(MOS_PRG) load addr = \$$C000"; \
	 else echo "FAIL: $(MOS_PRG) load addr is $$headbytes, expected 00c0"; false; fi
	@echo "=== Smoke test in x128 ==="
	@if command -v x128 >/dev/null 2>&1; then \
	 timeout 8 x128 -silent -warp -autostartprgmode 1 -autostart $(LOADER_PRG); \
	 rc=$$?; \
	 if [ $$rc -eq 124 ]; then \
	   echo "PASS: x128 ran for 8s without crash"; \
	 elif [ $$rc -eq 0 ]; then \
	   echo "PASS: x128 exited cleanly"; \
	 else \
	   echo "FAIL: x128 exited with code $$rc"; false; \
	 fi; \
	else \
	 echo "SKIP: x128 not found"; \
	fi
	@echo "=== All checks passed ==="
