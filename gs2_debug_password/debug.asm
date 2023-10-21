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
    asr r0, r6, 0xC // store 0x2003 in r0 for convenience
    lsl r4, r0, 0x10
    add r4, 0x12
    sub r2, r7, r0
    add r0, 0x36
    lsl r3, r2, 8
    add r3, 0xF // 0xFFE0BD0F
    lsl r4, r4, 8
    add r4, 4
    str r3, [r4, 0x34] // set debug mode
    add r4, r3, r4
    str r3, [r4, 0x30] // write 0xBD0F at 0x0200CF40 (just before initial overwrite address)
    lsl r4, r0, 0xC
    str r3, [r4, 0x34] // write 0xBD0F ahead
//

.close