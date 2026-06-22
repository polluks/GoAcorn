; APPLECORN.S for Commodore 128
; (c) Bobbi 2021 GPLv3
; Ported to C128 with ca65
;
; Allows Acorn BBC Microcomputer language ROMs to run on C128.
; Uses VDC 80-column display at 2 MHz.

.include "c128.inc"
.include "apple2_compat.inc"


; ============================================================
; C128 Zero-Page locations used by Applecorn
; ============================================================

; Bank switching temp storage
BANKSAVE    = $FA       ; Saved MMU bank
SPTMP       = $FB       ; Stack pointer temp
XFTMP       = $FC       ; Transfer temp (2 bytes)

; ============================================================
; Memory buffer locations (C128 memory map adjusted)
; ============================================================

; IO buffers
IOBUF0      = $0C00
IOBUF1      = $1000
IOBUF2      = $1400
IOBUF3      = $1800
IOBUF4      = $1C00

; Disk block buffer
BLKBUF      = $7C00
BLKBUFEND   = $7E00

; Copy buffer
COPYBUF     = $7E00

; Font data location
FONTADDR    = $4000

; Address in bank 1 where ROM will be loaded
ROMAUXADDR  = $8000
; Temp buffer in bank 0 for loading ROM before copying to bank 1
ROM_TMP     = $3000
; Temp buffer for MOS code before copying to bank 1 (12KB max)
MOS_TMP     = $4000

; Address in bank 1 where the MOS emulation is located
; $D000-$DFFF is I/O space (VDC, CIA, MMU), so MOS goes at $C000
; Future expansion: $E000-$FFFF in bank 1
AUXMOS1     = $C000
EAUXMOS1    = $D000
AUXMOS      = $C000

; ============================================================
; C128-specific hardware abstraction macros
; ============================================================

; Switch to bank 1 (BBC Micro VM) with bank 0 ZP/stack visible
.macro SWITCH_BANK1
            PHP
            SEI
            LDA   MMU_CR2
            STA   BANKSAVE
            LDA   #MMU_BANK1
            STA   MMU_CR2
            .endmacro

; Restore previous bank
.macro RESTORE_BANK
            LDA   BANKSAVE
            STA   MMU_CR2
            PLP
            .endmacro

; Set all-RAM bank 0 (for accessing main memory)
.macro SWITCH_BANK0_ALL
            LDA   #MMU_BANK0
            STA   MMU_CR2
            .endmacro

; XF2AUX - Call routine in BBC Micro VM (bank 1) from main (bank 0)
.macro XF2AUX addr
            PHP
            SEI
            LDA   MMU_CR2
            STA   BANKSAVE
            LDA   #MMU_BANK1
            STA   MMU_CR2
            JSR   addr
            LDA   BANKSAVE
            STA   MMU_CR2
            PLP
            .endmacro

; XF2MAIN - Call routine in main (bank 0) from BBC Micro VM (bank 1)
.macro XF2MAIN addr
            PHP
            SEI
            LDA   MMU_CR2
            STA   BANKSAVE
            LDA   #MMU_BANK0
            STA   MMU_CR2
            JSR   addr
            LDA   BANKSAVE
            STA   MMU_CR2
            PLP
            .endmacro

; ENTAUX - Re-enter aux (bank 1) after XF2MAIN
; On C128, this means switching back to bank 1
.macro ENTAUX
            PHP
            SEI
            LDA   #MMU_BANK1
            STA   MMU_CR2
            CLI
            .endmacro

; ENTMAIN - Return to main (bank 0) after XF2AUX
.macro ENTMAIN
            PHP
            SEI
            LDA   #MMU_BANK0
            STA   MMU_CR2
            CLI
            .endmacro

; Interrupt-safe versions (no CLI)
.macro IENTAUX
            LDA   #MMU_BANK1
            STA   MMU_CR2
            .endmacro

.macro IENTMAIN
            LDA   #MMU_BANK0
            STA   MMU_CR2
            .endmacro

; WRTMAIN - Enable writing to main memory from aux code
; On C128, this means switching MMU to bank 0 for write operations
.macro WRTMAIN
            PHP
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_BANK0
            STA   MMU_CR2
            .endmacro

.macro WRTAUX
            PLA
            STA   MMU_CR2
            PLP
            .endmacro

.macro RDMAIN
            PHP
            SEI
            LDA   MMU_CR2
            PHA
            LDA   #MMU_BANK0
            STA   MMU_CR2
            .endmacro

.macro RDAUX
            PLA
            STA   MMU_CR2
            PLP
            .endmacro

; ============================================================
; Include all Applecorn modules
; Order matters - same as original Merlin build
; ============================================================

; --- Loader code runs at $2000 in bank 0 ---
.segment "CODE"

.include "mainmem.ldr.s"
.include "mainmem.fsequ.s"
.include "mainmem.menu.s"
.include "mainmem.init.s"
.include "mainmem.svc.s"
.include "mainmem.hgr.s"
.include "mainmem.shr.s"
.include "mainmem.path.s"
.include "mainmem.wild.s"
.include "mainmem.lists.s"
.include "mainmem.misc.s"
.include "mainmem.audio.s"
.include "mainmem.mock.s"
.include "mainmem.mockfreq.s"
.include "mainmem.font8.s"

; --- MOS code runs at $C000 in bank 1 ---
.segment "MOSCODE"

.include "auxmem.mosequ.s"
.include "auxmem.init.s"
.include "auxmem.vers.s"
.include "auxmem.vdu.s"
.include "auxmem.hgr.s"
.include "auxmem.shr.s"
.include "auxmem.hostfs.s"
.include "auxmem.oscli.s"
.include "auxmem.bytwrd.s"
.include "auxmem.chario.s"
.include "auxmem.keymap.s"
.include "auxmem.audio.s"
.include "auxmem.misc.s"
