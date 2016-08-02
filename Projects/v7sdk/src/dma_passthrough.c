
// Includes
#include <stdlib.h>
#include "xaxidma.h"
//#include "xscugic.h"
#include "dma_passthrough.h"
#include "xaxidma_bdring.h"

// Defines
#define RESET_TIMEOUT_COUNTER 10000

// Macros
#define ALIGN64(some_ptr) (int*)(some_ptr + XAXIDMA_BD_MINIMUM_ALIGNMENT-some_ptr%XAXIDMA_BD_MINIMUM_ALIGNMENT);

// Private data
typedef struct dma_passthrough_periphs
{
	XAxiDma dma_inst;
//	XScuGic intc_inst;
} dma_passthrough_periphs_t;

typedef struct dma_passthrough
{
	dma_passthrough_periphs_t periphs;
	void*                     p_rcv_buf;
	void*                     p_snd_buf;
	int                       num_bds_per_ring;
	int                       buf_length;
	int                       sample_size_bytes;
	int*					  tx_bd_mem;
	int						  cyclic_enable;
} dma_passthrough_t;

static int g_s2mm_done = 0;
static int g_mm2s_done = 0;
static int g_dma_err   = 0;



static int init_dma(XAxiDma* p_dma_inst, int dma_device_id)
{

	// Local variables
	int             status = 0;
	XAxiDma_Config* cfg_ptr;

	// Look up hardware configuration for device
	cfg_ptr = XAxiDma_LookupConfig(dma_device_id);
	if (!cfg_ptr)
	{
		xil_printf("ERROR! No hardware configuration found for AXI DMA with device id %d.\r\n", dma_device_id);
		return DMA_PASSTHROUGH_DMA_INIT_FAIL;
	}

	// Initialize driver
	status = XAxiDma_CfgInitialize(p_dma_inst, cfg_ptr);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Initialization of AXI DMA failed with %d\r\n", status);
		return DMA_PASSTHROUGH_DMA_INIT_FAIL;
	}

	// Test for Scatter Gather
	if (!XAxiDma_HasSg(p_dma_inst))
	{
		xil_printf("ERROR! Device configured in Register Direct mode.\r\n");
		return DMA_PASSTHROUGH_DMA_INIT_FAIL;
	}

	// Reset DMA
	XAxiDma_Reset(p_dma_inst);
	while (!XAxiDma_ResetIsDone(p_dma_inst)) {}

	// Enable DMA interrupts
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_IntrEnable(p_dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

	return DMA_PASSTHROUGH_SUCCESS;

}


static int bd_ch_setup(XAxiDma* p_dma_inst, void* p_dma_buf, int* p_bd_mem, const int num_bds_per_ring,
                       const int num_samples_per_bd, const int sample_size_bytes, const int is_rx, int cyclic)
{

	// Local Variables
	int             ii             = 0;
	int             status         = 0;
	XAxiDma_BdRing* ring;
	XAxiDma_Bd*     bd_ptr;
	XAxiDma_Bd*     cur_bd_ptr;
	XAxiDma_Bd      bd_template;
	int             buf_addr;
	int*            p_bd_mem_aligned;
	int             cr_bits        = 0;

	// Get a BD ring to work on
	if (is_rx)
		ring = XAxiDma_GetRxRing(p_dma_inst);
	else
		ring = XAxiDma_GetTxRing(p_dma_inst);

	// Disable interrupts
	XAxiDma_BdRingIntDisable(ring, XAXIDMA_IRQ_ALL_MASK);

	// Need to make sure rx_bd_mem is 16-word aligned per AXI DMA requirements
	p_bd_mem_aligned = ALIGN64((int)p_bd_mem);

	// Setup space for BD ring in memory
	status = XAxiDma_BdRingCreate(ring, (int)p_bd_mem_aligned, (int)p_bd_mem_aligned, XAXIDMA_BD_MINIMUM_ALIGNMENT, num_bds_per_ring);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed create %s buffer descriptor ring.\r\n", (is_rx ? "s2mm" : "mm2s"));
		return DMA_PASSTHROUGH_BD_SETUP_FAIL;
	}

	// Allocate BDs from template
	XAxiDma_BdClear(&bd_template);
	status = XAxiDma_BdRingClone(ring, &bd_template);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed allocate buffer descriptors.\r\n");
		return DMA_PASSTHROUGH_BD_SETUP_FAIL;
	}

	status = XAxiDma_BdRingAlloc(ring, num_bds_per_ring, &bd_ptr);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to allocate locations in the buffer descriptor ring.\r\n");
		return DMA_PASSTHROUGH_BD_SETUP_FAIL;
	}

	// Initialize to point to first BD and first part of data buffer
	cur_bd_ptr = bd_ptr;
	buf_addr   = (int)p_dma_buf;

	for(ii = 0; ii < num_bds_per_ring; ii++)
	{

		// Set source address of buffer described by current BD
		status = XAxiDma_BdSetBufAddr(cur_bd_ptr, buf_addr);
		if (status != XST_SUCCESS)
		{
			xil_printf("ERROR! Failed to set source address for this BD.\r\n");
			return DMA_PASSTHROUGH_BD_SETUP_FAIL;
		}

		// Set length of buffer
		status = XAxiDma_BdSetLength(cur_bd_ptr, num_samples_per_bd*sample_size_bytes, ring->MaxTransferLen);
		if (status != XST_SUCCESS)
		{
			xil_printf("ERROR! Failed to set buffer length for this BD.\r\n");
			return DMA_PASSTHROUGH_BD_SETUP_FAIL;
		}

		// Set control bits for TX side
		if (!is_rx)
		{
			if (ii == 0)
			{
				cr_bits |= XAXIDMA_BD_CTRL_TXSOF_MASK; // Set SOF (tuser) for first BD
			}

			cr_bits |= XAXIDMA_BD_CTRL_TXEOF_MASK; // Sets tlast to generate an interrupt. Coalescing is set to interrupt once per ring
		}

		// Set control register
		XAxiDma_BdSetCtrl(cur_bd_ptr, cr_bits);

		// Increment pointer address to the next BD
		buf_addr += num_samples_per_bd*sample_size_bytes;

		// Advance current BD pointer for next iteration
		cur_bd_ptr = (XAxiDma_Bd*)XAxiDma_BdRingNext(ring, cur_bd_ptr);

	}

	// Setup interrupt coalescing so only 1 interrupt fires per BD ring transfer
	status = XAxiDma_BdRingSetCoalesce(ring, num_bds_per_ring, 0);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed set interrupt coalescing.\r\n");
		return DMA_PASSTHROUGH_BD_SETUP_FAIL;
	}



	// Pass the BD to hardware for transmission
	status = XAxiDma_BdRingToHw(ring, num_bds_per_ring, bd_ptr); // This function manages cache coherency for BDs
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to pass buffer descriptor ring to the hardware. \n\r");
		return DMA_PASSTHROUGH_BD_SETUP_FAIL;
	}

	if (cyclic == TRUE)
	{
		//Setup cyclic mode
		XAxiDma_SelectCyclicMode(p_dma_inst,XAXIDMA_DMA_TO_DEVICE,cyclic);
		//set the tail to a location that is not a bd so that the dma never pauses
		ring->HwTail = (XAxiDma_Bd *)(ring->FirstBdAddr + 0x120);
		//And then write this to the dma tail register
		XAxiDma_WriteReg(
		            ring->ChanBase,
		            XAXIDMA_TDESC_OFFSET,
		            (((UINTPTR)(ring->HwTail)+(ring->FirstBdPhysAddr-ring->FirstBdAddr)) & XAXIDMA_DESC_LSB_MASK));
	}



	// Enable interrupts
	XAxiDma_BdRingIntEnable(ring, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK));

	return DMA_PASSTHROUGH_SUCCESS;

}

// Public functions
dma_passthrough_t* dma_passthrough_create(int dma_device_id, int sample_size_bytes, int num_samples_per_buffer, int num_bds_per_ring)
{

	// Local variables
	dma_passthrough_t* p_obj;
	int                status;

	// Allocate memory for DMA Accelerator object
	p_obj = (dma_passthrough_t*) malloc(sizeof(dma_passthrough_t));
	if (p_obj == NULL)
	{
		xil_printf("ERROR! Failed to allocate memory for DMA Passthrough object.\n\r");
		return NULL;
	}
	p_obj->cyclic_enable = FALSE;
	// Register and initialize peripherals
	status = init_dma(&p_obj->periphs.dma_inst, dma_device_id);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! Failed to initialize AXI DMA.\n\r");
		dma_passthrough_destroy(p_obj);
		return NULL;
	}

	// Initialize buffer pointers
	dma_passthrough_set_rcv_buf(p_obj, NULL);
	dma_passthrough_set_snd_buf(p_obj, NULL);

	// Set the number of BDs per ring
	dma_passthrough_set_num_bds_per_ring(p_obj, num_bds_per_ring);

	// Initialize buffer length
	dma_passthrough_set_buf_length(p_obj, num_samples_per_buffer);

	// Initialize sample size
	dma_passthrough_set_sample_size_bytes(p_obj, sample_size_bytes);


	return p_obj;

}

void dma_passthrough_destroy(dma_passthrough_t* p_dma_passthrough_inst)
{
	free(p_dma_passthrough_inst->tx_bd_mem);
	free(p_dma_passthrough_inst);
}

void dma_passthrough_free_bd_mem(dma_passthrough_t* p_dma_passthrough_inst)
{
	free(p_dma_passthrough_inst->tx_bd_mem);
}

void dma_passthrough_reset(dma_passthrough_t* p_dma_passthrough_inst)
{
	XAxiDma_Reset(&p_dma_passthrough_inst->periphs.dma_inst);
}

void dma_passthrough_set_rcv_buf(dma_passthrough_t* p_dma_passthrough_inst, void* p_rcv_buf)
{
	p_dma_passthrough_inst->p_rcv_buf = p_rcv_buf;
}

void* dma_passthrough_get_rcv_buf(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->p_rcv_buf);
}

void dma_passthrough_set_snd_buf(dma_passthrough_t* p_dma_passthrough_inst, void* p_snd_buf)
{
	p_dma_passthrough_inst->p_snd_buf = p_snd_buf;
}

void* dma_passthrough_get_snd_buf(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->p_snd_buf);
}

void dma_passthrough_set_num_bds_per_ring(dma_passthrough_t* p_dma_passthrough_inst, int num_bds_per_ring)
{
	p_dma_passthrough_inst->num_bds_per_ring = num_bds_per_ring;
}

int dma_passthrough_get_num_bds_per_ring(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->num_bds_per_ring);
}

void dma_passthrough_set_buf_length(dma_passthrough_t* p_dma_passthrough_inst, int buf_length)
{
	p_dma_passthrough_inst->buf_length = buf_length;
}

int dma_passthrough_get_buf_length(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->buf_length);
}

void dma_passthrough_set_sample_size_bytes(dma_passthrough_t* p_dma_passthrough_inst, int sample_size_bytes)
{
	p_dma_passthrough_inst->sample_size_bytes = sample_size_bytes;
}

int dma_passthrough_get_sample_size_bytes(dma_passthrough_t* p_dma_passthrough_inst)
{
	return (p_dma_passthrough_inst->sample_size_bytes);
}

int dma_passthrough_rcv(dma_passthrough_t* p_dma_passthrough_inst)
{

	// Local variables
	int             status    = 0;
	const int       num_bytes = p_dma_passthrough_inst->num_bds_per_ring*p_dma_passthrough_inst->buf_length*p_dma_passthrough_inst->sample_size_bytes;
	int*            rx_bd_mem;
	XAxiDma_BdRing* rx_ring   = XAxiDma_GetRxRing(&p_dma_passthrough_inst->periphs.dma_inst);

	// Flush cache
	#if (!DMA_PASSTHROUGH_IS_CACHE_COHERENT)
		Xil_DCacheFlushRange((int)p_dma_passthrough_inst->p_rcv_buf, num_bytes);
	#endif

	// Allocate space for BD rings in memory
	rx_bd_mem = (int*) malloc((p_dma_passthrough_inst->num_bds_per_ring+1)*XAXIDMA_BD_MINIMUM_ALIGNMENT); // +1 to account for worst case misalignment
	if (rx_bd_mem == NULL)
	{
		xil_printf("ERROR! Failed to allocate memory for S2MM BDs.\n\r");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}

	// Set up RX buffer descriptors
	status = bd_ch_setup
	(
		&p_dma_passthrough_inst->periphs.dma_inst,
		p_dma_passthrough_inst->p_rcv_buf,
		rx_bd_mem,
		p_dma_passthrough_inst->num_bds_per_ring,
		p_dma_passthrough_inst->buf_length,
		p_dma_passthrough_inst->sample_size_bytes,
		1,
		FALSE
	);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! Failed to set up the S2MM buffer descriptors.\r\n");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}


	// Enable interrupts
	XAxiDma_BdRingIntEnable(rx_ring, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK));

	// Kick off S2MM transfer
	status = XAxiDma_BdRingStart(rx_ring);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to kick off S2MM transfer.\n\r");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}

	return DMA_PASSTHROUGH_SUCCESS;

}

int dma_passthrough_snd(dma_passthrough_t* p_dma_passthrough_inst, int blocking, int cyclic)
{

	// Local variables
	int             status    = 0;
	const int       num_bytes = p_dma_passthrough_inst->num_bds_per_ring*p_dma_passthrough_inst->buf_length*p_dma_passthrough_inst->sample_size_bytes;
	XAxiDma_BdRing* tx_ring   = XAxiDma_GetTxRing(&p_dma_passthrough_inst->periphs.dma_inst);

	// Flush cache
	#if (!DMA_PASSTHROUGH_IS_CACHE_COHERENT)
		Xil_DCacheFlushRange((int)p_dma_passthrough_inst->p_snd_buf, num_bytes);
	#endif


	// Allocate space for BD rings in memory
	xil_printf("malloc bytes %d\r\n",(p_dma_passthrough_inst->num_bds_per_ring+1)*XAXIDMA_BD_MINIMUM_ALIGNMENT);
	p_dma_passthrough_inst->tx_bd_mem = (int*) malloc((p_dma_passthrough_inst->num_bds_per_ring+1)*XAXIDMA_BD_MINIMUM_ALIGNMENT); // +1 to account for worst case misalignment
	if (p_dma_passthrough_inst->tx_bd_mem == NULL)
	{
		xil_printf("ERROR! Failed to allocate memory for MM2S BDs.\n\r");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}

	// Set up TX buffer descriptors
	status = bd_ch_setup
	(
		&p_dma_passthrough_inst->periphs.dma_inst,
		p_dma_passthrough_inst->p_snd_buf,
		p_dma_passthrough_inst->tx_bd_mem,
		p_dma_passthrough_inst->num_bds_per_ring,
		p_dma_passthrough_inst->buf_length,
		p_dma_passthrough_inst->sample_size_bytes,
		0,
		cyclic
	);
	if (status != DMA_PASSTHROUGH_SUCCESS)
	{
		xil_printf("ERROR! Failed to set up the MM2S buffer descriptors.\r\n");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}

	// Initialize control flags which get set by ISR

	// Enable interrupts
	//XAxiDma_BdRingIntEnable(tx_ring, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK));

	// Kick off MM2S transfer
	status = XAxiDma_BdRingStart(tx_ring);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Failed to kick off MM2S transfer.\n\r");
		return DMA_PASSTHROUGH_XFER_FAIL;
	}
	if (blocking)
	{
		// Wait for transfer to complete
		while (XAxiDma_Busy(&p_dma_passthrough_inst->periphs.dma_inst, XAXIDMA_DMA_TO_DEVICE)) {}

		// Check DMA for errors
		if ((XAxiDma_ReadReg(p_dma_passthrough_inst->periphs.dma_inst.RegBase, XAXIDMA_TX_OFFSET+XAXIDMA_SR_OFFSET) & XAXIDMA_IRQ_ERROR_MASK) != 0)
		{
			xil_printf("ERROR! AXI DMA returned an error during the MM2S transfer.\n\r");
			return DMA_PASSTHROUGH_XFER_FAIL;
		}
	}


	return DMA_PASSTHROUGH_SUCCESS;

}

void dma_passthrough_pause(dma_passthrough_t* p_dma_passthrough_inst)
{
	XAxiDma_Pause(&p_dma_passthrough_inst->periphs.dma_inst);
}
void dma_check_snd(dma_passthrough_t* p_dma_passthrough_inst)
{
	u32 busy = XAxiDma_Busy(&p_dma_passthrough_inst->periphs.dma_inst, XAXIDMA_DMA_TO_DEVICE);
	XAxiDma_BdRing* tx_ring   = XAxiDma_GetTxRing(&p_dma_passthrough_inst->periphs.dma_inst);
	int ringStatus = XAxiDma_BdRingCheck(tx_ring);
	int ringBusy = XAxiDma_BdRingBusy(tx_ring);
	xil_printf("dmaBusy %d, ringStatus %d, ringBusy %d\r\n",busy,ringStatus,ringBusy);
}

void dma_dump_all_bd(dma_passthrough_t* p_dma_passthrough_inst)
{
	XAxiDma_BdRing* tx_ring   = XAxiDma_GetTxRing(&p_dma_passthrough_inst->periphs.dma_inst);
	XAxiDma_Bd* cur_bd_ptr;
	XAxiDma_BdRingDumpRegs(tx_ring);
	cur_bd_ptr = (XAxiDma_Bd*)XAxiDma_BdRingGetCurrBd(tx_ring);
	int ii;
	for (ii = 0; ii < p_dma_passthrough_inst->num_bds_per_ring; ++ii)
	{
		XAxiDma_DumpBd(cur_bd_ptr);
		cur_bd_ptr = (XAxiDma_Bd*)XAxiDma_BdRingNext(tx_ring, cur_bd_ptr);
	}
}


