/*
 * trf3795.h
 *
 *  Created on: May 18, 2016
 *      Author: zmuda
 */

#ifndef TRF3795_H_
#define TRF3795_H_

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

int SpiSetupLo(u16 DeviceId, XSpi *Spi);
int trf3795WriteAndRead(XSpi *Spi);
int trf3795EnableFrac(XSpi *Spi);
int trf3795EnableInt(XSpi *Spi);
int trf3795changeFreqInt(XSpi *InstancePtr, u32 freq);
int trf3795changeFreqFrac(XSpi *InstancePtr, double freq);
int trf3795ReadBackRegs(XSpi *InstancePtr);


#endif /* TRF3795_H_ */
