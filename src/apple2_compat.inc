; Apple II compatibility layer for C128
; Maps Apple II hardware concepts to C128 equivalents
; This allows the BBC Micro emulation source files to compile
; with minimal changes during the porting process.

; ============================================================
; Memory management - Apple LC card -> C128 MMU
; ============================================================

; Apple II LC card softswitches - mapped to no-ops or MMU ops
; These are used for bank switching between main and aux memory
RDMAINRAM   = MMU_CR2
RDCARDRAM  = MMU_CR2
WRMAINRAM  = MMU_CR2
WRCARDRAM  = MMU_CR2
SETSTDZP   = MMU_CR2
SETALTZP   = MMU_CR2

; ROM banking
ROMIN      = MMU_CR2
LCBANK1    = MMU_CR2

; ============================================================
; Apple II ROM routines -> C128 KERNAL equivalents
; ============================================================

; Character output
BELL       = $FFD2   ; CHROUT (KERNAL) - will handle bell via CHROUT
COUT1      = $FFD2   ; CHROUT
CROUT      = $FFD2   ; Print CR
HOME       = $FF81   ; CINT - clear screen (initialize editor)

; Keyboard
KEYBOARD   = $DC01   ; CIA1 PRB (keyboard row read)
KBDSTRB    = $DC00   ; CIA1 PRA (keyboard column drive)

; ============================================================
; ProDOS -> KERNAL API stubs
; ============================================================

; MLI entry point (ProDOS) -> mapped to non-functional
; Individual MLI calls need to be converted to KERNAL calls
MLI        = $FFFF   ; Will be replaced per-call

; ProDOS global page - keep at same addresses for compatibility
DEVNUM     = $BF30
DEVCNT     = $BF31
DEVLST     = $BF32

; Version bytes
IBAKVER    = $BFFC
IVERSION   = $BFFD

; ============================================================
; Apple II I/O softswitches -> C128 equivalents
; ============================================================

; 80 column display control -> VDC
CLR80VID   = VDC_ADDR
SET80VID   = VDC_ADDR
CLRALTCHAR = VDC_ADDR
SETALTCHAR = VDC_ADDR

; Video mode softswitches -> VDC
TEXTON     = VDC_ADDR
GRON       = VDC_ADDR
FULLGR     = VDC_ADDR
MIXGRTXT   = VDC_ADDR
PAGE1      = VDC_ADDR
PAGE2      = VDC_ADDR
LORES      = VDC_ADDR
HIRES      = VDC_ADDR

; Graphics softswitches
AN0OFF     = VDC_ADDR
AN0ON      = VDC_ADDR
AN1OFF     = VDC_ADDR
AN1ON      = VDC_ADDR
AN2OFF     = VDC_ADDR
AN2ON      = VDC_ADDR
AN3OFF     = VDC_ADDR
AN3ON      = VDC_ADDR

; Buttons
BUTTON0    = $DC01   ; CIA1 PRB
BUTTON1    = $DC01

; Speaker -> SID (or no-op)
SPKR       = $D400   ; SID base

; ============================================================
; Apple II zero page locations
; ============================================================
A1L = $3C
A1H = $3D
A2L = $3E
A2H = $3F
A3L = $40
A3H = $41

; XFER variables
STRTL = $FC
STRTH = $FD
