; MAINMEM.FSEQU.S
; (c) Bobbi 2021-2022 GPL v3
;
; Constant definitions for ProDOS filesystem code that
; resides in main memory.

; ProDOS string buffers
RTCBUF = $0200
;               ; $0228-$023D
DRVBUF1 = $023E
DRVBUF2 = $023F
;                 $0240       ; Prefix path
CMDPATH = $0280
;               ; $02C0-$02FF

; Filename string buffers
MOSFILE1 = $0300
MOSFILE2 = $0341
MOSFILE = MOSFILE1
;               ; $0382-$03A3 ROM selection w/s (move?)
;               ; $03A4-$03BD

; Control block for OSFILE
FILEBLK = $03BE
FBPTR = FILEBLK+0
FBLOAD = FILEBLK+2
FBEXEC = FILEBLK+6
FBSIZE = FILEBLK+10
FBSTRT = FILEBLK+10
FBATTR = FILEBLK+14
FBEND = FILEBLK+14

; Control block for OSGBPB
GBPBBLK = FILEBLK+1
GBPBHDL = GBPBBLK+0
GBPBDAT = GBPBBLK+1
GBPBNUM = GBPBBLK+5
GBPBPTR = GBPBBLK+9
GBPBAUXCB = GBPBBLK+13

;               ; $03D0-$03FF ; ProDOS workspace

; ProDOS MLI command numbers
ALLOCCMD = $40
DEALLOCCMD = $41
QUITCMD = $65
GTIMECMD = $82
CREATCMD = $C0
DESTCMD = $C1
RENCMD = $C2
SINFOCMD = $C3
GINFOCMD = $C4
ONLNCMD = $C5
SPFXCMD = $C6
GPFXCMD = $C7
OPENCMD = $C8
READCMD = $CA
WRITECMD = $CB
CLSCMD = $CC
FLSHCMD = $CD
SMARKCMD = $CE
GMARKCMD = $CF
GEOFCMD = $D1

