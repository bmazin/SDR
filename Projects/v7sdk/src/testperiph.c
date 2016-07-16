/*
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
 * 
 *
 * This file is a generated sample test application.
 *
 * This application is intended to test and/or illustrate some 
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * SDK application project when you run the "Generate Libraries" menu item.
 *
 */

#include <stdio.h>
#include <math.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xspi.h"
#include "spi_header.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "gpio_header.h"
//include code to program the LMK04821 Clock
#include "platform_drivers.h"
#include "lmk04821.h"
// include code to program the AD9625 ADC
#include "ad9625.h"
// include code to program the AD9136 DAC
#include "ad9136.h"
#include "dac_core.h"
// include code for the JESD204B interface
#include "jesd204b_v51.h"
#include "dac_dma.h"
#include "dma_passthrough.h"
#include "xuartlite_l.h"
#include "xuartlite.h"
// include code to program the RF/IF board
#include "trf3795.h"
#include "pe43705.h"

int zdok_recv_LUT(u8* LUTBuffer, int nBytesToRecv)
{
	int ctr=0;
    int iTimer;
    int iByte = 0;
    int isNextByte = 1;
    int byteTimeout = 100000;
    XUartLite_SendByte(XPAR_UART_2_ZDOK_BASEADDR, 1);
	while (XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR));
	while(isNextByte)
	{
		LUTBuffer[iByte] = (u8)XUartLite_ReadReg(XPAR_UART_2_ZDOK_BASEADDR, 0);
		iByte++;

		if (iByte >= nBytesToRecv )
			isNextByte = 0;
		else
		{
			for(iTimer=0; iTimer < byteTimeout; iTimer++)
			{
				isNextByte = !XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR);
				if(isNextByte)
					break;
			}
		}
	}

	return iByte;

}

int main() 
{
	int choice, exit_flag,status;
	XSpi SpiLO, SpiAtten;
	XGpio GpioOutput;
	XStatus gpioStatus;
	XUartLite UartLite;


	dma_passthrough_t* p_dma_pass;

	u32 address0;
	u32 addressIncrement = 2;
	u32 valueIncrement = 1000;

	int loInit = 0;
	int attenInit = 0;
	int dmaInit = 0;

	Xil_ICacheEnable();
	Xil_DCacheEnable();

	print("\n\r********************************************************");
	print("\n\r********************************************************");
	print("\n\r**           MKIDs ADC/DAC Loop Back Tests            **");
	print("\n\r********************************************************");
	print("\n\r********************************************************\r\n");


	gpioStatus = XGpio_Initialize(&GpioOutput, XPAR_GPIO_JESD_DEVICE_ID);
	if (gpioStatus != XST_SUCCESS)
	{
		xil_printf("GPIO initialization failure");

	}
	//Set the direction for all signals to be outputs
	XGpio_SetDataDirection(&GpioOutput, 1, 0x0);
    
    // after power-up use the following routines to initialize the board
	XGpio_DiscreteWrite(&GpioOutput, 1, 0b01); // Enable JESD reset, set SYSREF to 0
	mdelay(100);
    lmk04821_setup(XPAR_LMK_SPI_0_DEVICE_ID, 0);	// routine to setup the LMK Clock Chip
    xil_printf("Now wait 30s for initialization of JESD204 . . . \r\n");
    mdelay(5000);
    jesd204b_setup(XPAR_JESD204_0_BASEADDR); // routine to initialize the JESD204 IP for ADC0
    mdelay(100);
    jesd204b_setup(XPAR_JESD204_1_BASEADDR); // routine to initialize the JESD204 IP for ADC1
    mdelay(100);
    jesd204b_setup(XPAR_JESD204_2_BASEADDR); // routine to initialize the JESD204 IP for DACs
    mdelay(100);
    ad9625_setup(XPAR_ADC0_SPI_1_DEVICE_ID, 0);	// routine to setup ADC0
    mdelay(10);
    ad9625_setup(XPAR_ADC1_SPI_2_DEVICE_ID, 0);	// routine to setup ADC1
    mdelay(10);
    ad9136_setup(XPAR_DAC_SPI_3_DEVICE_ID, 0);	// routine to setup the DACs
    mdelay(100);
    XGpio_DiscreteWrite(&GpioOutput, 1, 0b00); // Disable JESD reset
    mdelay(1000);
    XGpio_DiscreteWrite(&GpioOutput, 1, 0b10); // Assert SYSREF

	exit_flag = 0;
    
    //status = UartLiteSelfTestExample(XPAR_UART_2_ZDOK_DEVICE_ID);
    status = XUartLite_Initialize(&UartLite, XPAR_UART_2_ZDOK_DEVICE_ID);
    status |= XUartLite_SelfTest(&UartLite);
	if (status == 0) {
		print("UartLiteSelfTestExample PASSED\r\n");
	}
	else {
	      print("UartLiteSelfTestExample FAILED\r\n");
	}

	XUartLite_ResetFifos(&UartLite);

	xil_printf("Waiting for ROACH 2 init\r\n");

	while(XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR))
	{
		XUartLite_SendByte(XPAR_UART_2_ZDOK_BASEADDR, 1);
		mdelay(100);

	}
    
    xil_printf("ROACH 2 ready\r\n");
	while(1) {
        xil_printf("Waiting for ROACH2 input\r\n");
		while(XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR));
		choice = (int)XUartLite_ReadReg(XPAR_UART_2_ZDOK_BASEADDR, 0);
/*	    print("Choose Option:\r\n");
	    print("1: Initialize\r\n");
	    print("2: Check Status Enable SYSREF\r\n");
	    print("3: Enable DACs\r\n");
	    print("4: Set ADC output to debug ramp\r\n");
	    print("5: Set ADC output to normal\r\n");
	    print("6: Configure DMA and send buffer to DAC\r\n");
	    print("7: Write Counter LUT to DDR3\r\n");
	    print("8: Write Sine LUT to DDR3\r\n");
	    print("9: Recieve external LUT to DDR3\r\n");
	    print("A: Pause DMA\r\n");
	    print("B: Check DMA status\r\n");
	    print("C: Program RF-IF LO\r\n");
	    print("D: Program RF-IF Attenuators\r\n");
//	    print("7: DDR3 C0 External Memory Test\r\n");
//	    print("8: DDR3 C1 External Memory Test\r\n");
//	    print("9: BRAM Internal Memory Test\r\n");
//	    print("A: XADC Test\r\n");
	    print("0: Exit\r\n");
	    choice = inbyte();
    	if (isalpha(choice)) {
    	    choice = toupper(choice);
    	}*/
    	xil_printf("%c\r\n", choice);

    	switch(choice)
    	{
			case 1:
                xil_printf("Already initialized\r\n");
				break;   
			case 2:
				//	while ADCs and DACs are transmitting data, run these routines before issuing each SYSREF
				//	and to check status

				ad9625_status(XPAR_ADC0_SPI_1_DEVICE_ID, 0);	// routine to check status of ADC0
				mdelay(10);
				ad9625_status(XPAR_ADC1_SPI_2_DEVICE_ID, 0);	// routine to check status of ADC1
				mdelay(10);
			    ad9136_serdes_status(XPAR_DAC_SPI_3_DEVICE_ID, 0);	// routine to check status of DACs
				break;
			case 3:
				// after applying first SYSREF, call routine to enable the DAC(s) links

				ad9136_link_enable(XPAR_DAC_SPI_3_DEVICE_ID, 0);
				mdelay(10);
				break;
			case 4: //Set ADC output to debug ramp
				ad9625_enter_ramp_mode(XPAR_ADC0_SPI_1_DEVICE_ID, 0);
				mdelay(10);
				ad9625_enter_ramp_mode(XPAR_ADC1_SPI_2_DEVICE_ID, 0);
				mdelay(10);
				break;
			case 5: //Set ADC output to normal
				ad9625_exit_ramp_mode(XPAR_ADC0_SPI_1_DEVICE_ID, 0);
				mdelay(10);
				ad9625_exit_ramp_mode(XPAR_ADC1_SPI_2_DEVICE_ID, 0);
				mdelay(10);
				break;
			case 7: //DDR3 memory test
				; //empty statement after case label before assignment
                xil_printf("Writing ramp LUT\r\n");
                u32 address0;
                u32 addressIncrement = 4;
                u32 valueIncrement = 4096;
                u64 baseValueToWrite = 0;
                u64 valueToWrite = 0;

                int timeIndex = 0;
                address0 = DDR_DAC_BUFFER_BASEADDR ;
                for (timeIndex=0; timeIndex < NUM_DAC_SAMPLES_IN_LUT; ++timeIndex)
                {
                	valueToWrite = (baseValueToWrite + 0*(timeIndex % 8)) % 65536;

                	if (timeIndex % 8 == 1)
                		valueToWrite = baseValueToWrite+8192;
                    if (timeIndex % 10000 == 0)
                    {
                        xil_printf("index %d\r\n",timeIndex);
                    }


                    //Write the same to I and Q, 2 bytes each each, I in higher bytes than Q
                    Xil_Out16(address0 , (u16)(valueToWrite));
                    Xil_Out16(address0+2, (u16)(valueToWrite));
                    if (timeIndex < 20)
                    {
                        xil_printf("%x",valueToWrite);
                    }
                    if (timeIndex % 8 == 7)
                        baseValueToWrite = (baseValueToWrite + valueIncrement) % 65536;
                    address0+=addressIncrement;
                }
                xil_printf("Finished writing.\r\n");
                break;


			case 8:
				;
				xil_printf("Writing sine LUT\r\n");

				addressIncrement = 4;
				double arg = 0;
				//int freqIndex = 5000; //38.14 MHz
				u32 freqIndex = 111;
				double sineVal = 0;
				double cosVal = 0;
				u16 sineValInt = 0;
				u16 cosValInt = 0;

				timeIndex = 0;
				address0 = DDR_DAC_BUFFER_BASEADDR ;
				for (timeIndex=0; timeIndex < NUM_DAC_SAMPLES_IN_LUT; ++timeIndex)
				{
					arg = (M_TWOPI*freqIndex*timeIndex) / NUM_DAC_SAMPLES_IN_LUT;
					sineVal = sin(arg);
					cosVal = cos(arg);
					sineValInt = (u16)((short)(sineVal*FLOAT_TO_I16_SHIFT));
					cosValInt = (u16)((short)(cosVal*FLOAT_TO_I16_SHIFT));
					if (timeIndex == 21000)
					{
						xil_printf("index %d, i16 %d, u16 %d\r\n",timeIndex,((short)(sineVal*FLOAT_TO_I16_SHIFT)), sineValInt);
					}
					if (timeIndex % 1000 == 0)
					{
						xil_printf("index %d\r\n",timeIndex);
					}
					Xil_Out16(address0 , sineValInt);
					Xil_Out16(address0+2, cosValInt);

					address0+=addressIncrement;
				}
				xil_printf("Finished writing.\r\n");
				break;
			case 9:
				;
				xil_printf("Receiving LUT over UART\r\n");
                int numRecv;
                int iBuffer;
                int j;
                int ddr3Addr=DDR_DAC_BUFFER_BASEADDR;
                int numBuffersToRecv = ceil(NUM_DAC_SAMPLES_IN_LUT*NUM_BYTES_PER_DAC_SAMPLE_PAIR/NUM_BYTES_PER_V6_UART_BUFFER);
				u8 LUTBuffer[NUM_BYTES_PER_V6_UART_BUFFER+10];


                for(iBuffer=0; iBuffer < numBuffersToRecv; iBuffer++)
                {
                	xil_printf("listening for buffer\r\n");
                    numRecv = zdok_recv_LUT(LUTBuffer,NUM_BYTES_PER_V6_UART_BUFFER);
                    xil_printf("numRecv: %d\r\n", numRecv);

                    if(ddr3Addr+numRecv-1 > DDR_DAC_BUFFER_HIGHADDR)
                    {
                        xil_printf("Not Enough LUT memory! \r\n");
                        break;

                    }
                    for(j=0; j<numRecv; j++)
                        Xil_Out8(j+ddr3Addr, LUTBuffer[j]);


                    ddr3Addr+=numRecv;
                }

                xil_printf("Finished writing.\r\n");
                xil_printf("DDR3 Offset: %d\r\n", ddr3Addr-DDR_DAC_BUFFER_BASEADDR);

                for (address0 = DDR_DAC_BUFFER_BASEADDR; address0 < DDR_DAC_BUFFER_BASEADDR+80; address0+=2)
                {
                	xil_printf("%d\r\n", Xil_In16(address0));

                }
				xil_printf("Finished writing.\r\n");
				break;
			case 6:
				; //empty statement after case label before assignment

				xil_printf("Configuring DMA\r\n");

				if(dmaInit)
					break;


				p_dma_pass = dma_passthrough_create(XPAR_AXI_DMA_0_DEVICE_ID,NUM_BYTES_PER_SAMPLE,NUM_SAMPLES_PER_BUFFER,NUM_BD_PER_RING);

				char* p_snd_buf = (void*)DDR_DAC_BUFFER_BASEADDR;
				dma_passthrough_set_snd_buf(p_dma_pass, p_snd_buf);

				xil_printf("Sending DDR3 buffer to DAC\r\n");
				int sendIdx;
				int sndReturnVal;
				int blocking = FALSE;
				int nSends = 1;
				int cyclic = TRUE;
				if (blocking == TRUE && nSends > 1)
				{
					xil_printf("configuring dma\r\n");
					p_dma_pass = dma_passthrough_create(XPAR_AXI_DMA_0_DEVICE_ID,NUM_BYTES_PER_SAMPLE,NUM_SAMPLES_PER_BUFFER,NUM_BD_PER_RING);

					char* p_snd_buf = (void*)DDR_DAC_BUFFER_BASEADDR;
					dma_passthrough_set_snd_buf(p_dma_pass, p_snd_buf);
				}
				for (sendIdx = 0; sendIdx < nSends; ++sendIdx)
				{
					sndReturnVal = dma_passthrough_snd(p_dma_pass,blocking,cyclic);
					if (sndReturnVal != DMA_PASSTHROUGH_SUCCESS)
					{
						xil_printf("ERROR: Problem in sending.\r\n");
						break;
					}
					xil_printf("sent %d\r\n",sendIdx);
					if (blocking == TRUE && nSends > 1)
					{
						xil_printf("reset before next\r\n");
						dma_passthrough_destroy(p_dma_pass);
					}
				}
				dmaInit = 1;
				break;
			case 0xA:
				xil_printf("Pause DMA");
				dma_passthrough_pause(p_dma_pass);
				break;
			case 0xB:
				xil_printf("DMA Status\r\n");
				dma_check_snd(p_dma_pass);
				dma_dump_all_bd(p_dma_pass);
				break;
			
            //Initialize LO in integer mode
            case 0xC:
			   /*
				* Use the GPIO to set the SPI output enable high before
				* programming the RF/IF board Local Oscillator because
				* this transceiver output enable is active high
				*/
				GpioSetOebHigh(XPAR_GPIO_LEDS1_DEVICE_ID);

				{               
                    XStatus status=0;
                    print("\r\nSetup the RF/IF board LO - TRF3765\r\n");
                    status = SpiSetupLo(XPAR_LO_SPI_4_DEVICE_ID, &SpiLO);	// Setup RF board LO
                    if (status == 0) {
                        print("\r\nTRF3765 Setup PASSED\r\n");
                    }
                    else {
                        print("\r\nTRF3765 Setup FAILED\r\n");
				  }

				}
			   /*
				* Use the GPIO to set the SPI output enable low before
				* programming any other SPI devices on the board
				*/
				GpioSetOebLow(XPAR_GPIO_LEDS1_DEVICE_ID);
				loInit = 1;
				break;
			case 0xD:
			   {
				  XStatus status;
				  print("\r\n Setup the RF/IF board Attenuators - PE43705\r\n");
				  status = SpiSetupAttn(XPAR_ATTN_SPI_5_DEVICE_ID, &SpiAtten);	// Setup RF board Attenuator
				  if (status == 0) {
					 print("\r\nPE43705 Setup PASSED\r\n");
				  }
				  else {
					 print("\r\nPE43705 Setup FAILED\r\n");
				  }
				  XSpi_Reset(&SpiAtten);
			   }
			   attenInit = 1;
			   break;
//				break;
//			case '9':
//				hello_bram();
//				break;
//			case 'A':
//				hello_xadc();
//				break;
            //Enable LO integer mode (initialize LO first)
			case 0x10:
				if(!loInit)
				{
					xil_printf("Initialize LO first!\r\n");
					break;

				}
                GpioSetOebHigh(XPAR_GPIO_LEDS1_DEVICE_ID);
                {
                    XStatus status;
                    status = trf3795EnableInt(&SpiLO);
                    
                    if(status!=0)
                        xil_printf("Integer mode initialization failure\r\n");
                    
                }
                
                
                GpioSetOebLow(XPAR_GPIO_LEDS1_DEVICE_ID);
                break;
            //Enable LO fractional mode (initialize LO first)
            case 0x11:
            	if(!loInit)
				{
					xil_printf("Initialize LO first!\r\n");
					break;

				}
                GpioSetOebHigh(XPAR_GPIO_LEDS1_DEVICE_ID);
                {
                    XStatus status;
                    status = trf3795EnableFrac(&SpiLO);
                    
                    if(status!=0)
                        xil_printf("Frac mode initialization failure\r\n");
                    
                }
                
                
                GpioSetOebLow(XPAR_GPIO_LEDS1_DEVICE_ID);
                break;
            
           /* Change LO frequency using ROACH2 UART
            * UART sends frequency in four bytes in the following order:
            *   Integer LSB
            *   Integer MSB
            *   Fractional LSB
            *   Fractional MSB
            * Integer here means multiple of 1 MHz
            */
            case 0x12:
            	if(!loInit)
				{
					xil_printf("Initialize LO first!\r\n");
					break;

				}
                GpioSetOebHigh(XPAR_GPIO_LEDS1_DEVICE_ID);
                {
                    double freq = 0;
                    int i = 0;
                    int rByte;                    
                    XStatus status;
                    
                    //Recieve the integer part of the frequency
                    for(i=0; i<2; i++)
                    {
                        XUartLite_SendByte(XPAR_UART_2_ZDOK_BASEADDR, 1);
                        while(XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR));
                        rByte = (int)XUartLite_ReadReg(XPAR_UART_2_ZDOK_BASEADDR, 0);
                        freq += (double)(rByte<<(i*8));
                        //xil_printf("rbyte: %d\r\n", rByte);
                        
                    }
                    
                    //Recieve fractional part of the frequency
                    for(i=0; i<2; i++)
                    {
                        XUartLite_SendByte(XPAR_UART_2_ZDOK_BASEADDR, 1);
                        while(XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR));
                        rByte = (int)XUartLite_ReadReg(XPAR_UART_2_ZDOK_BASEADDR, 0);
                        freq += (double)(rByte<<(i*8))/(1<<16);
                        //xil_printf("rbyte: %d\r\n", rByte);
                        
                    }

                    xil_printf("Frequency: %d\r\n",(int)freq);
                    //mdelay(50);
                    

                   	status = trf3795changeFreqFrac(&SpiLO,freq);
                   	mdelay(200);
                   	status = trf3795changeFreqFrac(&SpiLO,freq);

                    if(status!=0)
                        xil_printf("Frequency change failure\r\n");
                    
                }
                GpioSetOebLow(XPAR_GPIO_LEDS1_DEVICE_ID);
                break;

            //Reset LO SPI object
            case 0x13:
            	if(!loInit)
				{
					xil_printf("Initialize LO first!\r\n");
					break;

				}
                GpioSetOebHigh(XPAR_GPIO_LEDS1_DEVICE_ID);
            	XSpi_Reset(&SpiLO);
                GpioSetOebLow(XPAR_GPIO_LEDS1_DEVICE_ID);
            	break;

            //Read back LO SPI registers
            case 0x14:
            	if(!loInit)
            	{
            		xil_printf("Initialize LO first!\r\n");
            		break;

            	}
            	xil_printf("Read back SPI registers\r\n");
            	GpioSetOebHigh(XPAR_GPIO_LEDS1_DEVICE_ID);
            	trf3795ReadBackRegs(&SpiLO);
            	GpioSetOebLow(XPAR_GPIO_LEDS1_DEVICE_ID);
            	break;

           /* Change Atten over ROACH2 UART (initialize attenuator first)
            * UART sends two bytes: first attenID, then attenVal
            */
            case 0x20:
            	{
            		if(!attenInit)
					{
						xil_printf("Initialize attenuators first!\r\n");
						break;

					}
            		u8 recv[2];
            		int i;
            		XStatus status;
            		for(i=0; i<2; i++)
					{
						XUartLite_SendByte(XPAR_UART_2_ZDOK_BASEADDR, 1);
						while(XUartLite_IsReceiveEmpty(XPAR_UART_2_ZDOK_BASEADDR));
						recv[i] = (int)XUartLite_ReadReg(XPAR_UART_2_ZDOK_BASEADDR, 0);

					}
                    
            		xil_printf("Done Receiving\r\n");
            		XSpi_Reset(&SpiAtten);
                    status = changeAtten(&SpiAtten, recv[0], recv[1]);


            	}
            	break;

            //Reset Attenuator SPI object
            case 0x21:
            	XSpi_Reset(&SpiAtten);
            	break;
            //LUT dump test
            case 0x30:
            {
            	u8 LUTBuffer[NUM_BYTES_PER_V6_UART_BUFFER+10];
                numRecv = zdok_recv_LUT(LUTBuffer,NUM_BYTES_PER_V6_UART_BUFFER);
                int i;
                
                u32* LUTBufferRd = (u32*)LUTBuffer;

                xil_printf("Buffer Received\r\n");
                xil_printf("First ten Values");
                for(i=0; i<10; i++)
                {
                	xil_printf("%d\r\n",LUTBuffer[i]);

                }

                xil_printf("Last ten Values");
                for(i=0; i<10; i++)
				{
					xil_printf("%d\r\n",LUTBuffer[4086+i]);

				}

            	break;

            }

            //write zeros to DAC LUT
            case 0x31:
            {
            	int addr;
            	for(addr=DDR_DAC_BUFFER_BASEADDR; addr<DDR_DAC_BUFFER_HIGHADDR; addr++)
            	{
            		Xil_Out8(addr, 0);

            	}

            }

			default:
				break;
		

        }

    	XUartLite_SendByte(XPAR_UART_2_ZDOK_BASEADDR, 1);
	}
	print("Good-bye!\r\n");


	print("---Exiting main---\n\r");
	Xil_DCacheDisable();
	Xil_ICacheDisable();
	return 0;
}
