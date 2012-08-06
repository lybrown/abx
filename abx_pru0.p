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
#define jumptable r29
#define localdata0 c24
#define localdata2 c25
#define shared_minus_16k c28
#define ALO_EN 0b111110
#define AHI_EN 0b111101
#define DATAOUT_EN 0b111011
#define DATAIN_EN 0b110111
#define EXTSEL 0b011111
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
    CLEAR_DDR_MEMORY
    ENABLE_BUFFERS
    ldi r30, AHI_EN
mem:
    qbbc quit, r31, 16 // RESET
    wbc r31, 15
    wbs r31, 15 // PHI2 rising edge
    lbbo r1.b1, pru1_r31, 0, 1 // AHI
    ldi r30, ALO_EN
    NOP
    qbge mem, r1.b1, 0x70 // Ignore high mem
    qbge mem40_6f, r1.b1, 0x40 // Dispatch
.macro MEM_MACRO
.mparam membase
    qbbc mem, r31, 7 // Ignore REF cycles
    qbbs read, r31, 14 // RW
write:
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    ldi r30, DATAIN_EN
    EN_DELAY
    lbbo r3, pru1_r31, 0, 1 // DATAIN
    sbco r3, membase, r1.w0, 1
    jmp mem
read:
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    //ldi r30, DATAOUT_EN
    lbco r3.b1, membase, r1.w0, 1
    sbbo r3, pru1_r30, 0, 2 // DATAOUT
    mov r30.b1, r3.b1 // DATAOUT
    ldi r30, AHI_EN
    jmp mem
.endm
mem00_3f:
    MEM_MACRO localdata0
mem40_6f:
    MEM_MACRO shared_minus_16k
quit:
    mov r1, 0
    mov r2, 0x20000
copy:
    lbbo r0, r1, 0, 4
    sbbo r0, ddr, r1, 4
    add r1, r1, 4
    qblt copy, r2, r1
    QUIT
