@main equ 0x02002A00
@add_to_main_loop equ 0x080145A9
@on_vblank equ 0x0801399D


.org 0x020000C0 // flag 400
@copy: // copy next flag page to dest, and increment dest
    pop {r0-r3,pc} // unset bit 8 to convert to `pop {r0-r3}`, which allows below code to run
    lsl r0, r0, 0 // intentionally blank because ace activation overwrites this area
    add r1, pc, 0
    sub r1, 0x020000C8-0x020000BD
    strb r1, [r1, 4] // resets bit 8 of first instruction
    add r4, =@@pool
    ldmia r4!, {r0} // dest
    mov r3, 8 // number of 32-bit words to copy
    @@loop:
        sub r3, 1
        ldmia r4!, {r2} // unset 49A and set 4AA to swap src, des
        stmia r0!, {r2} // set bit 13 to branch to setup (becomes `b 0xC`)
        bhi @@loop
    str r0, [r1, @@pool-0x020000BC] // increment dest; flip bit 11, 13, or 14 to disable
    pop {r4-r7,pc} // jump up two stack levels; convenient way to restore r5-r7 in one line
    .align
    @@pool:
        .word @main

.org 0x020000E0 // flag 500
@setup: // called while on debug tile; add each_frame to interrupt handler
    lsr r0, r1, 1
    add r1, 0x2E
    add r2, pc, 0xA0
    str r1, [r0, r2] // write @each_frame+1 at 030001E4
    pop {pc}
@each_frame: // called each frame after graphic updates; add main to frame loop
    lsr r1, r2, 0x6 // 0x4C0, r2 was 0x13000
    add r0, =@@pool
    ldmia r0!, {r0,r2-r3}
    push {r1-r3,r5-r7,lr} // black magic to branch to three addresses with bx r2
    bx r2
    .align
    @@pool:
        .word @main + 1
        .word @add_to_main_loop + 2
        .word @on_vblank + 2

// flip flag 4AD then flag 408 to branch to setup
.org 0x020000D4
    b @setup
.org 0x020000C0
    pop {r0-r3}
