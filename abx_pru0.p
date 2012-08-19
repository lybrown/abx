// Atari XL PBI to Beaglebone memory expansion
// Convention:
//  r0-r15 are temp registers
//  r16-r29 are variables
//  r30 is output register
//  r31 is input register
.origin 0
.entrypoint abx_pru0
#include "pru.hp"
#define ddr r26
#define pru1_r30 r27
#define pru1_r31 r28
#define localdata0 c24
#define localdata2 c25
#define shared_minus_16k c28
#define AHI_EN 0b111110
#define ALO_EN 0b111101
#define DATAOUT_EN 0b011011 // also asserts EXTSEL
#define DATAIN_EN 0b110111
#define EXTSEL_BIT 5
#define REF_BIT 7
#define RW_BIT 14
#define PHI2_BIT 15
#define RESET_BIT 16
.macro CLEAR_MEMORY
.mparam from, to
    zero &r2, 32
    mov r0, from
    mov r1, to
clear:
    sbbo r2, r0, 0, 32
    add r0, r0, 32
    qble clear, r1, r0
.endm
.macro ENABLE_BUFFERS
    // Clear ABX_CTRL_EN (GPIO0_14) value
    mov r0, GPIO0 | GPIO_CLEARDATAOUT
    mov r1, 1<<14
    sbbo r1, r0, 0, 4
    // Clear ABX_CTRL_EN (GPIO0_14) output enable
    mov r0, GPIO0 | GPIO_OE
    lbbo r1, r0, 0, 4
    clr r1, 31
    sbbo r1, r0, 0, 4
.endm
.macro DISABLE_BUFFERS
    // Set ABX_CTRL_EN (GPIO0_14) value
    mov r0, GPIO0 | GPIO_SETDATAOUT
    mov r1, 1<<14
    sbbo r1, r0, 0, 4
    // Clear ABX_CTRL_EN (GPIO0_14) output enable
    mov r0, GPIO0 | GPIO_OE
    lbbo r1, r0, 0, 4
    clr r1, 31
    sbbo r1, r0, 0, 4
    // Set ABX_ALO_EN
    // Set ABX_AHI_EN
    // Set ABX_DATAOUT_EN
    // Set ABX_DATAIN_EN
    mov r30, 0xffffffff
    sbbo r30, pru1_r30, 0, 4
.endm
.macro QUIT
    DISABLE_BUFFERS
    // Send notification to host for program completion
    mov r31.b0, PRU0_ARM_INTERRUPT+16
    halt
.endm
.macro NOP
    mov r16, r16
.endm
.macro EN_DELAY
    NOP
    NOP
    NOP
    NOP
    NOP
.endm
.macro DATAOUT_DELAY
    NOP
    NOP
    NOP
    NOP
    NOP
.endm
.macro DELAY
.mparam count
    mov r0, 0
    mov r1, count
loop:
    add r0, r0, 1
    qbne loop, r0, r1
.endm
abx_pru0:
    // Clear syscfg[standby_init] to enable ocp master port
    lbco r0, CONST_PRUCFG, 4, 4
    clr r0, r0, 4
    sbco r0, CONST_PRUCFG, 4, 4
    // Address of PRU1 R30 debug register
    mov pru1_r30, 0x24478
    // Address of PRU1 R31 debug register
    mov pru1_r31, 0x2447c
    // Disable everything
    mov r30, 0xffffffff
    sbbo r30, pru1_r30, 0, 4
    // Load DDR address
    mov ddr, 0x8c000000
    // Point c24 at 0x00000n00, PRU0 Local Data RAM (localdata0)
    // Point c25 at 0x00002n00, PRU1 Local Data RAM (localdata1)
    POKE CTBIR_0, 0
    // Point c28 at 0x00nnnn00, Shared PRU RAM (shared_minus_16k)
    POKE CTPPR_0, 0x100-0x40
    CLEAR_MEMORY 0x8c000000, 0x8fffffff
    CLEAR_MEMORY 0, 0x1ffff
    // Put rainbow ML routine in RAM
    mov r4, 0
    POKE r4, 0x8d00a978
    add r4, r4, 4
    POKE r4, 0x0e8dd20e
    add r4, r4, 4
    POKE r4, 0xd40a8ed4
    add r4, r4, 4
    POKE r4, 0xe8d01a8e
    add r4, r4, 4
    POKE r4, 0xd40bade8
    add r4, r4, 4
    POKE r4, 0x9888f3d0
    add r4, r4, 4
    POKE r4, 0xd40a8eaa
    add r4, r4, 4
    POKE r4, 0x0000eb50
    ENABLE_BUFFERS
    ldi r30, AHI_EN
    DELAY 0x10000000
//#define SIMPLE 1
//#define CAPTURE 1
#ifdef SIMPLE
    mov r4, 0
    mov r5, 0x2000
    mov r1, 0
    mov r6, 0
capture:
    qbbc quit, r31, RESET_BIT // RESET
    wbc r31, PHI2_BIT
    wbs r31, PHI2_BIT // PHI2 rising edge
    lbbo r1.b1, pru1_r31, 0, 1 // AHI
    ldi r30, ALO_EN
    EN_DELAY
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    ldi r30, DATAIN_EN
    EN_DELAY
    lbbo r1.b2, pru1_r31, 0, 1 // DATAIN
    ldi r30, AHI_EN
#ifdef CAPTURE
    mov r1.b3, r31.b0
    sbbo r1, r4, 0, 4
    add r4, r4, 4
    qblt capture, r5, r4
#else
    sbbo r1.b2, 0, r1.w0, 1
    jmp capture
#endif
    jmp quit
#endif
mem:
    qbbc quit, r31, RESET_BIT // RESET
    wbc r31, PHI2_BIT
    //DATAOUT_DELAY
    //DATAOUT_DELAY
    //DATAOUT_DELAY
    ldi r30, AHI_EN
    wbs r31, PHI2_BIT // PHI2 rising edge
    lbbo r1.b1, pru1_r31, 0, 1 // AHI
    ldi r30, ALO_EN
    NOP
#define D5XX
#ifdef D5XX
    //qbne mem, r1.b1, 0x40 // Only respond to D5XX
    BLT mem, r1.b1, 0x40
    BGT mem, r1.b1, 0x4f
#else
    qble mem, r1.b1, 0x70 // Ignore high mem
    qble mem40_6f, r1.b1, 0x40 // Dispatch
#endif
.macro MEM_MACRO
.mparam membase
    qbbc mem, r31, REF_BIT // Ignore REF cycles
    qbbs read, r31, RW_BIT // RW
write:
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    ldi r30, DATAIN_EN
    EN_DELAY
    lbbo r3, pru1_r31, 0, 4 // DATAIN
#ifdef MARK
    sbco pru1_r30.b0, membase, r1.w0, 1
#else
#ifdef D5XX
    sbco r3, membase, r1.b0, 1
#else
    sbco r3, membase, r1.w0, 1
#endif
#endif
    jmp mem
read:
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    ldi r30, DATAOUT_EN
#ifdef D5XX
    lbco r3.b1, membase, r1.b0, 1
#else
    lbco r3.b1, membase, r1.w0, 1
#endif
    sbbo r3, pru1_r30, 0, 2 // DATAOUT
    mov r30.b1, r3.b1 // DATAOUT
#ifdef MARK
    sbco ddr.b3, membase, r1.w0, 1
#endif
    jmp mem
.endm
mem00_3f:
    MEM_MACRO localdata0
mem40_6f:
    MEM_MACRO shared_minus_16k
quit:
    mov r0, 0
    mov r1, 0x20000
copy:
#define STRIDE 32
    lbbo r2, r0, 0, STRIDE
    sbbo r2, ddr, r0, STRIDE
    add r0, r0, STRIDE
    qblt copy, r1, r0
    QUIT
