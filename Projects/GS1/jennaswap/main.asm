.gba
.create "main.bin", 0x02000000

.org 0x020005D8
.word 0x10B40067 // give Isaac one herb to activate flag execution

.org 0x020000E4

.arm
add r0, pc, 9
mov r1, 0x03000000
str r0, [r1, 0xE0]
bx lr

.thumb
add r0, =@@pool
ldmia r0!, {r0-r3}
ldrh r4, [r0]
lsl r4, 0x1E
bcc @@exit
add r0, 0x60
ldrh r0, [r0]
lsl r0, 0x17
bcc @@exit
ldr r0, [r1]
mov r4, 5
eor r0, r4
str r0, [r1]
sub r1, 0x4D
strh r1, [r2]
@@exit:
    bx r3
.align
@@pool:
    .word 0x03001C94, 0x02000434, 0x02030170, 0x08003651

.close