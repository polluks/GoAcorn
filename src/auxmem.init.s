; AUXMEM.INIT.S - C128 initialization for BBC Micro VM
; Runs in bank 1 (BBC Micro VM context)
; Sets up the MOS emulation environment

; Initialize auxiliary (VM) memory on C128
; This runs when first entering bank 1 after loader sets everything up
AUXINIT:
            LDX   #$FF
            TXS               ; Initialize VM stack to $01FF

; Ensure 2 MHz clock speed
            LDA   #FASTCLOCK
            STA   MMU_MCR

; Initialize VDC scroll offset to 0
            LDA   #0
            STA   SCROLL_OFFSET_L
            STA   SCROLL_OFFSET_H

; Set up VDC display for the BBC Micro text mode
; Use 80x25 character mode with Acorn font
            SEI

; Set up CIA timer for 100Hz interrupt (for audio envelopes and TIME)
            LDA   #$C7        ; 100Hz at 2MHz = 20000 cycles
            STA   CIA1_TAL
            LDA   #$4E
            STA   CIA1_TAH
            LDA   #CRA_START  ; Start timer A, continuous
            STA   CIA1_CRA

; Set up IRQ handler
            LDA   #<IRQ_HANDLER
            STA   $0314
            LDA   #>IRQ_HANDLER
            STA   $0315

            CLI

; Clear the VDC text screen (80x25 = 2000 bytes)
            LDA   #VDC_R18    ; Update address register
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #0
            STA   VDC_DATA    ; Update addr high = 0
            LDA   #VDC_R19
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            LDA   #0
            STA   VDC_DATA    ; Update addr low = 0

; Write spaces to fill the screen
            LDA   #VDC_R31    ; Data register
            STA   VDC_ADDR
@W3:        LDA   VDC_ADDR
            BPL   @W3
            LDX   #>2000       ; 2000 characters (high byte)
            LDY   #<2000       ; low byte
            LDA   #32         ; Space
@CLEARLP:
            STA   VDC_DATA
            DEY
            BNE   @CLEARLP
            DEX
            BPL   @CLEARLP

; Initialize BBC Micro MOS workspace in bank 1
            LDA   #0
            STA   $FF         ; Escape flag (BBC Micro ZP)
            STA   $FE         ; Ins Lock flag

; Set PAGE for language ROM
            LDA   #$0E
            STA   $18         ; PAGE high byte = &0E00

            RTS

; ============================================================
; IRQ Handler for BBC Micro VM
; ============================================================
IRQ_HANDLER:
            TYA
            PHA
            TXA
            PHA

; Check CIA timer A interrupt
            LDA   CIA1_ICR
            AND   #ICR_TA
            BEQ   @IRQEND

; 100Hz tick - update TIME, audio envelopes
            INC   TIME_L       ; Increment 4-byte TIME at $70
            BNE   @TICK
            INC   TIME_H
            BNE   @TICK
            INC   TIME_H2
            BNE   @TICK
            INC   TIME_H3

@TICK:
; Update audio envelopes (100Hz)
            JSR   UPDATE_ENVELOPES

@IRQEND:
            PLA
            TAX
            PLA
            TAY
            RTI

; TIME variable (BBC Micro compatible, 4 bytes at $70)
TIME_L  = $70   ; Low byte
TIME_H  = $71
TIME_H2 = $72
TIME_H3 = $73   ; High byte

; Stub for audio envelope update
UPDATE_ENVELOPES:
            RTS

; ============================================================
; VDU variables and workspace (C128 VDC-specific)
; ============================================================
VDUADDR     = $50   ; 2 bytes - VDC address pointer
VDUBANK     = $52   ; VDC bank select
VDUPORT     = $53   ; VDC register port

; ============================================================
; VDU font loading
; ============================================================
; Load Acorn 8x8 font into VDC character RAM
LOAD_ACORN_FONT:
            LDA   #0
            STA   VDC_ADDR
@W1:        LDA   VDC_ADDR
            BPL   @W1
            LDA   #$10        ; Character RAM select bit
            STA   VDC_DATA
            LDA   #0
            STA   VDC_ADDR
@W2:        LDA   VDC_ADDR
            BPL   @W2
            STA   VDC_DATA

; Copy font data
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
            BNE   @FLOOP
            RTS

; OSWRCH is in auxmem.vdu.s
