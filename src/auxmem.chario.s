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

; Function key support
; PROCESS_FKEY is called from the main input loop to handle C128 function keys.
;
; C128 function keys (f1-f8) produce PETSCII codes via GETIN:
;   f1=$85, f3=$86, f5=$87, f7=$88
;   f2=$89, f4=$8A, f6=$8B, f8=$8C
;
; These need to be translated to BBC Micro function key codes
; (f0=$80 .. f9=$89) and dispatched through the BBC *KEY mechanism.
;
; The KERNAL PFKEY call ($FF65) can program C128 function key strings,
; which may be a simpler path than implementing full *KEY emulation.
;
; Planned mapping:
;   C128 f1 -> BBC f0 ($80)    (*KEY 0)
;   C128 f3 -> BBC f1 ($81)    (*KEY 1)
;   C128 f5 -> BBC f2 ($82)    (*KEY 2)
;   C128 f7 -> BBC f3 ($83)    (*KEY 3)
;   C128 f2 -> BBC f4 ($84)    (*KEY 4)
;   C128 f4 -> BBC f5 ($85)    (*KEY 5)
;   C128 f6 -> BBC f6 ($86)    (*KEY 6)
;   C128 f8 -> BBC f7 ($87)    (*KEY 7)
;   Shift+f1/f3/f5/f7 -> BBC f8/f9
;   Shift+f2/f4/f6/f8 -> Help / unused
;
; TODO: Implement function key dispatch via *KEY lookup table
;
; BREAK key:
;   The BBC Micro BREAK key has no C128 equivalent.  The current
;   workarounds are:
;     *QUIT  -> JMP ($FFFC)  cold restart (preserves RAM)
;     *BASIC -> JMP (ROMRESET) re-enters language ROM
;   RUN/STOP+RESTORE on C128 generates NMI (currently unmapped).
;   A future implementation could detect RUN/STOP held at boot
;   to simulate Shift+Break (warm start) vs plain Break (cold start).
PROCESS_FKEY:
            RTS

; Copy editor support (stub)
COPY_EDITOR:
            RTS
