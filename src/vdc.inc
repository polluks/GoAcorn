; VDC (8563/8568) Video Display Controller - Commodore 128
; Used exclusively (no VIC-IIe 40-column support)

VDC_ADDR    = $D600
VDC_DATA    = $D601

; VDC status bits (read from $D600)
VDC_READY   = $80
VDC_VBLANK  = $20

; VDC internal register numbers (0-36)
VDC_R0  = 0   ; Horizontal Total
VDC_R1  = 1   ; Horizontal Displayed
VDC_R2  = 2   ; Horizontal Sync Position
VDC_R3  = 3   ; Vertical/Horizontal Sync Width
VDC_R4  = 4   ; Vertical Total
VDC_R5  = 5   ; Vertical Adjust
VDC_R6  = 6   ; Vertical Displayed
VDC_R7  = 7   ; Vertical Sync Position
VDC_R8  = 8   ; Interlace Mode
VDC_R9  = 9   ; Character Total Vertical
VDC_R10 = 10  ; Cursor Mode, Start Scan
VDC_R11 = 11  ; Cursor End Scan Line
VDC_R12 = 12  ; Display Start Address (high byte)
VDC_R13 = 13  ; Display Start Address (low byte)
VDC_R14 = 14  ; Cursor Position (high byte)
VDC_R15 = 15  ; Cursor Position (low byte)
VDC_R16 = 16  ; Light Pen Vertical Position
VDC_R17 = 17  ; Light Pen Horizontal Position
VDC_R18 = 18  ; Update Address (high byte)
VDC_R19 = 19  ; Update Address (low byte)
VDC_R20 = 20  ; Attribute Start Address (high byte)
VDC_R21 = 21  ; Attribute Start Address (low byte)
VDC_R22 = 22  ; Char Total Horizontal, Char Display Horizontal
VDC_R23 = 23  ; Character Display Vertical
VDC_R24 = 24  ; Vertical Smooth Scrolling
VDC_R25 = 25  ; Horizontal Smooth Scrolling
VDC_R26 = 26  ; Foreground/Background Color
VDC_R27 = 27  ; Address Increment per Row
VDC_R28 = 28  ; Character Base Address
VDC_R29 = 29  ; Underline Scan Line
VDC_R30 = 30  ; Word Count
VDC_R31 = 31  ; Data Register (video RAM read/write)
VDC_R32 = 32  ; Block Start Address (high byte)
VDC_R33 = 33  ; Block Start Address (low byte)
VDC_R34 = 34  ; Display Enable Begin
VDC_R35 = 35  ; Display Enable End
VDC_R36 = 36  ; DRAM Refresh Rate

; R8 - Interlace mode
VDC_INT_OFF = 0
VDC_INT_ON  = 3

; R10 - Cursor mode (upper nibble)
VDC_CUR_OFF      = $20
VDC_CUR_BLINK    = $00
VDC_CUR_SOLID    = $30
VDC_CUR_FASTBLINK = $10

; R24 - Vertical control
VDC_REVERSE  = $40
VDC_BLINK_1_32 = $20

; R25 - Horizontal control / attribute mode
VDC_ATRMODE  = $40
VDC_40COL    = $20
VDC_DBLWIDE  = $10

; R26 - color nibble shifts
VDC_FG_SHIFT = 4
VDC_BG_SHIFT = 0

; R28 - character base
VDC_CHAR16K  = $10

; Standard C128 colors for VDC
VCOL_BLACK      = 0
VCOL_WHITE      = 1
VCOL_RED        = 2
VCOL_CYAN       = 3
VCOL_PURPLE     = 4
VCOL_GREEN      = 5
VCOL_BLUE       = 6
VCOL_YELLOW     = 7
VCOL_ORANGE     = 8
VCOL_BROWN      = 9
VCOL_LTRED      = 10
VCOL_DKGRAY     = 11
VCOL_GRAY       = 12
VCOL_LTGREEN    = 13
VCOL_LTBLUE     = 14
VCOL_LTGRAY     = 15
