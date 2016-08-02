/*
 * pe43705.h
 *
 *  Created on: May 18, 2016
 *      Author: zmuda
 */

#ifndef PE43705_H_
#define PE43705_H_

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

int SpiSetupAttn(u16 DeviceId, XSpi *Spi);
int pe43705RegWrite(XSpi *Spi);
int changeAtten(XSpi *Spi, int attenID, int attenVal);

#endif /* PE43705_H_ */
