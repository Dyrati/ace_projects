.gba
.create "main.bin", 0x02000000

.org 0x020005D8
.halfword 0x0067, 0x10B4 // give Isaac one-piece-dress and 3 herbs

.org 0x020000C0

.arm
add r0, pc, 5
str r0, [r12, r8, lsl 8] // write r0 at 030000E0
bx lr

.thumb
add r0, =@@pool
ldmia r0!, {r0-r2}
ldrh r3, [r0]
lsl r3, 0x1E
bcc @@exit
ldr r0, [r0, 0x60]
lsl r0, 0x17
bcc @@exit
add r0, pc, 0x354
ldrb r3, [r0]
eor r3, r1
strb r3, [r0]
sub r0, 0x4D
str r0, [r1, 0x6C] // write 0x3E7 at 02030170
@@exit:
    bx r2
.align
@@pool:
    .word 0x03001C94, 0x02030105, 0x08003651

.close