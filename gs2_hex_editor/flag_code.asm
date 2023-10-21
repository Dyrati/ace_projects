// flag 400
    .org 0x020000C0
    @copy: // copy next flag page to dest, and increment dest
        pop {r0-r3,pc} // unset flag 408 to convert to pop {r0-r3}, which allows below code to run
        lsl r0, r0, 0 // intentionally blank because ace activation overwrites this area
        add r1, =@@pool
        ldmia r1!, {r0,r2} // dest, number of 32-bit integers to copy (8 = 1 flag page)
        @@loop:
            sub r2, 1
            ldmia r1!, {r3}
            stmia r0!, {r3} // set flag 46D to branch to setup (becomes b $+14)
            bcs @@loop
        sub r1, 0x02000100 - 0x020000BD
        strb r1, [r1, 4] // set flag 408 again
        str r0, [r1, @@pool + 4 - 0x020000BC] // flip flag 4AC, 4AE, or 4AF to disable dest increments
        pop {r4-r7,pc} // jump up two stack levels; convenient way to restore r5-r7 in one line
        .align
        @@pool:
            .word hex_editor
            .word 8

// flag 500
    .org 0x020000E0
    @setup: // called while on debug tile; add end_of_frame to interrupt handler
        lsr r0, r1, 1
        add r1, 7
        add r2, pc, 0x8C
        str r1, [r0, r2] // write r1 at 030001E4
        pop {pc}
    @each_frame: // called each frame after graphic updates; add hex_editor to frame loop
        lsr r1, r2, 0x6 // 0x4C0, r2 was 0x13000
        add r0, pc, 4
        ldmia r0!, {r0,r2-r3}
        push {r1-r3,r5-r7,lr} // black magic to branch to three addresses with bx r2
        bx r2
        .align
        @@pool:
            .word hex_editor
            .word 0x080145AB
            .word 0x0801399F

// flip flag 46D then flag 408 to branch to setup
    .org 0x020000CC
        b @setup
    .org 0x020000C0
        pop {r0-r3}
