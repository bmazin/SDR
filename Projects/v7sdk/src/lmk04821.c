/***************************************************************************//**
* @original author DBogdan (dragos.bogdan@analog.com)
********************************************************************************
* Copyright 2014(c) Analog Devices, Inc.
*
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
* - Redistributions of source code must retain the above copyright
* notice, this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright
* notice, this list of conditions and the following disclaimer in
* the documentation and/or other materials provided with the
* distribution.
* - Neither the name of Analog Devices, Inc. nor the names of its
* contributors may be used to endorse or promote products derived
* from this software without specific prior written permission.
* - The use of this software may or may not infringe the patent rights
* of one or more patent holders. This license does not release you
* from the requirement that you obtain separate licenses from these
* patent holders to use this software.
* - Use of the software either in source or binary form, must be run
* on or directly connected to an Analog Devices Inc. component.
*
* THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT,
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/
/***************************************************************************//**
* This file was modified to work with the LMK04821
* This file was modified by TZ
*******************************************************************************/
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <xil_printf.h>
#include "platform_drivers.h"
#include "lmk04821.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
uint8_t lmk04821_slave_select;

/***************************************************************************//**
* @brief lmk04821_spi_read
*******************************************************************************/
int32_t lmk04821_spi_read(uint16_t reg_addr, uint8_t *reg_data)
{
	uint8_t buf[3];
	int32_t ret;

	buf[0] = 0x80 | (reg_addr >> 8);
	buf[1] = reg_addr & 0xFF;
	buf[2] = 0x00;

	ret = spi_write_and_read(lmk04821_slave_select, buf, 3);
	*reg_data = buf[2];

	return ret;
}

/***************************************************************************//**
* @brief lmk04821_spi_write
*******************************************************************************/
int32_t lmk04821_spi_write(uint16_t reg_addr, uint8_t reg_data)
{
	uint8_t buf[3];
	int32_t ret;

	buf[0] = reg_addr >> 8;
	buf[1] = reg_addr & 0xFF;
	buf[2] = reg_data;

	ret = spi_write_and_read(lmk04821_slave_select, buf, 3);

	return ret;
}

/***************************************************************************//**
* @brief lmk04821_setup
*******************************************************************************/
int32_t lmk04821_setup(uint32_t spi_device_id, uint8_t slave_select)

{
	uint8_t id_device;
	uint8_t id_prod_msb;
	uint8_t id_prod_lsb;
	uint8_t id_mask;
	uint8_t id_vndr_msb;
	uint8_t id_vndr_lsb;
	uint8_t stat1;
	uint8_t stat2;
	uint8_t stat3;
	uint8_t stat4;
	uint8_t stat5;
	uint8_t stat6;
	uint8_t stat7;
	uint8_t stat8;

	lmk04821_slave_select = slave_select;
	spi_init(spi_device_id, 1, 1);

	lmk04821_spi_read(LMK_ID_DEVICE_TYPE, &id_device);
	mdelay(30);
	xil_printf("LMK device type (0x%x).\r\n", id_device);
	mdelay(30);
//	if(id_device != LMK04821_DEVICE_ID)
//	{
//		xil_printf("Error: Invalid CHIP ID (0x%x).\n", id_device);
//		return -1;
//	}

	lmk04821_spi_read(LMK_ID_PROD_MSB, &id_prod_msb);
	mdelay(30);
	xil_printf("LMK PROD ID (0x%x).\r\n", id_prod_msb);
	mdelay(30);
//	if(id_prod_msb != LMK04821_PROD_ID_MSB)
//	{
//		xil_printf("Error: Invalid PRODUCT ID (0x%x).\n", id_prod_msb);
//		return -1;
//	}

	lmk04821_spi_read(LMK_ID_PROD_LSB, &id_prod_lsb);
	mdelay(30);
	xil_printf("LMK PROD ID (0x%x).\r\n", id_prod_lsb);
	mdelay(30);
//	if(id_prod_lsb != LMK04821_PROD_ID_LSB)
//	{
//		xil_printf("Error: Invalid PRODUCT ID (0x%x).\n", id_prod_lsb);
//		return -1;
//	}

	lmk04821_spi_read(LMK_ID_MASKREV, &id_mask);
	mdelay(30);
	xil_printf("LMK MASK (0x%x).\r\n", id_mask);
	mdelay(30);

	lmk04821_spi_read(LMK_ID_VNDR_MSB, &id_vndr_msb);
	mdelay(30);
	xil_printf("LMK VENDOR ID (0x%x).\r\n", id_vndr_msb);
	mdelay(30);
	
	lmk04821_spi_read(LMK_ID_VNDR_LSB, &id_vndr_lsb);
	mdelay(30);
	xil_printf("LMK VENDOR ID (0x%x).\r\n", id_vndr_lsb);
	mdelay(30);

	// reset and initialization
	mdelay(10);

	lmk04821_spi_write(LMK_RESET_CONFIG, RESET);	// reset
	mdelay(10);
	lmk04821_spi_write(LMK_RESET_CONFIG, 0x00);	// remove reset

	mdelay(10);

	lmk04821_spi_write(POWERDOWN, 0x00);	// power up
	mdelay(10);

	// device configuration
	// LMK_CONTROL_CLK_0_1
//	lmk04821_spi_write(0x100, 0x10);	// REG0 ADC1_DCLK to probe @ 125 MHz
	lmk04821_spi_write(0x100, 0x01);	// REG0 ADC1_DCLK @ 2GHz
	lmk04821_spi_write(0x101, 0x55);	// REG1
//	lmk04821_spi_write(0x103, 0x00);	// REG2 - do not bypass DCLK divider
	lmk04821_spi_write(0x103, 0x02);	// REG2 - bypass DCLK divider
	lmk04821_spi_write(0x104, 0x27);	// REG3 - ADC1 SYSREF to device
//	lmk04821_spi_write(0x104, 0x23);	// REG3 - from codeloader register dump
	lmk04821_spi_write(0x105, 0x00);	// REG4
	lmk04821_spi_write(0x106, 0xF0);	// REG5 - SYSREF to ADC1 is powered
	lmk04821_spi_write(0x107, 0x11);	// REG6 - output drive LCPECL

	// LMK_CONTROL_CLK_2_3
//	lmk04821_spi_write(0x108, 0x0C);	// REG0 DAC_DCLK @ 166.67MHz uses DAC internal PLL
	lmk04821_spi_write(0x108, 0x02);	// REG0 DAC_DCLK @ 1 GHz
	lmk04821_spi_write(0x109, 0x55);	// REG1
//	lmk04821_spi_write(0x10B, 0x02);	// REG2 - bypass clock divider
	lmk04821_spi_write(0x10B, 0x00);	// REG2
//	lmk04821_spi_write(0x10C, 0x22);	// REG3
	lmk04821_spi_write(0x10C, 0x27);	// REG3 - from codeloader register dump
	lmk04821_spi_write(0x10D, 0x00);	// REG4
	lmk04821_spi_write(0x10E, 0xF0);	// REG5 - SYSREF to DAC is powered
	lmk04821_spi_write(0x10F, 0x11);	// REG6 - output drive LCPECL

	// LMK_CONTROL_CLK_4_5
	lmk04821_spi_write(0x110, 0x10);	// REG0 - ADC0 Refclk to FPGA @ 125MHz
	lmk04821_spi_write(0x111, 0x55);	// REG1
	lmk04821_spi_write(0x113, 0x00);	// REG2
//	lmk04821_spi_write(0x114, 0x00);	// REG3 - ADC1 Refclk to FPGA @ 125MHz
	lmk04821_spi_write(0x114, 0x02);	// REG3 - from codeloader register dump
	lmk04821_spi_write(0x115, 0x00);	// REG4
	lmk04821_spi_write(0x116, 0xF1);	// REG5
	lmk04821_spi_write(0x117, 0x11);	// REG6

	// LMK_CONTROL_CLK_6_7
	lmk04821_spi_write(0x118, 0x10);	// REG0 - ADC0 Core clock to FPGA @ 125MHz
	lmk04821_spi_write(0x119, 0x55);	// REG1
	lmk04821_spi_write(0x11B, 0x00);	// REG2
//	lmk04821_spi_write(0x11C, 0x00);	// REG3 - ADC1 Core clock to FPGA @ 125MHz
	lmk04821_spi_write(0x11C, 0x02);	// REG3 - from codeloader register dump
	lmk04821_spi_write(0x11D, 0x00);	// REG4
	lmk04821_spi_write(0x11E, 0xF1);	// REG5
	lmk04821_spi_write(0x11F, 0x11);	// REG6

	// LMK_CONTROL_CLK_8_9
	lmk04821_spi_write(0x120, 0x08);	// REG0 - DAC CORECLK to FPGA
	lmk04821_spi_write(0x121, 0x55);	// REG1
	lmk04821_spi_write(0x123, 0x00);	// REG2
	lmk04821_spi_write(0x124, 0x27);	// REG3 - DAC SYSREF to FPGA
	lmk04821_spi_write(0x125, 0x00);	// REG4
//	lmk04821_spi_write(0x126, 0xF0);	// REG5
	lmk04821_spi_write(0x126, 0xF0);	// REG5 - from codeloader register dump
	lmk04821_spi_write(0x127, 0x11);	// REG6

	// LMK_CONTROL_CLK_10_11
	lmk04821_spi_write(0x128, 0x08);	// REG0 - DAC REFCLK to FPGA
	lmk04821_spi_write(0x129, 0x55);	// REG1
	lmk04821_spi_write(0x12B, 0x00);	// REG2
	lmk04821_spi_write(0x12C, 0x27);	// REG3 - ADC SYSREF to FPGA
	lmk04821_spi_write(0x12D, 0x00);	// REG4
//	lmk04821_spi_write(0x12E, 0xF1);	// REG5
	lmk04821_spi_write(0x12E, 0xF0);	// REG5 - from codeloader register dump
	lmk04821_spi_write(0x12F, 0x11);	// REG6

	// LMK_CONTROL_CLK_12_13
//	lmk04821_spi_write(0x130, 0x10);	// REG0 - ADC0_DCLK to probe @ 125MHz
	lmk04821_spi_write(0x130, 0x01);	// REG0 - ADC0_DCLK @ 2GHz
	lmk04821_spi_write(0x131, 0x55);	// REG1
//	lmk04821_spi_write(0x133, 0x00);	// REG2 - do not bypass DCLK divider
	lmk04821_spi_write(0x133, 0x02);	// REG2 - bypass DCLK divider
	lmk04821_spi_write(0x134, 0x27);	// REG3 - ADC0 SYSREF to device
//	lmk04821_spi_write(0x134, 0x23);	// REG3 - from codeloader register dump
	lmk04821_spi_write(0x135, 0x00);	// REG4
	lmk04821_spi_write(0x136, 0xF0);	// REG5 - SYSREF to ADC0 is powered
	lmk04821_spi_write(0x137, 0x11);	// REG6 - output drive LCPECL


	lmk04821_spi_write(0x138, 0x00);	// LMK_CONTROL_CLK_SOURCE

	//	per setup of SYSREF example on page 37, 38
//	lmk04821_spi_write(0x139, 0x01);	// SYSREF_MUX = 1, re-clocked
//	lmk04821_spi_write(0x140, 0x00);	// SYSREF_PD = 0, SYSREF_DDLY_PD = 0, SYSREF_PLSR_PD = 0
//	lmk04821_spi_write(0x143, 0x91);	// SYNC_POL = 0, SYNC_MODE = 1, SYNC_EN = 1, SYSREF_CLR = 1

	lmk04821_spi_write(0x139, 0x00);	// LMK_CONTROL_SYSREF_MUX
	lmk04821_spi_write(0x13A, 0x00);	// LMK_SYSREF_DIVIDER_MSB
	lmk04821_spi_write(0x13B, 0x80);	// LMK_SYSREF_DIVIDER_LSB - divide by 128, ADCs work with this freq
	lmk04821_spi_write(0x13C, 0x00);	// LMK_SYSREF_DELAY_MSB
	lmk04821_spi_write(0x13D, 0x08);	// LMK_SYSREF_DELAY_LSB
//	lmk04821_spi_write(0x13D, 0x08);	// LMK_SYSREF_DELAY_LSB
//	lmk04821_spi_write(0x13E, 0x03);	// LMK_SYSREF_PULSE_COUNT - 8 pulses
	lmk04821_spi_write(0x13E, 0x00);	// LMK_SYSREF_PULSE_COUNT - 1 pulse
	lmk04821_spi_write(0x13F, 0x00);	// LMK_PLL_FEEDBACK_MUX
//	lmk04821_spi_write(0x140, 0x08);	// LMK_POWERDOWN_OSC_SYSREF
//	lmk04821_spi_write(0x140, 0x0B);	// LMK_POWERDOWN_OSC_SYSREF
	lmk04821_spi_write(0x140, 0x0A);	// codeloader register dump
	lmk04821_spi_write(0x141, 0x00);	// LMK_DELAY_ENABLE_OSC_SYSREF
	lmk04821_spi_write(0x142, 0x00);	// LMK_DELAY_STEP_COUNT
	lmk04821_spi_write(0x143, 0x12);	// codeloader register dump

	//	per setup of SYSREF example on page 37, 38
//	lmk04821_spi_write(0x144, 0x00);	// allow SYNC to effect dividers
//	lmk04821_spi_write(0x143, 0xB1);	// toggle SYNC_POL = 1
//	lmk04821_spi_write(0x143, 0x91);	// toggle SYNC_POL = 0
//	lmk04821_spi_write(0x144, 0xFF);	// prevent SYNC from effecting dividers
//	lmk04821_spi_write(0x143, 0x11);	// SYSREF_CLR = 0
//	lmk04821_spi_write(0x143, 0x12);	// SYNC_MODE = 2
//	lmk04821_spi_write(0x139, 0x02);	// SYSREF_MUX = 2, SYSREF Pulser

//	lmk04821_spi_write(0x142, 0x0B);	// LMK_DELAY_STEP_COUNT
//	lmk04821_spi_write(0x143, 0x32);	// LMK_SYNC_PARAMETERS - from codeloader register dump
//	lmk04821_spi_write(0x143, 0x12);	// LMK_SYNC_PARAMETERS
//	lmk04821_spi_write(0x144, 0xFF);	// LMK_SYNC_DISABLE
//	lmk04821_spi_write(0x144, 0x00);	// LMK_SYNC_DISABLE
	lmk04821_spi_write(0x145, 0x7F);	// LMK_SET_FIXED_VALUE
	lmk04821_spi_write(0x146, 0x18);	// LMK_CLKIN_TYPE
	lmk04821_spi_write(0x147, 0x02);	// LMK_CLKIN_CONTROL
//	lmk04821_spi_write(0x147, 0x1A);	// LMK_CLKIN_CONTROL
	lmk04821_spi_write(0x148, 0x02);	// LMK_CLKIN_SELECT_CONTROL0
	lmk04821_spi_write(0x149, 0x42);	// LMK_CLKIN_SELECT_CONTROL1
	lmk04821_spi_write(0x14A, 0x02);	// LMK_RESET_CONTROL
	lmk04821_spi_write(0x14B, 0x16);	// LMK_HOLDOVER_CONTROL0
	lmk04821_spi_write(0x14C, 0x00);	// LMK_HOLDOVER_CONTROL1
	lmk04821_spi_write(0x14D, 0x00);	// LMK_HOLDOVER_TRIP0
	lmk04821_spi_write(0x14E, 0xC0);	// LMK_HOLDOVER_TRIP1
	lmk04821_spi_write(0x14F, 0x7F);	// LMK_DAC_CLK_COUNTER

	lmk04821_spi_write(0x150, 0x03);	// LMK_HOLDOVER_CONTROL2
	lmk04821_spi_write(0x151, 0x02);	// LMK_HOLDOVER_COUNT_MSB
	lmk04821_spi_write(0x152, 0x00);	// LMK_HOLDOVER_COUNT_LSB
	lmk04821_spi_write(0x153, 0x00);	// LMK_CLKIN0_R_DIV_MSB
	lmk04821_spi_write(0x154, 0x01);	// LMK_CLKIN0_R_DIV_LSB
	lmk04821_spi_write(0x155, 0x00);	// LMK_CLKIN1_R_DIV_MSB
	lmk04821_spi_write(0x156, 0x01);	// LMK_CLKIN1_R_DIV_LSB
	lmk04821_spi_write(0x157, 0x00);	// LMK_CLKIN2_R_DIV_MSB
	lmk04821_spi_write(0x158, 0x96);	// LMK_CLKIN2_R_DIV_LSB
	lmk04821_spi_write(0x159, 0x00);	// LMK_PLL1_N_DIV_MSB
//	lmk04821_spi_write(0x159, 0x00);	// LMK_PLL1_N_DIV_MSB
	lmk04821_spi_write(0x15A, 0x0A);	// LMK_PLL1_N_DIV_LSB
	lmk04821_spi_write(0x15B, 0xD4);	// LMK_PLL1_PHASE_DETECTOR
	lmk04821_spi_write(0x15C, 0x20);	// LMK_PLL1_DELAY_CNT_MSB
	lmk04821_spi_write(0x15D, 0x00);	// LMK_PLL1_DELAY_CNT_LSB
	lmk04821_spi_write(0x15E, 0x00);	// LMK_PLL1_R_N_DELAY_CNT
	lmk04821_spi_write(0x15F, 0x0B);	// LMK_PLL1_STATUS_LD1

	lmk04821_spi_write(0x160, 0x00);	// LMK_PLL2_R_DIV_MSB
//	lmk04821_spi_write(0x160, 0x00);	// LMK_PLL2_R_DIV_MSB
	lmk04821_spi_write(0x161, 0x01);	// LMK_PLL2_R_DIV_LSB
//	lmk04821_spi_write(0x161, 0x01);	// LMK_PLL2_R_DIV_LSB
	lmk04821_spi_write(0x162, 0x44);	// LMK_PLL2_CONTROL
//	lmk04821_spi_write(0x162, 0x44);	// LMK_PLL2_CONTROL
	lmk04821_spi_write(0x163, 0x00);	// LMK_PLL2_N_CAL_HIGH
	lmk04821_spi_write(0x164, 0x00);	// LMK_PLL2_N_CAL_MID
	lmk04821_spi_write(0x165, 0x0A);	// LMK_PLL2_N_CAL_LOW
//	lmk04821_spi_write(0x165, 0x06);	// LMK_PLL2_N_CAL_LOW

	//Program before 0x166 per data sheet
//	lmk04821_spi_write(0x171, 0xAA);	// Per data sheet
//	lmk04821_spi_write(0x172, 0x02);	// Per data sheet
	lmk04821_spi_write(0x174, 0x00);	// LMK_VC01_DIVIDER
	// program these registers before 0x166, 0x167, and 0x168 per data sheet page 49
//	lmk04821_spi_write(0x17C, 0x21);	// LMK_VCO1_PHASE_NOISE_OPT1 - for LMK04821 per data sheet page 91
//	lmk04821_spi_write(0x17D, 0x51);	// LMK_VCO1_PHASE_NOISE_OPT2 - for LMK04821 per data sheet page 92
	lmk04821_spi_write(0x17C, 0x15);	// LMK_VCO1_PHASE_NOISE_OPT1 - for LMK04821
	lmk04821_spi_write(0x17D, 0x33);	// LMK_VCO1_PHASE_NOISE_OPT2 - for LMK04821

	lmk04821_spi_write(0x166, 0x00);	// LMK_PLL2_N_DIV_HIGH
//	lmk04821_spi_write(0x167, 0x0C);	// LMK_PLL2_N_DIV_MID
	lmk04821_spi_write(0x167, 0x00);	// LMK_PLL2_N_DIV_MID
//	lmk04821_spi_write(0x168, 0x35);	// LMK_PLL2_N_DIV_LOW
	lmk04821_spi_write(0x168, 0x0A);	// LMK_PLL2_N_DIV_LOW
	lmk04821_spi_write(0x169, 0x59);	// LMK_PLL2_PHASE_DETECTOR
	lmk04821_spi_write(0x16A, 0x20);	// LMK_PLL2_DELAY_CNT_MSB
	lmk04821_spi_write(0x16B, 0x00);	// LMK_PLL2_DELAY_CNT_LSB
	lmk04821_spi_write(0x16C, 0x00);	// LMK_PLL2_LOOP_FILTER_RES
	lmk04821_spi_write(0x16D, 0x00);	// LMK_PLL2_LOOP_FILTER_CAP
	lmk04821_spi_write(0x16E, 0x13);	// LMK_PLL2_STATUS_LD1

	lmk04821_spi_write(0x173, 0x00);	// LMK_PLL2_POWERDOWN


	lmk04821_spi_read(0x182, &stat1);	// LMK_PLL1_MISC_CONTROL1
	mdelay(30);
	xil_printf("LMK PLL1 (0x%x).\r\n", stat1);
	mdelay(30);

	lmk04821_spi_read(0x183, &stat2);	// LMK_PLL2_MISC_CONTROL1
	mdelay(30);
	xil_printf("LMK PLL2 (0x%x).\r\n", stat2);
	mdelay(30);

	lmk04821_spi_read(0x184, &stat3);	// LMK_CLK_MISC_CONTROL1
	mdelay(30);
	xil_printf("LMK CLK (0x%x).\r\n", stat3);
	mdelay(30);

	lmk04821_spi_read(0x185, &stat4);	// LMK_DAC_READBACK_LSB
	mdelay(30);
	xil_printf("LMK RDBCK (0x%x).\r\n", stat4);
	mdelay(30);

	lmk04821_spi_read(0x188, &stat5);	// LMK_DAC_HOLDOVER
	mdelay(30);
	xil_printf("LMK HLDOVR (0x%x).\r\n", stat5);
	mdelay(30);

	xil_printf("lmk04821 initialize SYSREF generation on SYNC request\r\n");

	//	Sync SYSREF
	lmk04821_spi_write(0x139, 0x01);	// SYSREF_MUX = 1, re-clocked
	lmk04821_spi_write(0x144, 0x80);	// SYNC_DIS0,2,4,6,8,10,12 = 0
//	lmk04821_spi_write(0x144, 0x00);	// SYNC_DIS0,2,4,6,8,10,12 = 0
	lmk04821_spi_write(0x143, 0x32);	// Toggle Sync SYNC_POL = 1
	lmk04821_spi_write(0x143, 0x12);	// SYNC_POL = 0
	lmk04821_spi_write(0x144, 0xFF);	// SYNC_DIS0,2,4,6,8,10,12 = 1
	lmk04821_spi_write(0x139, 0x02);	// SYSREF_MUX = 0, pulser

	lmk04821_spi_read(0x139, &stat6);	// LMK SYSREF mux
	mdelay(30);
	xil_printf("SYSREF MUX ADDR0x139 is (0x%x).\r\n", stat6);
	mdelay(30);

	lmk04821_spi_read(0x143, &stat7);	// LMK SYNC Parameters
	mdelay(30);
	xil_printf("SYNC Parameters ADDR0x143 is (0x%x).\r\n", stat7);
	mdelay(30);

	lmk04821_spi_read(0x16A, &stat8);	// LMK SYNC Parameters
	mdelay(30);
	xil_printf("SYSREF REQ ADDR0x16A is (0x%x).\r\n", stat8);
	mdelay(30);

//	lmk04821_spi_write(0x1FFD, 0x00);	// LMK_SPI_REG_LOCK_HIGH
//	lmk04821_spi_write(0x1FFE, 0x00);	// LMK_SPI_REG_LOCK_MID
//	lmk04821_spi_write(0x1FFF, 0x00);	// LMK_SPI_REG_LOCK_LOW

//	mdelay(20);

//	lmk04821_spi_read(0x281, &pll_stat);
//	xil_printf("lmk04821 PLL/link %s.\n", pll_stat & 0x01 ? "ok" : "errors");

//	mdelay(10);

//	lmk04821_spi_read(0x0e9, &cal_stat);
//	xil_printf("lmk04821 dac-0 calibration %s.\n", (cal_stat & 0xc0) == 0x80 ? "ok" : "failed");

//	lmk04821_spi_read(0x0e9, &cal_stat);
//	xil_printf("lmk04821 dac-1 calibration %s.\n", (cal_stat & 0xc0) == 0x80 ? "ok" : "failed");

	xil_printf("lmk04821 successfully initialized\r\n");
	xil_printf("\r\n");

	return 0;
}
