; AUXMEM.KEYMAP.S - PETSCII to BBC Micro key code translation
; Maps C128 KERNAL PETSCII codes to BBC Micro ASCII-like codes
;
; KEY MAP: C128 PETSCII -> BBC Micro
; ====================================
;
; Letters (handled by table $60-$7A -> $41-$5B):
;   C128 PETSCII lowercase a-z ($41-$5A) = ASCII uppercase A-Z -> pass through
;   C128 PETSCII uppercase A-Z ($61-$7A) = ASCII lowercase a-z -> convert to $41-$5A
;   Result: all letters arrive as uppercase ASCII A-Z, what BBC BASIC expects
;
; Cursor keys:
;   C128 $11 (Cursor Down) -> BBC $8A
;   C128 $91 (Cursor Up)   -> BBC $8B
;   C128 $1D (Cursor Right)-> BBC $89
;   C128 $9D (Cursor Left) -> BBC $88
;
; Function keys (C128 physical f1-f8):
;   C128 function keys are read via GETIN in auxmem.chario.s:PROCESS_FKEY
;   PROCESS_FKEY is currently a stub (RTS).
;
;   C128 f1-f8 PETSCII codes (from GETIN):
;     f1=$85, f3=$86, f5=$87, f7=$88
;     f2=$89, f4=$8A, f6=$8B, f8=$8C
;
;   BBC Micro function keys (f0-f9, codes $80-$89) are defined
;   via the *KEY command and dispatched through the keyboard
;   event system.  They are NOT read directly from GETIN.
;
;   Planned mapping (when PROCESS_FKEY is implemented):
;     C128 f1 -> BBC f0 ($80)    via *KEY 0 ...
;     C128 f3 -> BBC f1 ($81)    via *KEY 1 ...
;     C128 f5 -> BBC f2 ($82)    via *KEY 2 ...
;     C128 f7 -> BBC f3 ($83)    via *KEY 3 ...
;     C128 f2 -> BBC f4 ($84)    via *KEY 4 ...
;     C128 f4 -> BBC f5 ($85)    via *KEY 5 ...
;     C128 f6 -> BBC f6 ($86)    via *KEY 6 ...
;     C128 f8 -> BBC f7 ($87)    via *KEY 7 ...
;     (Keypad + or other key for f8/f9)
;
;   C128 Shift+f1-f8 could map to BBC f8-f9 and other functions.
;
;   Default BBC Micro *KEY assignments (from MOS 1.20):
;     *KEY 0  "|LIST"                     (f0 = LIST)
;     *KEY 1  "|LOAD "                    (f1 = LOAD)
;     *KEY 2  "|SAVE "                    (f2 = SAVE)
;     *KEY 3  "|CAT"                      (f3 = CAT)
;     *KEY 4  "|RUN"                      (f4 = RUN)
;     *KEY 5  "|KEY "                     (f5 = KEY)
;     *KEY 6  "|"
;     *KEY 7  "|"
;     *KEY 8  ""
;     *KEY 9  ""
;
;   The "|" prefix represents pressing the Shift key as part of
;   the function key definition on BBC Micro.
;
; Special keys:
;   C128 RUN/STOP ($03) -> captured by CHECK_ESCAPE in chario.s
;   C128 SHIFT+RUN/STOP -> would produce $83 or handled by KERNAL
;   C128 RESTORE (NMI)  -> handled by hardware, not through GETIN
;
; BREAK key (BBC Micro):
;   The BBC Micro has a dedicated BREAK key that triggers a hardware
;   reset.  On C128 there is no equivalent single key.
;
;   BBC BREAK behavior:
;     BREAK (alone)  = cold reset (JMP ($FFFC) with specific flags)
;     Shift+Break    = warm reset (re-enters language ROM, preserves PAGE)
;     Ctrl+Break     = cold reset (some versions)
;
;   C128 equivalents (planned):
;     C128 RUN/STOP only       -> ESC check (OSBYTE escape flag)
;     C128 RESTORE key         -> NMI (currently jumps to AUXINIT)
;     C128 RUN/STOP+RESTORE    -> hardware NMI -> C128 KERNAL (not mapped)
;     *QUIT command            -> JMP ($FFFC)  -> re-enters language ROM
;     *BASIC command           -> JMP (ROMRESET) -> enters BASIC ROM
;
;   The RESET vector at $FFFC in bank 1 is set to AUXINIT
;   (mainmem.ldr.s:460-463).  Shift+Break behavior (preserving
;   *KEY definitions) would require a separate warm-reset entry
;   that skips RAM clearing.

; KEY_MAP - Translate PETSCII code in A to BBC Micro code
; Entry: A = PETSCII character (from C128 KERNAL GETIN)
; Exit:  A = BBC Micro character code
KEY_MAP:
            TAX
            LDA   KEYMAP_TBL,X
            RTS

; PETSCII to BBC Micro translation table
; Identity mapping for codes that match, overrides for differences
KEYMAP_TBL:
; 0x00-0x0F
            .byte $00, $01, $02, $03, $04, $05, $06, $07
            .byte $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
; 0x10-0x1F
            .byte $10, $8A, $12, $13, $14, $15, $16, $17  ; $11 -> Cursor Down
            .byte $18, $19, $1A, $1B, $1C, $89, $1E, $1F  ; $1D -> Cursor Right
; 0x20-0x2F
            .byte $20, $21, $22, $23, $24, $25, $26, $27
            .byte $28, $29, $2A, $2B, $2C, $2D, $2E, $2F
; 0x30-0x3F
            .byte $30, $31, $32, $33, $34, $35, $36, $37
            .byte $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
; 0x40-0x4F  - PETSCII lowercase = ASCII uppercase
            .byte $40, $41, $42, $43, $44, $45, $46, $47
            .byte $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
; 0x50-0x5F
            .byte $50, $51, $52, $53, $54, $55, $56, $57
            .byte $58, $59, $5A, $5B, $5C, $5D, $5E, $5F
; 0x60-0x6F  - PETSCII uppercase -> ASCII uppercase (convert down)
            .byte $60, $41, $42, $43, $44, $45, $46, $47
            .byte $48, $49, $4A, $4B, $4C, $4D, $4E, $4F
; 0x70-0x7F
            .byte $50, $51, $52, $53, $54, $55, $56, $57
            .byte $58, $59, $5A, $7B, $7C, $7D, $7E, $7F
; 0x80-0x8F
            .byte $80, $81, $82, $83, $84, $85, $86, $87
            .byte $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
; 0x90-0x9F
            .byte $90, $8B, $92, $93, $94, $95, $96, $97  ; $91 -> Cursor Up
            .byte $98, $99, $9A, $9B, $9C, $88, $9E, $9F  ; $9D -> Cursor Left
; 0xA0-0xAF
            .byte $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7
            .byte $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF
; 0xB0-0xBF
            .byte $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7
            .byte $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF
; 0xC0-0xCF
            .byte $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7
            .byte $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF
; 0xD0-0xDF
            .byte $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7
            .byte $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF
; 0xE0-0xEF
            .byte $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7
            .byte $E8, $E9, $EA, $EB, $EC, $ED, $EE, $EF
; 0xF0-0xFF
            .byte $F0, $F1, $F2, $F3, $F4, $F5, $F6, $F7
            .byte $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF
