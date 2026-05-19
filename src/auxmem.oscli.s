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
            JSR   OSNEWL
            RTS

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
            JSR   PRNOTIMPL
            RTS

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
            JSR   PRNOTIMPL
            RTS

; Command handler: LOAD
CMD_LOAD:
            JSR   PRNOTIMPL
            RTS

; Command handler: SAVE
CMD_SAVE:
            JSR   PRNOTIMPL
            RTS

; Command handler: RUN
CMD_RUN:
            JSR   PRNOTIMPL
            RTS

; Command handler: EXEC
CMD_EXEC:
            JSR   PRNOTIMPL
            RTS

; Command handler: SPOOL
CMD_SPOOL:
            JSR   PRNOTIMPL
            RTS

; Command handler: TYPE
CMD_TYPE:
            JSR   PRNOTIMPL
            RTS

; Command handler: DUMP
CMD_DUMP:
            JSR   PRNOTIMPL
            RTS

; Command handler: COPY
CMD_COPY:
            JSR   PRNOTIMPL
            RTS

; Command handler: DELETE
CMD_DELETE:
            JSR   PRNOTIMPL
            RTS

; Command handler: RENAME
CMD_RENAME:
            JSR   PRNOTIMPL
            RTS

; Command handler: KEY
CMD_KEY:
            JSR   PRNOTIMPL
            RTS

; Command handler: FAST
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
