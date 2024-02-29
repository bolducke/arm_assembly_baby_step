.section .text
    .global main

main:
        // Prologue - Always matching epilogue size
        stp     fp, lr, [sp, -32]! // Stack grow to the LOWR adress // Only multiple of 16 are allowed
        mov     fp, sp

        // Store input char
        mov     w0, 97 // 97 -> 'a'
        strb    w0, [sp, 31] // Store character in stack memory
        add     x0, sp, 31 // Store address in register x0

        // Move it into registers x1
        mov     x1, x0

         // Retrieve the adress of the string
        adrp    x0, .LC0
        add     x0, x0, :lo12:.LC0

        // Call scanf with "%c"
        bl      scanf

        // Load back the input from the stack
        ldrb    w0, [sp, 31]

        // Move the value from w0 to w1 to format it to call the function
        mov     w1, w0

        // Retrieve the string at the adress into x0
        adrp    x0, .LC1
        add     x0, x0, :lo12:.LC1

        // Call printf with "\n%c\n", $input
        bl      printf

        // Return 0
        mov     w0, 0
        ldp     fp, lr, [sp], 32 // Always matching prologue size
        ret

.LC0:
        .string "%c"
.LC1:
        .string "\n%c\n"
