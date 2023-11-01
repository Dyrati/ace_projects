// Hex editor module
    .org 0x02002A00

    main: // called each frame within frameadvance function, before graphic updates
        push {r5-r7,lr}
        add sp, -0x20 // 5th arg, sprite_slot, sprite_attrs (0xC), prev_input, hold_timer, *panel
        add r5, =hex_editor_attrs
        ldrb r0, [r5, 7]
        cmp r0, 0 // if already running, exit; prevents calling self on frameadvance
        bne @@return
        mov r0, sp
        mov r1, 0x20
        bl @clear_bytes
        ldr r6, =0x03001150
        ldr r0, [r6] // current input
        mov r1, 0x81
        lsl r1, 0x2
        cmp r0, r1
        bne @@return
        str r0, [sp, 0x14]
        add r1, sp, 4 // sprite_slot
        add r0, sp, 8 // sprite_attrs
        bl create_cursor
        mov r0, 2
        str r0, [sp, 0]
        mov r0, 3
        mov r1, 0
        mov r2, 25
        mov r3, 20
        bl create_panel
        str r0, [sp, 0x1C]
        @@menu:
            ldr r0, [r6]
            cmp r0, 0x2
            beq @@exit
            ldr r3, [sp, 0x14] // previous input
            str r0, [sp, 0x14]
            ldr r4, [sp, 0x18] // timer for held inputs
            // handle repeated inputs
                cmp r0, r3
                beq @@repeat
                mov r4, 0
                @@repeat:
                    add r4, 1
                cmp r4, 20
                bcc @@halt
                mov r4, 16
                b @@halt+2
                @@halt:
                    bic r0, r3
                str r4, [sp, 0x18]
            //
            mov r1, r5
            bl @edit_menu
            mov r1, r0
            ldr r0, [sp, 0x1C] // *panel
            mov r2, r5
            bl @move_cursor
            mov r1, r5
            add r2, sp, 8
            bl @draw_cursor_to_panel
            ldr r1, [r5]
            ldrb r2, [r5, 6]
            bl @draw_mem_viewer
            mov r0, 1
            strb r0, [r5, 7] // set editor state as active
            mov r1, 0
            str r1, [r6] // disable inputs
            ldr r4, =0x02030F00
            strb r0, [r4, 3] // update VRAM
            bl frameadvance
            b @@menu
            @@exit:
                ldr r0, [sp, 0x4]
                bl delete_cursor
                mov r0, 0
                strb r0, [r5, 7]
                ldr r0, =0x0203015A
                mov r1, 0x16
                bl @clear_bytes
                ldr r0, [sp, 0x1C]
                mov r1, 2
                bl delete_panel
        @@return:
            add sp, 0x20
            pop {r5-r7,pc}
        .pool

    hex_editor_attrs: // addr, cursor_x, cursor_y, groupsize, active
        .word 0x02000000
        .byte 0
        .byte 0
        .byte 1
        .byte 0

    @edit_menu: // inputs, *editor_attrs
        push {r0-r7,lr}
        mov r5, r1
        mov r1, 8
        bl  @check_opposing_buttons
        cmp r1, 0
        beq @@return
        ldrb r2, [r5, 4] // cursor x
        ldrb r3, [r5, 5] // cursor y
        cmp r3, 0
        bne @@data_region
        cmp r2, 7
        bls @@addr_region
        cmp r2, 9
        beq @@groupsize_region
        b @@return
        @@addr_region:
            mov r3, 7
            sub r3, r3, r2
            lsl r3, 2 // shift amount
            lsl r1, r3
            ldr r4, [r5]
            add r4, r4, r1
            str r4, [r5]
            b @@return
        @@groupsize_region:
            ldrb r2, [r5, 6]
            cmp r1, 0
            blt @@div
            @@mul:
                cmp r2, 4
                bcs @@return
                lsl r2, 1
                b @@edit_groupsize
            @@div:
                cmp r2, 1
                bls @@return
                lsr r2, 1
            @@edit_groupsize:
                strb r2, [r5, 6]
            b @@return
        @@data_region:
            sub r3, 2
            bmi @@return
            ldr r4, [r5] // addr
            lsl r3, 3
            add r4, r4, r3 // add 8 bytes per row to addr
            ldrb r6, [r5, 6] // group_size
            lsl r7, r6, 1 // digits per group
            add r3, r7, 1 // width per group
            @@loop:
                add r4, r4, r6
                sub r2, r2, r3
                bpl @@loop
            sub r4, r4, r6
            add r2, r2, r3
            sub r7, 1
            sub r7, r7, r2
            bmi @@return
            lsl r7, 2
            lsl r1, r7 // amount to add
            cmp r6, 1
            beq @@write8
            cmp r6, 2
            beq @@write16
            cmp r6, 4
            beq @@write32
            @@write8:
                ldrb r0, [r4]
                add r0, r0, r1
                strb r0, [r4]
                b @@return
            @@write16:
                ldrh r0, [r4]
                add r0, r0, r1
                strh r0, [r4]
                b @@return
            @@write32:
                ldr r0, [r4]
                add r0, r0, r1
                str r0, [r4]
        @@return:
            pop {r0-r7,pc}

    @check_opposing_buttons: // input, bitpos; returns (in r1) -1 if first input, 1 if second input, and 0 if neither or both are held
        push {r0,r2,lr}
        mov r2, 0x1F
        sub r2, r2, r1
        mov r1, 0
        lsl r0, r2
        bcc @@up+2
        @@up:
            sub r1, 1
        lsl r0, 1
        bcc @@down+2
        @@down:
            add r1, 1
        pop {r0,r2,pc}

    @move_cursor: // *panel, input, *editor_attrs
        push {r0-r6,lr}
        ldrh r4, [r0, 0x8] // width
        ldrh r5, [r0, 0xA] // height
        sub r4, 3
        sub r5, 3
        mov r0, r1
        mov r6, r2
        ldrb r2, [r6, 4] // cursor_x
        ldrb r3, [r6, 5] // cursor_y
        @@UpDown:
            mov r1, 6
            bl @check_opposing_buttons
            cmp r1, 0
            beq @@LeftRight 
            sub r3, r3, r1
            bge @@topwrap+2
            @@topwrap:
                mov r3, r5
            cmp r3, r5
            ble @@botwrap+2
            @@botwrap:
                mov r3, 0
            strb r3, [r6, 5]
        @@LeftRight:
            mov r1, 4
            bl @check_opposing_buttons
            cmp r1, 0
            beq @@return
            add r2, r2, r1
            bge @@leftwrap+2
            @@leftwrap:
                mov r2, r4
            cmp r2, r4
            ble @@rightwrap+2
            @@rightwrap:
                mov r2, 0
            strb r2, [r6, 4]
        @@return:
            pop {r0-r6,pc}

    @draw_cursor_to_panel: // *panel, *editor_attrs, *sprite_attrs
        push {r0-r5,lr}
        ldr r3, [r0, 0xC] // panel x
        ldr r4, [r0, 0x10] // panel y
        mov r0, r2
        ldrb r2, [r1, 4] // cursor x
        ldrb r5, [r1, 5] // cursor y
        add r1, r2, r3
        add r2, r4, r5
        lsl r1, 3
        lsl r2, 3
        add r1, 2
        sub r2, 4
        bl draw_cursor
        pop {r0-r5,pc}

    @draw_mem_viewer: // *panel, address, groupsize
        push {r0-r7,lr}
        add sp, -0x4
        mov r5, r1
        mov r6, r2
        push {r0-r3}
        bl clear_panel
        pop {r0-r3}
        mov r4, 8
        str r4, [sp]
        mov r2, 0
        mov r3, 0
        bl @draw_hex_value // address
        mov r4, 1
        str r4, [sp]
        mov r1, r6
        mov r2, 9
        bl @draw_hex_value // group size
        mov r2, 0
        mov r3, 2
        lsl r4, r6, 1
        str r4, [sp]
        add r4, 1
        mov r7, 0x7
        @@loop:
            ldr r1, [r5]
            bl @draw_hex_value // byte group
            add r5, r5, r6
            add r2, r2, r4
            sub r7, r7, r6
            bpl @@loop
            mov r7, 0x7
            mov r2, 0
            add r3, 1
            cmp r3, 18
            bcc @@loop
        add sp, 0x4
        pop {r0-r7,pc}

    @draw_hex_value: // *panel, value, tile_x, tile_y, num_digits
        push {r0-r6,lr}
            ldr r4, [sp, 0x20]
            mov r5, r1
            sub r4, 1
            lsl r4, 2
            mov r6, 0xF
            @@loop:
                mov r1, r5
                lsr r1, r4
                and r1, r6
                bl @draw_hex_digit
                add r2, 1
                sub r4, 4
                bpl @@loop
        pop {r0-r6,pc}

    @draw_hex_digit: // *panel, value, tile_x, tile_y
        push {r0-r7,lr}
        add sp, -0x4
        cmp r1, 0x10
        bcs @@return
        cmp r1, 0xA
        bcc @@low
        add r1, 7
        @@low:
            add r1, 0x30
        mov r4, 2
        str r4, [sp, 0]
        bl draw_tile_to_panel
        @@return:
            add sp, 0x4
            pop {r0-r7,pc}

    @clear_bytes: // addr, length
        mov r2, 0
        @@loop:
            sub r1, 1
            strb r2, [r0, r1]
            bhi @@loop
        bx lr
