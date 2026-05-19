; AUXMEM.HGR.S - C128 stub (HGR graphics not applicable)
; BBC Micro MODE 2 graphics are mapped to VDC bitmapped mode

; HGR initialization (stub)
HGR_INIT:
            RTS

; HGR plot point
HGR_PLOT:
            RTS

; HGR draw line to point
HGR_LINE:
            RTS

; HGR clear screen
HGR_CLS:
            JMP   VDU_CLS

; HGR text overlay
HGR_TEXT:
            JMP   VDC_PUTCHAR

; Draw character in HGR mode
DRAWCHAR:
            JMP   VDC_PUTCHAR

; Scroll HGR screen up
HGR_SCROLL:
            RTS

; HGR mode VDU handler
HGR_VDU:
            RTS
