// Atari XL PBI to Beaglebone Memory Expansion

.origin 0
.entrypoint ABX_PRU0

#include "pru.hp"

ABX_PRU0:

    // Enable OCP master port
    LBCO r0, CONST_PRUCFG, 4, 4

    // Clear SYSCFG[STANDBY_INIT] to enable OCP master port
    CLR r0, r0, 4
    SBCO r0, CONST_PRUCFG, 4, 4

    // Configure the programmable pointer register for PRU0 by setting
    // c28_pointer[15:0] field to 0x0120. This will make C28 point to
    // 0x00012000 (PRU shared RAM).
    MOV r0, 0x00000120
    MOV r1, CTPPR_0
    ST32 r0, r1

//    // Load values from read from the DDR memory into PRU shared RAM
//
//    LBCO r0, CONST_PRUSHAREDRAM, 0, 12
//
//    // Store values from external DDR Memory into Registers R0/R1/R2
//
//    SBCO r0, CONST_DDR, 0, 12

    MOV r1, 10
BLINK:
    MOV r3, 7<<22
    MOV r4, GPIO1 | GPIO_SETDATAOUT
    SBBO r3, r4, 0, 4

    MOV r0, 0x00a00000
DELAY:
    SUB r0, r0, 1
    QBNE DELAY, r0, 0

    MOV r3, 7<<22
    MOV r4, GPIO1 | GPIO_CLEARDATAOUT
    SBBO r3, r4, 0, 4

    MOV r0, 0x00a00000
DELAY2:
    SUB r0, r0, 1
    QBNE DELAY2, r0, 0

    SUB r1, r1, 1
    QBNE BLINK, r1, 0

//    WBC r31, 15
//    MOV r1, 0x8c000000
//    SBBO r31, r1, 0, 4

    // Send notification to Host for program completion
    MOV r31.b0, PRU0_ARM_INTERRUPT+16

    HALT
