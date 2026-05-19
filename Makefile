# aC=orn for Commodore 128
# Build with ca65/ld65 (cc65 toolchain)
#
# Target: C128 native mode, 2 MHz, VDC 80-column only

CA65    := ca65
LD65    := ld65
CFG     := applecorn.cfg
OUT     := aC=orn.prg

# ca65 flags: target C128 (8502 CPU)
# 6502x enables 6502 + 65C02 + undocumented insns for compat during port
CA65FLAGS := -t c128 --cpu 6502x

SRCDIR  := src
INCDIR  := src

# Main source file (includes all others via .include)
MAIN    := $(SRCDIR)/applecorn.s

# All source files (for dependency tracking)
SRCS    := $(wildcard $(SRCDIR)/*.s)
OBJS    := $(SRCDIR)/applecorn.o

.PHONY: all clean

all: $(OUT)

# Assemble the main file
$(SRCDIR)/applecorn.o: $(MAIN) $(SRCS) $(CFG)
	$(CA65) $(CA65FLAGS) -I $(INCDIR) -o $@ $(MAIN)

# Link into C128 PRG file
$(OUT): $(OBJS) $(CFG)
	$(LD65) -C $(CFG) -o $@ $(OBJS)

# Quick test in x128 (if available)
run: $(OUT)
	x128 -autostartprgmode 1 -autostart $(OUT)

clean:
	rm -f $(OBJS) $(OUT) *.o *.prg
