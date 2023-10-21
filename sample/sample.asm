// set the architecture
.gba

// create your main file, with its first byte corresponding to address 02000000
.create "main.bin", 0x02000000

// move to address 02003610
.org 0x02003610

// write some data there
.word 0x02002A00
.word 0x000004FF

// write some assembly at 02002A00
.org 0x02002A00
mov r0, 0x60
lsl r0, 0x14
mov r1, 0
sub r1, 1
str r1, [r0]
bx lr

// close main.bin
.close