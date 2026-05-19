; MMU (8722) Memory Management Unit registers - Commodore 128

MMU_CR      = $D500
MMU_PCRA    = $D501
MMU_PCRB    = $D502
MMU_PCRC    = $D503
MMU_PCRD    = $D504
MMU_MCR     = $D505
MMU_RCR     = $D506
MMU_P0L     = $D507
MMU_P0H     = $D508
MMU_P1L     = $D509
MMU_P1H     = $D50A
MMU_VR      = $D50B

; MMU registers at top of memory (always visible)
MMU_CR2     = $FF00
MMU_LCRA    = $FF01
MMU_LCRB    = $FF02
MMU_LCRC    = $FF03
MMU_LCRD    = $FF04

; MMU Configuration Register (CR) bits at $FF00
; High bits 7-6: RAM bank for CPU
MMU_BANK0   = $3F   ; All RAM, no ROM, bank 0
MMU_BANK1   = $7F   ; All RAM, no ROM, bank 1
MMU_BANK15  = $00   ; KERNAL+BASIC ROM, I/O, bank 0 (default)

; MMU bank configurations with specific ROM regions
; Bit 5: $8000-$BFFF (0=internal ROM, 1=RAM)
; Bit 4: $C000-$CFFF (0=editor ROM, 1=RAM)
; Bit 3: $D000-$DFFF (0=I/O, 1=RAM/CharROM)
; Bit 2: $E000-$FFFF (0=KERNAL ROM, 1=RAM)
; Bit 1: $4000-$7FFF (0=BASIC ROM, 1=RAM)
; Bit 0: $1000-$3FFF (0=char ROM, 1=RAM)

; Useful configurations:
MMU_CFG_ALLRAM   = $3F   ; All RAM bank 0, no ROMs, no I/O
MMU_CFG_ALLRAM1  = $7F   ; All RAM bank 1, no ROMs, no I/O
MMU_CFG_KERN     = $05   ; KERNAL ROM + BASIC ROM, I/O, bank 0

; Mode Configuration Register (MCR)
MCR_8502    = $00
MCR_2MHZ    = $00   ; 2 MHz always (no VIC)
MCR_1MHZ    = $00   ; VIC requires 1 MHz

; RAM Configuration Register (RCR)
RCR_COMMON_BOTTOM = 0
RCR_COMMON_1K    = 0
