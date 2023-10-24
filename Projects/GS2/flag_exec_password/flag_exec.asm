.gba
.relativeinclude on
.create "main.bin", 0x02000000

// CPU State at 021B8FF8:
//  r0: 00000000   r1: 00000000   r2: 00000000   r3: 00000000
//  r4: 00000000   r5: 0000000E   r6: 02003660   r7: 000000C0
//  r8: 02030000   r9: 03001218  r10: 00000000  r11: 03001150
// r12: 00000000  r13: 03007E58  r14: 022A71F8  r15: 021B8FFE
// cpsr: 4000003F [-Z----T]

.org 0x0200A74A

// password text
    asr r2, r6, 0xC // store 0x2003 in r2 for convenience
    lsl r4, r2, 0x10
    add r4, 0x12
    lsl r4, r4, 8
    lsl r3, r4, 0xD
    sub r7, 3
    lsl r1, r2, 0x14
    lsl r0, r7, 8
    add r0, 0xF // store 0xBD0F (pop {r0-r3,pc}) in r0
    add r3, 0x30
    add r3, 0x63
    str r0, [r3, 0x30] // write r0 at 020000C0 (flag 400)
    sub r3, r4, r1
    add r4, 8
    add r2, 0x36
    str r0, [r4, 0x30] // set debug mode
    lsl r1, r2, 0xC
    str r0, [r1, 0x30] // write r0 ahead
    add r4, r3, r0 // r4 = 02D0CF0F
    sub r0, 0x17
    lsl r6, r0, 0x18
    lsl r0, r0, 8
    add r3, r6, r0
    sub r3, 0xD
    str r3, [r4, 0x34] // write bl $020000C0 at 0200CF40
//

.close