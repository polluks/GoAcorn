; AUXMEM.HOSTFS.S - C128 host filing system
; Maps BBC Micro OSFILE/OSFIND/OSBGET/OSBPUT to C128 KERNAL calls

; ============================================================
; OSFILE - File operations (load, save, etc.)
; A=0 -> load file to memory
; A=1 -> save memory to file
; A=2 -> write file (catalog)
; A=5 -> read catalog
; ============================================================
OSFILE:
            CMP   #0
            BEQ   OSFILE_LOAD
            CMP   #1
            BEQ   OSFILE_SAVE
            CMP   #5
            BEQ   OSFILE_CAT
            RTS

OSFILE_LOAD:
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #0
            JSR   SETLFS
            LDA   #0         ; Load
            LDX   OSCTRL     ; Load address low
            LDY   OSCTRL+1   ; Load address high
            JSR   LOAD
            JSR   CLRCHN
            RTS

OSFILE_SAVE:
            JSR   CLRCHN
            LDX   #<FILENAME_BUF
            LDY   #>FILENAME_BUF
            JSR   SETNAM
            LDA   #1
            LDX   #8
            LDY   #1
            JSR   SETLFS
            LDX   OSCTRL     ; Start low
            LDY   OSCTRL+1   ; Start high
            LDA   #$00       ; Save entire bank
            JSR   SAVE
            JSR   CLRCHN
            RTS

OSFILE_CAT:
; Read catalog directory
            RTS

; ============================================================
; OSFIND - Open/close files for byte access
; A=0 -> close file (handle in Y)
; A=$40 -> open for input (Y=handle, filename at OSCTRL)
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
            LDA   #2         ; Logical file
            LDX   #8         ; Device
            LDY   #2         ; Secondary addr
            JSR   SETLFS
            JSR   OPEN
            LDA   #2
            JSR   CHKIN
            RTS

OSFIND_CLOSE:
            TYA
            JSR   CLOSE
            JSR   CLRCHN
            RTS

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
OSFILE_START = $8000
OSFILE_END   = $9000
