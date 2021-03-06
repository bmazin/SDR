/*
 * dac_dma.h
 *
 *  Created on: May 20, 2016
 *      Author: kids
 */

#ifndef DAC_DMA_H_
#define DAC_DMA_H_

#define DDR_DAC_BUFFER_BASEADDR	0x80000000
#define DDR_DAC_BUFFER_HIGHADDR	0x80FFFFFF

#define NUM_BYTES_PER_SAMPLE 32
//32*16384*2 for a 1MB buffer
//#define NUM_SAMPLES_PER_BUFFER 16384
#define NUM_BD_PER_RING 2

//#define NUM_DAC_SAMPLES_IN_LUT 262144
//#define FLOAT_TO_I16_SHIFT 16384

//#define NUM_SAMPLES_PER_BUFFER 32768
//#define NUM_DAC_SAMPLES_IN_LUT 524288
#define FLOAT_TO_I16_SHIFT 32767
#endif /* DAC_DMA_H_ */

#define NUM_SAMPLES_PER_BUFFER 16384
#define NUM_DAC_SAMPLES_IN_LUT 262144

#define NUM_BYTES_PER_V6_UART_BUFFER 4096
#define NUM_BYTES_PER_DAC_SAMPLE_PAIR 4
