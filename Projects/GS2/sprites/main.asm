.gba
.create "main.bin", 0x02000000

.include "flag_code.asm"

.org 0x02002A00
.include "builtins.asm"

main:
    push {r5-r7,lr}
    ldr r6, =0x03001150
    add r5, =@@main_pool
    ldr r0, [r5, 0x1c]
    cmp r0, 0
    bne @@return
    @@loop:
        ldr r2, [r6]
        ldr r3, [r5, 0x0] // previous input
        str r2, [r5, 0x0]
        ldr r4, [r5, 0x14] // timer for held inputs
        // handle repeated inputs
            cmp r2, r3
            beq @@repeat
                mov r4, 0
                b @@repeat_end
            @@repeat:
                add r4, 1
                cmp r4, 20
                bcc @@halt
                mov r4, 16
                b @@halt+2
                @@halt:
                    bic r2, r3
            @@repeat_end:
            str r4, [r5, 0x14]
        ldr r3, [r5, 0x1c]
        mov r1, 0x81
        lsl r1, 0x2
        cmp r2, r1
        bne @@toggle_end
        @@toggle:
            mov r1, 0x1
            eor r3, r1
            str r3, [r5, 0x1c]
            b @@loop
        @@toggle_end:
        cmp r3, 1
        bne @@exit
        ldr r0, [r5, 0x4]
        cmp r0, 0
        bne @@init_end
        @@init:
            ldr r0, [r5, 0x8]
            mov r1, 1
            bl @initialize_sprite
            str r0, [r5, 0x4]
        @@init_end:
        lsl r2, 0x17
        bcs @@L
        lsl r2, 0x1
        bcs @@R
        lsl r2, 0x1
        bcs @@down
        lsl r2, 0x1
        bcs @@up
        lsl r2, 0x1
        bcs @@left
        lsl r2, 0x1
        bcs @@right
        ldr r0, [r5, 0x4]
        b @@updates
        @@L:
            lsl r2, 0x8
            bcs @@L_A
                ldr r1, [r5, 0x8]
                sub r1, 1
                str r1, [r5, 0x8]
                ldr r2, [r5, 0x18]
                bl @replace_sprite
                str r0, [r5, 0x4]
                b @@updates
            @@L_A:
                ldr r1, [r5, 0x18]
                sub r1, 1
                str r1, [r5, 0x18]
                bl set_sprite_animation
                b @@updates
        @@R:
            lsl r2, 0x7
            bcs @@R_A
                ldr r1, [r5, 0x8]
                add r1, 1
                str r1, [r5, 0x8]
                ldr r2, [r5, 0x18]
                bl @replace_sprite
                str r0, [r5, 0x4]
                b @@updates
            @@R_A:
                ldr r1, [r5, 0x18]
                add r1, 1
                str r1, [r5, 0x18]
                bl set_sprite_animation
                b @@updates
        @@left:
            mov r7, 0x8
            ldrh r1, [r5, 0xc]
            sub r1, 0x8
            strh r1, [r5, 0xc]
            b @@updates
        @@right:
            ldrh r1, [r5, 0xc]
            add r1, 0x8
            strh r1, [r5, 0xc]
            b @@updates
        @@up:
            ldrh r1, [r5, 0x10]
            sub r1, 0x8
            strh r1, [r5, 0x10]
            b @@updates
        @@down:
            ldrh r1, [r5, 0x10]
            add r1, 0x8
            strh r1, [r5, 0x10]
            b @@updates
        @@updates:
            bl @clear_inputs
            ldr r0, [r5, 0x4]
            ldr r3, =0xff
            ldrh r1, [r5, 0xc]
            ldrh r2, [r0, 0x6]
            bic r2, r3
            orr r1, r2
            strh r1, [r0, 0x6]
            mov r3, 0xff
            ldrh r1, [r5, 0x10]
            ldrh r2, [r0, 0x4]
            bic r2, r3
            orr r2, r1
            strh r2, [r0, 0x4]
            bl @update_sprite
            mov r0, 1
            bl frameadvance
        b @@loop
    @@exit:
        ldr r0, [r5, 0x4]
        bl clear_sprite
        mov r0, 0
        str r0, [r5, 0x1c]
    @@return:
        pop {r5-r7,pc}
    .pool
    @@main_pool:
        .word 0 // previous input
        .word 0 // *sprite_info
        .word 0 // sprite_index
        .word 0 // x
        .word 0 // y
        .word 0 // input_repeat_count
        .word 0 // animation
        .word 0 // enabled

@initialize_sprite: // index, animation; return *sprite_info
    push {r1-r5,lr}
    mov r5, r1
    bl create_sprite
    mov r1, r5
    strb r1, [r0, 0x9]
    mov r5, r0
    bl set_sprite_animation
    mov r0, r5
    pop {r1-r5,pc}

@update_sprite: // *sprite_info
    push {r0-r7,lr}
    mov r5, r0
    mov r1, 0x40
    lsl r1, 0x8
    bl update_sprite_graphic
    // set horizontal flip bit
        ldrb r1, [r5, 0x7]
        mov r2, 0x10
        bic r1, r2
        lsl r0, 4
        orr r1, r0
        //strb r1, [r5, 0x7]
    mov r0, r5
    ldrb r1, [r0, 0x10]
    bl update_sprite_slot
    pop {r0-r7,pc}

@replace_sprite: // *sprite_info, new_id, animation; return new *sprite_info
    push {r1-r6,lr}
    mov r5, r1
    mov r6, r2
    bl clear_sprite
    mov r0, r5
    mov r1, r6
    bl @initialize_sprite
    pop {r1-r6,pc}

@clear_bytes: // addr, length
    mov r2, 0
    @@loop:
        sub r1, 1
        strb r2, [r0, r1]
        bhi @@loop
    bx lr

@clear_inputs:
    push {r0-r2,lr}
    ldr r0, =0x03001150
    mov r1, 0
    strh r1, [r0]
    ldr r0, =0x0203015A
    mov r1, 0x16
    bl @clear_bytes
    pop {r0-r2,pc}
    .pool

.close