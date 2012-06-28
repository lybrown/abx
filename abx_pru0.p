// Atari XL PBI to Beaglebone memory expansion

.origin 0
.entrypoint abx_pru0

#include "pru.hp"

abx_pru0:

    // Clear syscfg[standby_init] to enable ocp master port
    lbco r0, CONST_PRUCFG, 4, 4
    clr r0, r0, 4
    sbco r0, CONST_PRUCFG, 4, 4

    // Configure the programmable pointer register for pru0 by setting
    // c28_pointer[15:0] field to 0x0120. this will make c28 point to
    // 0x00012000 (pru shared ram).
    mov r0, 0x00000120
    mov r1, CTPPR_0
    sbbo r0, r1, 0, 4

    // Load jumptable address into r29
    mov r29, 0x1c00

    mov r1, 10
blink:
    mov r3, 7<<22
    mov r4, GPIO1 | GPIO_SETDATAOUT
    sbbo r3, r4, 0, 4

    mov r0, 0x00a00000
delay:
    sub r0, r0, 1
    qbne delay, r0, 0

    mov r3, 7<<22
    mov r4, GPIO1 | GPIO_CLEARDATAOUT
    sbbo r3, r4, 0, 4

    mov r0, 0x00a00000
delay2:
    sub r0, r0, 1
    qbne delay2, r0, 0

    sub r1, r1, 1
    qbne blink, r1, 0

wait_phi2_rise:
    wbc r31, 15
    //jmp writeram

    // Send notification to host for program completion
    mov r31.b0, PRU0_ARM_INTERRUPT+16
    halt

.origin 0x1000
readram:
    jmp writeram
.origin 0x1200
writeram:

    jmp wait_phi2_rise
.origin 0x1400
readhard:
    jmp writeram
.origin 0x1600
writehard:
    jmp writeram
.origin 0x1800
nop:
    jmp wait_phi2_rise
