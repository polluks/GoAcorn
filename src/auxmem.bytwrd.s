; AUXMEM.BYTWRD.S - C128 byte/word operations
; OSWORD call handlers only (OSBYTE handlers in auxmem.misc.s)

; OSWORD - Perform a word-based operation
; A = OSWORD call number (0-7)
OSWORD:
            CMP   #0
            BEQ   OSWORD0     ; Read line
            CMP   #1
            BEQ   OSWORD1     ; Read character at cursor
            RTS

OSWORD0:
; Read line from keyboard into buffer
            RTS

OSWORD1:
; Read character at cursor position
            RTS
