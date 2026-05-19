; AUXMEM.CHARIO.S - C128 character I/O
; OSWRCH and OSRDCH are defined in auxmem.vdu.s
; This file provides additional character I/O utilities

; Check for ESCAPE condition
; Returns: C=1 if Escape pressed
CHECK_ESCAPE:
            LDA   CIA1_PRB
            CMP   CIA1_PRB
            BNE   CHECK_ESCAPE
            CMP   #$7F
            BNE   @NOESC
            LDA   CIA1_PRA
            AND   #$10
            BEQ   @NOESC
            SEC
            RTS
@NOESC:
            CLC
            RTS

; Function key support (stub)
PROCESS_FKEY:
            RTS

; Copy editor support (stub)
COPY_EDITOR:
            RTS
