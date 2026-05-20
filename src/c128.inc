; C128 platform master include
; Include this in applecorn.s after syntax conversion
; Replaces the Apple II hardware definitions

.include "vdc.inc"
.include "cia.inc"
.include "mmu.inc"
.include "kernal.inc"

; C128 specific zero-page and hardware locations

; CPU I/O port (8502 internal, like 6510)
CPU_DDR     = $00
CPU_PORT    = $01

; C128 KERNAL/BASIC ZP locations
TXTTAB      = $2D
VARTAB      = $2F
ARYTAB      = $31
STREND      = $33
FRETOP      = $37
MEMSIZ      = $39
CURLIN      = $3B

; Virtual memory map for the BBC Micro VM on C128
; Using MMU bank switching to emulate the BBC Micro layout
;
; Main memory (bank 0):
;   $0000-$7FFF: Applecorn loader and main memory code
;   $8000-$BFFF: Available for BBC Micro ROM data (bank 1)
;   $C000-$CFFF: I/O space
;   $D000-$DFFF: I/O space (VDC, CIA, MMU)
;   $E000-$FFFF: KERNAL ROM / available
;
; Aux memory (bank 1):
;   $0000-$7FFF: BBC Micro user RAM (32K)
;   $8000-$BFFF: Acorn language ROM
;   $C000-$CFFF: Reserved
;   $C000-$CFFF: Applecorn MOS emulation code (lower 4K)
;   $D000-$DFFF: I/O space (VDC, CIA, MMU)
;   $E000-$FFFF: KERNAL ROM (bank 0) / future MOS expansion (bank 1)

; C128 2MHz speed (always on - no VIC)
FASTCLOCK    = $00
