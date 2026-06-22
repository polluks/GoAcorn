; AUXMEM.OSCLI.S - C128 OSCLI command handler
; Processes BBC Micro star (*) commands

; OSCLI - Execute star command
; Entry: A = command string length, X/Y = pointer to command string
OSCLI:
            PHA
            JSR   OSNEWL

            PLA
            LDY   #0
            STA   CMDLEN
@PARSE:
            LDA   (OSCTRL),Y
            CMP   #$0D
            BEQ   @DONE
            STA   CMDBUF,Y
            INY
            CPY   CMDLEN
            BNE   @PARSE
@DONE:
            STY   CMDLEN

            LDX   #0
            STX   CMDIDX
@CMDLP:
            LDX   CMDIDX
            LDA   CMDTABLE,X
            BEQ   @NOMATCH
            JSR   CMPCMD
            BCC   @MATCH
@NEXT:
            INC   CMDIDX
@SKIPLP:
            LDX   CMDIDX
            LDA   CMDTABLE,X
            BEQ   @FOUNDEND
            INX
            STX   CMDIDX
            JMP   @SKIPLP
@FOUNDEND:
            INC   CMDIDX
            JMP   @CMDLP
@MATCH:
            LDX   CMDIDX
@SKIPCMD:
            LDA   CMDTABLE,X
            BEQ   @DISPATCH
            INX
            JMP   @SKIPCMD
@DISPATCH:
            INX
            LDA   CMDTABLE,X
            STA   CMDJMPL
            INX
            LDA   CMDTABLE,X
            STA   CMDJMPH
            JMP   (CMDJMPL)
@NOMATCH:
            JSR   PRNOTIMPL
            JMP   OSNEWL

; CMPCMD - Compare command at CMDIDX with CMDBUF
; Sets C=0 if match
CMPCMD:
            LDY   #0
@LP:
            LDA   CMDTABLE,X
            BEQ   @CHECKEND
            CMP   CMDBUF,Y
            BNE   @NOMATCH
            INX
            INY
            BNE   @LP
@CHECKEND:
            LDA   CMDBUF,Y
            CMP   #$0D
            BEQ   @MATCH
            CMP   #$20
            BEQ   @MATCH
            CMP   #0
            BNE   @NOMATCH
@MATCH:
            CLC
            RTS
@NOMATCH:
            SEC
            RTS

; Command handler: HELP
CMD_HELP:
            LDX   #0
@LP:
            LDA   HELPTEXT,X
            BEQ   @DONE
            JSR   OSWRCH
            INX
            BNE   @LP
@DONE:
            JMP   OSNEWL

HELPTEXT:
            .byte "Applecorn C128 - available commands:", $0D
            .byte "HELP, CAT, DIR, INFO, LOAD, SAVE", $0D
            .byte "RUN, EXEC, SPOOL, TYPE, DUMP", $0D
            .byte "COPY, DELETE, RENAME, QUIT", $0D
            .byte "FX, KEY, BASIC, FAST", 0

; Command handler: BASIC (switch to BBC BASIC ROM)
CMD_BASIC:
            LDA   #$00
            STA   ROMID
            JMP   (ROMRESET)

; Command handler: QUIT
CMD_QUIT:
            JMP   ($FFFC)

; Command handler: FX (call OSBYTE)
CMD_FX:
            LDX   #2
            JMP   PRNOTIMPL

; Command handler: CAT/DIR
CMD_CAT:
CMD_DIR:
            LDA   #1
            LDX   #<DIRNAME
            LDY   #>DIRNAME
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #0
            JSR   SETLFS
            LDA   #0
            LDX   #<DIRBUF
            LDY   #>DIRBUF
            JSR   LOAD
            JSR   CLRCHN
            LDA   #FASTCLOCK
            STA   MMU_MCR

            LDX   #0
@LINE:
            LDA   DIRBUF,X
            ORA   DIRBUF+1,X
            BEQ   @DONE
            INX
            INX
            INX
            INX
@TEXT:
            LDA   DIRBUF,X
            BEQ   @NEXT
            JSR   OSWRCH
            INX
            JMP   @TEXT
@NEXT:
            INX
            JSR   OSNEWL
            JMP   @LINE
@DONE:
            RTS

DIRNAME:
            .byte "$"
DIRBUF      = $0801

; Command handler: INFO
CMD_INFO:
            JMP   PRNOTIMPL

; Command handler: LOAD
; Syntax: *LOAD <filename> [<addr>]
CMD_LOAD:
            LDX   CMDLEN
@SKIPCMD:
            DEX
            LDA   CMDBUF,X
            CMP   #$20
            BNE   @SKIPCMD
            INX
            JSR   EXTRACT_FN
            LDA   HF_FNLEN
            BEQ   @DONE
@SKP:
            LDA   CMDBUF,X
            CMP   #$0D
            BEQ   @NODEF
            CMP   #$20
            BNE   @HAVEADR
            INX
            BNE   @SKP
@HAVEADR:
            JSR   HEX_PARSE
            LDA   HF_FNLEN
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #1
            JSR   SETLFS
            LDA   #0
            LDX   HF_ADDR
            LDY   HF_ADDR+1
            JSR   LOAD
            JSR   CLRCHN
            LDA   #FASTCLOCK
            STA   MMU_MCR
            RTS
@NODEF:
            LDA   HF_FNLEN
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #0
            JSR   SETLFS
            LDA   #0
            JSR   LOAD
            JSR   CLRCHN
            LDA   #FASTCLOCK
            STA   MMU_MCR
@DONE:
            RTS

; Command handler: SAVE
; Syntax: *SAVE <filename> <start> <end>
CMD_SAVE:
            LDX   CMDLEN
@SKIPCMD:
            DEX
            LDA   CMDBUF,X
            CMP   #$20
            BNE   @SKIPCMD
            INX
            JSR   EXTRACT_FN
            LDA   HF_FNLEN
            BEQ   @DONE
@SKP1:
            LDA   CMDBUF,X
            CMP   #$20
            BNE   @GOTADR1
            INX
            BNE   @SKP1
@GOTADR1:
            JSR   HEX_PARSE
            LDA   HF_ADDR
            STA   HF_ADDR2
            LDA   HF_ADDR+1
            STA   HF_ADDR2+1
@SKP2:
            LDA   CMDBUF,X
            CMP   #$20
            BNE   @GOTADR2
            INX
            BNE   @SKP2
@GOTADR2:
            JSR   HEX_PARSE
            LDA   HF_ADDR+1
            SEC
            SBC   HF_ADDR2+1
            CLC
            ADC   #1
            STA   HF_PAGES
            LDA   HF_FNLEN
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #1
            JSR   SETLFS
            LDA   HF_PAGES
            LDX   HF_ADDR2
            LDY   HF_ADDR2+1
            JSR   SAVE
            JSR   CLRCHN
            LDA   #FASTCLOCK
            STA   MMU_MCR
@DONE:
            RTS

; EXTRACT_FN - Extract filename from CMDBUF at offset X
; Copies to FILENAME_BUF, returns length in HF_FNLEN
; Handles quoted ("...") and unquoted filenames
; X advanced past filename
EXTRACT_FN:
            LDA   CMDBUF,X
            CMP   #$22
            BEQ   @QUOTED
            LDY   #0
@ULP:
            LDA   CMDBUF,X
            CMP   #$0D
            BEQ   @UDONE
            CMP   #$20
            BEQ   @UDONE
            STA   FILENAME_BUF,Y
            INX
            INY
            CPY   #63
            BCC   @ULP
@UDONE:
            STY   HF_FNLEN
            RTS
@QUOTED:
            INX
            LDY   #0
@QLP:
            LDA   CMDBUF,X
            CMP   #$22
            BEQ   @QDONE
            CMP   #$0D
            BEQ   @QDONE
            STA   FILENAME_BUF,Y
            INX
            INY
            CPY   #63
            BCC   @QLP
@QDONE:
            INX
            STY   HF_FNLEN
            RTS

; HEX_PARSE - Parse hex number from CMDBUF at offset X
; Returns value in HF_ADDR (2 bytes), X advanced past digits
HEX_PARSE:
            LDA   #0
            STA   HF_ADDR
            STA   HF_ADDR+1
@LP:
            LDA   CMDBUF,X
            JSR   HEX_DIGIT
            BCS   @DONE
            ASL   HF_ADDR
            ROL   HF_ADDR+1
            ASL   HF_ADDR
            ROL   HF_ADDR+1
            ASL   HF_ADDR
            ROL   HF_ADDR+1
            ASL   HF_ADDR
            ROL   HF_ADDR+1
            ORA   HF_ADDR
            STA   HF_ADDR
            INX
            JMP   @LP
@DONE:
            RTS

; HEX_DIGIT - Convert ASCII hex digit to value
; Entry: A = ASCII character
; Exit:  A = value, C=0 if valid digit, C=1 if not
HEX_DIGIT:
            CMP   #'0'
            BCC   @BAD
            CMP   #'9'+1
            BCC   @DIGIT
            CMP   #'A'
            BCC   @BAD
            CMP   #'F'+1
            BCC   @ALPHA
            CMP   #'a'
            BCC   @BAD
            CMP   #'f'+1
            BCS   @BAD
            SEC
            SBC   #$57
            CLC
            RTS
@ALPHA:
            SEC
            SBC   #$37
            CLC
            RTS
@DIGIT:
            SEC
            SBC   #'0'
            CLC
            RTS
@BAD:
            SEC
            RTS

; Command handler: RUN
CMD_RUN:
            JMP   PRNOTIMPL

CMD_EXEC:
            JMP   PRNOTIMPL

CMD_SPOOL:
            JMP   PRNOTIMPL

CMD_TYPE:
            JMP   PRNOTIMPL

CMD_DUMP:
            JMP   PRNOTIMPL

CMD_COPY:
            JMP   PRNOTIMPL

CMD_DELETE:
            JMP   PRNOTIMPL

CMD_RENAME:
            JMP   PRNOTIMPL

CMD_KEY:
            JMP   PRNOTIMPL

CMD_FAST:
            LDA   #$00
            STA   MMU_MCR
            RTS

; PRNOTIMPL - Print "Not implemented"
PRNOTIMPL:
            PHA
            TXA
            PHA
            TYA
            PHA
            LDX   #0
@LP:
            LDA   NOTIMPL,X
            BEQ   @DONE
            JSR   OSWRCH
            INX
            BNE   @LP
@DONE:
            PLA
            TAY
            PLA
            TAX
            PLA
            RTS

NOTIMPL:
            .byte "Not implemented", 0

; Command table: null-terminated names, then address (low, high)
CMDTABLE:
            .byte "HELP", 0, <CMD_HELP, >CMD_HELP
            .byte "CAT", 0, <CMD_CAT, >CMD_CAT
            .byte "DIR", 0, <CMD_DIR, >CMD_DIR
            .byte "INFO", 0, <CMD_INFO, >CMD_INFO
            .byte "LOAD", 0, <CMD_LOAD, >CMD_LOAD
            .byte "SAVE", 0, <CMD_SAVE, >CMD_SAVE
            .byte "RUN", 0, <CMD_RUN, >CMD_RUN
            .byte "EXEC", 0, <CMD_EXEC, >CMD_EXEC
            .byte "SPOOL", 0, <CMD_SPOOL, >CMD_SPOOL
            .byte "TYPE", 0, <CMD_TYPE, >CMD_TYPE
            .byte "DUMP", 0, <CMD_DUMP, >CMD_DUMP
            .byte "COPY", 0, <CMD_COPY, >CMD_COPY
            .byte "DELETE", 0, <CMD_DELETE, >CMD_DELETE
            .byte "RENAME", 0, <CMD_RENAME, >CMD_RENAME
            .byte "QUIT", 0, <CMD_QUIT, >CMD_QUIT
            .byte "FX", 0, <CMD_FX, >CMD_FX
            .byte "KEY", 0, <CMD_KEY, >CMD_KEY
            .byte "BASIC", 0, <CMD_BASIC, >CMD_BASIC
            .byte "FAST", 0, <CMD_FAST, >CMD_FAST
            .byte 0

; Variables
CMDLEN      = $68
CMDIDX      = $6E
CMDJMPL     = $6F
CMDJMPH     = $70
CMDBUF      = $0200
ROMRESET    = $FFFC
