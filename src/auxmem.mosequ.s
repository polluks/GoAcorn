; AUXMEM.MOSEQU.S
; (c) Bobbi 2021 GPLv3
;

;******************************
; BBC MOS WORKSPACE LOCATIONS *
;******************************

; $00-$8F Language workspace
; $90-$9F Network workspace
; $A0-$A7 NMI workspace
; $A8-$AF Non-MOS *command workspace
; $B0-$BF Temporary filing system workspace
; $C0-$CF Persistant filing system workspace
; $D0-$DF VDU driver workspace
; $E0-$EE Internal MOS workspace
; $EF-$FF MOS API workspace

; DEBUG       EQU   $00         ; $00=*OPT 255 debug code removed
DEBUG = $E0
GSSPEED = $E1
FSFLAG1 = $E2
FSFLAG2 = $E3
GSFLAG = $E4
GSCHAR = $E5
OSTEXT = $E6
MAXLEN = OSTEXT+2
MINCHAR = OSTEXT+3
MAXCHAR = OSTEXT+4
OSNUM = OSTEXT
OSPAD = OSNUM+4
OSTEMP = $EB
OSKBD1 = $EC
OSKBD2 = OSKBD1+1
OSKBD3 = OSKBD1+2
OSAREG = $EF
OSXREG = OSAREG+1
OSYREG = OSXREG+1
OSCTRL = OSXREG
OSLPTR = $F2
ROMID = $F4
ROMTMP = $F5
ROMPTR = $F6
;                             ; $F8 pseudo-SROM settings
ROMMAX = $F9
OSINTWS = $FA
OSINTA = $FC
FAULT = $FD
ESCFLAG = $FF


; $0200-$0235 Vectors
; $0236-$028F OSBYTE variables ($190+BYTENUM)
; $0290-$02ED VDU workspace
; $02EE-$02FF MOS control block

USERV = $200
BRKV = $202
CLIV = $208
BYTEV = $20A
WORDV = $20C
WRCHV = $20E
RDCHV = $210
FILEV = $212
ARGSV = $214
BGETV = $216
BPUTV = $218
GBPBV = $21A
FINDV = $21C
FSCV = $21E

BYTEVARBASE = $190
OSFILECB = $2EE
OSGBPBCB = OSFILECB+1


; $0300-$03DF
; $03E0-$03EF Used for interfacing with ProDOS XFER
; $03F0-$03FF

