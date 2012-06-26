#include <assert.h>

// Bit 5: 1 - Input, 0 - Output
// Bit 4: 1 - Pull up, 0 - Pull down
// Bit 3: 1 - Pull disabled, 0 - Pull enabled
// Bit 2 \_
// Bit 1 |- Mode
// Bit 0 /

/*
 * MODE0 - Mux Mode 0
 * MODE1 - Mux Mode 1
 * MODE2 - Mux Mode 2
 * MODE3 - Mux Mode 3
 * MODE4 - Mux Mode 4
 * MODE5 - Mux Mode 5
 * MODE6 - Mux Mode 6
 * MODE7 - Mux Mode 7
 * IDIS - Receiver disabled
 * IEN - Receiver enabled
 * PD - Internal pull-down
 * PU - Internal pull-up
 * OFF - Internal pull disabled
 */

#define MODE0 0
#define MODE1 1
#define MODE2 2
#define MODE3 3
#define MODE4 4
#define MODE5 5
#define MODE6 6
#define MODE7 7
#define IDIS (0 << 5)
#define IEN (1 << 5)
#define PD (0 << 3)
#define PU (2 << 3)
#define OFF (1 << 3)

/*
 * To get the physical address the offset has
 * to be added to AM335X_CTRL_BASE
 */

#define CONTROL_PADCONF_GPMC_AD0                  0x0800
#define CONTROL_PADCONF_GPMC_AD1                  0x0804
#define CONTROL_PADCONF_GPMC_AD2                  0x0808
#define CONTROL_PADCONF_GPMC_AD3                  0x080C
#define CONTROL_PADCONF_GPMC_AD4                  0x0810
#define CONTROL_PADCONF_GPMC_AD5                  0x0814
#define CONTROL_PADCONF_GPMC_AD6                  0x0818
#define CONTROL_PADCONF_GPMC_AD7                  0x081C
#define CONTROL_PADCONF_GPMC_AD8                  0x0820
#define CONTROL_PADCONF_GPMC_AD9                  0x0824
#define CONTROL_PADCONF_GPMC_AD10                 0x0828
#define CONTROL_PADCONF_GPMC_AD11                 0x082C
#define CONTROL_PADCONF_GPMC_AD12                 0x0830
#define CONTROL_PADCONF_GPMC_AD13                 0x0834
#define CONTROL_PADCONF_GPMC_AD14                 0x0838
#define CONTROL_PADCONF_GPMC_AD15                 0x083C
#define CONTROL_PADCONF_GPMC_A0                   0x0840
#define CONTROL_PADCONF_GPMC_A1                   0x0844
#define CONTROL_PADCONF_GPMC_A2                   0x0848
#define CONTROL_PADCONF_GPMC_A3                   0x084C
#define CONTROL_PADCONF_GPMC_A4                   0x0850
#define CONTROL_PADCONF_GPMC_A5                   0x0854
#define CONTROL_PADCONF_GPMC_A6                   0x0858
#define CONTROL_PADCONF_GPMC_A7                   0x085C
#define CONTROL_PADCONF_GPMC_A8                   0x0860
#define CONTROL_PADCONF_GPMC_A9                   0x0864
#define CONTROL_PADCONF_GPMC_A10                  0x0868
#define CONTROL_PADCONF_GPMC_A11                  0x086C
#define CONTROL_PADCONF_GPMC_WAIT0                0x0870
#define CONTROL_PADCONF_GPMC_WPN                  0x0874
#define CONTROL_PADCONF_GPMC_BEN1                 0x0878
#define CONTROL_PADCONF_GPMC_CSN0                 0x087C
#define CONTROL_PADCONF_GPMC_CSN1                 0x0880
#define CONTROL_PADCONF_GPMC_CSN2                 0x0884
#define CONTROL_PADCONF_GPMC_CSN3                 0x0888
#define CONTROL_PADCONF_GPMC_CLK                  0x088C
#define CONTROL_PADCONF_GPMC_ADVN_ALE             0x0890
#define CONTROL_PADCONF_GPMC_OEN_REN              0x0894
#define CONTROL_PADCONF_GPMC_WEN                  0x0898
#define CONTROL_PADCONF_GPMC_BEN0_CLE             0x089C
#define CONTROL_PADCONF_LCD_DATA0                 0x08A0
#define CONTROL_PADCONF_LCD_DATA1                 0x08A4
#define CONTROL_PADCONF_LCD_DATA2                 0x08A8
#define CONTROL_PADCONF_LCD_DATA3                 0x08AC
#define CONTROL_PADCONF_LCD_DATA4                 0x08B0
#define CONTROL_PADCONF_LCD_DATA5                 0x08B4
#define CONTROL_PADCONF_LCD_DATA6                 0x08B8
#define CONTROL_PADCONF_LCD_DATA7                 0x08BC
#define CONTROL_PADCONF_LCD_DATA8                 0x08C0
#define CONTROL_PADCONF_LCD_DATA9                 0x08C4
#define CONTROL_PADCONF_LCD_DATA10                0x08C8
#define CONTROL_PADCONF_LCD_DATA11                0x08CC
#define CONTROL_PADCONF_LCD_DATA12                0x08D0
#define CONTROL_PADCONF_LCD_DATA13                0x08D4
#define CONTROL_PADCONF_LCD_DATA14                0x08D8
#define CONTROL_PADCONF_LCD_DATA15                0x08DC
#define CONTROL_PADCONF_LCD_VSYNC                 0x08E0
#define CONTROL_PADCONF_LCD_HSYNC                 0x08E4
#define CONTROL_PADCONF_LCD_PCLK                  0x08E8
#define CONTROL_PADCONF_LCD_AC_BIAS_EN            0x08EC
#define CONTROL_PADCONF_MMC0_DAT3                 0x08F0
#define CONTROL_PADCONF_MMC0_DAT2                 0x08F4
#define CONTROL_PADCONF_MMC0_DAT1                 0x08F8
#define CONTROL_PADCONF_MMC0_DAT0                 0x08FC
#define CONTROL_PADCONF_MMC0_CLK                  0x0900
#define CONTROL_PADCONF_MMC0_CMD                  0x0904
#define CONTROL_PADCONF_MII1_COL                  0x0908
#define CONTROL_PADCONF_MII1_CRS                  0x090C
#define CONTROL_PADCONF_MII1_RX_ER                0x0910
#define CONTROL_PADCONF_MII1_TX_EN                0x0914
#define CONTROL_PADCONF_MII1_RX_DV                0x0918
#define CONTROL_PADCONF_MII1_TXD3                 0x091C
#define CONTROL_PADCONF_MII1_TXD2                 0x0920
#define CONTROL_PADCONF_MII1_TXD1                 0x0924
#define CONTROL_PADCONF_MII1_TXD0                 0x0928
#define CONTROL_PADCONF_MII1_TX_CLK               0x092C
#define CONTROL_PADCONF_MII1_RX_CLK               0x0930
#define CONTROL_PADCONF_MII1_RXD3                 0x0934
#define CONTROL_PADCONF_MII1_RXD2                 0x0938
#define CONTROL_PADCONF_MII1_RXD1                 0x093C
#define CONTROL_PADCONF_MII1_RXD0                 0x0940
#define CONTROL_PADCONF_RMII1_REF_CLK             0x0944
#define CONTROL_PADCONF_MDIO                      0x0948
#define CONTROL_PADCONF_MDC                       0x094C
#define CONTROL_PADCONF_SPI0_SCLK                 0x0950
#define CONTROL_PADCONF_SPI0_D0                   0x0954
#define CONTROL_PADCONF_SPI0_D1                   0x0958
#define CONTROL_PADCONF_SPI0_CS0                  0x095C
#define CONTROL_PADCONF_SPI0_CS1                  0x0960
#define CONTROL_PADCONF_ECAP0_IN_PWM0_OUT         0x0964
#define CONTROL_PADCONF_UART0_CTSN                0x0968
#define CONTROL_PADCONF_UART0_RTSN                0x096C
#define CONTROL_PADCONF_UART0_RXD                 0x0970
#define CONTROL_PADCONF_UART0_TXD                 0x0974
#define CONTROL_PADCONF_UART1_CTSN                0x0978
#define CONTROL_PADCONF_UART1_RTSN                0x097C
#define CONTROL_PADCONF_UART1_RXD                 0x0980
#define CONTROL_PADCONF_UART1_TXD                 0x0984
#define CONTROL_PADCONF_I2C0_SDA                  0x0988
#define CONTROL_PADCONF_I2C0_SCL                  0x098C
#define CONTROL_PADCONF_MCASP0_ACLKX              0x0990
#define CONTROL_PADCONF_MCASP0_FSX                0x0994
#define CONTROL_PADCONF_MCASP0_AXR0               0x0998
#define CONTROL_PADCONF_MCASP0_AHCLKR             0x099C
#define CONTROL_PADCONF_MCASP0_ACLKR              0x09A0
#define CONTROL_PADCONF_MCASP0_FSR                0x09A4
#define CONTROL_PADCONF_MCASP0_AXR1               0x09A8
#define CONTROL_PADCONF_MCASP0_AHCLKX             0x09AC
#define CONTROL_PADCONF_XDMA_EVENT_INTR0          0x09B0
#define CONTROL_PADCONF_XDMA_EVENT_INTR1          0x09B4
#define CONTROL_PADCONF_WARMRSTN                  0x09B8
#define CONTROL_PADCONF_PWRONRSTN                 0x09BC
#define CONTROL_PADCONF_EXTINTN                   0x09C0
#define CONTROL_PADCONF_XTALIN                    0x09C4
#define CONTROL_PADCONF_XTALOUT                   0x09C8
#define CONTROL_PADCONF_TMS                       0x09D0
#define CONTROL_PADCONF_TDI                       0x09D4
#define CONTROL_PADCONF_TDO                       0x09D8
#define CONTROL_PADCONF_TCK                       0x09DC
#define CONTROL_PADCONF_TRSTN                     0x09E0
#define CONTROL_PADCONF_EMU0                      0x09E4
#define CONTROL_PADCONF_EMU1                      0x09E8
#define CONTROL_PADCONF_RTC_XTALIN                0x09EC
#define CONTROL_PADCONF_RTC_XTALOUT               0x09F0
#define CONTROL_PADCONF_RTC_PWRONRSTN             0x09F8
#define CONTROL_PADCONF_PMIC_POWER_EN             0x09FC
#define CONTROL_PADCONF_EXT_WAKEUP                0x0A00
#define CONTROL_PADCONF_RTC_KALDO_ENN             0x0A04
#define CONTROL_PADCONF_USB0_DM                   0x0A08
#define CONTROL_PADCONF_USB0_DP                   0x0A0C
#define CONTROL_PADCONF_USB0_CE                   0x0A10
#define CONTROL_PADCONF_USB0_ID                   0x0A14
#define CONTROL_PADCONF_USB0_VBUS                 0x0A18
#define CONTROL_PADCONF_USB0_DRVVBUS              0x0A1C
#define CONTROL_PADCONF_USB1_DM                   0x0A20
#define CONTROL_PADCONF_USB1_DP                   0x0A24
#define CONTROL_PADCONF_USB1_CE                   0x0A28
#define CONTROL_PADCONF_USB1_ID                   0x0A2C
#define CONTROL_PADCONF_USB1_VBUS                 0x0A30
#define CONTROL_PADCONF_USB1_DRVVBUS              0x0A34
#define CONTROL_PADCONF_DDR_RESETN                0x0A38
#define CONTROL_PADCONF_DDR_CSN0                  0x0A3C
#define CONTROL_PADCONF_DDR_CKE                   0x0A40
#define CONTROL_PADCONF_DDR_CK                    0x0A44
#define CONTROL_PADCONF_DDR_CKN                   0x0A48
#define CONTROL_PADCONF_DDR_CASN                  0x0A4C
#define CONTROL_PADCONF_DDR_RASN                  0x0A50
#define CONTROL_PADCONF_DDR_WEN                   0x0A54
#define CONTROL_PADCONF_DDR_BA0                   0x0A58
#define CONTROL_PADCONF_DDR_BA1                   0x0A5C
#define CONTROL_PADCONF_DDR_BA2                   0x0A60
#define CONTROL_PADCONF_DDR_A0                    0x0A64
#define CONTROL_PADCONF_DDR_A1                    0x0A68
#define CONTROL_PADCONF_DDR_A2                    0x0A6C
#define CONTROL_PADCONF_DDR_A3                    0x0A70
#define CONTROL_PADCONF_DDR_A4                    0x0A74
#define CONTROL_PADCONF_DDR_A5                    0x0A78
#define CONTROL_PADCONF_DDR_A6                    0x0A7C
#define CONTROL_PADCONF_DDR_A7                    0x0A80
#define CONTROL_PADCONF_DDR_A8                    0x0A84
#define CONTROL_PADCONF_DDR_A9                    0x0A88
#define CONTROL_PADCONF_DDR_A10                   0x0A8C
#define CONTROL_PADCONF_DDR_A11                   0x0A90
#define CONTROL_PADCONF_DDR_A12                   0x0A94
#define CONTROL_PADCONF_DDR_A13                   0x0A98
#define CONTROL_PADCONF_DDR_A14                   0x0A9C
#define CONTROL_PADCONF_DDR_A15                   0x0AA0
#define CONTROL_PADCONF_DDR_ODT                   0x0AA4
#define CONTROL_PADCONF_DDR_D0                    0x0AA8
#define CONTROL_PADCONF_DDR_D1                    0x0AAC
#define CONTROL_PADCONF_DDR_D2                    0x0AB0
#define CONTROL_PADCONF_DDR_D3                    0x0AB4
#define CONTROL_PADCONF_DDR_D4                    0x0AB8
#define CONTROL_PADCONF_DDR_D5                    0x0ABC
#define CONTROL_PADCONF_DDR_D6                    0x0AC0
#define CONTROL_PADCONF_DDR_D7                    0x0AC4
#define CONTROL_PADCONF_DDR_D8                    0x0AC8
#define CONTROL_PADCONF_DDR_D9                    0x0ACC
#define CONTROL_PADCONF_DDR_D10                   0x0AD0
#define CONTROL_PADCONF_DDR_D11                   0x0AD4
#define CONTROL_PADCONF_DDR_D12                   0x0AD8
#define CONTROL_PADCONF_DDR_D13                   0x0ADC
#define CONTROL_PADCONF_DDR_D14                   0x0AE0
#define CONTROL_PADCONF_DDR_D15                   0x0AE4
#define CONTROL_PADCONF_DDR_DQM0                  0x0AE8
#define CONTROL_PADCONF_DDR_DQM1                  0x0AEC
#define CONTROL_PADCONF_DDR_DQS0                  0x0AF0
#define CONTROL_PADCONF_DDR_DQSN0                 0x0AF4
#define CONTROL_PADCONF_DDR_DQS1                  0x0AF8
#define CONTROL_PADCONF_DDR_DQSN1                 0x0AFC
#define CONTROL_PADCONF_DDR_VREF                  0x0B00
#define CONTROL_PADCONF_DDR_VTP                   0x0B04
#define CONTROL_PADCONF_AIN7                      0x0B10
#define CONTROL_PADCONF_AIN6                      0x0B14
#define CONTROL_PADCONF_AIN5                      0x0B18
#define CONTROL_PADCONF_AIN4                      0x0B1C
#define CONTROL_PADCONF_AIN3                      0x0B20
#define CONTROL_PADCONF_AIN2                      0x0B24
#define CONTROL_PADCONF_AIN1                      0x0B28
#define CONTROL_PADCONF_AIN0                      0x0B2C
#define CONTROL_PADCONF_VREFP                     0x0B30
#define CONTROL_PADCONF_VREFN                     0x0B34

#define AM335X_CTRL_BASE 0x44E10000 
#define AM335X_CTRL_SIZE 0x2000

#define MUX_VAL(OFFSET,VALUE)\
    writel((VALUE), AM335X_CTRL_BASE + (OFFSET));

static int mem_fd;
static void* ctrlMem;

void ctrl_mux(unsigned long offset, unsigned long value)
{
    assert(offset < CONTROL_PADCONF_USB1_DRVVBUS);
    *(unsigned long*)(ctrlMem + offset) = value;
}

int ctrl_cleanup()
{
    munmap(ctrlMem, AM335X_CTRL_SIZE);
    close(mem_fd);
}

int ctrl_init()
{
    mem_fd = 0;
    ctrlMem = 0;

    /* open the device */
    mem_fd = open("/dev/mem", O_RDWR);
    if (mem_fd < 0) {
        printf("ERROR: Could not open /dev/mem: %s\n", strerror(errno));
        return -1;
    }

    /* map the DDR memory */
    ctrlMem = mmap(0, AM335X_CTRL_SIZE, PROT_WRITE | PROT_READ, MAP_SHARED, mem_fd, AM335X_CTRL_BASE);
    if (ctrlMem == NULL) {
        printf("ERROR: mmap failed: %s\n", strerror(errno));
        close(mem_fd);
        return -1;
    }

    ctrl_mux(CONTROL_PADCONF_GPMC_AD12, (IDIS | PU | MODE6));     /* PR1_PRU0_PRU_R30[14]  T12  P8,12 */
    ctrl_mux(CONTROL_PADCONF_GPMC_AD13, (IDIS | PU | MODE6));     /* PR1_PRU0_PRU_R30[15]  R12  P8,11 */
    ctrl_mux(CONTROL_PADCONF_MCASP0_ACLKX, (IEN | PU | MODE6));   /* PR1_PRU0_PRU_R31[0]   A13  P9,31 */
    ctrl_mux(CONTROL_PADCONF_MCASP0_FSX, (IEN | PU | MODE6));     /* PR1_PRU0_PRU_R31[1]   B13  P9,29 */
    ctrl_mux(CONTROL_PADCONF_MCASP0_AXR0, (IEN | PU | MODE6));    /* PR1_PRU0_PRU_R31[2]   D12  P9,30 */
    ctrl_mux(CONTROL_PADCONF_MCASP0_AHCLKR, (IEN | PU | MODE6 )   /* PR1_PRU0_PRU_R31[3]   C12  P9,28 */
    ctrl_mux(CONTROL_PADCONF_MCASP0_ACLKR, (IEN | PU | MODE6));   /* PR1_PRU0_PRU_R31[4]   B12  ?? */
    ctrl_mux(CONTROL_PADCONF_MCASP0_FSR, (IEN | PU | MODE6));     /* PR1_PRU0_PRU_R31[5]   C13  P9,27 */
    ctrl_mux(CONTROL_PADCONF_MCASP0_AXR1, (IEN | PU | MODE6));    /* PR1_PRU0_PRU_R31[6]   D13  ?? */
    ctrl_mux(CONTROL_PADCONF_MCASP0_AHCLKX, (IEN | PU | MODE6 )   /* PR1_PRU0_PRU_R31[7]   A14  P9,25 */
    ctrl_mux(CONTROL_PADCONF_MMC0_DAT3, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[8]   F17  ?? */
    ctrl_mux(CONTROL_PADCONF_MMC0_DAT2, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[9]   F18  ?? */
    ctrl_mux(CONTROL_PADCONF_MMC0_DAT1, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[10]  G15  ?? */
    ctrl_mux(CONTROL_PADCONF_MMC0_DAT0, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[11]  G16  ?? */
    ctrl_mux(CONTROL_PADCONF_MMC0_CLK, (IEN | PU | MODE6));       /* PR1_PRU0_PRU_R31[12]  G17  ?? */
    ctrl_mux(CONTROL_PADCONF_MMC0_CMD, (IEN | PU | MODE6));       /* PR1_PRU0_PRU_R31[13]  G18  ?? */
    ctrl_mux(CONTROL_PADCONF_GPMC_AD14, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[14]  V13  P8,16 */
    ctrl_mux(CONTROL_PADCONF_GPMC_AD15, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[15]  U13  P8,15 */
    ctrl_mux(CONTROL_PADCONF_UART1_TXD, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[16]  D15  P9,24 */
    ctrl_mux(CONTROL_PADCONF_UART1_TXD, (IEN | PU | MODE6));      /* PR1_PRU0_PRU_R31[16]  D14  P9,41 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA0, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[0]   R1   P8,45  R31[7:0] can swap with R30[7:0] (MODE5) */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA1, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[1]   R2   P8,46 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA2, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[2]   R3   P8,43 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA3, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[3]   R4   P8,44 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA4, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[4]   T1   P8,41 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA5, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[5]   T2   P8,42 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA6, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[6]   T3   P8,39 */
    ctrl_mux(CONTROL_PADCONF_LCD_DATA7, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[7]   T4   P8,40 */
    ctrl_mux(CONTROL_PADCONF_LCD_VSYNC, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[8]   U5   P8,27 */
    ctrl_mux(CONTROL_PADCONF_LCD_HSYNC, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[9]   R5   P8,29 */
    ctrl_mux(CONTROL_PADCONF_LCD_PCLK, (IEN | PU | MODE6));       /* PR1_PRU1_PRU_R31[10]  V5   P8,28 */
    ctrl_mux(CONTROL_PADCONF_LCD_AC_BIAS_EN, (IEN | PU | MODE6)); /* PR1_PRU1_PRU_R31[11]  R6   P8,30 */
    ctrl_mux(CONTROL_PADCONF_GPMC_CSN1, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[12]  U9   P8,21 */
    ctrl_mux(CONTROL_PADCONF_GPMC_CSN2, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[13]  V9   P8,20 */
    ctrl_mux(CONTROL_PADCONF_UART0_RXD, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[14]  E15  ?? */
    ctrl_mux(CONTROL_PADCONF_UART0_TXD, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[15]  E16  ?? */
    ctrl_mux(CONTROL_PADCONF_UART1_RXD, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[16]  D16  P9,26 */
    ctrl_mux(CONTROL_PADCONF_UART1_RXD, (IEN | PU | MODE6));      /* PR1_PRU1_PRU_R31[16]  A15  ?? */
}
