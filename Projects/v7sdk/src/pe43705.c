/*
 * pe43705.c
 *
 *  Created on: May 17, 2016
 *  Modified by: zmuda
 */
/******************************************************************************
*
* Copyright (C) 2001 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file pe43705.c
* @addtogroup spi_v4_1
* @{
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xspi.h"

/************************** Constant Definitions *****************************/

#define XSP_SR_RESET_STATE		0x5	   		/* Default to Tx/Rx reg empty */
#define XSP_CR_RESET_STATE		0x180

#define XSP_HALF_WORD_TESTBYTE	0x2200		/* Test Pattern for Half Word */
#define XSP_WORD_TESTBYTE		0xFF117700	/* Test Pattern for Word */

#define XSP_CR_LSB_FIRST		0x200		/* LSB first - transfer format */

/*
* Attenuator number is 1-3 set on upper byte
* 0x01nn RF up-converter path 1st attenuator
* 0x02nn RF up-converter path 2nd attenuator
* 0x03nn RF down-converter path attenuator
* Attenuation value is 0 to 31.75 dB, set on lower 7 bits, 0.25 dB per bit
* example:	0x0n7f 31.75 dB attenuation
* 			0x0n10 4 db attenuation
* 			0x0n40 16 dB attenuation
*/
#define XSP_REG1_WRITE			0x014c		/* RF up-converter path 1st attenuator.  Address 001 */
#define XSP_REG2_WRITE			0x0240		/* RF up-converter path 2nd attenuator.  Address 010 */
#define XSP_REG3_WRITE			0x037f		/* RF down-converter path attenuator.  Address 011 */


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

static int pe43705RegWrite(XSpi *InstancePtr);

/************************** Variable Definitions *****************************/
int write_pe_register[3]; // create an array for the register values

/*****************************************************************************/
/**
*
* Runs a self-test on the driver/device. The self-test is destructive in that
* a reset of the device is performed in order to check the reset values of
* the registers and to get the device into a known state. A simple loopback
* test is also performed to verify that transmit and receive are working
* properly. The device is changed to master mode for the loopback test, since
* only a master can initiate a data transfer.
*
* Upon successful return from the self-test, the device is reset.
*
* @param	InstancePtr is a pointer to the XSpi instance to be worked on.
*
* @return
* 		- XST_SUCCESS if successful.
*		- XST_REGISTER_ERROR indicates a register did not read or write
*		  correctly.
* 		- XST_LOOPBACK_ERROR if a loopback error occurred.
*
* @note		None.
*
******************************************************************************/
int PeXSpiSetup(XSpi *InstancePtr)
{
	int Result;
//	u32 Register;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Reset the SPI device to leave it in a known good state.
	 */
//	XSpi_Reset(InstancePtr);
//
//	if(InstancePtr->XipMode)
//	{
//		Register = XSpi_GetControlReg(InstancePtr);
//		if (Register != XSP_CR_RESET_STATE) {
//			return XST_REGISTER_ERROR;
//		}
//
//		Register = XSpi_GetStatusReg(InstancePtr);
//		if ((Register & XSP_SR_RESET_STATE) != XSP_SR_RESET_STATE) {
//			return XST_REGISTER_ERROR;
//		}
//	}
//
//	/*
//	 * All the SPI registers should be in their default state right now.
//	 */
//	Register = XSpi_GetControlReg(InstancePtr);
//	if (Register != XSP_CR_RESET_STATE) {
//		return XST_REGISTER_ERROR;
//	}
//
//	Register = XSpi_GetStatusReg(InstancePtr);
//	if ((Register & XSP_SR_RESET_STATE) != XSP_SR_RESET_STATE) {
//		return XST_REGISTER_ERROR;
//	}
//
//	/*
//	 * Each supported slave select bit should be set to 1.
//	 */
//	Register = XSpi_GetSlaveSelectReg(InstancePtr);
//	if (Register != InstancePtr->SlaveSelectMask) {
//		return XST_REGISTER_ERROR;
//	}
//
//	/*
//	 * If configured with FIFOs, the occupancy values should be 0.
//	 */
//	if (InstancePtr->HasFifos) {
//		Register = XSpi_ReadReg(InstancePtr->BaseAddr,
//					 XSP_TFO_OFFSET);
//		if (Register != 0) {
//			return XST_REGISTER_ERROR;
//		}
//		Register = XSpi_ReadReg(InstancePtr->BaseAddr,
//					 XSP_RFO_OFFSET);
//		if (Register != 0) {
//			return XST_REGISTER_ERROR;
//		}
//	}
//
//	/*
//	 * Run loopback test only in case of standard SPI mode.
//	 */
//	if (InstancePtr->SpiMode != XSP_STANDARD_MODE) {
//		return XST_SUCCESS;
//	}

	/*
	 * Run write and read on the SPI attached to RF board.
	 */
	Result = pe43705RegWrite(InstancePtr);
	if (Result != XST_SUCCESS) {
		return Result;
	}

	/*
	 * Reset the SPI device to leave it in a known good state.
	 */
	XSpi_Reset(InstancePtr);

	return XST_SUCCESS;
}

/*****************************************************************************/
/* Write to the RF board PE43705 Attenuator
*
*
******************************************************************************/
static int pe43705RegWrite(XSpi *InstancePtr)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
//	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
//	u32 NumRecvd = 0;
//	u32 RxData;
	u8  DataWidth;
	u16 write_pe_register[] = {XSP_REG1_WRITE,XSP_REG2_WRITE,XSP_REG3_WRITE};

	/*
	 * Setup the control register to enable master mode and
	 * to send least significant bit 1st
	 */
	ControlReg = XSpi_GetControlReg(InstancePtr);
	XSpi_SetControlReg(InstancePtr, ControlReg | XSP_CR_MASTER_MODE_MASK |
						XSP_CR_LSB_FIRST);

	/*
	 * Set the slave select zero bit to active - low
	 */
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE);

	/*
	 * We do not need interrupts for now
	 */
	XSpi_IntrGlobalDisable(InstancePtr);

	DataWidth = InstancePtr->DataWidth;

	/*****************************************************************************/

	/*
	 * perform a write to a PE43705 register
	 */

	/*
	 * This for loop will write all three PE43705 chips in succession.
	 */
	for (Index = 0; Index < 3; Index++) {
		Data = 0;

		/*
		 * Write to the transmit register.
		 */
		StatusReg = XSpi_GetStatusReg(InstancePtr);
//		while ((StatusReg & XSP_SR_TX_FULL_MASK) == 0) {	// no loop, do just a single transfer for now
			if (DataWidth == XSP_DATAWIDTH_BYTE) {
				/*
				 * Data Transfer Width is Byte (8 bit).
				 */
				Data = 0;
			} else if (DataWidth == XSP_DATAWIDTH_HALF_WORD) {
				/*
				 * Data Transfer Width is Half Word (16 bit).
				 */
				Data = write_pe_register[Index];			// Index to get the register value out of the array
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = XSP_WORD_TESTBYTE;	// write value to register *****************************************
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			NumSent += (DataWidth >> 3);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

			/*
			* set the slave select one SS(0) bit low
			*/
			XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the slave select low
	//		for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
	//		{}
	//		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

		/*
		 * Start the transfer by not inhibiting the transmitter and
		 * enabling the device.
		 */
		ControlReg = XSpi_GetControlReg(InstancePtr) &
						 (~XSP_CR_TRANS_INHIBIT_MASK);
		XSpi_SetControlReg(InstancePtr, ControlReg |
				    XSP_CR_ENABLE_MASK);

		/*
		 * Wait for the transfer to be done by polling the transmit
		 * empty status bit.
		 */
		xil_printf("start while loop \r\n");
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);
		xil_printf("end while loop \r\n");

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

	/*
	* To create a latch enable pulse,
	* set the slave select one SS(0) bit high then back low
	*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the slave select

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);

		xil_printf("\r%04x\n\r", Data);
	}

	xil_printf("\n\rPE43705 Register Access Done\n\r");

	return XST_SUCCESS;
}

/*
 * Change the attenuation of the attenuator specified by attenID (1, 2, or 3),
 * to the value specified by attenVal/4.
 */
int changeAtten(XSpi *InstancePtr, int attenID, int attenVal)
{
    u32 StatusReg;
	u32 ControlReg;
//	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
//	u32 NumRecvd = 0;
//	u32 RxData;
    u16 attenData;
	u8  DataWidth;
    
    if(attenID > 3)
    {
        xil_printf("AttenID must be <=3!\r\n");
        return XST_FAILURE;
        
    }
    
    attenData = (u16)(attenVal + (attenID<<8));
	/*
	 * Setup the control register to enable master mode and
	 * to send least significant bit 1st
	 */
	ControlReg = XSpi_GetControlReg(InstancePtr);
	XSpi_SetControlReg(InstancePtr, ControlReg | XSP_CR_MASTER_MODE_MASK |
						XSP_CR_LSB_FIRST);

	/*
	 * Set the slave select zero bit to active - low
	 */
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE);

	/*
	 * We do not need interrupts for now
	 */
	XSpi_IntrGlobalDisable(InstancePtr);

	DataWidth = InstancePtr->DataWidth;

	/*****************************************************************************/

	/*
	 * perform a write to a PE43705 register
	 */


    Data = 0;

    /*
     * Write to the transmit register.
     */
    StatusReg = XSpi_GetStatusReg(InstancePtr);
//		while ((StatusReg & XSP_SR_TX_FULL_MASK) == 0) {	// no loop, do just a single transfer for now
        if (DataWidth == XSP_DATAWIDTH_BYTE) {
            /*
             * Data Transfer Width is Byte (8 bit).
             */
            Data = 0;
        } else if (DataWidth == XSP_DATAWIDTH_HALF_WORD) {
            /*
             * Data Transfer Width is Half Word (16 bit).
             */
            Data = attenData;			
        } else if (DataWidth == XSP_DATAWIDTH_WORD){
            /*
             * Data Transfer Width is Word (32 bit).
             */
            Data = XSP_WORD_TESTBYTE;	// write value to register *****************************************
        }

        XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
        NumSent += (DataWidth >> 3);
        StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

        /*
        * set the slave select one SS(0) bit low
        */
        XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the slave select low
//		for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//		{}
//		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

    /*
     * Start the transfer by not inhibiting the transmitter and
     * enabling the device.
     */
    ControlReg = XSpi_GetControlReg(InstancePtr) &
                     (~XSP_CR_TRANS_INHIBIT_MASK);
    XSpi_SetControlReg(InstancePtr, ControlReg |
                XSP_CR_ENABLE_MASK);

    /*
     * Wait for the transfer to be done by polling the transmit
     * empty status bit.
     */
    do {
        StatusReg = XSpi_IntrGetStatus(InstancePtr);
    } while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

    XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

/*
* To create a latch enable pulse,
* set the slave select one SS(0) bit high then back low
*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
    XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the slave select

    /*
     * Stop the transfer (hold off automatic sending) by inhibiting
     * the transmitter and disabling the device.
     */
    ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
    XSpi_SetControlReg(InstancePtr ,
                ControlReg & ~ XSP_CR_ENABLE_MASK);

    xil_printf("\r%04x\n\r", Data);
	

	xil_printf("\n\rPE43705 Register Access Done\n\r");
	XSpi_Reset(InstancePtr);

	return XST_SUCCESS;
    
    
}
/** @} */
