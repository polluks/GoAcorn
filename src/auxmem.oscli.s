; AUXMEM.OSCLI.S - C128 OSCLI command handler
; Processes BBC Micro star (*) commands

; OSCLI - Execute star command
; Entry: A=command string length, X/Y=pointer to command string
OSCLI:
            PHA
            JSR   OSNEWL

; Parse command and dispatch
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

; Compare against known commands
            LDX   #0
@CMDLP:
            LDA   CMDTABLE,X
            BEQ   @CHECK
            INX
            BNE   @CMDLP
@CHECK:
; TODO: Implement command dispatch
            JSR   PRCOMMAND
            RTS

PRCOMMAND:
            JSR   OSNEWL
            RTS

; Command table
CMDTABLE:
            .byte "HELP", 0
            .byte "CAT", 0
            .byte "DIR", 0
            .byte "INFO", 0
            .byte "LOAD", 0
            .byte "SAVE", 0
            .byte "RUN", 0
            .byte "EXEC", 0
            .byte "SPOOL", 0
            .byte "TYPE", 0
            .byte "DUMP", 0
            .byte "COPY", 0
            .byte "DELETE", 0
            .byte "RENAME", 0
            .byte "QUIT", 0
            .byte "FX", 0
            .byte "KEY", 0
            .byte "BASIC", 0
            .byte "HELP", 0
            .byte "FAST", 0
            .byte "SLOW", 0
            .byte 0

; Variables
CMDLEN      = $68
CMDBUF      = $0200
