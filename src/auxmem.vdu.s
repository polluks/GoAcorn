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
; The VDC uses R18/R19 (Update Address) for R31 (Data Register) access,
; NOT R14/R15 (Cursor Position). Must set update address before writing.
VDC_PUTCHAR:
            PHA
; Set update address to cursor position
            LDA   #VDC_R18
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   CURSOR_H
            STA   VDC_DATA
            LDA   #VDC_R19
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            LDA   CURSOR_L
            STA   VDC_DATA

; Write character at cursor via data register (auto-increments)
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
            BCC   @CHK
            INC   CURSOR_H
@CHK:
            LDA   CURSOR_H
            CMP   #$07
            BCC   @DONE
            BNE   @SCROLL
            LDA   CURSOR_L
            CMP   #$D0
            BCC   @DONE
@SCROLL:
            JSR   VDC_SCROLL
            LDA   CURSOR_L
            SEC
            SBC   #80
            STA   CURSOR_L
            LDA   CURSOR_H
            SBC   #0
            STA   CURSOR_H
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
            LDA   CURSOR_L
            PHA
            LDA   CURSOR_H
            PHA
            LDA   #0
            STA   SCRATCH
@SUBLP:
            LDA   CURSOR_L
            CMP   #80
            BCC   @DONESUB
            SBC   #80
            STA   CURSOR_L
            LDA   CURSOR_H
            SBC   #0
            STA   CURSOR_H
            JMP   @SUBLP
@DONESUB:
            LDA   CURSOR_L
            STA   SCRATCH
            PLA
            STA   CURSOR_H
            PLA
            STA   CURSOR_L
            LDA   CURSOR_L
            SEC
            SBC   SCRATCH
            STA   CURSOR_L
            LDA   CURSOR_H
            SBC   #0
            STA   CURSOR_H
            RTS

VDU_CRLF:
            JSR   VDU_CR
            JMP   VDU_LF

VDU_CLS:
; Clear VDC screen and reset display start
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
            LDX   #>2000
            LDY   #<2000
            LDA   #32
@LOOP:
            STA   VDC_DATA
            DEY
            BNE   @LOOP
            DEX
            BPL   @LOOP
; Reset display start address to 0
            LDA   #VDC_R12
            STA   VDC_ADDR
@W4:        LDA   VDC_ADDR
            BPL   @W4
            LDA   #0
            STA   VDC_DATA
            LDA   #VDC_R13
            STA   VDC_ADDR
@W5:        LDA   VDC_ADDR
            BPL   @W5
            LDA   #0
            STA   VDC_DATA
; Clear reverse bit
            LDA   #VDC_R24
            STA   VDC_ADDR
@W6:        LDA   VDC_ADDR
            BPL   @W6
            LDA   VDC_DATA
            AND   #$FF - VDC_REVERSE
            PHA
            LDA   #VDC_R24
            STA   VDC_ADDR
@W7:        LDA   VDC_ADDR
            BPL   @W7
            PLA
            STA   VDC_DATA
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
; Scroll VDC display up by one row using display-start manipulation
; VDC_REVERSE bit makes video RAM wrap at 16K, avoiding data copy
; Data is only copied back to offset 0 every ~200 scrolls
            LDA   SCROLL_OFFSET_L
            CLC
            ADC   #80
            STA   SCROLL_OFFSET_L
            BCC   @OK
            INC   SCROLL_OFFSET_H
@OK:
            CLC
            LDA   SCROLL_OFFSET_L
            ADC   #<2000
            LDA   SCROLL_OFFSET_H
            ADC   #>2000
            CMP   #$40
            BCC   @SETDISP
            JSR   VDC_REWRAP
            LDA   #0
            STA   SCROLL_OFFSET_L
            STA   SCROLL_OFFSET_H

@SETDISP:
            LDA   #VDC_R12
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   SCROLL_OFFSET_H
            STA   VDC_DATA
            LDA   #VDC_R13
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            LDA   SCROLL_OFFSET_L
            STA   VDC_DATA

            LDA   #VDC_R24
            STA   VDC_ADDR
@W3:        LDA   VDC_ADDR
            BPL   @W3
            LDA   VDC_DATA
            ORA   #VDC_REVERSE
            PHA
            LDA   #VDC_R24
            STA   VDC_ADDR
@W4:        LDA   VDC_ADDR
            BPL   @W4
            PLA
            STA   VDC_DATA

            LDA   SCROLL_OFFSET_L
            CLC
            ADC   #<1920
            STA   VDC_ADDRL
            LDA   SCROLL_OFFSET_H
            ADC   #>1920
            STA   VDC_ADDRH
            JSR   VDC_SET_UADDR

            LDX   #80
            LDA   #32
@CLR:
            LDA   VDC_ADDR
            BPL   @CLR
            STA   VDC_DATA
            DEX
            BNE   @CLR
            RTS

VDC_REWRAP:
; Copy 2000 bytes from scroll_offset to 0 in 256-byte blocks
            LDA   #0
            STA   REWRAP_BLK
@BLK:
            LDA   SCROLL_OFFSET_L
            STA   VDC_ADDRL
            LDA   SCROLL_OFFSET_H
            CLC
            ADC   REWRAP_BLK
            STA   VDC_ADDRH
            JSR   VDC_SET_UADDR

            LDX   #0
@READ:
            LDA   VDC_ADDR
            BPL   @READ
            LDA   VDC_DATA
            STA   SCROLLBUF,X
            INX
            BNE   @READ

            LDA   #0
            STA   VDC_ADDRL
            LDA   REWRAP_BLK
            STA   VDC_ADDRH
            JSR   VDC_SET_UADDR

            LDX   #0
@WRITE:
            LDA   VDC_ADDR
            BPL   @WRITE
            LDA   SCROLLBUF,X
            STA   VDC_DATA
            INX
            BNE   @WRITE

            INC   REWRAP_BLK
            LDA   REWRAP_BLK
            CMP   #7
            BNE   @BLK

            LDA   SCROLL_OFFSET_L
            STA   VDC_ADDRL
            LDA   SCROLL_OFFSET_H
            CLC
            ADC   #7
            STA   VDC_ADDRH
            JSR   VDC_SET_UADDR

            LDX   #0
@READ2:
            LDA   VDC_ADDR
            BPL   @READ2
            LDA   VDC_DATA
            STA   SCROLLBUF,X
            INX
            CPX   #208
            BNE   @READ2

            LDA   #0
            STA   VDC_ADDRL
            LDA   #7
            STA   VDC_ADDRH
            JSR   VDC_SET_UADDR

            LDX   #0
@WRITE2:
            LDA   VDC_ADDR
            BPL   @WRITE2
            LDA   SCROLLBUF,X
            STA   VDC_DATA
            INX
            CPX   #208
            BNE   @WRITE2
            RTS

VDC_SET_UADDR:
            PHA
            LDA   #VDC_R18
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   VDC_ADDRH
            STA   VDC_DATA
            LDA   #VDC_R19
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            LDA   VDC_ADDRL
            STA   VDC_DATA
            PLA
            RTS

; ============================================================
; VDU variables - using BBC Micro VDU workspace ($D0-$DF)
; ============================================================
CURSOR_H = $D0
CURSOR_L = $D1
VDUQUEUE = $D2    ; VDU queue (4 bytes)
VDUQIDX  = $D6
VDUSTAT  = $D7
SCRATCH       = $D8
SCROLL_OFFSET_L = $D9
SCROLL_OFFSET_H = $DA
REWRAP_BLK    = $DB
SCROLLBUF     = $0600

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
; Switch to KERNAL-visible config for keyboard input, then restore
OSRDCH:
            SEI
            LDA   MMU_CR2
            PHA                ; Save current bank config
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2      ; Switch to config 0 with KERNAL visible
            JSR   SCNKEY       ; KERNAL scan keyboard
            JSR   GETIN        ; KERNAL get character
            CMP   #0
            BEQ   @NOKEY
            PLA                ; We consumed the key, restore bank
            STA   MMU_CR2
            CLI
            CMP   #$60         ; Convert lowercase to uppercase for BBC Micro
            BCC   @OK
            SBC   #$20
@OK:
            PHA
            JSR   OSWRCH       ; Echo character
            PLA
            RTS
@NOKEY:
            PLA                ; Restore bank and retry
            STA   MMU_CR2
            CLI
            JMP   OSRDCH
