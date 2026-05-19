# aC=orn - Acorn BBC Micro Language ROMs on Commodore 128

Allows Acorn BBC Microcomputer language ROMs to run on Commodore 128.
Uses VDC 80-column display at 2 MHz (no VIC-IIe).

Port of [bobbimanners/Applecorn](https://github.com/bobbimanners/Applecorn) from Apple II/ProDOS to C128/CBM DOS, using ca65 assembler.

## References

- https://github.com/bobbimanners/Applecorn - Original Applecorn project (Apple II)
- https://github.com/raybellis/mos120 - C128 BBC Micro MOS port reference
- https://tobylobster.github.io/mos/mos/index.html - BBC Micro MOS API documentation

## Build

Requires cc65 toolchain (ca65, ld65).

    make

## Hardware Requirements

- Commodore 128 (any model)
- 128KB RAM minimum
- VDC 80-column display

## Memory Map

See source files and applecorn.cfg for linker configuration.
