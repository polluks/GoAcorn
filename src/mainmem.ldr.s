; MAINMEM.LDR.S - C128 loader for Applecorn
; Runs in main memory (bank 0)
;
; Sets up the BBC Micro VM in bank 1:
;   Bank 1 layout:
;     $0000-$7FFF: BBC Micro user RAM (32K)
;     $8000-$BFFF: Acorn language ROM
;     $C000-$CFFF: Applecorn MOS emulation (lower)
;     $D000-$DFFF: I/O space (VDC, CIA, MMU)
;     $E000-$FFFF: KERNAL ROM (bank 0) / future MOS (bank 1)

; Entry point from ProDOS-style startup
; On C128, this is loaded and started via the KERNAL LOAD routine

SYSTEM:
            SEI
            LDX   #$FF
            TXS

; ----------------------------------------------------------
; Initialize VDC 80-column display
; ----------------------------------------------------------
            JSR   VDC_INIT

; ----------------------------------------------------------
; Clear VDC video RAM and write startup message
; ----------------------------------------------------------
            LDA   #VDC_R18
            STA   VDC_ADDR
@WCLS1:     LDA   VDC_ADDR
            BPL   @WCLS1
            LDA   #0
            STA   VDC_DATA
            LDA   #VDC_R19
            STA   VDC_ADDR
@WCLS2:     LDA   VDC_ADDR
            BPL   @WCLS2
            STA   VDC_DATA
            LDA   #VDC_R31
            STA   VDC_ADDR
@WCLS3:     LDA   VDC_ADDR
            BPL   @WCLS3
; Clear 2000 bytes (7 full pages of 256 + 208 extra)
            LDX   #6
            LDA   #32
@CLSPAGE:
            LDY   #0
@CLSBYTE:
            STA   VDC_DATA
            DEY
            BNE   @CLSBYTE
            DEX
            BPL   @CLSPAGE
            LDY   #208
@CLSREM:
            STA   VDC_DATA
            DEY
            BNE   @CLSREM
; Write startup message
            LDX   #0
@MSG:       LDA   STARTUP_MSG,X
            BEQ   @DONEMSG
            STA   VDC_DATA
            INX
            BNE   @MSG
@DONEMSG:

; ----------------------------------------------------------
; Switch to 2 MHz mode
; ----------------------------------------------------------
            LDA   #$00
            STA   MMU_MCR       ; 8502 mode, 2 MHz

; ----------------------------------------------------------
; Initialize MMU for bank switching
; KERNAL + I/O visible (needed for KERNAL calls and VDC access)
; ----------------------------------------------------------
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2       ; Bank 0, KERNAL+I/O visible, rest RAM

; ----------------------------------------------------------
; Load Acorn language ROM into bank 1 at $8000
; ----------------------------------------------------------
            JSR   LOAD_LANG_ROM

; ----------------------------------------------------------
; Load and relocate MOS emulation code into bank 1 at $C000
; ----------------------------------------------------------
            JSR   LOAD_MOS_CODE

; ----------------------------------------------------------
; Set up BBC Micro VM state in bank 1
; ----------------------------------------------------------
            JSR   SETUP_VM

; ----------------------------------------------------------
; Switch to bank 1 VM config (I/O visible) and start ROM
; ----------------------------------------------------------
            LDA   #MMU_CFG_VM
            STA   MMU_CR2       ; Switch to bank 1 VM config
            LDA   #1            ; A=1 for language ROM entry
            JMP   ROMAUXADDR    ; Start the BBC Micro language ROM

; ============================================================
; VDC initialization
; ============================================================
VDC_INIT:
            PHP
            SEI

; Wait for VDC ready
            LDX   #37           ; Number of VDC registers to init
            LDY   #0
@VINITLP:
            LDA   VDC_INIT_TBL,Y
            STA   VDC_ADDR
            INY
            LDA   VDC_INIT_TBL,Y
            STA   VDC_DATA
            INY
            LDA   VDC_ADDR      ; Wait for VDC ready
            BPL   *-3
            DEX
            BNE   @VINITLP

; Load Acorn font into VDC character RAM
            JSR   VDC_LOAD_FONT

            PLP
            RTS

; VDC register initialization table (register, value pairs)
; 80x25 text mode
VDC_INIT_TBL:
            .byte 0, 126        ; R0: Horizontal Total
            .byte 1, 80         ; R1: Horizontal Displayed
            .byte 2, 98         ; R2: Horizontal Sync Position
            .byte 3, 39         ; R3: Vertical/Horizontal Sync Width
            .byte 4, 32         ; R4: Vertical Total
            .byte 5, 0          ; R5: Vertical Adjust
            .byte 6, 25         ; R6: Vertical Displayed
            .byte 7, 29         ; R7: Vertical Sync Position
            .byte 8, 0          ; R8: Interlace off
            .byte 9, 7          ; R9: Character Total Vertical (8 scanlines)
            .byte 10, $20       ; R10: Cursor off
            .byte 11, 7         ; R11: Cursor End Scan Line
            .byte 12, 0         ; R12: Display Start Addr H
            .byte 13, 0         ; R13: Display Start Addr L
            .byte 14, 0         ; R14: Cursor Position H
            .byte 15, 0         ; R15: Cursor Position L
            .byte 16, 0         ; R16: Light Pen V
            .byte 17, 0         ; R17: Light Pen H
            .byte 18, 0         ; R18: Update Address H
            .byte 19, 0         ; R19: Update Address L
            .byte 20, 0         ; R20: Attribute Start Addr H
            .byte 21, 0         ; R21: Attribute Start Addr L
            .byte 22, 80        ; R22: Char Disp Horizontal
            .byte 23, 25        ; R23: Char Disp Vertical
            .byte 24, 0         ; R24: Vertical Scroll
            .byte 25, 0         ; R25: Horizontal Scroll
            .byte 26, $10       ; R26: Foreground/BG color (green on black)
            .byte 27, 80        ; R27: Address Increment per Row
            .byte 28, 0         ; R28: Character Base Addr
            .byte 29, 0         ; R29: Underline
            .byte 30, 0         ; R30: Word Count
            .byte 31, 0         ; R31: Data reg
            .byte 32, 0         ; R32: Block Start H
            .byte 33, 0         ; R33: Block Start L
            .byte 34, 0         ; R34: Display Enable Begin
            .byte 35, 0         ; R35: Display Enable End
            .byte 36, 0         ; R36: Refresh Rate

; ----------------------------------------------------------
; Load Acorn font into VDC character RAM
; ----------------------------------------------------------
VDC_LOAD_FONT:
; Set VDC update address to character RAM base
            LDA   #VDC_R18
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #$10          ; Bit 4 = char RAM select
            STA   VDC_DATA

            LDA   #VDC_R19
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            LDA   #0
            STA   VDC_DATA

; Select R31 (data register) for auto-increment writes
            LDA   #VDC_R31
            STA   VDC_ADDR

; Copy 768 bytes of font data to VDC character RAM
            LDY   #0
@P0:        LDA   VDC_ADDR
            BPL   @P0
            LDA   FONT8,Y
            STA   VDC_DATA
            INY
            BNE   @P0

@P1:        LDA   VDC_ADDR
            BPL   @P1
            LDA   FONT8+256,Y
            STA   VDC_DATA
            INY
            BNE   @P1

@P2:        LDA   VDC_ADDR
            BPL   @P2
            LDA   FONT8+512,Y
            STA   VDC_DATA
            INY
            BNE   @P2

            RTS

; ============================================================
; Load language ROM from disk
; ============================================================
LOAD_LANG_ROM:
; Load ROM into bank 0 temp buffer at ROM_TMP ($3000)
; We stay in config 0 (KERNAL at $E000) for KERNAL calls

; Set filename
            LDA   #LANGROM_NAME_END - LANGROM_NAME
            LDX   #<LANGROM_NAME
            LDY   #>LANGROM_NAME
            JSR   SETNAM

; Set logical file parameters
            LDA   #1            ; Logical file number
            LDX   #8            ; Device (disk drive)
            LDY   #1            ; SA=1: load at specified address, return
            JSR   SETLFS

; Load file to temp buffer in bank 0 (KERNAL visible in config 0)
            LDA   #0            ; Load (not verify)
            LDX   #<ROM_TMP     ; Temp buffer low
            LDY   #>ROM_TMP     ; Temp buffer high
            JSR   LOAD

; Copy from bank 0 temp buffer to bank 1 at $8000
; ZP: $70 = temp byte, $71-$72 = source ptr, $73-$74 = dest ptr
LD_TMP      = $70
LD_SRC      = $71
LD_DST      = $73

            LDX   #64           ; 64 pages of 256 bytes = 16K
            LDA   #<ROM_TMP
            STA   LD_SRC
            LDA   #>ROM_TMP
            STA   LD_SRC+1
            LDA   #<ROMAUXADDR
            STA   LD_DST
            LDA   #>ROMAUXADDR
            STA   LD_DST+1

@PAGE:
            LDY   #0
@BYTE:
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            LDA   (LD_SRC),Y   ; Read from bank 0 temp buffer
            STA   LD_TMP

            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2
            LDA   LD_TMP
            STA   (LD_DST),Y   ; Write to bank 1

            INY
            BNE   @BYTE

            INC   LD_SRC+1
            INC   LD_DST+1
            DEX
            BNE   @PAGE

; Restore to loader config (KERNAL + I/O visible)
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            RTS

LANGROM_NAME:
            .byte "BBCBASIC"
LANGROM_NAME_END:

; ============================================================
; Load MOS emulation code from disk
; ============================================================
LOAD_MOS_CODE:
; Load loadmos.prg into bank 0 temp buffer, then copy to bank 1 at $C000

; Set filename
            LDA   #MOS_NAME_END - MOS_NAME
            LDX   #<MOS_NAME
            LDY   #>MOS_NAME
            JSR   SETNAM

; Set logical file parameters
            LDA   #2            ; Logical file number
            LDX   #8            ; Device (disk drive)
            LDY   #1            ; SA=1: load at specified address
            JSR   SETLFS

; Load file to temp buffer in bank 0
            LDA   #0            ; Load (not verify)
            LDX   #<MOS_TMP
            LDY   #>MOS_TMP
            JSR   LOAD
            BCS   @LOADFAIL    ; skip copy on error

; LOAD returns: A = end_lo, X = end_hi
; Compute pages = end_hi - >MOS_TMP + (end_lo > 0 ? 1 : 0)
            PHA                ; save end_lo
            TXA                ; end_hi
            SEC
            SBC   #>MOS_TMP    ; end_hi - $40
            TAY                ; Y = base pages
            PLA                ; restore end_lo
            BEQ   @COPYMOS
            INY                ; add one page for partial

; Copy pages to bank 1 at $C000 and bank 0 at $C000
; Entry: Y = number of pages, MOS code at MOS_TMP in bank 0
; ZP: $70 = temp, $71-$72 = source, $73-$74 = dest
@COPYMOS:
            TYA                ; Save page count
            PHA
            BEQ   @LOADFAIL

; Copy to bank 1 at $C000
            LDA   #<MOS_TMP
            STA   LD_SRC
            LDA   #>MOS_TMP
            STA   LD_SRC+1
            LDA   #<AUXMOS
            STA   LD_DST
            LDA   #>AUXMOS
            STA   LD_DST+1
            PLA
            TAX                ; X = page count
            TXA
            PHA                ; Save again
@P1:
            LDY   #0
@B1:
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            LDA   (LD_SRC),Y
            STA   LD_TMP
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2
            LDA   LD_TMP
            STA   (LD_DST),Y
            INY
            BNE   @B1
            INC   LD_SRC+1
            INC   LD_DST+1
            DEX
            BNE   @P1

; Copy to bank 0 at $C000 (needed for cross-bank KERNAL calls)
            LDA   #<MOS_TMP
            STA   LD_SRC
            LDA   #>MOS_TMP
            STA   LD_SRC+1
            LDA   #<AUXMOS
            STA   LD_DST
            LDA   #>AUXMOS
            STA   LD_DST+1
            PLA
            TAX                ; X = page count
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
@P2:
            LDY   #0
@B2:
            LDA   (LD_SRC),Y
            STA   (LD_DST),Y
            INY
            BNE   @B2
            INC   LD_SRC+1
            INC   LD_DST+1
            DEX
            BNE   @P2

@LOADFAIL:
            LDA   #MMU_CFG_LOADER
            STA   MMU_CR2
            RTS

MOS_NAME:
            .byte "loadmos"
MOS_NAME_END:

; ============================================================
; Set up BBC Micro VM state in bank 1
; ============================================================
CLR_ADDR = $50   ; 2-byte temp address for clear loop

SETUP_VM:
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2

; Clear BBC Micro user RAM ($0000-$7FFF in bank 1)
            LDX   #$00
            STX   CLR_ADDR
            STX   CLR_ADDR+1
@CLEAR_LOOP:
            LDA   #0
            LDY   #0
@CLEAR_INNER:
            STA   (CLR_ADDR),Y
            INY
            BNE   @CLEAR_INNER
            INC   CLR_ADDR+1
            LDA   CLR_ADDR+1
            CMP   #$80
            BNE   @CLEAR_LOOP

; Write BBC Micro MOS dispatch table at $FFCE-$FFF7 in bank 1.
; The language ROM at $8000 calls these fixed addresses for OS functions.
; Each entry: JMP handler (3 bytes).
; Data table format: target_lo, target_hi, handler_lo, handler_hi
VEC_TEMP = $52   ; 2 bytes temp address

            LDX   #0
@VLOOP:
; Set target address in VEC_TEMP
            LDA   VEC_DATA,X
            STA   VEC_TEMP
            LDA   VEC_DATA+1,X
            STA   VEC_TEMP+1
; Write JMP at target
            LDA   #$4C
            LDY   #0
            STA   (VEC_TEMP),Y
; Write handler address low
            LDA   VEC_DATA+2,X
            INY
            STA   (VEC_TEMP),Y
; Write handler address high
            LDA   VEC_DATA+3,X
            INY
            STA   (VEC_TEMP),Y
; Next entry (4 bytes per entry)
            INX
            INX
            INX
            INX
            CPX   #VEC_DATA_SIZE
            BNE   @VLOOP

; Set hardware vectors at $FFFA-$FFFF
            LDA   #<AUXINIT
            STA   $FFFC
            LDA   #>AUXINIT
            STA   $FFFD
            LDA   #<IRQ_HANDLER
            STA   $FFFE
            LDA   #>IRQ_HANDLER
            STA   $FFFF
; NMI vector -> AUXINIT (stub)
            LDA   #<AUXINIT
            STA   $FFFA
            LDA   #>AUXINIT
            STA   $FFFB

            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            RTS

; Vector initialization data
; Format: target_lo, target_hi, handler_lo, handler_hi
VEC_DATA:
            .byte <$FFCE, >$FFCE, <OSWRCH, >OSWRCH   ; OSNWRH
            .byte <$FFD2, >$FFD2, <OSASCI, >OSASCI   ; OSASCI
            .byte <$FFD9, >$FFD9, <OSWRCH, >OSWRCH   ; OSWRCH
            .byte <$FFDC, >$FFDC, <OSWORD, >OSWORD   ; OSWORD
            .byte <$FFE0, >$FFE0, <OSBYTE, >OSBYTE   ; OSBYTE
            .byte <$FFE3, >$FFE3, <OSBGET, >OSBGET   ; OSBGET
            .byte <$FFE6, >$FFE6, <OSBPUT, >OSBPUT   ; OSBPUT
            .byte <$FFE9, >$FFE9, <OSFIND, >OSFIND   ; OSFIND
            .byte <$FFEC, >$FFEC, <OSARGS, >OSARGS   ; OSARGS
            .byte <$FFF0, >$FFF0, <OSFILE, >OSFILE   ; OSFILE
            .byte <$FFF4, >$FFF4, <OSRDCH, >OSRDCH   ; OSRDCH
            .byte <$FFF7, >$FFF7, <OSGBPB, >OSGBPB   ; OSGBPB
VEC_DATA_SIZE = * - VEC_DATA

; Startup message
STARTUP_MSG:
            .byte "aC=orn for Commodore 128",13
            .byte "Loading BBC BASIC...",0

; ============================================================
; Data area
; ============================================================

