; AUXMEM.HOSTFS.S - C128 host filing system
; Maps BBC Micro OSFILE/OSFIND/OSBGET/OSBPUT to C128 KERNAL calls

; ============================================================
; OSFILE - File operations (load, save, etc.)
; Entry: A=0 -> load, A=1 -> save, A=5 -> catalog
;        X/Y -> control block:
;          +0-1: pointer to CR-terminated filename
;          +2-5: load address (32-bit)
;          +6-9: execution address (32-bit)
;          +10-13: start address for save (32-bit)
;          +14-17: end address for save (32-bit)
; ============================================================
OSFILE:
            CMP   #0
            BEQ   OSFILE_LOAD
            CMP   #1
            BEQ   OSFILE_SAVE
            CMP   #5
            BNE   @DONE
            JMP   OSFILE_CAT
@DONE:
            RTS

OSFILE_LOAD:
            STX   HF_PTR
            STY   HF_PTR+1
            JSR   OSFILE_GETFN
            LDY   #2
            LDA   (HF_PTR),Y
            STA   HF_ADDR
            INY
            LDA   (HF_PTR),Y
            STA   HF_ADDR+1
            LDA   HF_FNLEN
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #0
            JSR   SETLFS
            LDA   #0
            LDX   HF_ADDR
            LDY   HF_ADDR+1
            JSR   LOAD
            JSR   CLRCHN
            LDA   #FASTCLOCK
            STA   MMU_MCR
            RTS

OSFILE_SAVE:
            STX   HF_PTR
            STY   HF_PTR+1
            JSR   OSFILE_GETFN
            LDY   #10
            LDA   (HF_PTR),Y
            STA   HF_ADDR
            INY
            LDA   (HF_PTR),Y
            STA   HF_ADDR+1
            LDY   #14
            LDA   (HF_PTR),Y
            STA   HF_ADDR2
            INY
            LDA   (HF_PTR),Y
            STA   HF_ADDR2+1
            LDA   HF_ADDR2+1
            SEC
            SBC   HF_ADDR+1
            CLC
            ADC   #1
            STA   HF_PAGES
            LDA   HF_FNLEN
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #1
            JSR   SETLFS
            LDA   HF_PAGES
            LDX   HF_ADDR
            LDY   HF_ADDR+1
            JSR   SAVE
            JSR   CLRCHN
            LDA   #FASTCLOCK
            STA   MMU_MCR
            RTS

; OSFILE_GETFN - Copy CR-terminated filename to FILENAME_BUF
; Entry: HF_PTR -> OSFILE control block (+0 = filename pointer)
; Exit:  HF_FNLEN = length, FILENAME_BUF filled
OSFILE_GETFN:
            LDY   #0
            LDA   (HF_PTR),Y
            STA   HF_FNPTR
            INY
            LDA   (HF_PTR),Y
            STA   HF_FNPTR+1
            LDY   #0
            LDX   #0
@LP:
            LDA   (HF_FNPTR),Y
            CMP   #$0D
            BEQ   @DONE
            CMP   #$00
            BEQ   @DONE
            STA   FILENAME_BUF,X
            INX
            INY
            CPX   #63
            BCC   @LP
@DONE:
            STX   HF_FNLEN
            RTS

OSFILE_CAT:
            RTS

; ============================================================
; OSFIND - Open/close files for byte access
; A=0 -> close file (handle in Y)
; A=$40 -> open for input
; A=$80 -> open for output
; A=$C0 -> open for update
; ============================================================
OSFIND:
            CMP   #0
            BEQ   OSFIND_CLOSE
            AND   #$40
            BNE   OSFIND_OPEN
OSFIND_OPEN:
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #2
            LDX   #8
            LDY   #2
            JSR   SETLFS
            JSR   OPEN
            LDA   #2
            JMP   CHKIN

OSFIND_CLOSE:
            TYA
            JSR   CLOSE
            JMP   CLRCHN

; ============================================================
; OSBGET - Get byte from file
; ============================================================
OSBGET:
            JSR   CHRIN
            STA   OSCTRL
            RTS

; ============================================================
; OSBPUT - Put byte to file
; ============================================================
OSBPUT:
            PHA
            JSR   CHROUT
            PLA
            RTS

; ============================================================
; OSARGS - Read file arguments
; ============================================================
OSARGS:
            RTS

; ============================================================
; OSGBPB - Read/write block from file
; ============================================================
OSGBPB:
            RTS

; ============================================================
; Variables
; ============================================================
FILENAME_BUF:
            .res 64
HF_PTR      = $75     ; control block pointer (2 bytes)
HF_FNPTR    = $77     ; filename string pointer (2 bytes)
HF_FNLEN    = $79     ; filename length
HF_ADDR     = $7A     ; address (2 bytes)
HF_ADDR2    = $7C     ; end/start address (2 bytes)
HF_PAGES    = $7E     ; page count for save
OSFILE_START = $8000
OSFILE_END   = $9000
