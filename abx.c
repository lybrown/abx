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

#define DDR_BASEADDR 0x80000000

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
        printf("prussdrv_open open failed\n");
        return (ret);
    }

    /* Get the interrupt initialized */
    prussdrv_pruintc_init(&pruss_intc_initdata);

    /* Initialize example */
    printf("INFO: Mapping memory.\n");

    static int mem_fd = 0;
    static void *ddrMem = 0;
    static void *sharedMem = 0;

    /* open the device */
    mem_fd = open("/dev/mem", O_RDWR);
    if (mem_fd < 0) {
        printf("Failed to open /dev/mem (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    /* map the DDR memory */
    ddrMem = mmap(0, 0x0FFFFFFF, PROT_WRITE | PROT_READ, MAP_SHARED, mem_fd, DDR_BASEADDR);
    if (ddrMem == NULL) {
        printf("Failed to map the device (%s)\n", strerror(errno));
        goto CLEANUP;
    }

    /* Locate Shared PRU memory. */
    prussdrv_map_prumem(PRUSS0_SHARED_DATARAM, &sharedMem);

    printf("INFO: Executing PRU code.\n");
    prussdrv_pru_disable(PRU_NUM0);
    prussdrv_pru_disable(PRU_NUM1);
    prussdrv_pru_write_memory(PRUSS0_PRU0_IRAM, 0, abx_pru0, sizeof(abx_pru0));
    prussdrv_pru_write_memory(PRUSS0_PRU1_IRAM, 0, abx_pru1, sizeof(abx_pru1));
    prussdrv_pru_enable(PRU_NUM0);
    prussdrv_pru_enable(PRU_NUM1);

    /* Wait until PRU0 has finished execution */
    printf("INFO: Waiting for interrupt.\n");
    fflush(stdout);
    prussdrv_pru_wait_event (PRU_EVTOUT_0);
    printf("INFO: PRU sent interrupt.\n");
    prussdrv_pru_clear_event (PRU0_ARM_INTERRUPT);

CLEANUP:
    /* Disable PRU and close memory mapping*/
    printf("INFO: Cleaning up.\n");
    prussdrv_pru_disable(PRU_NUM0);
    prussdrv_pru_disable(PRU_NUM1);
    prussdrv_exit ();
    if (ddrMem)
        munmap(ddrMem, 0x0FFFFFFF);
    if (mem_fd)
        close(mem_fd);

    return(0);
}
