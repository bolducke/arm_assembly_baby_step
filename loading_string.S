// To load string which can contains more characters than a registers can have, the processor can load them
//
//

.section .text
    .global main

main:
        // Function prologue
        stp     x29, x30, [sp, -48]!
        mov     x29, sp
        
        // Load string and Modify one of the character
        adrp    x0, .str
        add     x0, x0, :lo12:.str
        ldp     x2, x3, [x0]
        stp     x2, x3, [sp, 24]
        ldr     x0, [x0, 13]
        str     x0, [sp, 37]
        mov     w0, 102
        strb    w0, [sp, 44]
        add     x1, sp, 24

        // Load format adress
        adrp    x0, .fmt
        add     x0, x0, :lo12:.fmt

        // Printf
        bl      printf

        // Function epilogue
        mov     w0, 0
        ldp     x29, x30, [sp], 48
        ret
.str:
        .string "abcdeghijklmnopqrstuv"

.fmt:
        .string "%s"
