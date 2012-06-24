// Atari XL PBI to Beaglebone Memory Expansion

.origin 0
.entrypoint ABX_PRU1

#include "pru.hp"

ABX_PRU1:
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
