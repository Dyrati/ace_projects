frameadvance: // frames
    ldr r4, =0x08013561
    bx r4
create_sprite: // sprite_index; return *sprite_info
    ldr r4, =0x08022D41
    bx r4
set_sprite_animation: // *sprite_info, ?
    ldr r4, =0x08020031
    bx r4
update_sprite_graphic: // *sprite_info, direction
    ldr r4, =0x08021A85
    bx r4
update_sprite_slot: // *sprite_info, slot
    ldr r4, =0x08014129
    bx r4
clear_sprite: // *sprite_info
    ldr r4, =0x08022E91
    bx r4
.pool