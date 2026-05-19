; MAINMEM.MISC.S - C128 main memory misc routines
; Runs in bank 0, provides services to the BBC Micro VM in bank 1

; Main memory service entry
MAIN_SERVICE:
            RTS

; Handle MMU bank switching for aux memory access
; Entry: A = function number
;         0 = read byte from aux
;         1 = write byte to aux
MAIN_MEMOP:
            CMP   #0
            BEQ   MAIN_READ
            CMP   #1
            BEQ   MAIN_WRITE
            RTS

MAIN_READ:
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2
            LDA   (XFTMP),Y
            PHA
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            PLA
            RTS

MAIN_WRITE:
            LDA   #MMU_CFG_ALLRAM1
            STA   MMU_CR2
            TXA
            STA   (XFTMP),Y
            LDA   #MMU_CFG_ALLRAM
            STA   MMU_CR2
            RTS
