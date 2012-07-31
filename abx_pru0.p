// Atari XL PBI to Beaglebone memory expansion

// 6-bit MConnID
// Initiator 6-bit MConnID (Debug) Instrumentation
// MPUSS M1 (128-bit) 0x00 0 Connects only to EMIF
// MPUSS M2 (64-bit) 0x01 SW 
// DAP 0x04 SW
// P1500 0x05 SW
// PRU-ICSS (PRU0) 0x0E SW
// PRU-ICSS (PRU1) 0x0F SW
// Wakeup M3 0x14 SW
// TPTC0 Read 0x18 0
// TPTC0 Write 0x19 SW
// TPTC1 Read 0x1A 0
// TPTC1 Write 0x1B 0
// TPTC2 Read 0x1C 0
// TPTC2 Write 0x1D 0
// SGX530 0x20 0
// OCP WP Traffic Probe 0x20 (1) HW Direct connect to DebugSS
// OCP WP DMA Profiling 0x21 (1) HW Direct connect to DebugSS
// OCP-WP Event Trace 0x22 (1) HW Direct connect to DebugSS
// LCD Ctrl 0x24 0
// GEMAC 0x30 0
// USB DMA 0x34 0
// USB QMGR 0x35 0
// Stat Collector 0 0x3C HW
// Stat Collector 1 0x3D HW
// Stat Collector 2 0x3E HW
// Stat Collector 3 0x3F HW
// 
// (1) Comment Connects only to L4_WKUP One WR port for data logging These
// MConnIDs are generated within the OCP-WP module based on the H0, H1, and H2
// configuration parameters.
// 
// NOTE:
// Instrumentation refers to debug type. SW instrumentation means that the master
// can write data to be logged to the STM (similar to a printf()). HW indicates
// debug


// Convention:
//  r0-r15 are temp registers
//  r16-r29 are variables
//  r30-r31 are write and read I/O
.origin 0
.entrypoint abx_pru0

    mov r30, 0xffffffff

#include "pru.hp"

#define pru1_r31_shadow r18
#define num_zero r19
#define lastcycles r20
#define laststalls r21
#define gpio2_dataout r22
#define capture_addr r23
#define ddr r24
#define pru1_r30 r25
#define pru1_r31 r26
#define gpio2_datain r27
#define gpio1_datain r28
#define jumptable r29

#define localdata0 c24
#define localdata2 c25
#define shared c28

#define ALO_EN 0b011110
#define AHI_EN 0b011101
#define DATAOUT_EN 0b011011
#define DATAIN_EN 0b010111
#define CTRL_EN 0b011111

    mov num_zero, 0

.macro ENABLE_CYCLE_COUNTER
    mov r0, CTRL_CONTROL
    lbbo r1, r0, 0, 4
    set r1, 3
    sbbo r1, r0, 0, 4
    mov r0, CTRL_CYCLE
    lbbo r1, r0, 0, 8
    mov r1, lastcycles
    mov r2, laststalls
.endm

.macro WRITE_CYCLES_STALLS
.mparam dst
    mov r0, CTRL_CYCLE
    lbbo r1, r0, 0, 8
    sub r3, r1, lastcycles
    sub r3, r3, 0x12
    sub r4, r2, laststalls
    sub r4, r4, 0x7
    mov lastcycles, r1
    mov laststalls, r2
    sbbo r3, dst, 0, 8
.endm

.macro BLINK_BOARD_LEDS
    mov r3, 7<<22
    mov r1, 5
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
    zero &r2, 32
    mov r0, 0x8c000000
    mov r1, 0x90000000
clear:
    sbbo r2, r0, 0, 32
    add r0, r0, 32
    qblt clear, r1, r0
.endm

.macro ENABLE_BUFFERS
//    // Clear ABX_OE (GPIO1_31) value
//    mov r0, GPIO1 | GPIO_CLEARDATAOUT
//    mov r1, 1<<31
//    sbbo r1, r0, 0, 4
//
//    // Clear ABX_OE (GPIO1_31) output enable
//    mov r0, GPIO1 | GPIO_OE
//    lbbo r1, r0, 0, 4
//    clr r1, 31
//    sbbo r1, r0, 0, 4
.endm

.macro DISABLE_BUFFERS
//    // Set ABX_OE (GPIO1_31) value
//    mov r0, GPIO1 | GPIO_SETDATAOUT
//    mov r1, 1<<31
//    sbbo r1, r0, 0, 4
//
//    // Clear ABX_OE (GPIO1_31) output enable
//    mov r0, GPIO1 | GPIO_OE
//    lbbo r1, r0, 0, 4
//    clr r1, 31
//    sbbo r1, r0, 0, 4
    mov r30, 0xffffffff
.endm

.macro QUIT
    // Send notification to host for program completion
    DISABLE_BUFFERS
    mov r31.b0, PRU0_ARM_INTERRUPT+16
    halt
.endm

.macro POKE
.mparam addr, value
    mov r0, value
    mov r1, addr
    sbbo r0, r1, 0, 4
.endm

.macro PEEK
.mparam addr
    mov r1, addr
    lbbo r0, r1, 0, 4
.endm

abx_pru0:

    // Clear syscfg[standby_init] to enable ocp master port
    lbco r0, CONST_PRUCFG, 4, 4
    clr r0, r0, 4
    sbco r0, CONST_PRUCFG, 4, 4

    // Point c24 at 0x00000n00, PRU0 Local Data RAM
    // Point c25 at 0x00002n00, PRU1 Local Data RAM
    POKE CTBIR_0, 0
    // Point c28 at 0x00nnnn00, Shared PRU RAM
    POKE CTPPR_0, 0x100

    // Load jumptable address
    mov jumptable, 0x1c00
    // Load GPIO_DATAIN addresses
    mov gpio1_datain, GPIO1 | GPIO_DATAIN
    mov gpio2_datain, GPIO2 | GPIO_DATAIN
    mov gpio2_dataout, GPIO2 | GPIO_DATAOUT
    // Load DDR address
    mov ddr, 0x8c000000
    mov capture_addr, ddr
    mov pru1_r31_shadow, 0x10000
    // Address of PRU1 R30 debug register
    mov pru1_r30, 0x24478
    // Address of PRU1 R31 debug register
    mov pru1_r31, 0x2447c

    BLINK_BOARD_LEDS

    CLEAR_DDR_MEMORY

.macro TESTSTORE
.mparam dst
    sbbo num_zero, dst, 0, 4
    add capture_addr, capture_addr, 4
    sbbo num_zero, dst, 0, 4
    add capture_addr, capture_addr, 4
    sbbo num_zero, dst, 0, 4
    sub capture_addr, capture_addr, 4
    sbbo num_zero, dst, 0, 4
    sub capture_addr, capture_addr, 4
    WRITE_CYCLES_STALLS capture_addr
    add capture_addr, capture_addr, 8
.endm
.macro TESTLOAD
.mparam src
    lbbo r0, src, 0, 4
    add capture_addr, capture_addr, 4
    lbbo r0, src, 0, 4
    add capture_addr, capture_addr, 4
    lbbo r0, src, 0, 4
    sub capture_addr, capture_addr, 4
    lbbo r0, src, 0, 4
    sub capture_addr, capture_addr, 4
    WRITE_CYCLES_STALLS capture_addr
    add capture_addr, capture_addr, 8
.endm
.macro TESTDMA
    mov r0, 0
    mov r1, 0x4000
copy:
    lbbo r2, ddr, r0, 32
    sbco r2, localdata0, r0, 32
    add r0, r0, 32
    qblt copy, r1, r0

    mov r0, 0
    mov r1, 0x3000
copy2:
    lbbo r2, ddr, r0, 32
    sbco r2, shared, r0, 32
    add r0, r0, 32
    qblt copy2, r1, r0


    mov r0, 0xffffeeee
    sbbo r0, capture_addr, 0, 4
    add capture_addr, capture_addr, 4
    PEEK 0x24000
    sbbo r0, capture_addr, 0, 4
    add capture_addr, capture_addr, 4
    WRITE_CYCLES_STALLS capture_addr
    add capture_addr, capture_addr, 8
.endm

    // None of this appears to help lbbo latency:

    // Set PRU to class 1 in EMIF 
    mov r0, 0x4c000104
    mov r1, 0x87000000
    sbbo r1, r0, 0, 4
    // Set all others to class 2 in EMIF 
    mov r0, 0x4c000108
    mov r1, 0x80700000
    sbbo r1, r0, 0, 4
    // Set PRU0 priority to 0 in CONTROL MODULE
    mov r0, 0x44e10670
    mov r1, 0x44444044
    sbbo r1, r0, 0, 4
    // Set priority 1-7 to class 2, 0 to class1 in EMIF
    mov r0, 0x4c000100
    mov r1, 0x8000aaa9
    sbbo r1, r0, 0, 4

    ENABLE_CYCLE_COUNTER
    WRITE_CYCLES_STALLS capture_addr
    add capture_addr, capture_addr, 8
    TESTSTORE jumptable
    TESTLOAD jumptable
    TESTSTORE pru1_r31
    TESTLOAD pru1_r31
    TESTSTORE gpio2_dataout
    TESTLOAD gpio2_datain
    TESTSTORE capture_addr
    TESTLOAD capture_addr
    TESTDMA
    WRITE_CYCLES_STALLS capture_addr
    add capture_addr, capture_addr, 8

// Capture Test
    ENABLE_BUFFERS
    //zero &data1, 8

    ldi r30, AHI_EN
    mov r0, 0
    mov r2.w0, 0x200-8
    mov r2.w2, capture_addr.w2
capture:
    //mov r31, r0
    //lsr r0, r0, 1
    //lbbo r1, capture_addr, 0, 1
    //lsl r1, r1, 1
    //sbbo r1, gpio2_dataout, 0, 1

    //lbbo data1, gpio1_datain, 0, 1
    //lbbo data2, gpio2_datain, 0, 3
    //lsr data2, data2, 1
    //sbbo data1, capture_addr, 0, 8

    //lbbo r0.b1, pru1_r31_shadow, 0, 1
    //lbbo r0.b1, r15, 0, 1 // Doesn't work --> reads zero
    //mov r0.b0, r31.b1

    //lbbo r0.b2, ddr, 0, 1

    //lbbo r0, pru1_r31, 0, 4
    //mov r0, r31

.macro EN_DELAY
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
.endm

    wbc r31, 15
    wbs r31, 15
    lsr r0.b3, r31.b0, 7
    add r0.b3, r0.b3, r31.b1
    lbbo r0.b0, pru1_r31, 0, 1
    ldi r30, ALO_EN
    EN_DELAY
    lbbo r0.b1, pru1_r31, 0, 1
    ldi r30, DATAIN_EN
    //EN_DELAY
    lbbo r1, ddr, 0, 1
    lbbo r0.b2, pru1_r31, 0, 1
    ldi r30, AHI_EN

    sbbo r0, capture_addr, 0, 4

//    mov r1, 0x1
//    mov r0, 0
//capdelay:
//    sub r1, r1, 1
//    qbne capdelay, r1, r0

    add capture_addr, capture_addr, 4
    qblt capture, r2, capture_addr

    WRITE_CYCLES_STALLS capture_addr
    add capture_addr, capture_addr, 8

//    mov r1, 0
//    mov r2, 0x1000
//copy:
//    lbbo r0, r1, 0, 4
//    sbbo r0, ddr, r1, 4
//    add r1, r1, 4
//    qblt copy, r2, r1

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
