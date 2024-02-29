// TODO:
// - Reduce the numbers of call to ldr and stp which are the most costly
// - Reduce the numbers of instructions


// Even thought debuggers give the impression that instruction are called linearly, most operation on a CPU are done async and in parallel

.section .data
    string_toguess: .asciz "helloworld"
    string_tofill:  .asciz "__________"

.section .text
    .global main

replace_if_contain:
// STACK
// 0-8: fp
// 8-16: lr
// 16-24: str_toguess
// 24-32: str_tofill
// 32-36: str_len
// 36-40: input
// 40-44: filled
// 44-48: i

    .replace_if_contain_prologue:
        stp fp, lr, [sp, -64]!
        mov fp, sp

        str x0, [sp, 16] // (str_toguess)
        str x1, [sp, 24] // (str_tofill)
        str w2, [sp, 32] // (str_len)
        str w3, [sp, 36] // (input)

        mov w0, 0 // (filled)
        str w0, [sp, 40]

        mov w0, 0 // (i)
        str w0, [sp, 44]

        b .replace_if_contain_loop_entry

    .replace_if_contain_loop_if_true:
        // Update filled to True
        mov w0, 1
        str w0, [sp, 40]

        // Load (i)
        ldr w0, [sp, 44]

        // Load (*str_tofill)
        ldr x1, [sp, 24]

        // Load (input)
        ldr w2, [sp, 36]

        // str_tofill[i] = input
        // This throw an error
        strb w2, [x1, x0, LSL#0]

        b .replace_if_contain_loop_inc

    .replace_if_contain_loop_body:
        ldr w0, [sp, 44] // (i)

        // Load Memory Address of str_toguess
        ldr x1, [sp, 16]

        // Load character str_toguess[i]
        ldrb w1, [x1, x0, LSL#0]

        // Load input
        ldr w0, [sp, 36]

        cmp w0, w1
        b.eq .replace_if_contain_loop_if_true

    .replace_if_contain_loop_inc:
        //
        // for(;; i+= 1)
        //
        ldr w0, [sp, 44] // (i)
        add w0, w0, 1
        str w0, [sp, 44]

    .replace_if_contain_loop_entry:
        //
        // for(; i < str_len;)
        //
        ldr w0, [sp, 44] // (i)
        ldr w1, [sp, 32] // (str_len)
        cmp w0, w1
        b.le .replace_if_contain_loop_body

    .replace_if_contain_epilogue:
        ldr w0, [sp, 40]
        ldp fp, lr, [sp], 64
        ret

main:
// Stack
// 0-8: fp
// 8-16: lr
// 16-20: input
// 20-24: life

    // Prologue - Always matching epilogue size
    stp     fp, lr, [sp, -32]! // Stack grow to the LOWR adress // Only multiple of 16 bytes are allowed
    mov     fp, sp // 8 bytes

    mov w0, 0
    str w0, [sp, 16] // Initialize _input_ at 0

    mov w0, 5
    str w0, [sp, 20] // Initialize _life_ at 5

    .main_loop:
        //
        // Prepare format for calling scanf
        //

        // Load .data subsection
        adrp    x0, .scanf_format_input
        add     x0, x0, :lo12:.scanf_format_input

        // Store &input
        add x1, sp, 16

        // Call scanf / Value at adress store at [sp, 25] has been updated
        bl scanf

        //
        // Check if _input_ == "!"
        //
        ldr x0, [sp, 16]
        cmp x0, 33
        b.eq .main_if_exclamation_mark

        //
        // Check if __input__ is contained inside string_toguess
        //

        //
        // Retrieve String Length
        //
        adrp    x0, string_toguess
        add     x0, x0, :lo12:string_toguess

        bl strlen

        //
        // Call replace_if_contain
        //

        // str_len
        mov w2, w0

        adrp    x0, string_toguess
        add     x0, x0, :lo12:string_toguess

        // _str_tofill_
        adrp    x1, string_tofill
        add     x1, x1, :lo12:string_tofill

        // Store input
        ldr w3, [sp, 16] // _input_

        bl replace_if_contain

        cmp w0, 0
        b.eq .main_if_incorrect_guess

    .main_if_correct_guess:
        adrp    x0, .printf_format_correct_guess
        add     x0, x0, :lo12:.printf_format_correct_guess // Store string adress into x0

        bl printf

    //
    // Check if string_toguess == string_tofill
    //
    .main_if_toguess_eq_tofill:
        adrp    x0, string_toguess
        add     x0, x0, :lo12:string_toguess // Store string adress into x0

        adrp    x1, string_tofill
        add     x1, x1, :lo12:string_tofill // Store string adress into x1

        bl strcmp

        cmp w0, 0
        b.eq .main_if_completed

    .main_print_state:
        adrp    x0, .printf_format_state
        add     x0, x0, :lo12:.printf_format_state // Store string adress into x0

        adrp    x1, string_tofill
        add     x1, x1, :lo12:string_tofill // Store string adress into x1

        bl printf

        // Loop otherwise if no condition has been hit
        b .main_loop

    .main_end:
        // Return 0
        mov     w0, 0
        ldp     fp, lr, [sp], 32 // Always matching prologue size
        ret

    .main_if_incorrect_guess:
        ldr w1, [sp, 20]
        sub w1, w1, 1
        str w1, [sp, 20]

        cmp w1, 0
        b.eq .main_if_die

        adrp    x0, .printf_format_incorrect_guess
        add     x0, x0, :lo12:.printf_format_incorrect_guess // Store string adress into x0

        bl printf

        b .main_print_state

    .main_if_exclamation_mark:
        adrp    x0, .printf_format_quit
        add     x0, x0, :lo12:.printf_format_quit // Store string adress into x0

        bl printf

        b .main_end

    .main_if_die:
        adrp    x0, .printf_format_died
        add     x0, x0, :lo12:.printf_format_died // Store string adress into x0

        bl printf

        b .main_end

    .main_if_completed:
        adrp    x0, .printf_format_completion
        add     x0, x0, :lo12:.printf_format_completion // Store string adress into x0

        bl printf

        b .main_end

.scanf_format_input: .asciz "%1s"

.printf_format_state: .asciz "%s\n"

.printf_format_correct_guess: .asciz "You have guessed correctly! Well done!!! \n"

.printf_format_incorrect_guess: .asciz "You have lost one life. \nRemaining Life: %d\n"

.printf_format_died: .asciz "Shoot. You ave lost! :(\n"

.printf_format_completion: .asciz "You have won! Congrats! :)\n"

.printf_format_quit: .asciz "Never give up! :( Try again!\n"

