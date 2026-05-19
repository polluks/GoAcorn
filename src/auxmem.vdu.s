; AUXMEM.VDU.S - C128 VDC VDU driver
; Provides BBC Micro-compatible VDU calls using VDC

; VDU dispatch table
; Each VDU command (0-31) has a handler
VDU_DISPATCH:
            .word VDU_NUL     ; 00 - NUL
            .word VDU_NUL     ; 01 - (reserved)
            .word VDU_PRINT   ; 02 - Print text
            .word VDU_NUL     ; 03 - (reserved)
            .word VDU_TEXT    ; 04 - Text mode
            .word VDU_NUL     ; 05 - (reserved)
            .word VDU_NUL     ; 06 - (reserved)
            .word VDU_BELL    ; 07 - Bell
            .word VDU_BS      ; 08 - Backspace
            .word VDU_TAB     ; 09 - Tab
            .word VDU_LF      ; 0A - Line feed
            .word VDU_UP      ; 0B - Cursor up
            .word VDU_CR      ; 0C - Carriage return
            .word VDU_CRLF    ; 0D - CR+LF
            .word VDU_NUL     ; 0E - (reserved)
            .word VDU_NUL     ; 0F - (reserved)
            .word VDU_CLS     ; 10 - CLS
            .word VDU_COLOUR  ; 11 - Colour
            .word VDU_NUL     ; 12 - (reserved)
            .word VDU_NUL     ; 13 - (reserved)
            .word VDU_NUL     ; 14 - (reserved)
            .word VDU_NUL     ; 15 - (reserved)
            .word VDU_NUL     ; 16 - (reserved)
            .word VDU_NUL     ; 17 - (reserved)
            .word VDU_NUL     ; 18 - (reserved)
            .word VDU_NUL     ; 19 - (reserved)
            .word VDU_NUL     ; 20 - (reserved)
            .word VDU_NUL     ; 21 - (reserved)
            .word VDU_NUL     ; 22 - (reserved)
            .word VDU_NUL     ; 23 - Define character
            .word VDU_NUL     ; 24 - (reserved)
            .word VDU_NUL     ; 25 - (reserved)
            .word VDU_NUL     ; 26 - (reserved)
            .word VDU_NUL     ; 27 - (reserved)
            .word VDU_NUL     ; 28 - (reserved)
            .word VDU_NUL     ; 29 - (reserved)
            .word VDU_NUL     ; 30 - (reserved)
            .word VDU_NUL     ; 31 - (reserved)

; OSWRCH - Write character to VDC display
; Entry: A = character
OSWRCH:
            CMP   #32
            BCS   @PRINT
            ASL   A
            TAX
            LDA   VDU_DISPATCH+1,X
            PHA
            LDA   VDU_DISPATCH,X
            PHA
            RTS
@PRINT:
            JSR   VDC_PUTCHAR
            RTS

; VDC_PUTCHAR - Write character to VDC at cursor position
VDC_PUTCHAR:
            PHA
            LDA   #VDC_R14    ; Cursor position high
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   CURSOR_H
            STA   VDC_DATA
            LDA   #VDC_R15    ; Cursor position low
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            LDA   CURSOR_L
            STA   VDC_DATA

; Write character at cursor
            LDA   #VDC_R31
            STA   VDC_ADDR
@W3:        LDA   VDC_ADDR
            BPL   @W3
            PLA
            STA   VDC_DATA

; Advance cursor
            INC   CURSOR_L
            BNE   @DONE
            INC   CURSOR_H
@DONE:
            RTS

; VDU command handlers
VDU_NUL:    RTS

VDU_PRINT:
; Print string (terminated by 00 or 0D)
            RTS

VDU_TEXT:
; Switch to text mode
            RTS

VDU_BELL:
            LDA   #7
            ; TODO: SID sound
            RTS

VDU_BS:
            DEC   CURSOR_L
            BPL   @DONE
            DEC   CURSOR_H
@DONE:
            RTS

VDU_TAB:
            LDA   CURSOR_L
            CLC
            ADC   #8
            STA   CURSOR_L
            BCC   @NOWRAP
            INC   CURSOR_H
            LDA   CURSOR_H
            AND   #$03        ; Max 80 columns
            STA   CURSOR_H
@NOWRAP:
            RTS

VDU_LF:
            LDA   CURSOR_L
            CLC
            ADC   #80
            STA   CURSOR_L
            BCC   @DONE
            INC   CURSOR_H
            LDA   CURSOR_H
            CMP   #25
            BCC   @DONE
            JSR   VDC_SCROLL
@DONE:
            RTS

VDU_UP:
            LDA   CURSOR_L
            SEC
            SBC   #80
            STA   CURSOR_L
            BCS   @DONE
            DEC   CURSOR_H
@DONE:
            RTS

VDU_CR:
            LDA   CURSOR_H
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            STA   VDC_DATA
            RTS

VDU_CRLF:
            JSR   VDU_CR
            JMP   VDU_LF

VDU_CLS:
; Clear VDC screen
            LDA   #VDC_R18
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #0
            STA   VDC_DATA
            LDA   #VDC_R19
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            STA   VDC_DATA
            LDA   #VDC_R31
            STA   VDC_ADDR
@W3:        LDA   VDC_ADDR
            BPL   @W3
            LDX   #>2000      ; 2000 chars (high)
            LDY   #<2000      ; (low)
            LDA   #32
@LOOP:
            STA   VDC_DATA
            DEY
            BNE   @LOOP
            DEX
            BPL   @LOOP
; Reset cursor
            LDA   #0
            STA   CURSOR_H
            STA   CURSOR_L
            RTS

VDU_COLOUR:
; Set text colour (BBC Micro VDU 19 equivalent)
            LDA   #VDC_R26
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #$10        ; Green on black
            STA   VDC_DATA
            RTS

VDC_SCROLL:
; Scroll VDC display up by one row
            LDA   #VDC_R24
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #VDC_REVERSE ; Set reverse bit
            STA   VDC_DATA
            RTS

; ============================================================
; VDU variables
; ============================================================
CURSOR_H = $60
CURSOR_L = $61
VDUQUEUE = $62    ; VDU queue (4 bytes)
VDUQIDX  = $66
VDUSTAT  = $67

; OSASCI - Write character with line feed expansion
; Entry: A = character
OSASCI:
            CMP   #$0D
            BEQ   @ISCR
            JMP   OSWRCH
@ISCR:
            LDA   #$0A
            JSR   OSWRCH
            LDA   #$0D
            JMP   OSWRCH

; OSNEWL - New line
OSNEWL:
            LDA   #$0A
            JSR   OSWRCH
            LDA   #$0D
            JMP   OSWRCH

; OSRDCH - Read character from keyboard
OSRDCH:
            JSR   SCNKEY      ; KERNAL scan keyboard
            JSR   GETIN       ; KERNAL get character
            CMP   #0
            BEQ   OSRDCH
            CMP   #$60        ; Convert lowercase to uppercase for BBC Micro
            BCC   @OK
            SBC   #$20
@OK:
            PHA
            JSR   OSWRCH      ; Echo character
            PLA
            RTS
