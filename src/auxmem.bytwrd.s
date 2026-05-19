; AUXMEM.BYTWRD.S - C128 byte/word operations
; OSWORD call handlers

; OSWORD - Perform a word-based operation
; Entry: A = OSWORD call number, X/Y = pointer to parameter block
OSWORD:
            CMP   #0
            BEQ   OSWORD0     ; Read line from keyboard
            CMP   #1
            BEQ   OSWORD1     ; Read character at cursor
            RTS

; OSWORD0 - Read line from keyboard into buffer
; Entry: X/Y = pointer to 4-byte control block:
;   +0: buffer address low
;   +1: buffer address high
;   +2: maximum line length
;   +3: minimum line length (unused)
; Exit:  A = terminator ($0D = CR, $1B = ESC)
OSWORD0:
            STX   OSLPTR
            STY   OSLPTR+1
            LDY   #0
            LDA   (OSLPTR),Y
            STA   OSCTRL
            INY
            LDA   (OSLPTR),Y
            STA   OSCTRL+1
            INY
            LDA   (OSLPTR),Y
            STA   MAXLEN
            INY
            LDA   (OSLPTR),Y
            STA   MINCHAR

            LDY   #0
@LOOP:
            JSR   GETKEY
            CMP   #$0D
            BEQ   @DONE
            CMP   #$1B
            BEQ   @ESCAPE
            CMP   #$08
            BEQ   @DELETE
            CMP   #$7F
            BEQ   @DELETE
            CPY   MAXLEN
            BCS   @LOOP
            STA   (OSCTRL),Y
            INY
            JSR   OSWRCH
            JMP   @LOOP
@DELETE:
            CPY   #0
            BEQ   @LOOP
            DEY
            LDA   #$08
            JSR   OSWRCH
            LDA   #$20
            JSR   OSWRCH
            LDA   #$08
            JSR   OSWRCH
            JMP   @LOOP
@ESCAPE:
            LDA   #$FF
            STA   ESCFLAG
            LDA   #$1B
            RTS
@DONE:
            LDA   #$0D
            RTS

; GETKEY - Read a key from keyboard (no echo)
; Exit:  A = key code (uppercase)
GETKEY:
            JSR   SCNKEY
            JSR   GETIN
            CMP   #0
            BEQ   GETKEY
            CMP   #$60
            BCC   @OK
            SBC   #$20
@OK:
            RTS

; OSWORD1 - Read character at cursor position
; Entry: X/Y = pointer to 2-byte block:
;   +0: X position (column, 0-79)
;   +1: Y position (row, 0-24)
; Exit:  A = character at that position
OSWORD1:
            STX   OSLPTR
            STY   OSLPTR+1
            LDY   #0
            LDA   (OSLPTR),Y
            STA   VDC_X
            INY
            LDA   (OSLPTR),Y
            STA   VDC_Y
            JSR   VDC_READ_CHAR
            RTS

; VDC_READ_CHAR - Read character from VDC at cursor
; Entry: VDC_X = column, VDC_Y = row
; Exit:  A = character
VDC_READ_CHAR:
            LDA   VDC_Y
            JSR   MUL80
            CLC
            ADC   VDC_X
            STA   VDC_ADDRL
            LDA   VDC_ADDRH
            ADC   #0
            STA   VDC_ADDRH
            JMP   VDC_READ_AT_ADDR

; VDC_READ_AT_ADDR - Read byte from VDC at VDC_ADDRH:VDC_ADDRL
; Exit:  A = byte
VDC_READ_AT_ADDR:
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
@W3:        LDA   VDC_ADDR
            BPL   @W3
            LDA   VDC_DATA
            RTS

; MUL80 - Multiply accumulator by 80
; Entry: A = value (0-24)
; Exit:  A = low byte, VDC_ADDRH = high byte
MUL80:
            STA   VDC_TEMP
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   VDC_ADDRL
            LDA   #0
            STA   VDC_ADDRH
            LDA   VDC_TEMP
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            ASL   A
            STA   VDC_TEMP
            LDA   VDC_ADDRL
            CLC
            ADC   VDC_TEMP
            STA   VDC_ADDRL
            BCC   @DONE
            INC   VDC_ADDRH
@DONE:
            LDA   VDC_ADDRL
            RTS

; Zero-page temporaries
VDC_TEMP    = $69
VDC_ADDRH   = $6A
VDC_ADDRL   = $6B
VDC_X       = $6C
VDC_Y       = $6D
