// Atari XL PBI to Beaglebone Memory Expansion

.origin 0
.entrypoint ABX

#include "abx.hp"

ABX:

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

    // Configure the programmable pointer register for PRU0 by setting
    // c31_pointer[15:0] field to 0x0010. This will make C31 point to
    // 0x80001000 (DDR memory).

    MOV r0, 0x00100000
    MOV r1, CTPPR_1
    ST32 r0, r1


LOOP:

    // Fundamentally:
    // If read from ram:  read DDR, write to DATA
    // If write to ram:   read DATA, write to DDR

    // Factors:
    //   PORTB bits 1, 2, 8, high 5 bits of ADDRESS, R/W, REF, bank_en
    //   11bits = 2048 entry table = 8K if words
    //   PORTB
    //     8 - !selftest
    //     6 - antic bank_en
    //     5 - cpu bank_en
    //     4:3 - bank
    //     2 - !basic
    //     1 - osrom

    // INIT:
    //   EXTSEL = active
    //   DDIR = atari-to-bone (DATA)
    //   ADIR = atari-to-bone (ADDRESS, R/W, REF, etc.)
    // LOOP:
    //   Wait for PHI2 rise
    //   Assemble factors
    //   JMP *(jumptable + factors)
    // NOP:
    //   JMP LOOP
    // READ:
    //   DDIR = bone-to-atari
    //   DATA = *(bankoffset + ADDRESS)
    //   Wait for PHI2 fall
    //   DDIR = atari-to-bone
    //   JMP LOOP
    // WRITE:
    //   JSR WAIT_FOR_DATA
    //   *(bankoffset + ADDRESS) = DATA
    //   JMP LOOP
    // WRITE_TO_D6XX:
    //   JSR WAIT_FOR_DATA
    //   (hardware + ADDRESS & 0x0fff) = DATA
    //   bank = ADDRESS & 0x00ff | DATA
    //   bankoffset = ddr + bank << 16
    //   bank_en = bank != 0
    //   JMP LOOP
    // WRITE_TO_DXXX:
    //   JSR WAIT_FOR_DATA
    //   (hardware + ADDRESS & 0x0fff) = DATA
    //   JMP LOOP
    // WAIT_FOR_DATA:
    //   Wait for PHI2 fall
    //   Or wait for ~200ns
    //   RTS


    // Computing lookup table:
    //
    // UPPERCASE = PBI SIGNALS or OE
    // lowercase = extension values
    //
    // Wait for PHI2, RAS or CAS
    //
    // Read ADDRESS, DATA, R/W, REF, HALT, EXTENB
    //
    // write = R/W
    // read = !R/W
    //
    // bankselect = ADDRESS & 0xff80 == 0xd600
    // if (bankselect)
    //   bank = ADDRESS & 0x00ff | DATA
    //
    // portbselect = ADDRESS == 0xd301
    // if (portbselect && write)
    //   portb = DATA
    //   osrom_en = portb & 0x1
    //   basic_en = !(portb & 0x2)
    //   self_en = !(portb & 0x8)
    //
    // basicrange = 0xa000 <= ADDRESS && ADDRESS <= 0xbfff
    // osromrange = 0xc000 <= ADDRESS && ADDRESS <= 0xffff
    // selfrange = 0x5000 <= ADDRESS && ADDRESS <= 0x57ff
    // hardrange = 0xd000 <= ADDRESS && ADDRESS <= 0xd7ff
    //
    // ext_address = bank << 16 | ADDRESS
    // 
    // rom_or_hardware = 
    //   basicrange && basic_en ||
    //   osromrange && osrom_en ||
    //   selfrange && self_en ||
    //   hardrange
    //
    // EXTSEL = !rom_or_hardware
    //
    // bone-to-atari = !rom_or_hardware && read && PHI2
    //


    // RAS        _____/''''\______________/''''\_________
    // RCAS       _____/'''''''''\_________/'''''''''\____
    // WCAS       _____/''''''''''''\______/''''''''''''\_
    // PHI0       _/'''''''''\_________/'''''''''\________
    // PHI2       ''\_________/'''''''''\_________/'''''''
    // R/W        ===XXX=================XXX==============
    // ADDRESS    ===XXX=================XXX==============
    // RDATA      -------------------X===X----------------
    // WDATA      ---------------X=======X----------------


    // Wait for a PHI, RAS or CAS

    WBS r31, 25

    // Load values from read from the DDR memory into PRU shared RAM

    LBCO r0, CONST_PRUSHAREDRAM, 0, 12

    // Store values from external DDR Memory into Registers R0/R1/R2

    SBCO r0, CONST_DDR, 0, 12

    // Send notification to Host for program completion

    MOV r31.b0, PRU0_ARM_INTERRUPT+16

    // Halt the processor

    JMP LOOP

    HALT
