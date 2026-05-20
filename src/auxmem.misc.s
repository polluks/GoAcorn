; AUXMEM.MISC.S - C128 misc MOS routines
; BBC Micro OSBYTE and miscellaneous MOS functions

; Helper: switch to KERNAL-visible config to call KERNAL routine
; Preserves A,X,Y across bank switch
CALL_KERN:
            PHA
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            PLA
            STA   BNKSAV
            LDA   #0
            STA   BNKSAV+1     ; flag: need restore
            PLA                ; restore entry A
            JSR   @KERN
            PHA
            LDA   BNKSAV+1
            BEQ   @RESTORE
            ; Call used BNKSAV as return address indicator
            PHA
@RESTORE:
            LDA   BNKSAV
            STA   MMU_CR2
            PLA
            RTS
@KERN:
            ; Jump table entry point - override via JMP
            RTS

; Timer value read helper
GET_KERN_TIME:
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            JSR   RDTIM
            PLA
            STA   MMU_CR2
            RTS

; OSBYTE call dispatch
; Entry: A = OSBYTE number, X/Y = parameters
; Uses table-driven dispatch to avoid branch range issues
OSBYTE:
            LDX   #OSB_NUM-1
@LOOP:
            CMP   OSB_TBL,X
            BEQ   @FOUND
            DEX
            BPL   @LOOP
            RTS               ; Unknown OSBYTE: no action
@FOUND:
            TXA
            ASL   A
            TAX
            LDA   OSB_ADR+1,X
            PHA
            LDA   OSB_ADR,X
            PHA
            RTS               ; JMP to handler via RTS trick

; OSBYTE dispatch table: values and handler addresses
OSB_TBL:
            .byte $00, $01, $02, $03, $04
            .byte $05, $06, $07, $09, $0A
            .byte $0B, $0C, $0D, $0E, $0F
            .byte $10, $11, $12, $13, $14
            .byte $15, $1E, $7E, $80, $81
            .byte $82, $83, $84, $85, $86
            .byte $87, $8A, $8B, $8E, $9F
            .byte $A0, $A1, $AA, $AB, $AC
OSB_NUM = * - OSB_TBL

OSB_ADR:
            .addr OSBYTE00    ; $00 Read character from buffer
            .addr OSBYTE01    ; $01 Read character from keyboard
            .addr OSBYTE02    ; $02 Read keyboard shift state
            .addr OSBYTE03    ; $03 Read ADC channel
            .addr OSBYTE04    ; $04 Read key press time
            .addr OSBYTE05    ; $05 Read key (non-destructive)
            .addr OSBYTE06    ; $06 Check for key press
            .addr OSBYTE07    ; $07 Read key with cursor control
            .addr OSBYTE09    ; $09 Read escape key flag
            .addr OSBYTE0A    ; $0A Write escape key flag
            .addr OSBYTE0B    ; $0B Check for key press with T
            .addr OSBYTE0C    ; $0C Read keyboard buffer address
            .addr OSBYTE0D    ; $0D Clear keyboard buffer
            .addr OSBYTE0E    ; $0E Read ADC channel 0-3
            .addr OSBYTE0F    ; $0F Flush buffer
            .addr OSBYTE10    ; $10 Print character in X
            .addr OSBYTE11    ; $11 Read line at cursor
            .addr OSBYTE12    ; $12 Write character to VDU
            .addr OSBYTE13    ; $13 Read character from keyboard
            .addr OSBYTE14    ; $14 Check for key press
            .addr OSBYTE15    ; $15 Write character to buffer
            .addr OSBYTE1E    ; $1E Read/change pulse generator
            .addr OSBYTE7E    ; $7E Read last key pressed
            .addr OSBYTE80    ; $80 Read keyboard translation
            .addr OSBYTE81    ; $81 Read key (blocking)
            .addr OSBYTE82    ; $82 Read key with timeout
            .addr OSBYTE83    ; $83 Check for key press
            .addr OSBYTE84    ; $84 Check for key press with timeout
            .addr OSBYTE85    ; $85 Read key (non-blocking)
            .addr OSBYTE86    ; $86 Flush keyboard buffer
            .addr OSBYTE87    ; $87 Set keyboard auto-repeat
            .addr OSBYTE8A    ; $8A Read machine high byte
            .addr OSBYTE8B    ; $8B Read machine low byte
            .addr OSBYTE8E    ; $8E Read operating system version
            .addr OSBYTE9F    ; $9F Enable/disable escape detection
            .addr OSBYTEA0    ; $A0 Read/change keyboard auto-repeat delay
            .addr OSBYTEA1    ; $A1 Read/change keyboard auto-repeat rate
            .addr OSBYTEAA    ; $AA Read key press timer
            .addr OSBYTEAB    ; $AB Check for keypress with timeout
            .addr OSBYTEAC    ; $AC Read key (immediate)

; Temporary storage for bank save
BNKSAV = $54   ; 2 bytes: saved bank + flags

OSBYTE00:
; Read character from keyboard buffer (non-blocking)
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            JSR   GETIN
            PHA
            PLA
            STA   MMU_CR2
            CLI
            RTS

OSBYTE01:
; Read character from keyboard (blocking)
            JSR   OSRDCH
            RTS

OSBYTE02:
; Read shift/control keys
; Returns: A = bitmask (bit 0=Shift, bit 1=Ctrl)
; C128: check CIA1 port A for shift/ctrl
            LDA   CIA1_PRA
            LDX   #0
            BIT   #$04         ; Shift lock?
            BEQ   @NORMAL
; TODO: Full keyboard state reading
@NORMAL:
            LDA   #0
            RTS

OSBYTE03:
; Read ADC channel (not on C128 - no analog-to-digital converter)
; Returns A=$FF (invalid), X=0
            LDA   #$FF
            LDX   #0
            RTS

OSBYTE04:
; Read key press time (centiseconds)
; Returns: X=low byte, Y=high byte
            LDX   #0
            LDY   #0
            RTS

OSBYTE05:
; Read key (non-destructive, i.e. peek buffer without removing)
            JSR   OSBYTE00
            RTS

OSBYTE06:
; Check for key press immediately
; Returns: A=0 if no key, key code if key waiting
            JSR   OSBYTE00
            RTS

OSBYTE07:
; Read key with cursor control handling
            JSR   OSRDCH
            RTS

OSBYTE09:
; Read escape key flag
            LDA   ESCFLAG
            RTS

OSBYTE0A:
; Write escape key flag
; Entry: X = new flag value (0 = clear, non-zero = set)
            TXA
            STA   ESCFLAG
            RTS

OSBYTE0B:
; Check for key press with timeout T
; Entry: Y=T (centiseconds), X=0
            TYA
            BEQ   @IMMED
            JSR   OSBYTE83
            RTS
@IMMED:
            JSR   GETIN
            CMP   #0
            RTS

OSBYTE0C:
; Read keyboard buffer address
; Returns: X=low, Y=high of keyboard buffer in BBC Micro memory
            LDX   #<KEYBUF
            LDY   #>KEYBUF
            RTS

OSBYTE0D:
; Clear keyboard buffer
            STA   KEYBUF
            RTS

OSBYTE0E:
; Read ADC channel 0-3
            LDA   #$FF
            LDX   #0
            LDY   #0
            RTS

OSBYTE0F:
; Flush keyboard buffer and get keyboard semaphore
            RTS

OSBYTE10:
; Print character in X (same as OSWRCH)
            TXA
            JMP   OSWRCH

OSBYTE11:
; Read line at cursor (OSWORD 0 equivalent)
            RTS

OSBYTE12:
; Write character to VDU (same as OSWRCH)
            JMP   OSWRCH

OSBYTE13:
; Read character from keyboard (same as OSRDCH)
            JMP   OSRDCH

OSBYTE14:
; Check for key press (same as OSBYTE 0B with T=0)
            JSR   GETIN
            CMP   #0
            RTS

OSBYTE15:
; Write character to keyboard buffer
            STA   KEYBUF
            RTS

OSBYTE1E:
; Read/change pulse generator (not on C128 - ignore)
            RTS

OSBYTE7E:
; Read last key pressed
            LDA   OSKBD1
            CMP   #$FF
            BNE   @HAVEKEY
            JSR   OSBYTE00     ; Get a fresh key
            CMP   #0
            BEQ   @NOKEY
            STA   OSKBD1
            RTS
@NOKEY:
            LDA   #$FF
@HAVEKEY:
            RTS

OSBYTE80:
; Read keyboard translation mode
; X=0 returns current mode in X
            RTS

OSBYTE81:
; Read key (blocking, no screen echo)
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
@WAIT:
            JSR   SCNKEY
            JSR   GETIN
            CMP   #0
            BEQ   @WAIT
            STA   BNKSAV       ; save key code
            PLA
            STA   MMU_CR2      ; Restore bank config
            LDA   BNKSAV
            CLI
            AND   #$7F
            RTS

OSBYTE82:
; Read key with timeout (not implemented - blocking)
            JSR   OSRDCH
            AND   #$7F
            RTS

OSBYTE83:
; Check for key press (immediate)
; Returns: C=1 if key pressed, C=0 if no key
; If C=1, A=key code
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            JSR   GETIN
            PHA
            LDA   MMU_CR2
            STA   MMU_CR2
            PLA
            CLI
            CMP   #0
            BEQ   @NOKEY
            CLC               ; C=0 for key pressed (BBC convention)
            RTS
@NOKEY:
            SEC               ; C=1 for no key
            RTS

OSBYTE84:
; Check for key press with timeout
; Entry: Y=T (centiseconds), X=0
            TYA
            BEQ   @IMMED
; TODO: implement timeout with CIA timer
@IMMED:
            JSR   OSBYTE83
            RTS

OSBYTE85:
; Read key (non-blocking)
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            JSR   GETIN
            PHA
            LDA   MMU_CR2
            STA   MMU_CR2
            PLA
            CLI
            CMP   #0
            RTS

OSBYTE86:
; Flush keyboard buffer
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
@FLUSH:
            JSR   GETIN
            CMP   #0
            BNE   @FLUSH
            PLA
            STA   MMU_CR2
            CLI
            RTS

OSBYTE87:
; Set keyboard auto-repeat
; Entry: X=repeat delay (centiseconds), Y=repeat rate
            RTS

OSBYTE8A:
; Read machine high byte - return BBC Micro model
; $FF = BBC B, $FE = BBC B+ etc
            LDA   #$FF
            RTS

OSBYTE8B:
; Read machine low byte - return Country/OS
; $FF = UK
            LDA   #$FF
            RTS

OSBYTE8E:
; Read operating system version
            LDA   #$00         ; Applecorn MOS
            RTS

OSBYTE9F:
; Enable/disable escape detection
; Entry: X=0 disable, X<>0 enable
            TXA
            STA   ESCFLAG
            RTS

OSBYTEA0:
; Read/change keyboard auto-repeat delay
            RTS

OSBYTEA1:
; Read/change keyboard auto-repeat rate
            RTS

OSBYTEAA:
; Read key press timer
            LDX   #0
            LDY   #0
            RTS

OSBYTEAB:
; Check for keypress with timeout
            JSR   OSBYTE83
            RTS

OSBYTEAC:
; Read key (immediate)
            JSR   OSBYTE85
            RTS

; Keyboard buffer for OSBYTE 0C/0D
KEYBUF = $02FF
