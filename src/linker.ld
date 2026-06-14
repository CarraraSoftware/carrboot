OUTPUT_FORMAT("binary")
SECTIONS {
    .bouncercode 0x8000: {
        *(.bouncercode)
    }
}
