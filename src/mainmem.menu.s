; MAINMEM.MENU.S - C128 ROM selection menu
; This is the ROM selection screen shown at startup

; ROM selection menu entry
ROMMENU:
            JSR   VDU_CLS
            LDX   #0
@PRINT:
            LDA   MENUTEXT,X
            BEQ   @DONE
            JSR   VDC_PUTCHAR
            INX
            BNE   @PRINT
@DONE:
            JSR   OSRDCH     ; Wait for key press
            AND   #$0F       ; Convert to number
            TAX
            DEX
            TXA
            RTS             ; Return ROM number in A

MENUTEXT:
            .byte "aC=orn - Acorn BBC Micro on C128", 13
            .byte "Select language ROM:", 13
            .byte "1. BBC BASIC", 13
            .byte "2. Acornsoft COMAL", 13
            .byte "3. Acornsoft FORTH", 13
            .byte "4. Acornsoft LISP", 13
            .byte 0
