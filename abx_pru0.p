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

    MUX CONTROL_PADCONF_GPMC_AD12, (IDIS | PU | MODE6)     // PR1_PRU0_PRU_R30[14]  T12  P8,12
    MUX CONTROL_PADCONF_GPMC_AD13, (IDIS | PU | MODE6)     // PR1_PRU0_PRU_R30[15]  R12  P8,11
    MUX CONTROL_PADCONF_MCASP0_ACLKX, (IEN | PU | MODE6)   // PR1_PRU0_PRU_R31[0]   A13  P9,31
    MUX CONTROL_PADCONF_MCASP0_FSX, (IEN | PU | MODE6)     // PR1_PRU0_PRU_R31[1]   B13  P9,29
    MUX CONTROL_PADCONF_MCASP0_AXR0, (IEN | PU | MODE6)    // PR1_PRU0_PRU_R31[2]   D12  P9,30
    MUX CONTROL_PADCONF_MCASP0_AHCLKR, (IEN | PU | MODE6 )   // PR1_PRU0_PRU_R31[3]   C12  P9,28
    MUX CONTROL_PADCONF_MCASP0_ACLKR, (IEN | PU | MODE6)   // PR1_PRU0_PRU_R31[4]   B12  ??
    MUX CONTROL_PADCONF_MCASP0_FSR, (IEN | PU | MODE6)     // PR1_PRU0_PRU_R31[5]   C13  P9,27
    MUX CONTROL_PADCONF_MCASP0_AXR1, (IEN | PU | MODE6)    // PR1_PRU0_PRU_R31[6]   D13  ??
    MUX CONTROL_PADCONF_MCASP0_AHCLKX, (IEN | PU | MODE6 )   // PR1_PRU0_PRU_R31[7]   A14  P9,25
    MUX CONTROL_PADCONF_MMC0_DAT3, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[8]   F17  ??
    MUX CONTROL_PADCONF_MMC0_DAT2, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[9]   F18  ??
    MUX CONTROL_PADCONF_MMC0_DAT1, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[10]  G15  ??
    MUX CONTROL_PADCONF_MMC0_DAT0, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[11]  G16  ??
    MUX CONTROL_PADCONF_MMC0_CLK, (IEN | PU | MODE6)       // PR1_PRU0_PRU_R31[12]  G17  ??
    MUX CONTROL_PADCONF_MMC0_CMD, (IEN | PU | MODE6)       // PR1_PRU0_PRU_R31[13]  G18  ??
    MUX CONTROL_PADCONF_GPMC_AD14, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[14]  V13  P8,16
    MUX CONTROL_PADCONF_GPMC_AD15, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[15]  U13  P8,15
    MUX CONTROL_PADCONF_UART1_TXD, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[16]  D15  P9,24
    MUX CONTROL_PADCONF_UART1_TXD, (IEN | PU | MODE6)      // PR1_PRU0_PRU_R31[16]  D14  P9,41
    MUX CONTROL_PADCONF_LCD_DATA0, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[0]   R1   P8,45  R31[7:0] can swap with R30[7:0] (MODE5)
    MUX CONTROL_PADCONF_LCD_DATA1, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[1]   R2   P8,46
    MUX CONTROL_PADCONF_LCD_DATA2, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[2]   R3   P8,43
    MUX CONTROL_PADCONF_LCD_DATA3, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[3]   R4   P8,44
    MUX CONTROL_PADCONF_LCD_DATA4, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[4]   T1   P8,41
    MUX CONTROL_PADCONF_LCD_DATA5, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[5]   T2   P8,42
    MUX CONTROL_PADCONF_LCD_DATA6, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[6]   T3   P8,39
    MUX CONTROL_PADCONF_LCD_DATA7, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[7]   T4   P8,40
    MUX CONTROL_PADCONF_LCD_VSYNC, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[8]   U5   P8,27
    MUX CONTROL_PADCONF_LCD_HSYNC, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[9]   R5   P8,29
    MUX CONTROL_PADCONF_LCD_PCLK, (IEN | PU | MODE6)       // PR1_PRU1_PRU_R31[10]  V5   P8,28
    MUX CONTROL_PADCONF_LCD_AC_BIAS_EN, (IEN | PU | MODE6) // PR1_PRU1_PRU_R31[11]  R6   P8,30
    MUX CONTROL_PADCONF_GPMC_CSN1, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[12]  U9   P8,21
    MUX CONTROL_PADCONF_GPMC_CSN2, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[13]  V9   P8,20
    MUX CONTROL_PADCONF_UART0_RXD, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[14]  E15  ??
    MUX CONTROL_PADCONF_UART0_TXD, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[15]  E16  ??
    MUX CONTROL_PADCONF_UART1_RXD, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[16]  D16  P9,26
    MUX CONTROL_PADCONF_UART1_RXD, (IEN | PU | MODE6)      // PR1_PRU1_PRU_R31[16]  A15  ??

    // Send notification to Host for program completion
    MOV r31.b0, PRU0_ARM_INTERRUPT+16

    HALT

//LOOP:
//
//    // Fundamentally:
//    // If read from ram:  read DDR, write to DATA
//    // If write to ram:   read DATA, write to DDR
//
//    // Factors:
//    //   PORTB bits 1, 2, 8, high 5 bits of ADDRESS, R/W, REF
//    //   11bits = 2048 entry table = 8K if words
//    //   PORTB
//    //     8 - !selftest
//    //     6 - antic bank_en
//    //     5 - cpu bank_en
//    //     4:3 - bank
//    //     2 - !basic
//    //     1 - osrom
//
//    // INIT:
//    //   EXTSEL = active
//    //   DDIR = atari-to-bone (DATA)
//    //   ADIR = atari-to-bone (ADDRESS, R/W, REF, etc.)
//    // LOOP:
//    //   Wait for PHI2 low
//    //   Wait for PHI2 high
//    //   Assemble factors
//    //   JMP *(jumptable + factors)
//    // .origin 0x1000
//    // NOP:
//    //   JMP LOOP
//    // .origin 0x1100
//    // READ:
//    //   DDIR = bone-to-atari
//    //   DATA = *(bankoffset + ADDRESS)
//    //   Wait for PHI2 low
//    //   DDIR = atari-to-bone
//    //   JMP LOOP
//    // .origin 0x1200
//    // WRITE:
//    //   JSR WAIT_FOR_DATA
//    //   *(bankoffset + ADDRESS) = DATA
//    //   JMP LOOP
//    // .origin 0x1300
//    // WRITE_TO_D7XX:
//    //   JSR WAIT_FOR_DATA
//    //   (hardware + ADDRESS & 0x0fff) = DATA
//    //   bank = ADDRESS & 0x00ff | DATA
//    //   bankoffset = ddr + bank << 16
//    //   bone_en = bank != 0xffff
//    //   JMP LOOP
//    // .origin 0x1400
//    // WRITE_TO_DXXX:
//    //   JSR WAIT_FOR_DATA
//    //   (hardware + ADDRESS & 0x0fff) = DATA
//    //   JMP LOOP
//    // .origin 0x1500
//    // WAIT_FOR_DATA:
//    //   Wait for PHI2 low
//    //   Or wait for ~200ns
//    //   RTS
//
//
//    // Computing lookup table:
//    //
//    // UPPERCASE = PBI SIGNALS or OE
//    // lowercase = extension values
//    //
//    // Wait for PHI2, RAS or CAS
//    //
//    // Read ADDRESS, DATA, R/W, REF, HALT, EXTENB
//    //
//    // write = R/W
//    // read = !R/W
//    //
//    // bankselect = ADDRESS & 0xff80 == 0xd700
//    // if (bankselect)
//    //   bank = ADDRESS & 0x00ff | DATA
//    //
//    // portbselect = ADDRESS == 0xd301
//    // if (portbselect && write)
//    //   portb = DATA
//    //   osrom_en = portb & 0x1
//    //   basic_en = !(portb & 0x2)
//    //   self_en = !(portb & 0x8)
//    //
//    // basicrange = 0xa000 <= ADDRESS && ADDRESS <= 0xbfff
//    // osromrange = 0xc000 <= ADDRESS && ADDRESS <= 0xffff
//    // selfrange = 0x5000 <= ADDRESS && ADDRESS <= 0x57ff
//    // hardrange = 0xd000 <= ADDRESS && ADDRESS <= 0xd7ff
//    //
//    // ext_address = bank << 16 | ADDRESS
//    //
//    // rom_or_hardware =
//    //   basicrange && basic_en ||
//    //   osromrange && osrom_en ||
//    //   selfrange && self_en ||
//    //   hardrange
//    //
//    // EXTSEL = !rom_or_hardware
//    //
//    // bone-to-atari = !rom_or_hardware && read && PHI2
//    //
//
//
//    // RAS        _____/''''\______________/''''\_________
//    // RCAS       _____/'''''''''\_________/'''''''''\____
//    // WCAS       _____/''''''''''''\______/''''''''''''\_
//    // PHI0       _/'''''''''\_________/'''''''''\________
//    // PHI2       ''\_________/'''''''''\_________/'''''''
//    // R/W        ===XXX=================XXX==============
//    // ADDRESS    ===XXX=================XXX==============
//    // RDATA      -------------------X===X----------------
//    // WDATA      ---------------X=======X----------------
//
//
//    // Wait for a PHI, RAS or CAS
//
//    WBS r31, 25
//
//    // Load values from read from the DDR memory into PRU shared RAM
//
//    LBCO r0, CONST_PRUSHAREDRAM, 0, 12
//
//    // Store values from external DDR Memory into Registers R0/R1/R2
//
//    SBCO r0, CONST_DDR, 0, 12
//
//    // Send notification to Host for program completion
//
//    MOV r31.b0, PRU0_ARM_INTERRUPT+16
//
//    // Halt the processor
//
//    JMP LOOP
//
//    HALT


