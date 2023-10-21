// built-in functions

    frameadvance: // num_of_frames
        ldr r4, =0x08013561
        bx r4
        .pool
    create_panel: // x, y, width, height, animation; return *panel
        ldr r4, =0x08039261
        bx r4
        .pool
    clear_panel: // *panel
        ldr r4, =0x080393FD
        bx r4
        .pool
    delete_panel: // *panel
        ldr r4, =0x0803939D
        bx r4
        .pool
    draw_tile_to_panel: // *panel, tile_index, tile_x, tile_y, animation
        ldr r4, =0x0803C275
        bx r4
        .pool
    create_cursor: // *sprite_attrs, *sprite_slot
        ldr r4, =0x0803F625
        bx r4
        .pool
    draw_cursor: // *sprite_attrs, x, y
        ldr r4, =0x0803F699
        bx r4
        .pool
    delete_cursor: // *sprite_slot
        ldr r4, =0x0803F6C1
        bx r4
        .pool