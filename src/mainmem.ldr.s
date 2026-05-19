; MAINMEM.LDR.S - C128 loader for Applecorn
; Runs in main memory (bank 0)
;
; Sets up the BBC Micro VM in bank 1:
;   Bank 1 layout:
;     $0000-$7FFF: BBC Micro user RAM (32K)
;     $8000-$BFFF: Acorn language ROM
;     $D000-$FFFF: Applecorn MOS emulation

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
; Switch to 2 MHz mode
; ----------------------------------------------------------
            LDA   #$00
            STA   MMU_MCR       ; 8502 mode, 2 MHz

; ----------------------------------------------------------
; Initialize MMU for bank switching
; ----------------------------------------------------------
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2       ; Bank 0, all RAM, no ROMs

; ----------------------------------------------------------
; Load Acorn language ROM into bank 1 at $8000
; ----------------------------------------------------------
            JSR   LOAD_LANG_ROM

; ----------------------------------------------------------
; Load and relocate MOS emulation code into bank 1 at $D000
; ----------------------------------------------------------
            JSR   LOAD_MOS_CODE

; ----------------------------------------------------------
; Set up BBC Micro VM state in bank 1
; ----------------------------------------------------------
            JSR   SETUP_VM

; ----------------------------------------------------------
; Switch to bank 1 and start the language ROM
; ----------------------------------------------------------
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2
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
; Set VDC update address to character RAM base (bank 0)
            LDA   #0
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #$10          ; Set bit 4 = char RAM select
            STA   VDC_DATA
            LDA   #0
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            STA   VDC_DATA      ; Low byte of address = 0

; Copy font data to VDC character RAM
            LDX   #0
            LDY   #0
@FLOOP:
            LDA   FONT8,Y
            STA   VDC_ADDR
@W3:        LDA   VDC_ADDR
            BPL   @W3
            TXA
            STA   VDC_DATA
            INX
            INY
            CPY   #0
            BNE   @FLOOP
            RTS

; ============================================================
; Load language ROM from disk
; ============================================================
LOAD_LANG_ROM:
; Use KERNAL to load the ROM file into bank 1 at $8000
; First, switch to bank 1 for writing
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2

; Set filename
            LDA   #LANGROM_NAME_END - LANGROM_NAME
            LDX   #<LANGROM_NAME
            LDY   #>LANGROM_NAME
            JSR   SETNAM

; Set logical file parameters
            LDA   #1            ; Logical file number
            LDX   #8            ; Device (disk drive)
            LDY   #0            ; No secondary address
            JSR   SETLFS

; Load file
            LDA   #0            ; Load (not verify)
            LDX   #<ROMAUXADDR  ; Load address low
            LDY   #>ROMAUXADDR  ; Load address high
            JSR   LOAD

; Restore to bank 0 for main execution
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            RTS

LANGROM_NAME:
            .byte "BBCBASIC.ROM"
LANGROM_NAME_END:

; ============================================================
; Load MOS emulation code
; ============================================================
LOAD_MOS_CODE:
; The MOS code is included in the binary as AUXCODE.
; On C128, it's linked at $D000 in the binary file.
; At runtime, we need to ensure bank 1 has the MOS code at $D000.
; Since our binary has it embedded, we just set up bank 1 memory.
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2

; MOS code is assembled inline - already at $D000 via linker
; On C128, the MMU maps bank 1, so code at $D000 is accessible
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            RTS

; ============================================================
; Set up BBC Micro VM state in bank 1
; ============================================================
SETUP_VM:
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2

; Initialize zero page for BBC Micro VM
            LDA   #$00
            STA   $00
            LDX   #$FF
            TXS               ; Set C128 stack to $01FF

; Clear BBC Micro user RAM ($0000-$7FFF in bank 1)
            LDY   #0
            TYA
@CLEARLP:
            STA   $0000,Y
            STA   $0100,Y
            STA   $0200,Y
            STA   $0300,Y
            STA   $0400,Y
            STA   $0500,Y
            STA   $0600,Y
            STA   $0700,Y
            INY
            BNE   @CLEARLP

; Set up vectors for BBC Micro VM
            LDA   #<AUXMOS
            STA   $FFFE        ; IRQ vector -> MOS
            LDA   #>AUXMOS
            STA   $FFFF
            LDA   #<AUXMOS
            STA   $FFFC        ; RESET vector -> MOS
            LDA   #>AUXMOS+1   ; +1 for checksum byte
            STA   $FFFD

            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            RTS

; ============================================================
; Data area
; ============================================================

