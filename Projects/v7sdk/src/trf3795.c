/*
 * trf3795.c
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
* @file trf3795.c
* @addtogroup spi_v4_1
* @{
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xspi.h"
//#include "math.h"

/************************** Constant Definitions *****************************/

#define XSP_SR_RESET_STATE		0x5	   		/* Default to Tx/Rx reg empty */
#define XSP_CR_RESET_STATE		0x180

#define XSP_HALF_WORD_TESTBYTE	0x2200		/* Test Pattern for Half Word */
#define XSP_WORD_TESTBYTE		0xFF117700	/* Test Pattern for Word */

#define XSP_CR_LSB_FIRST		0x200		/* LSB first - transfer format */
#define XSP_SET_READBACK		0x80000008	/* Put device into read-back mode */
#define XSP_REG0_READBACK		0x80000008	/* Set read-back mode register 0 */
#define XSP_REG1_READBACK		0x90000008	/* Set read-back mode register 1 */
#define XSP_REG2_READBACK		0xA0000008	/* Set read-back mode register 2 */
#define XSP_REG3_READBACK		0xB0000008	/* Set read-back mode register 3 */
#define XSP_REG4_READBACK		0xC0000008	/* Set read-back mode register 4 */
#define XSP_REG5_READBACK		0xD0000008	/* Set read-back mode register 5 */
#define XSP_REG6_READBACK		0xE0000008	/* Set read-back mode register 6 */
#define XSP_REG7_READBACK		0xF0000008	/* Set read-back mode register 7 */
//
#define XSP_ZERO_WRITE			0x00000000	/* Write zeros during read-back */
//
#define XSP_REG0_WRITE			0x80000028	/* Test register write value */
#define XSP_REG1_WRITE			0x68300149	/* Test register write value */
//#define XSP_REG2_WRITE			0x8881388A	/* Test register write value 5GHz*/
#define XSP_REG2_WRITE_ENC		0x88A0BB8A	/* Test register write value 6GHz*/
#define XSP_REG2_WRITE			0x08A0BB8A	/* Test register write value 6GHz*/
//#define XSP_REG2_WRITE			0x88A0DACA	/* Test register write value 7GHz*/
#define XSP_REG3_WRITE			0x0000000B	/* Test register write value */
#define XSP_REG4_WRITE   		0x0800E00C	/* Test register write value */
#define XSP_REG5_WRITE			0x908E968D	/* Test register write value */
#define XSP_REG6_WRITE			0x5441100E	/* Test register write value */
#define XSP_REG7_WRITE			0x0000000F	/* Test register write value */

//#define XSP_REG4_WRITE_FRAC     0xCA04E00C
#define XSP_REG4_WRITE_FRAC 	0b11001010000111001110000000001100 //ANA = 1 (both in and out) Speedup is off
#define XSP_REG5_WRITE_FRAC     0x1086968D //Used to be 0x1086968D, changed 1086 -> 108E Jul 14
#define XSP_REG6_WRITE_FRAC     0x5441100e /*ISOURCE_TRIM = 100 - optimal may be different*/

#define XSP_REG4_WRITE_DEF_INT  0x4A00F80C /*Both DEF_INT and DEF_FRAC use defaults */

#define XSP_REG1_WRITE_DEF_FRAC 0b11001010000111001111100000001100 //with ANA = 1 //0x41500029
#define XSP_REG4_WRITE_DEF_FRAC 0xCA04F80C /*  from the datasheet - FRAC replaces these with 
                                               recommended fractional values when needed*/
#define XSP_REG5_WRITE_DEF_FRAC 0b00101010001001101010001010001101
#define XSP_REG6_WRITE_DEF_FRAC 0b01010000010000010011000000001110 //set en_lockdet to 1, not a default

//start with these reg values when changing frequency 
//#define XSP_REG1_WRITE_CF      0x68300009
#define XSP_REG1_WRITE_CF      0b1100001010100000000000000001001 //new charge pump, high freq calibration
#define XSP_REG2_WRITE_CF_ENC  0x8800000A
//#define XSP_REG2_WRITE_CF_ENC  0b11101000000000000000000000001010 //call_Acc max
#define XSP_REG2_WRITE_CF      0x0800000A
#define XSP_REG3_WRITE_CF      XSP_REG3_WRITE
#define XSP_REG6_WRITE_CF      0x5441300E //lockdet on
//#define XSP_REG6_WRITE_CF	   0b1010100010000010001000000001110  //lockdet off

#define SPI_TIMEOUT			   1000000



/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

static int trf3795WriteAndRead(XSpi *InstancePtr);

/************************** Variable Definitions *****************************/


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
int TrfXSpiSetup(XSpi *InstancePtr)
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
	 * Run write and read on the SPI attached to RF LO.
	 */
	Result = trf3795WriteAndRead(InstancePtr);
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
/* Write to and read back the RF board TRF3795
*
*
******************************************************************************/
static int trf3795WriteAndRead(XSpi *InstancePtr)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
	u32 NumRecvd = 0;
	u32 RxData[] = {0,0,0};
	u8  DataWidth;
	u8  j;
	int ctr = 0;
	u32 write_trf_register[] = {XSP_REG0_WRITE,XSP_REG1_WRITE,XSP_REG2_WRITE_ENC,XSP_REG3_WRITE,
							 XSP_REG4_WRITE,XSP_REG5_WRITE,XSP_REG6_WRITE, XSP_REG7_WRITE};
	u32 read_trf_register[] = {XSP_REG0_READBACK,XSP_REG1_READBACK,XSP_REG2_READBACK,XSP_REG3_READBACK,
							XSP_REG4_READBACK,XSP_REG5_READBACK,XSP_REG6_READBACK,XSP_REG7_READBACK,XSP_REG7_READBACK};

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
	 * perform a write to a TRF3765 register
	 */

	for (Index = 0; Index < 8; Index++) {	// for loop write to all eight registers
		Data = 0;

		/*
		 * Fill the transmit register.
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
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = write_trf_register[Index];	// choose the register index 0 to 7 ************
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			NumSent += (DataWidth >> 3);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

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
		//xil_printf("status reg %d \r\n", StatusReg);
		//xil_printf("intr status reg %d \r\n", XSpi_IntrGetStatus(InstancePtr));
		ctr = 0;
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
			if(ctr > SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


	/*
	* To create a latch enable pulse,
	* set the slave select one SS(0) bit low
	*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);
//	}	// end of the for loop


	/*****************************************************************************/

	/*
	 * To Read-back from the Internal Register Banks, Register 0 must be programmed
	 * with a specific command that sets the TRF3765 into read-back mode and
	 * specifies the register to be read
	 */

//	for (Index = 0; Index < 1; Index++) {
//		Data = 0;

		/*
		 * Fill the transmit register.
		 */
		StatusReg = XSpi_GetStatusReg(InstancePtr);
//		while ((StatusReg & XSP_SR_TX_FULL_MASK) == 0) {	// do just a single transfer for now
			if (DataWidth == XSP_DATAWIDTH_BYTE) {
				/*
				 * Data Transfer Width is Byte (8 bit).
				 */
				Data = 0;
			} else if (DataWidth == XSP_DATAWIDTH_HALF_WORD) {
				/*
				 * Data Transfer Width is Half Word (16 bit).
				 */
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = read_trf_register[Index]; // index of the register to readback here *********************
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			NumSent += (DataWidth >> 3);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

		/*
		 * Start the transfer by not inhibiting the transmitter and
		 * enabling the device.
		 */
		ControlReg = XSpi_GetControlReg(InstancePtr) &
						 (~XSP_CR_TRANS_INHIBIT_MASK);
		XSpi_SetControlReg(InstancePtr, ControlReg |
				    XSP_CR_ENABLE_MASK);					// | XSP_CR_CLK_PHASE_MASK);

		/*
		 * Wait for the transfer to be done by polling the transmit
		 * empty status bit.
		 */
		ctr = 0;
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
			if(ctr > SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		for (Delay = 0; Delay < 10; Delay++)	// add delay
		{}

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


		for (Delay = 0; Delay < 10; Delay++)	// add delay
		{}

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);
//	}	// end of the for loop

	/*
	 *************  Now read-back the specific register *********************************
	 */

//	for (Index = 0; Index < 1; Index++) {
//		Data = 0;

		/*
		 * Fill the transmit register.
		 */
		StatusReg = XSpi_GetStatusReg(InstancePtr);
//		while ((StatusReg & XSP_SR_TX_FULL_MASK) == 0) {	// do just a single transfer for now
			if (DataWidth == XSP_DATAWIDTH_BYTE) {
				/*
				 * Data Transfer Width is Byte (8 bit).
				 */
				Data = 0;
			} else if (DataWidth == XSP_DATAWIDTH_HALF_WORD) {
				/*
				 * Data Transfer Width is Half Word (16 bit).
				 */
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = XSP_ZERO_WRITE;	// just leave the data bits at zero during read-back
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET,
					Data + Index);
			NumSent += (DataWidth >> 3);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

		/*
		 * Start the transfer by not inhibiting the transmitter and
		 * enabling the device.
		 */
		ControlReg = XSpi_GetControlReg(InstancePtr) &
						 (~XSP_CR_TRANS_INHIBIT_MASK);
		XSpi_SetControlReg(InstancePtr, ControlReg |
				    XSP_CR_ENABLE_MASK | XSP_CR_CLK_PHASE_MASK);	// clock data in on the second edge (falling)

		/*
		 * Wait for the transfer to be done by polling the transmit
		 * empty status bit.
		 */
		ctr = 0;
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
			if(ctr > SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		/*
		 * Receive and verify the data just transmitted.
		 */
		StatusReg = XSpi_GetStatusReg(InstancePtr);
		while ((StatusReg & XSP_SR_RX_EMPTY_MASK) == 0) {


			for (j = 0; j < 3; j++) {
				RxData[j] = XSpi_ReadReg(InstancePtr->BaseAddr,
							XSP_DRR_OFFSET);
				NumRecvd += (DataWidth >> 3);
				StatusReg = XSpi_GetStatusReg(InstancePtr);
			}
		xil_printf("\r%08x\n\r", RxData[2]);
		}

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);
	}	// end of the for loop

	/*
	 * One final check to make sure the total number of bytes sent equals
	 * the total number of bytes received.
	 */
//	if (NumSent != NumRecvd) {
//		return XST_LOOPBACK_ERROR;
//	}

	xil_printf("\n\rTRF3765 Register Access Done\n\r");

	return XST_SUCCESS;
}

/*
 * Enables the fractional mode of the LO
 * LO must be initialized first
 */
int trf3795EnableFrac(XSpi *InstancePtr)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
	u32 NumRecvd = 0;
	u32 RxData[] = {0,0,0};
	u8  DataWidth;
	u8  j;
	int ctr;
	u32 write_trf_register[] = {XSP_REG0_WRITE,XSP_REG1_WRITE,XSP_REG2_WRITE_ENC,XSP_REG3_WRITE,
							 XSP_REG4_WRITE_FRAC,XSP_REG5_WRITE_FRAC,XSP_REG6_WRITE_FRAC,XSP_REG7_WRITE};


	/*
	 * Setup the control reogister to enable master mode and
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
	 * perform a write to a TRF3765 register
	 */
	//XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK); //Remove this later
	for (Index = 0; Index < 8; Index++) {	// for loop write to all eight registers
		Data = 0;

		/*
		 * Fill the transmit register.
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
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = write_trf_register[Index];	// choose the register index 0 to 7 ************
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			NumSent += (DataWidth >> 3);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

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
		//xil_printf("Intr stat reg 0x%x\r\n",XSpi_IntrGetStatus(InstancePtr));
		ctr = 0;
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
			if(ctr>SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


	/*
	* To create a latch enable pulse,
	* set the slave select one SS(0) bit low
	*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);
 
    }
	XSpi_Reset(InstancePtr);
	return XST_SUCCESS;

}

/*
 * Enables the fractional mode of the LO
 * LO must be initialized first
 */
int trf3795EnableInt(XSpi *InstancePtr)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
	u32 NumRecvd = 0;
	u32 RxData[] = {0,0,0};
	u8  DataWidth;
	u8  j;
	int ctr;
	u32 write_trf_register[] = {XSP_REG0_WRITE,XSP_REG1_WRITE,XSP_REG2_WRITE,XSP_REG3_WRITE,
							 XSP_REG4_WRITE,XSP_REG5_WRITE,XSP_REG6_WRITE,XSP_REG7_WRITE};


	/*
	 * Setup the control reogister to enable master mode and
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
	 * perform a write to a TRF3765 register
	 */

	for (Index = 0; Index < 8; Index++) {	// for loop write to all eight registers
		Data = 0;

		/*
		 * Fill the transmit register.
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
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = write_trf_register[Index];	// choose the register index 0 to 7 ************
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			NumSent += (DataWidth >> 3);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
//		}

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
			if(ctr > SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


	/*
	* To create a latch enable pulse,
	* set the slave select one SS(0) bit low
	*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);

    }

	XSpi_Reset(InstancePtr);
	return XST_SUCCESS;


}
/*
 * Change LO frequency in integer mode
 * frequency must be multiple of 40 (MHz)
 */
int trf3795changeFreqInt(XSpi *InstancePtr, u32 freq)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
	u32 NumRecvd = 0;
	u32 RxData[] = {0,0,0};
	u32 reg1Val, reg2Val, reg6Val;
	u8  DataWidth;
	u8  j;
	int ctr;
    
    u8 loDivSel, loDiv;
    u8 pllDiv;
    u8 pllDivSel;
    u8 prscSel;
    u16 rDiv;
    u16 nInt;

    // Calculate parameter and register values
    
    freq = freq/2; // Output frequency is doubled
	if(freq>2400)
	{
		loDiv = 1;
		loDivSel = 0;

	}
	else if(freq>1200)
	{
		loDiv = 2;
		loDivSel = 1;

	}
	else if(freq>600)
	{
		loDiv = 4;
		loDivSel = 2;

	}
	else if(freq>300)
	{
		loDiv = 8;
		loDivSel = 3;

	}
    pllDiv = (u8)ceil((double)loDiv*freq/3000.0);
    //xil_printf("Pll Div %d\r\n", pllDiv);
    rDiv = 1;
    nInt = (u16)(loDiv*freq*rDiv/(10*pllDiv));
    
    if(pllDiv==1)
        pllDivSel = 0;
    else if(pllDiv==2)
        pllDivSel = 1;
    else if(pllDiv==4)
        pllDivSel = 2;    
    else
    {
        xil_printf("Invalid PLL_DIV!\r\n");
        return XST_FAILURE;
        
    }
    
    if(nInt>=72)
        prscSel = 1;
    else
        prscSel = 0;

    //xil_printf("NInt %d\r\n", nInt);
    //xil_printf("prscSel %d\r\n", prscSel);
    //xil_printf("loDiv %d\r\n", loDiv);
    
    reg1Val = XSP_REG1_WRITE_CF + (rDiv<<5);
    reg2Val = XSP_REG2_WRITE_CF + (nInt<<5) + (pllDivSel<<21) + (prscSel<<23);
    reg6Val = XSP_REG6_WRITE_CF + (loDivSel<<23);
    u32 write_trf_register[] = {reg1Val,reg6Val,reg2Val};
    u32 reg_list = {1,2,6};
    
    //xil_printf("reg1: %x", reg1Val);
    //xil_printf("reg2: %x", reg2Val);
    //xil_printf("reg6: %x", reg6Val);


    
    /*
	 * Setup the control reogister to enable master mode and
	 * to send least significant bit 1st
	 */
    
	ControlReg = XSpi_GetControlReg(InstancePtr);
	XSpi_SetControlReg(InstancePtr, ControlReg | XSP_CR_MASTER_MODE_MASK |
						XSP_CR_LSB_FIRST);

	//xil_printf("ctrl reg setup done\r\n");

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
	 * perform a write to a TRF3765 register
	 */

	for (Index = 0; Index < 3; Index++) {	// for loop write to three registers
		Data = 0;
		xil_printf("start transfer %d\r\n", Index);
		/*
		 * Fill the transmit register.
		 */
		StatusReg = XSpi_GetStatusReg(InstancePtr);
		//xil_printf("got status reg\r\n");
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
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = write_trf_register[Index];	// choose the register index 0 to 7 ************
				//xil_printf("selected register \r\n");
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			//xil_printf("wrote data \r\n");
			NumSent += (DataWidth >> 3);
			//xil_printf("Numsent %d\r\n", NumSent);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
			//xil_printf("status reg %d \r\n", StatusReg);
//		}

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
		//xil_printf("start for loop\r\n");
		//xil_printf("status reg %d\r\n", XSpi_IntrGetStatus(InstancePtr));
		ctr = 0;
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
			if(ctr > SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		//xil_printf("done with while loop \r\n");

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


	/*
	* To create a latch enable pulse,
	* set the slave select one SS(0) bit low
	*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);

		//xil_printf("Done transfer %d\r\n", Index);
 
    }

	XSpi_Reset(InstancePtr);


	return XST_SUCCESS;

}    

/*
 * Change LO frequency in fractional mode.
 * Must call trf3795EnableFrac() first. 
 */
int trf3795changeFreqFrac(XSpi *InstancePtr, double freq)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
	u32 NumRecvd = 0;
	u32 RxData[] = {0,0,0};
	u32 reg1Val, reg2Val, reg2ENCVal, reg3Val, reg6Val;
	u8  DataWidth;
	u8  j;
	int ctr;
    
    u8 loDivSel, loDiv;
    u8 pllDiv;
    u8 pllDivSel;
    u8 prscSel;
    u16 rDiv;
    u16 nInt;
    u32 nFrac;

    // Calculate parameter and register values
    
    freq = freq/2; // Output frequency is doubled
    
    if(freq>2400)
	{
		loDiv = 1;
		loDivSel = 0;

	}
	else if(freq>1200)
	{
		loDiv = 2;
		loDivSel = 1;

	}
	else if(freq>600)
	{
		loDiv = 4;
		loDivSel = 2;

	}
	else if(freq>300)
	{
		loDiv = 8;
		loDivSel = 3;

	}
    pllDiv = (u8)ceil((double)loDiv*freq/3000.0);
    //xil_printf("Pll Div %d\r\n", pllDiv);
    rDiv = 1;
    nInt = (u16)(loDiv*freq*rDiv/(10*pllDiv));
    nFrac = (u32)(((loDiv*freq*rDiv/(10*pllDiv))-nInt)*(1<<25));
    
    if(pllDiv==1)
        pllDivSel = 0;
    else if(pllDiv==2)
        pllDivSel = 1;
    else if(pllDiv==4)
        pllDivSel = 2;    
    else
    {
        xil_printf("Invalid PLL_DIV!\r\n");
        return XST_FAILURE;
        
    }
    
    if(nInt>=75)      // 72 in integer mode, 75 in frac
        prscSel = 1;
    else
        prscSel = 0;

    //xil_printf("NInt %d\r\n", nInt);
    //xil_printf("prscSel %d\r\n", prscSel);
    //xil_printf("loDiv %d\r\n", loDiv);
    //xil_printf("NFrac %x\r\n", nFrac);
    
    reg1Val = XSP_REG1_WRITE_CF + (rDiv<<5);
    reg2Val = XSP_REG2_WRITE_CF + (nInt<<5) + (pllDivSel<<21) + (prscSel<<23);
    reg2ENCVal = XSP_REG2_WRITE_CF_ENC + (nInt<<5) + (pllDivSel<<21) + (prscSel<<23);
    reg3Val = XSP_REG3_WRITE_CF + (nFrac<<5);
    reg6Val = XSP_REG6_WRITE_CF + (loDivSel<<23);
    u32 write_trf_register[] = {XSP_REG0_WRITE, reg1Val, reg3Val, XSP_REG4_WRITE_FRAC,
    			XSP_REG5_WRITE_FRAC, reg6Val, reg2ENCVal, XSP_REG7_WRITE};
    
    xil_printf("reg1: %x\r\n", reg1Val);
    xil_printf("reg2: %x\r\n", reg2ENCVal);
    xil_printf("reg3: %x\r\n", reg3Val);
    xil_printf("reg6: %x\r\n", reg6Val);


    
    /*
	 * Setup the control reogister to enable master mode and
	 * to send least significant bit 1st
	 */
    
	ControlReg = XSpi_GetControlReg(InstancePtr);
	XSpi_SetControlReg(InstancePtr, ControlReg | XSP_CR_MASTER_MODE_MASK |
						XSP_CR_LSB_FIRST);

	//xil_printf("ctrl reg setup done\r\n");

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
	 * perform a write to a TRF3765 register
	 */

	for (Index = 0; Index < 8; Index++) {	// for loop write to three registers
		//mdelay(5);
		Data = 0;
		//xil_printf("start transfer %d\r\n", Index);
		/*
		 * Fill the transmit register.
		 */
		StatusReg = XSpi_GetStatusReg(InstancePtr);
		//xil_printf("got status reg\r\n");
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
				Data = XSP_HALF_WORD_TESTBYTE;
			} else if (DataWidth == XSP_DATAWIDTH_WORD){
				/*
				 * Data Transfer Width is Word (32 bit).
				 */
				Data = write_trf_register[Index];	// choose the register index 0 to 7 ************
				//xil_printf("selected register \r\n");
			}

			XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
			//xil_printf("wrote data \r\n");
			NumSent += (DataWidth >> 3);
			//xil_printf("Numsent %d\r\n", NumSent);
			StatusReg = XSpi_GetStatusReg(InstancePtr);
			//xil_printf("status reg %d \r\n", StatusReg);
			mdelay(5);
//		}

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
		//xil_printf("start while loop\r\n");
		//xil_printf("intr status reg %d\r\n", XSpi_IntrGetStatus(InstancePtr));
		ctr = 0;
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
			if(ctr>SPI_TIMEOUT)
				break;
			ctr++;
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);
		//mdelay(5);
		//xil_printf("done with while loop \r\n");

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


	/*
	* To create a latch enable pulse,
	* set the slave select one SS(0) bit low
	*/
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE); // drives the latch enable
//	for (Delay = 0; Delay < 10; Delay++)	// more delay makes pulse wider
//	{}
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes the latch enable

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
				    ControlReg & ~ XSP_CR_ENABLE_MASK);

		//xil_printf("Done transfer %d\r\n", Index);
 
    }

	XSpi_Reset(InstancePtr);


	return XST_SUCCESS;

}

int trf3795ReadBackRegs(XSpi *InstancePtr)
{
	u32 StatusReg;
	u32 ControlReg;
	u32 Index;
	u32 Delay;
	u32 Data;
	u32 NumSent = 0;
	u32 NumRecvd = 0;
	u32 RxData[] = {0,0,0};
	u8  DataWidth;
	u8  j;
	u32 read_trf_register[] = {XSP_REG0_READBACK,XSP_REG1_READBACK,XSP_REG2_READBACK,XSP_REG3_READBACK,
								XSP_REG4_READBACK,XSP_REG5_READBACK,XSP_REG6_READBACK,XSP_REG7_READBACK};

	ControlReg = XSpi_GetControlReg(InstancePtr);
	XSpi_SetControlReg(InstancePtr, ControlReg | XSP_CR_MASTER_MODE_MASK |
						XSP_CR_LSB_FIRST);

	xil_printf("ctrl reg setup done\r\n");

	/*
	 * Set the slave select zero bit to active - low
	 */
//	XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFE);

	/*
	 * We do not need interrupts for now
	 */
	XSpi_IntrGlobalDisable(InstancePtr);

	DataWidth = InstancePtr->DataWidth;

	StatusReg = XSpi_GetStatusReg(InstancePtr);

	for(Index=0; Index<8; Index++)
	{
		if (DataWidth == XSP_DATAWIDTH_BYTE) {
			/*
			 * Data Transfer Width is Byte (8 bit).
			 */
			Data = 0;
		} else if (DataWidth == XSP_DATAWIDTH_HALF_WORD) {
			/*
			 * Data Transfer Width is Half Word (16 bit).
			 */
			Data = XSP_HALF_WORD_TESTBYTE;
		} else if (DataWidth == XSP_DATAWIDTH_WORD){
			/*
			 * Data Transfer Width is Word (32 bit).
			 */
			Data = read_trf_register[Index]; // index of the register to readback here *********************
		}

		XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET, Data);
		NumSent += (DataWidth >> 3);
		StatusReg = XSpi_GetStatusReg(InstancePtr);


		/*
		 * Start the transfer by not inhibiting the transmitter and
		 * enabling the device.
		 */
		ControlReg = XSpi_GetControlReg(InstancePtr) &
						 (~XSP_CR_TRANS_INHIBIT_MASK);
		XSpi_SetControlReg(InstancePtr, ControlReg |
					XSP_CR_ENABLE_MASK);					// | XSP_CR_CLK_PHASE_MASK);

		/*
		 * Wait for the transfer to be done by polling the transmit
		 * empty status bit.
		 */
		//xil_printf("enter first tx while loop \r\n");
		do {
			StatusReg = XSpi_IntrGetStatus(InstancePtr);
		} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

		XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

		for (Delay = 0; Delay < 10; Delay++)	// add delay
		{}

		/*
		* To create a latch enable pulse and extra read clock pulse,
		* set the slave select one SS(1) bit low
		*/
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFD); // creates read pulse and clock
		for (Delay = 0; Delay < 10; Delay++)	// more delay makes wider pulses
		{}
		XSpi_SetSlaveSelectReg(InstancePtr, 0xFFFF); // removes read pulse and clock


		for (Delay = 0; Delay < 10; Delay++)	// add delay
		{}

		/*
		 * Stop the transfer (hold off automatic sending) by inhibiting
		 * the transmitter and disabling the device.
		 */
		ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
		XSpi_SetControlReg(InstancePtr ,
					ControlReg & ~ XSP_CR_ENABLE_MASK);
	//	}	// end of the for loop

		/*
		 *************  Now read-back the specific register *********************************
		 */

	//	for (Index = 0; Index < 1; Index++) {
	//		Data = 0;

			/*
			 * Fill the transmit register.
			 */
			StatusReg = XSpi_GetStatusReg(InstancePtr);
	//		while ((StatusReg & XSP_SR_TX_FULL_MASK) == 0) {	// do just a single transfer for now
				if (DataWidth == XSP_DATAWIDTH_BYTE) {
					/*
					 * Data Transfer Width is Byte (8 bit).
					 */
					Data = 0;
				} else if (DataWidth == XSP_DATAWIDTH_HALF_WORD) {
					/*
					 * Data Transfer Width is Half Word (16 bit).
					 */
					Data = XSP_HALF_WORD_TESTBYTE;
				} else if (DataWidth == XSP_DATAWIDTH_WORD){
					/*
					 * Data Transfer Width is Word (32 bit).
					 */
					Data = XSP_ZERO_WRITE;	// just leave the data bits at zero during read-back
				}

				XSpi_WriteReg(InstancePtr->BaseAddr, XSP_DTR_OFFSET,
						Data + Index);
				NumSent += (DataWidth >> 3);
				StatusReg = XSpi_GetStatusReg(InstancePtr);
	//		}

			/*
			 * Start the transfer by not inhibiting the transmitter and
			 * enabling the device.
			 */
			ControlReg = XSpi_GetControlReg(InstancePtr) &
							 (~XSP_CR_TRANS_INHIBIT_MASK);
			XSpi_SetControlReg(InstancePtr, ControlReg |
					    XSP_CR_ENABLE_MASK | XSP_CR_CLK_PHASE_MASK);	// clock data in on the second edge (falling)

			/*
			 * Wait for the transfer to be done by polling the transmit
			 * empty status bit.
			 */
			//xil_printf("Enter tx empty while loop\r\n");
			do {
				StatusReg = XSpi_IntrGetStatus(InstancePtr);
			} while ((StatusReg & XSP_INTR_TX_EMPTY_MASK) == 0);

			XSpi_IntrClear(InstancePtr, XSP_INTR_TX_EMPTY_MASK);

			/*
			 * Receive and verify the data just transmitted.
			 */
			StatusReg = XSpi_GetStatusReg(InstancePtr);
			//xil_printf("Enter rx empty while loop\r\n");
			while ((StatusReg & XSP_SR_RX_EMPTY_MASK) == 0) {


				for (j = 0; j < 3; j++) {
					RxData[j] = XSpi_ReadReg(InstancePtr->BaseAddr,
								XSP_DRR_OFFSET);
					NumRecvd += (DataWidth >> 3);
					StatusReg = XSpi_GetStatusReg(InstancePtr);
				}
			xil_printf("\r%08x\n\r", RxData[2]);
			}

			/*
			 * Stop the transfer (hold off automatic sending) by inhibiting
			 * the transmitter and disabling the device.
			 */
			ControlReg |= XSP_CR_TRANS_INHIBIT_MASK;
			XSpi_SetControlReg(InstancePtr ,
					    ControlReg & ~ XSP_CR_ENABLE_MASK);
		}	// end of the for loop



		xil_printf("\n\rTRF3765 Register Access Done\n\r");

		return XST_SUCCESS;

}
        
/** @} */
