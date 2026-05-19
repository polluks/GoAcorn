; AUXMEM.MISC.S - C128 misc MOS routines
; BBC Micro OSBYTE and miscellaneous MOS functions

; OSBYTE call dispatch
; Entry: A = OSBYTE number, X/Y = parameters
OSBYTE:
            CMP   #$00
            BEQ   OSBYTE00    ; Read character from buffer
            CMP   #$01
            BEQ   OSBYTE01    ; Read character from keyboard
            CMP   #$02
            BEQ   OSBYTE02    ; Read keyboard shift state
            CMP   #$03
            BEQ   OSBYTE03    ; Read ADC channel
            CMP   #$04
            BEQ   OSBYTE04    ; Read key press time
            CMP   #$7E
            BEQ   OSBYTE7E    ; Read last key pressed
            CMP   #$81
            BEQ   OSBYTE81    ; Read key (blocking)
            CMP   #$82
            BEQ   OSBYTE82    ; Read key with timeout
            CMP   #$83
            BEQ   OSBYTE83    ; Check for key press
            CMP   #$84
            BEQ   OSBYTE84    ; Check for key press with timeout
            CMP   #$85
            BEQ   OSBYTE85    ; Read key (non-blocking)
            CMP   #$86
            BEQ   OSBYTE86    ; Flush keyboard buffer
            CMP   #$87
            BEQ   OSBYTE87    ; Set keyboard auto-repeat
            RTS

OSBYTE00:
; Read character from keyboard buffer
            JSR   GETIN
            RTS

OSBYTE01:
; Read character from keyboard (blocking)
            JSR   OSRDCH
            RTS

OSBYTE02:
; Read shift/control keys
            LDA   #0
            RTS

OSBYTE03:
; Read ADC channel (not on C128)
            LDA   #$FF
            RTS

OSBYTE04:
; Read key press time
            LDA   #0
            TAX
            RTS

OSBYTE7E:
; Read last key pressed
            JSR   GETIN
            CMP   #0
            BNE   @HAVEKEY
            LDA   #$FF
@HAVEKEY:
            STA   OSKBD1
            RTS

OSBYTE81:
; Read key (blocking, no screen echo)
            JSR   OSRDCH
            AND   #$7F
            RTS

OSBYTE82:
; Read key with timeout (not implemented)
            JSR   OSRDCH
            AND   #$7F
            RTS

OSBYTE83:
; Check for key press (immediate)
            JSR   GETIN
            CMP   #0
            BEQ   @NOKEY
            CLC
            RTS
@NOKEY:
            SEC
            RTS

OSBYTE84:
; Check for key press with timeout
            JSR   GETIN
            CMP   #0
            BEQ   @NOKEY
            CLC
            RTS
@NOKEY:
            SEC
            RTS

OSBYTE85:
; Read key (non-blocking)
            JSR   GETIN
            CMP   #0
            RTS

OSBYTE86:
; Flush keyboard buffer
            RTS

OSBYTE87:
; Set keyboard auto-repeat
            RTS
