// Atari XL PBI to Beaglebone memory expansion
// Convention:
//  r0-r19 are temp registers
//  r18-r29 are variables
//  r30 is output register
//  r31 is input register
.origin 0
.entrypoint abx_pru0
#include "pru.hp"
#define localdata_minus_16k r24
#define shared_minus_32k r25
#define ddr r26
#define pru1_r30 r27
#define pru1_r31 r28
#define localdata0 c24
#define localdata2 c25
#define shared c28
#define AHI_EN 0b111110
#define ALO_EN 0b111101
#define DATAOUT_EN 0b011011 // also asserts EXTSEL
#define DATAIN_EN 0b110111
#define EXTSEL_BIT 5
#define REF_BIT 7
#define RW_BIT 14
#define PHI2_BIT 15
#define RESET_BIT 16
#define STRIDE 64
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
    mov ddr, 0x86c00000
    // Point c24 at 0x00000n00, PRU0 Local Data RAM (localdata0)
    // Point c25 at 0x00002n00, PRU1 Local Data RAM (localdata1)
    POKE CTBIR_0, 0
    // Point c28 at 0x00nnnn00, Shared PRU RAM
    POKE CTPPR_0, 0x100
    // Initialize localdata_minus_16k
    mov localdata_minus_16k, 0-0x4000
    // Initialize shared_minus_32k
    mov shared_minus_32k, 0x10000-0x8000
    //CLEAR_MEMORY 0x8c000000, 0x8fffffff
    ENABLE_BUFFERS
    ldi r30, AHI_EN
    DELAY 0x10000000
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

    // Branch tree:
    // 0x00 - 0x3F RAM
    // 0x40 - 0x4F RAM
    // 0x50 - 0x57 RAM / SELFTEST
    // 0x58 - 0xA0 RAM
    // 0xA0 - 0xBF RAM / BASIC
    // 0xC0 - 0xD0 RAM / ROM
    // 0xD0 - 0xD8 HARDWARE
    // 0xD8 - 0xFF RAM / ROM

    qbbc mem, r31, REF_BIT // Ignore REF cycles
    qbeq memD7, r1.b1, 0xD7 // Blit request 0xD7
    BLT mem, r1.b1, 0x40 // Ignore low mem < 0x40
    BGE mem, r1.b1, 0xA0 // Ignore high mem >= 0xA0
    BGE mem80_A0, r1.b1, 0x80 // 0x80 <= ahi < 0xA0
.macro MEM_MACRO
.mparam membase
    qbbs read, r31, RW_BIT // RW
write:
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    ldi r30, DATAIN_EN
    EN_DELAY
    lbbo r3, pru1_r31, 0, 4 // DATAIN
    sbbo r3, membase, r1.w0, 1
    jmp mem
read:
    ldi r30, DATAOUT_EN
    lbbo r1.b0, pru1_r31, 0, 1 // ALO
    lbbo r3.b1, membase, r1.w0, 1
    sbbo r3, pru1_r30, 0, 2 // DATAOUT
    mov r30.b1, r3.b1 // DATAOUT
    jmp mem
.endm
mem40_80:
    MEM_MACRO localdata_minus_16k
mem80_A0:
    MEM_MACRO shared_minus_32k
memD7:
    qbbs mem, r31, RW_BIT // RW - ignore read
    // Blit new bank into 24K region from 0x4000 - 0xA000
    mov r3.w1, 0
    lbbo r3.b1, pru1_r31, 0, 1 // ALO
    ldi r30, DATAIN_EN
    EN_DELAY
    lbbo r3.b0, pru1_r31, 0, 1 // DATAIN
    lsl r2, r3, 14 // Multiply by 24K
    lsl r3, r3, 13
    add r3, r3, r2
    add r3, r3, ddr // Add to ddr base
    mov r0, 0
    mov r1, 0x4000
blit1:
    lbbo r4, r3, r0, STRIDE
    sbco r4, localdata0, r0, STRIDE
    add r0, r0, STRIDE
    BLE blit1, r0, r1
    add r3, r3, r1
    mov r0, 0
    mov r1, 0x2000
blit2:
    lbbo r4, r3, r0, STRIDE
    sbco r4, shared, r0, STRIDE
    add r0, r0, STRIDE
    BLE blit2, r0, r1
    jmp mem
quit:
    mov r0, 0x00000
    mov r1, 0x20000
    mov r2, 0
copy:
    lbbo r4, r0, r2, STRIDE
    sbbo r4, ddr, r2, STRIDE
    add r2, r2, STRIDE
    qblt copy, r1, r2
    QUIT
