; KERNAL API entry points - Commodore 128
; Standard KERNAL jump table (C64/C128 compatible)

CINT      = $FF81
IOINIT    = $FF84
RAMTAS    = $FF87
RESTOR    = $FF8A
VECTOR    = $FF8D
SETMSG    = $FF90
SECOND    = $FF93
TKSA      = $FF96
MEMTOP    = $FF99
MEMBOT    = $FF9C
SCNKEY    = $FF9F
SETTMO    = $FFA2
ACPTR     = $FFA5
CIOUT     = $FFA8
UNTLK     = $FFAB
UNLSN     = $FFAE
LISTEN    = $FFB1
TALK      = $FFB4
READST    = $FFB7
SETLFS    = $FFBA
SETNAM    = $FFBD
OPEN      = $FFC0
CLOSE     = $FFC3
CHKIN     = $FFC6
CHKOUT    = $FFC9
CLRCHN    = $FFCC
CHRIN     = $FFCF
CHROUT    = $FFD2
LOAD      = $FFD5
SAVE      = $FFD8
SETTIM    = $FFDB
RDTIM     = $FFDE
STOP      = $FFE1
GETIN     = $FFE4
CLALL     = $FFE7
UDTIM     = $FFEA
SCRORG    = $FFED
PLOT      = $FFF0
IOBASE    = $FFF3

; C128 extended jump table
SPINSPOUT = $FF47
CLOSE_ALL = $FF4A
C64MODE   = $FF4D
DMA_CALL  = $FF50
BOOT_CALL = $FF53
PHOENIX   = $FF56
LKUPLA    = $FF59
LKUPSA    = $FF5C
SWAPPER   = $FF5F
DLCHR     = $FF62
PFKEY     = $FF65
SETBNK    = $FF68
GETCFG    = $FF6B
JSRFAR    = $FF6E
JMPFAR    = $FF71
INDFET    = $FF74
INDSTA    = $FF77
INDCMP    = $FF7A
PRIMM     = $FF7D

; KERNAL indirect vector table
IOPEN   = $031A
ICLOSE  = $031C
ICHKIN  = $031E
ICHKOUT = $0320
ICLRCH  = $0322
IBASIN  = $0324
IBSOUT  = $0326
ISTOP   = $0328
IGETIN  = $032A
ICLALL  = $032C

; KERNAL status byte bits (READST)
ST_CARR    = 1
ST_EOF     = 2
ST_READ    = 4
ST_TIMEOUT = 8
ST_VERIFY  = $10
ST_TAPE    = $20
ST_BREAK   = $40
ST_DEVICE  = $80

; C128 KERNAL VDC helper entry points
VDC_WRITE  = $CDCC
VDC_READ   = $CDDA

; Zero-page locations (key ones)
BANK_NO   = $02
STKPTR    = $09
COLFLG    = $D7

; Hardware interrupt vectors
NMI_VEC   = $FFFA
RESET_VEC = $FFFC
IRQ_VEC   = $FFFE
