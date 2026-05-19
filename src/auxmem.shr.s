; AUXMEM.SHR.S - C128 stub (Super Hi-Res graphics not applicable)
; The C128 uses VDC for graphics, not Apple II SHR

; Stub entries for SHR graphics calls
; These are called by the BBC Micro emulation when MODE 0 or 1 is selected

; Initialize SHR mode (stub - delegates to VDC)
SHR_INIT:
            RTS

; SHR plot point
SHR_PLOT:
            RTS

; SHR draw line
SHR_LINE:
            RTS

; SHR fill area
SHR_FILL:
            RTS

; SHR set palette
SHR_PALETTE:
            RTS

; SHR set colour
SHR_COLOUR:
            RTS

; SHR clear screen
SHR_CLS:
            JMP   VDU_CLS

; SHR scroll
SHR_SCROLL:
            RTS

; SHR text output
SHR_PUTCH:
            JMP   VDC_PUTCHAR

; SHR mode-specific VDU handlers
SHR_VDU:
            RTS
