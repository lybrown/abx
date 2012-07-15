// Atari XL PBI to Beaglebone memory expansion

// Convention:
//  r0-r15 are temp registers
//  r16-r29 are variables
//  r30-r31 are write and read I/O
.origin 0
.entrypoint abx_pru0

#include "pru.hp"

.macro BLINK_BOARD_LEDS
    mov r3, 7<<22
    mov r1, 10
blink:
    mov r4, GPIO1 | GPIO_SETDATAOUT
    sbbo r3, r4, 0, 4

    mov r0, 0x00a00000
delay:
    sub r0, r0, 1
    qbne delay, r0, 0

    mov r4, GPIO1 | GPIO_CLEARDATAOUT
    sbbo r3, r4, 0, 4

    mov r0, 0x00a00000
delay2:
    sub r0, r0, 1
    qbne delay2, r0, 0

    sub r1, r1, 1
    qbne blink, r1, 0
.endm

.macro CLEAR_DDR_MEMORY
    zero &r0, 64
    mov r1, 0x8c000000
    mov r2, 0x90000000
clear:
    sbbo r0, r1, 0, 64
    add r1, r1, 64
    qblt clear, r2, r1
.endm

.macro QUIT
    // Send notification to host for program completion
    mov r31.b0, PRU0_ARM_INTERRUPT+16
    halt
.endm

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

#define jumptable r29
#define gpio1_datain r28
#define gpio2_datain r27
#define data1 r26
#define data2 r25
#define ddr r24
#define capture_addr r23

    // Load jumptable address
    mov jumptable, 0x1c00
    // Load GPIO_DATAIN addresses
    mov gpio1_datain, GPIO1 | GPIO_DATAIN
    mov gpio2_datain, GPIO2 | GPIO_DATAIN
    // Load DDR address
    mov ddr, 0x8c000000
    mov capture_addr, ddr

    BLINK_BOARD_LEDS

    CLEAR_DDR_MEMORY

    // Clear ABX_OE (GPIO1_31) value
    mov r0, GPIO1 | GPIO_CLEARDATAOUT
    mov r1, 1<<31
    sbbo r1, r0, 0, 4

    // Clear ABX_OE (GPIO1_31) output enable
    mov r0, GPIO1 | GPIO_OE
    lbbo r1, r0, 0, 4
    clr r1, 31
    sbbo r1, r0, 0, 4

    mov r2, 0x10000
    add r2, r2, ddr
capture:
    lbbo data1, gpio1_datain, 0, 4
    lbbo data2, gpio2_datain, 0, 4
    sbbo data1, capture_addr, 0, 8

    mov r1, 0x10
    mov r0, 0
capdelay:
    sub r1, r1, 1
    qbne capdelay, r1, r0

    add capture_addr, capture_addr, 8
    qblt capture, r2, capture_addr

    QUIT

wait_phi2_rise:
    wbc r31, 15
    wbs r31, 15

//    // compute index
//
//    // compute jump table offset
//    add r0, jumptable, r4
//    // load jump address
//    lbbo r0, r0, 0, 2
//    // jump
//    jmp r0.w0
    jmp writeram

wait_phi2_fall:
    wbs r31, 15
    wbc r31, 15

    //jmp writeram

    QUIT

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
