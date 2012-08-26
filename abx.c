// Atari XL PBI to Beaglebone Memory Expansion

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include "prussdrv.h"
#include "pruss_intc_mapping.h"
#include "abx_pru0_bin.h"
#include "abx_pru1_bin.h"
//#include "abx_jumptable.h"

#define DDR_BASEADDR 0x80000000
#define DDR_RESERVED 0x8C000000
#define DDR_RES_SIZE 0x03FFFFFF

int mux(char *name, int val)
{
    char cmd[1024];
    sprintf(cmd, "echo %x > /sys/kernel/debug/omap_mux/%s", val, name);
    if (system(cmd) != 0) {
        printf("ERROR: Failed to set pin mux %s = %x\n", name, val);
        return -1;
    }
    return 0;
}
int main (int argc, char **argv)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;

    printf("INFO: Initializing driver\n");
    /* Initialize the PRU */
    prussdrv_init();

    /* Open PRU Interrupt */
    ret = prussdrv_open(PRU_EVTOUT_0);
    if (ret)
    {
        printf("ERROR: prussdrv_open open failed\n");
        return (ret);
    }

    /* Get the interrupt initialized */
    prussdrv_pruintc_init(&pruss_intc_initdata);

    /* Initialize example */
    printf("INFO: Mapping memory.\n");

    static int mem_fd = 0;
    static void *ddrMem = 0;
    static void *sharedMem = 0;
    static FILE *app_fd = 0;

    app_fd = fopen("app.mem", "r");
    if (app_fd == 0) {
        printf("ERROR: Failed to open app.mem (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    /* open the device */
    mem_fd = open("/dev/mem", O_RDWR);
    if (mem_fd < 0) {
        printf("ERROR: Failed to open /dev/mem (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    /* map the DDR memory */
    ddrMem = mmap(0, DDR_RES_SIZE, PROT_WRITE | PROT_READ, MAP_SHARED, mem_fd, DDR_RESERVED);
    if (ddrMem == NULL) {
        printf("ERROR: Failed to map the device (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    size_t count = fread(ddrMem, 1, 256*1024*1024, app_fd);
    printf("INFO: Read %u bytes from app.mem\n", count);
    static unsigned int first[(0x4000+0x2000)/sizeof(int)];
    memcpy(first, ddrMem, 0x6000);

    munmap(ddrMem, DDR_RES_SIZE);
    ddrMem = 0;
    close(mem_fd);
    mem_fd = 0;
    fclose(app_fd);
    app_fd = 0;

    struct MUX { char *name; int val; } muxes[] = {
//        // GPIO1
//        {"gpmc_ad0", 0x2f}, // d0
//        {"gpmc_ad1", 0x2f},
//        {"gpmc_ad2", 0x2f},
//        {"gpmc_ad3", 0x2f},
//        {"gpmc_ad4", 0x2f},
//        {"gpmc_ad5", 0x2f},
//        {"gpmc_ad6", 0x2f},
//        {"gpmc_ad7", 0x2f}, // d7
//        {"gpmc_ad14", 0x2e}, // rw
//        {"gpmc_ad15", 0x2e}, // phi2
//        {"gpmc_csn1", 0x37}, // oe
//        {"gpmc_csn2", 0x37}, // dir
//        // GPIO2
//        {"gpmc_clk", 0x2f}, // a0
//        {"gpmc_advn_ale", 0x2f},
//        {"gpmc_oen_ren", 0x2f},
//        {"gpmc_wen", 0x2f},
//        {"gpmc_ben0_cle", 0x2f},
//        {"lcd_data0", 0x2e},
//        {"lcd_data1", 0x2e},
//        {"lcd_data2", 0x2e},
//        {"lcd_data3", 0x2e},
//        {"lcd_data4", 0x2e},
//        {"lcd_data5", 0x2e},
//        {"lcd_data6", 0x2e},
//        {"lcd_data7", 0x2e},
//        {"lcd_data8", 0x2f},
//        {"lcd_data9", 0x2f},
//        {"lcd_data10", 0x2f}, // a15
//        {"lcd_data11", 0x2f}, // ref

        // P8
        {"lcd_data0", 0x2e}, // i0
        {"lcd_data1", 0x2e},
        {"lcd_data2", 0x2e},
        {"lcd_data3", 0x2e},
        {"lcd_data4", 0x2e},
        {"lcd_data5", 0x2e},
        {"lcd_data6", 0x2e},
        {"lcd_data7", 0x2e}, // i7
        {"lcd_vsync", 0x0d}, // o0
        {"lcd_hsync", 0x0d},
        {"lcd_pclk", 0x0d},
        {"lcd_ac_bias_en", 0x0d},
        {"gpmc_csn1", 0x0d},
        {"gpmc_csn2", 0x0d},
        {"gpmc_ad12", 0x0e},
        {"gpmc_ad13", 0x0e}, // o7
        {"gpmc_ad15", 0x2e}, // phi2
        {"gpmc_ad14", 0x2e}, // rw
        // P9
        {"mcasp0_aclkx", 0x0d}, // ahi_en (pru0_r30[00])
        {"mcasp0_fsx", 0x0d}, // alo_en (pru0_r30[01])
        {"mcasp0_axr0", 0x0d}, // dataout_en (pru0_r30[02])
        {"mcasp0_ahclkr", 0x0d}, // datain_en (pru0_r30[03])
        {"mcasp0_fsr", 0x0d}, // extsel (pru0_r30[05])
        {"mcasp0_ahclkx", 0x2e}, // ref (pru0_r31[07])
        {"uart1_rxd", 0x0f}, // ctrl_en (GPIO0_14)
        {"xdma_event_intr1", 0x2d}, // reset (pru0_r31[16])
        {"uart1_txd", 0x2f}, // reset (pru0_r31[16])

        {0, 0},
    };

    /* Locate Shared PRU memory. */
    prussdrv_map_prumem(PRUSS0_SHARED_DATARAM, &sharedMem);

    printf("INFO: Executing PRU code.\n");
    prussdrv_pru_disable(PRU_NUM0);
    prussdrv_pru_disable(PRU_NUM1);
    prussdrv_pru_write_memory(PRUSS0_PRU0_IRAM, 0, abx_pru0, sizeof(abx_pru0));
    prussdrv_pru_write_memory(PRUSS0_PRU1_IRAM, 0, abx_pru1, sizeof(abx_pru1));
    prussdrv_pru_write_memory(PRUSS0_PRU0_DATARAM, 0, first, 0x4000);
    prussdrv_pru_write_memory(PRUSS0_SHARED_DATARAM, 0, first+0x4000/sizeof(int), 0x2000);
    //prussdrv_pru_enable(PRU_NUM1);
    prussdrv_pru_enable(PRU_NUM0);

    /* Set pin mux */
    for (struct MUX *m = muxes; m->name; ++m) {
        if (mux(m->name, m->val)) goto CLEANUP;
    }

    /* Wait until PRU0 has finished execution */
    printf("INFO: Waiting for interrupt.\n");
    fflush(stdout);
    prussdrv_pru_wait_event (PRU_EVTOUT_0);
    printf("INFO: PRU sent interrupt.\n");
    prussdrv_pru_clear_event (PRU0_ARM_INTERRUPT);

    /* open the device */
    mem_fd = open("/dev/mem", O_RDWR);
    if (mem_fd < 0) {
        printf("ERROR: Failed to open /dev/mem (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    /* map the DDR memory */
    ddrMem = mmap(0, DDR_RES_SIZE, PROT_WRITE | PROT_READ, MAP_SHARED, mem_fd, DDR_RESERVED);
    if (ddrMem == NULL) {
        printf("ERROR: Failed to map the device (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    unsigned long read_addr = DDR_RESERVED;
    //unsigned long read_addr = 0x8c00fe00;
    unsigned long read_offs = 0;
    printf("read_addr: %08lx read_offs: %08lx ddrMem: %08lx\n",
        read_addr, read_offs, (unsigned long)ddrMem);
    int i;
    const int stride = 16;
    char* rd = (char*)(ddrMem + read_offs);
    printf("%08X: ", (unsigned)read_addr);
    for (i = 0; i < 0x300; ++i) {
        rd = (char*)(ddrMem + read_offs + i);
        printf("%02X", (unsigned)*rd);
        if (i % stride == stride - 1) {
            printf("\n%08X: ", (unsigned)(read_addr + i + 1));
        } else if (i % 4 == 3) { 
            printf("  ");
        } else { 
            printf(" ");
        }
    }

CLEANUP:
    /* Disable PRU and close memory mapping*/
    printf("INFO: Cleaning up.\n");
    mux("uart1_rxd", 0x37);
    prussdrv_pru_disable(PRU_NUM0);
    prussdrv_pru_disable(PRU_NUM1);
    prussdrv_exit ();
    if (ddrMem)
        munmap(ddrMem, DDR_RES_SIZE);
    if (mem_fd)
        close(mem_fd);
    if (app_fd)
        fclose(app_fd);

    return(0);
}
