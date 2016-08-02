/***************************************************************************//**
* @file ad9144.c
* @brief Implementation of AD9144 Driver.
* @author DBogdan (dragos.bogdan@analog.com)
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
/*******************************************************************************
* This file was modified to work with the AD9136
* Analog Devices website doesn't have a driver available for the 9136
* This file was modified by TZ
*******************************************************************************/
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <xil_printf.h>
#include "platform_drivers.h"
#include "ad9136.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
uint8_t ad9136_slave_select;

/***************************************************************************//**
* @brief ad9136_spi_read
*******************************************************************************/
int32_t ad9136_spi_read(uint16_t reg_addr, uint8_t *reg_data)
{
	uint8_t buf[3];
	int32_t ret;

	buf[0] = 0x80 | (reg_addr >> 8);
	buf[1] = reg_addr & 0xFF;
	buf[2] = 0x00;

	ret = spi_write_and_read(ad9136_slave_select, buf, 3);
	*reg_data = buf[2];

	return ret;
}

/***************************************************************************//**
* @brief ad9136_spi_write
*******************************************************************************/
int32_t ad9136_spi_write(uint16_t reg_addr, uint8_t reg_data)
{
	uint8_t buf[3];
	int32_t ret;

	buf[0] = reg_addr >> 8;
	buf[1] = reg_addr & 0xFF;
	buf[2] = reg_data;

	ret = spi_write_and_read(ad9136_slave_select, buf, 3);

	return ret;
}

/***************************************************************************//**
* @brief ad9136_setup
*******************************************************************************/
int32_t ad9136_setup(uint32_t spi_device_id, uint8_t slave_select)
//						ad9136_init_param init_param)
{
	uint8_t rst_stat;
	uint8_t chip_type;
	uint8_t chip_idl;
	uint8_t chip_idh;
	uint8_t chip_grade;
	uint8_t scratch;
	uint8_t dev_id;
	uint8_t bank_id;
	uint8_t lane_id;
//	uint8_t pll_lock;
//	uint8_t kchar_ok;
//	uint8_t fsync_ok;
//	uint8_t chksm_ok;
//	uint8_t ilas_ok;
	uint8_t pll_stat;
	uint8_t pll_value;
	uint8_t pwr_ctrl;
//	uint8_t irq_stat0;
//	uint8_t err_cnt;
	uint8_t cal_stat;
//	uint8_t dc_test;
//	uint8_t value_lsb;
//	uint8_t value_msb;
	uint8_t sync_status;
	uint8_t sync_control;

	ad9136_slave_select = slave_select;
	spi_init(spi_device_id, 0, 0);
	mdelay(30);

	xil_printf("\r\nInitialize ad9136\r\n");

//	ad9136_spi_write(DAC_SPI_INTFCONFA, SOFTRESET_M | SOFTRESET);	// reset
//	mdelay(30);
//	ad9136_spi_write(DAC_SPI_INTFCONFA, 0x00);	// remove reset
//	mdelay(30);
	ad9136_spi_write(0x000, 0xBD);	// soft reset
	mdelay(100);
	ad9136_spi_write(0x000, 0x00);	// de-assert reset
	mdelay(50);
	ad9136_spi_write(0x008, 0x03);	// config both DACs at the same time
	mdelay(50);
	ad9136_spi_read(0x400, &rst_stat);
	xil_printf("\r\nReset Status (0x%x).\r\n", rst_stat);
	mdelay(30);

	ad9136_spi_read(DAC_CHIPTYPE, &chip_type);
	mdelay(30);
	xil_printf("DAC Chip Type (0x%x).\r\n", chip_type);
	mdelay(30);

	ad9136_spi_read(DAC_PRODIDL, &chip_idl);
	mdelay(30);
	xil_printf("DAC PROD ID (0x%x).\r\n", chip_idl);
	mdelay(30);

	ad9136_spi_read(DAC_PRODIDH, &chip_idh);
	mdelay(30);
	xil_printf("DAC PROD ID (0x%x).\r\n", chip_idh);
	mdelay(30);

	ad9136_spi_read(DAC_CHIPGRADE, &chip_grade);
	mdelay(30);
	xil_printf("DAC GRADE (0x%x).\r\n", chip_grade);
	mdelay(30);

	ad9136_spi_write(0x00A, 0xAD);	// scratch pad
	ad9136_spi_read(0x00A, &scratch);
	mdelay(30);
	xil_printf("DAC Scratch Pad (0x%x).\r\n", scratch);
	mdelay(30);

	//	 power-up and DAC initialization

	ad9136_spi_write(0x011, 0x28);	// enable reference, DAC channels, and master DAC
	ad9136_spi_write(0x080, 0x00);	// power-up all clocks
	ad9136_spi_write(0x081, 0x00);	// power-up SYSREF receiver
	mdelay(30);

	ad9136_spi_read(0x080, &pwr_ctrl);
	mdelay(30);
	xil_printf("DAC POWER CONTROL (0x%x).\r\n", pwr_ctrl);
	mdelay(30);

	// required device configurations after any reset or power-up

	ad9136_spi_write(0x12D, 0x8B);	// data-path
	ad9136_spi_write(0x146, 0x01);	// data-path
	ad9136_spi_write(0x2A4, 0xFF);	// clock
	ad9136_spi_write(0x232, 0xFF);	// jesd
	ad9136_spi_write(0x333, 0x01);	// jesd

	// optimal DAC PLL settings per table 78 AD9136 data sheet
	ad9136_spi_write(0x087, 0x62);	// loop filter
	ad9136_spi_write(0x088, 0xC9);	// loop filter
	ad9136_spi_write(0x089, 0x0E);	// loop filter
	ad9136_spi_write(0x08A, 0x12);	// range is 0x01 to 0x3F
	ad9136_spi_write(0x08D, 0x7B);	// LDO
	ad9136_spi_write(0x1B0, 0x00);	// PLL blocks
	ad9136_spi_write(0x1B9, 0x24);	// charge pump
	ad9136_spi_write(0x1BC, 0x0D);	// VCO control
	ad9136_spi_write(0x1BE, 0x02);	// VCO power
	ad9136_spi_write(0x1BF, 0x8E);	// VCO calibration
	ad9136_spi_write(0x1C0, 0x2A);	// PLL lock counter length
	ad9136_spi_write(0x1C1, 0x2A);	// charge pump
	ad9136_spi_write(0x1C4, 0x7E);	// PLL varactor

	// configure DAC PLL for a reference frequency of 166.67MHz

	ad9136_spi_write(0x08B, 0x01);	// LODivFactor - DAC VCO divided by
	ad9136_spi_write(0x08C, 0x04);	// Ref Divide Factor - 1GHz div by 16 = 62.5MHz
//	ad9136_spi_write(0x08C, 0x02);	// Ref Divide Factor - 166.667 MHz div by 4 = 41.667MHz
	ad9136_spi_write(0x085, 0x10);	// BCount - divide by 16 for 62.5 MHz (between 6 to 127)
//	ad9136_spi_write(0x085, 0x18);	// BCount - divide by 24 for 41.667 MHz (between 6 to 127)
	// configured using table 73 in AD9136 or table 25 in AD9144 data sheet
	ad9136_spi_write(0x1B5, 0x09);	// PLL lookup from Rev.A Table 78 or table 25 in AD9144 data sheet
	ad9136_spi_write(0x1BB, 0x13);	// PLL lookup from Rev.A Table 78 or table 25 in AD9144 data sheet
	ad9136_spi_write(0x1C5, 0x06);	// PLL lookup from Rev.A Table 78 or table 25 in AD9144 data sheet

//	ad9136_spi_write(0x083, 0x00);	// disable PLL
	ad9136_spi_write(0x083, 0x10);	// enable PLL
	mdelay(1000);

	ad9136_spi_read(0x084, &pll_value); // check PLL status
	mdelay(30);
	xil_printf("DAC PLL status (0x%x).\r\n", pll_value);
	xil_printf("A DAC PLL is %s\r\n", pll_value & 0x22 ? "locked" : "!!!!! unlocked !!!!!");
	mdelay(30);

	// digital data path

	ad9136_spi_write(0x112, 0x00);	// interpolation (bypass)
	ad9136_spi_write(0x110, 0x00);	// 2's complement

	// transport layer link 0

	ad9136_spi_write(0x200, 0x00);	// phy - power up
	ad9136_spi_write(0x201, 0x00);	// phy - power up all PHYs
	ad9136_spi_write(0x300, 0x00);	// single-link mode 11

	ad9136_spi_read(0x400, &dev_id);
	mdelay(30);
	xil_printf("DAC DEVICE ID (0x%x).\r\n", dev_id);
	mdelay(30);

	ad9136_spi_read(0x401, &bank_id);
	mdelay(30);
	xil_printf("DAC BANK ID (0x%x).\r\n", bank_id);
	mdelay(30);

	ad9136_spi_read(0x402, &lane_id);
	mdelay(30);
	xil_printf("DAC LANE ID (0x%x).\r\n", lane_id);
	mdelay(30);

	ad9136_spi_write(0x450, 0x00);	// device id, read from (0x400)
	ad9136_spi_write(0x451, 0x00);	// bank id, read from (0x401)
	ad9136_spi_write(0x452, 0x00);	// lane id, read from (0x402)

	ad9136_spi_write(0x453, 0x83);	// de-scrambling enabled, 4 lane(s) per converter [L-1]
	ad9136_spi_write(0x454, 0x00);	// 1 octets per frame per lane [F-1]
	ad9136_spi_write(0x455, 0x1f);	// multi-frame - frame count (32) [K-1]
	ad9136_spi_write(0x456, 0x00);	// no-of-converters (1) [M-1]
	ad9136_spi_write(0x457, 0x0f);	// no CS bits, 16bit dac
	ad9136_spi_write(0x458, 0x2f);	// subclass 1, 16bits per sample
	ad9136_spi_write(0x459, 0x21);	// jesd204b, 2 sample(s) per converter per device
	ad9136_spi_write(0x45a, 0x80);	// HD mode, no CS bits
	ad9136_spi_write(0x45d, 0x00);	// check-sum of 0x450 to 0x45c
//	ad9136_spi_write(0x45d, 0x45);	// check-sum of 0x450 to 0x45c
	ad9136_spi_write(0x46c, 0xFF);	// enable deskew for lane(s) 7 down to 0
	ad9136_spi_write(0x476, 0x01);	// frame - bytecount (1)
	ad9136_spi_write(0x47d, 0xFF);	// enable lane(s) 7 down to 0

	// transport layer link 1

//	ad9136_spi_write(0x300, 0x0C);	// dual-link
//
//	ad9136_spi_read(0x400, &dev_id);
//	mdelay(30);
//	xil_printf("DAC DEVICE ID (0x%x).\r\n", dev_id);
//	mdelay(30);
//
//	ad9136_spi_read(0x401, &bank_id);
//	mdelay(30);
//	xil_printf("DAC BANK ID (0x%x).\r\n", bank_id);
//	mdelay(30);
//
//	ad9136_spi_read(0x402, &lane_id);
//	mdelay(30);
//	xil_printf("DAC LANE ID (0x%x).\r\n", lane_id);
//	mdelay(30);
//
//	ad9136_spi_write(0x450, 0x00);	// device id, read from (0x400)
//	ad9136_spi_write(0x451, 0x00);	// bank id, read from (0x401)
//	ad9136_spi_write(0x452, 0x00);	// lane id, read from (0x402)
//
//	ad9136_spi_write(0x453, 0x03);	// no descrambling, 4 lane(s) per converter [L-1]
//	ad9136_spi_write(0x454, 0x00);	// 1 octets per frame per lane [F-1]
//	ad9136_spi_write(0x455, 0x1f);	// multi-frame - frame count (32) [K-1]
//	ad9136_spi_write(0x456, 0x00);	// no-of-converters (1) [M-1]
//	ad9136_spi_write(0x457, 0x0f);	// no CS bits, 16bit dac
//	ad9136_spi_write(0x458, 0x0f);	// subclass 0, 16bits per sample
//	ad9136_spi_write(0x459, 0x21);	// jesd204b, 2 sample(s) per converter per device
//	ad9136_spi_write(0x45a, 0x80);	// HD mode, no CS bits
//	ad9136_spi_write(0x45d, 0x00);	// check-sum of 0x450 to 0x45c
////	ad9136_spi_write(0x45d, 0x45);	// check-sum of 0x450 to 0x45c
//	ad9136_spi_write(0x46c, 0x0F);	// enable deskew for lane(s) 7 down to 0
//	ad9136_spi_write(0x476, 0x01);	// frame - bytecount (1)
//	ad9136_spi_write(0x47d, 0x0F);	// enable lane(s) 7 down to 0

	// physical layer

	ad9136_spi_write(0x2AA, 0xb7);	// jesd termination
	ad9136_spi_write(0x2AB, 0x87);	// jesd termination
	ad9136_spi_write(0x2B1, 0xb7);	// jesd termination
	ad9136_spi_write(0x2B2, 0x87);	// jesd termination
	ad9136_spi_write(0x2A7, 0x01);	// input termination calibration
	ad9136_spi_write(0x2AE, 0x01);	// input termination calibration
	ad9136_spi_write(0x314, 0x01);	// pclk == qbd master clock
	ad9136_spi_write(0x230, 0x28);	// cdr mode - halfrate, no division
	ad9136_spi_write(0x206, 0x00);	// cdr reset
	ad9136_spi_write(0x206, 0x01);	// cdr reset
	ad9136_spi_write(0x289, 0x04);	// data-rate == 10Gbps
	ad9136_spi_write(0x284, 0x62);	// loop filter
	ad9136_spi_write(0x285, 0xC9);	// loop filter
	ad9136_spi_write(0x286, 0x0E);	// loop filter
	ad9136_spi_write(0x287, 0x12);	// charge pump
	ad9136_spi_write(0x28A, 0x7B);	// VCO LDO
//	ad9136_spi_write(0x28A, 0x12);	// VCO LDO was configured with
	ad9136_spi_write(0x28B, 0x00);	// config
	ad9136_spi_write(0x290, 0x89);	// VCO varactor
//	ad9136_spi_write(0x290, 0x00);	// VCO varactor was configured with
//	ad9136_spi_write(0x291, 0x49);	// serdes-pll
	ad9136_spi_write(0x294, 0x24);	// charge pump
	ad9136_spi_write(0x296, 0x03);	// VCO
	ad9136_spi_write(0x297, 0x0D);	// VCO
	ad9136_spi_write(0x299, 0x02);	// config
	ad9136_spi_write(0x29A, 0x8E);	// VCO varactor
	ad9136_spi_write(0x29C, 0x2A);	// charge pump
	ad9136_spi_write(0x29F, 0x78);	// VCO varactor
	ad9136_spi_write(0x2A0, 0x06);	// VCO varactor

	ad9136_spi_write(0x280, 0x01);	// enable serdes pll
//	ad9136_spi_write(0x280, 0x05);	// enable serdes calibration
	mdelay(1000);
	ad9136_spi_read(0x281, &pll_stat);
	mdelay(30);
	xil_printf("DAC SERDES PLL Status (0x%x).\r\n", pll_stat);
	mdelay(30);
	ad9136_spi_write(0x268, 0x62);	// equalizer
	mdelay(100);

	// cross-bar

	// ad9136_spi_write(REG_XBAR_LN_0_1, SRC_LANE0(init_param.jesd_xbar_lane0_sel) |
		// SRC_LANE1(init_param.jesd_xbar_lane1_sel));	// lane selects
	// ad9136_spi_write(REG_XBAR_LN_2_3, SRC_LANE2(init_param.jesd_xbar_lane2_sel) |
		// SRC_LANE3(init_param.jesd_xbar_lane3_sel));	// lane selects

	// data link layer

//	ad9136_spi_write(0x008, 0x01);	// set page to DAC0
//	mdelay(50);
	ad9136_spi_write(0x301, 0x01);	// enable subclass-1 for now
	ad9136_spi_write(0x304, 0x00);	// lmfc delay
	ad9136_spi_write(0x305, 0x00);	// lmfc delay
	ad9136_spi_write(0x306, 0x0A);	// receive buffer delay was 0xA
	ad9136_spi_write(0x307, 0x0A);	// receive buffer delay was 0xA
//	ad9136_spi_write(0x03a, 0x02);	// sync- continuous mode
//	ad9136_spi_write(0x03a, 0x82);	// sync-enable
	ad9136_spi_write(0x03a, 0x01);	// sync-one shot
	mdelay(100);
	ad9136_spi_write(0x03a, 0x81);	// sync-enable machine
	mdelay(100);
	ad9136_spi_write(0x03a, 0xc1);	// sync-arm machine
	mdelay(100);
	xil_printf(" \r\n ad9136 Arm SYNC Machine\r\n");
//	ad9136_spi_write(0x300, 0x01);	// enable link

	xil_printf(" \r\nBegin ad9136 DAC0 SYNC Status\r\n");

	ad9136_spi_write(0x008, 0x01);	// read DAC0
	mdelay(50);
	ad9136_spi_read(0x034, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Error Window (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x038, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Last Error L (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x039, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Last Error H (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Status before (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03C, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Align Error (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03D, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Under/Over Error (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03A, &sync_control);
	mdelay(30);
	xil_printf("DAC LMFC Sync Control (0x%x).\r\n", sync_control);
	mdelay(30);

	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Status after (0x%x).\r\n", sync_status);

	xil_printf(" \r\nEnd ad9136 DAC0 Register Status\r\n");

	// data link layer - program DAC1 separately

//	ad9136_spi_write(0x008, 0x02);	// set page to DAC1
//	mdelay(50);
//	ad9136_spi_write(0x301, 0x01);	// enable subclass-1 for now
//	ad9136_spi_write(0x304, 0x00);	// lmfc delay
//	ad9136_spi_write(0x305, 0x00);	// lmfc delay
//	ad9136_spi_write(0x306, 0x0A);	// receive buffer delay was 0xA
//	ad9136_spi_write(0x307, 0x0A);	// receive buffer delay was 0xA
////	ad9136_spi_write(0x03a, 0x02);	// sync- continuous mode
////	ad9136_spi_write(0x03a, 0x82);	// sync-enable
//	ad9136_spi_write(0x03a, 0x01);	// sync-one shot
//	mdelay(100);
//	ad9136_spi_write(0x03a, 0x81);	// sync-enable machine
//	mdelay(100);
//	ad9136_spi_write(0x03a, 0xc1);	// sync-arm machine
//	mdelay(100);
//	xil_printf(" \r\n ad9136 Arm SYNC Machine\r\n");
////	ad9136_spi_write(0x300, 0x01);	// enable link
//
//	xil_printf(" \r\nBegin ad9136 DAC1 SYNC Status\r\n");
//
//	ad9136_spi_write(0x008, 0x02);	// read DAC1
//	mdelay(50);
//	ad9136_spi_read(0x034, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Error Window (0x%x).\r\n", sync_status);
//
//	mdelay(30);
//	ad9136_spi_read(0x038, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Last Error L (0x%x).\r\n", sync_status);
//
//	mdelay(30);
//	ad9136_spi_read(0x039, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Last Error H (0x%x).\r\n", sync_status);
//
//	mdelay(30);
//	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Status before (0x%x).\r\n", sync_status);
//
//	mdelay(30);
//	ad9136_spi_read(0x03C, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Align Error (0x%x).\r\n", sync_status);
//
//	mdelay(30);
//	ad9136_spi_read(0x03D, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Under/Over Error (0x%x).\r\n", sync_status);
//
//	mdelay(30);
//	ad9136_spi_read(0x03A, &sync_control);
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Control (0x%x).\r\n", sync_control);
//	mdelay(30);
//
//	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
//	mdelay(30);
//	xil_printf("DAC LMFC Sync Status after (0x%x).\r\n", sync_status);
//
//	xil_printf(" \r\nEnd ad9136 DAC1 Register Status\r\n");

//
//	// error monitoring
//
//	mdelay(1000);
//	ad9136_spi_read(0x470, &kchar_ok);
//	mdelay(30);
//	xil_printf("K28.5 OK (0x%x).\r\n", kchar_ok);
//	mdelay(20);
//	ad9136_spi_read(0x471, &fsync_ok);
//	mdelay(30);
//	xil_printf("FSYNC OK (0x%x).\r\n", fsync_ok);
//	mdelay(20);
//	ad9136_spi_read(0x472, &chksm_ok);
//	mdelay(30);
//	xil_printf("CHECKSUM OK (0x%x).\r\n", chksm_ok);
//	mdelay(20);
//	ad9136_spi_read(0x473, &ilas_ok);
//	mdelay(30);
//	xil_printf("ILAS OK (0x%x).\r\n", ilas_ok);
//
//	ad9136_spi_read(0x084, &pll_lock);
//	mdelay(30);
//	xil_printf("DAC PLL LOCK (0x%x).\r\n", pll_lock);
//	mdelay(30);
//
//	ad9136_spi_read(0x023, &irq_stat0);
//	mdelay(30);
//	xil_printf("DAC IRQ Status0 (0x%x).\r\n", irq_stat0);
//	mdelay(30);
//
//	ad9136_spi_write(0x46B, 0x40);	// subclass-1
//	ad9136_spi_read(0x46B, &err_cnt);
//	mdelay(30);
//	xil_printf("DAC Disparity (0x%x).\r\n", err_cnt);
//	mdelay(30);
//
//	ad9136_spi_write(0x46B, 0x41);	// subclass-1
//	ad9136_spi_read(0x46B, &err_cnt);
//	mdelay(30);
//	xil_printf("DAC Table Error (0x%x).\r\n", err_cnt);
//	mdelay(30);
//
//	ad9136_spi_write(0x46B, 0x42);	// subclass-1
//	ad9136_spi_read(0x46B, &err_cnt);
//	mdelay(30);
//	xil_printf("DAC Char Error (0x%x).\r\n", err_cnt);
//	mdelay(30);
//
//	ad9136_spi_read(0x46D, &err_cnt);
//	mdelay(30);
//	xil_printf("DAC Bad Dis (0x%x).\r\n", err_cnt);
//	mdelay(30);

	// dac calibration

//	ad9136_spi_write(0x0e7, 0x38);	// set calibration clock to 1m
//	ad9136_spi_write(0x0ed, 0xa6);	// use isb reference of 38 to set cal
//	ad9136_spi_write(0x0e8, 0x05);	// cal 2 dacs at once
//	ad9136_spi_write(0x0e9, 0x01);	// single cal enable
//	ad9136_spi_write(0x0e9, 0x03);	// single cal start
//	mdelay(10);
//
//	ad9136_spi_write(0x0e8, 0x01);	// read dac-0
//	ad9136_spi_read(0x0e9, &cal_stat);
//	xil_printf("ad9136 dac-0 calibration %s.\r\n", (cal_stat & 0xc0) == 0x80 ? "ok" : "failed");
//
//	ad9136_spi_write(0x0e8, 0x04);	// read dac-1
//	ad9136_spi_read(0x0e9, &cal_stat);
//	xil_printf("ad9136 dac-1 calibration %s.\r\n", (cal_stat & 0xc0) == 0x80 ? "ok" : "failed");
//
//	ad9136_spi_write(0x0e7, 0x30);	// turn off cal clock

	// DC test value
//	ad9136_spi_write(0x520, 0x1E);	// set DC value
//	ad9136_spi_read(0x520, &dc_test);
//	mdelay(30);
//	xil_printf("DC TEST (0x%x).\r\n", dc_test);
//	mdelay(20);
//	ad9136_spi_write(0x521, 0xFF);	// set DC value
//	ad9136_spi_read(0x521, &value_lsb);
//	mdelay(30);
//	xil_printf("DC VALUE (0x%x).\r\n", value_lsb);
//	mdelay(20);
//	ad9136_spi_write(0x522, 0xFF);	// set DC value
//	ad9136_spi_read(0x522, &value_msb);
//	mdelay(30);
//	xil_printf("DC VALUE (0x%x).\r\n", value_msb);

//	xil_printf("ad9136 successfully initialized.\r\n");

	return 0;
}

/***************************************************************************//**
* @brief ad9136_setup
*******************************************************************************/
int32_t ad9136_serdes_status(uint32_t spi_device_id, uint8_t slave_select)
//						ad9136_init_param init_param)
{
	uint8_t pll_lock;
	uint8_t kchar_ok;
	uint8_t fsync_ok;
	uint8_t chksm_ok;
	uint8_t ilas_ok;
	uint8_t pll_stat;
	uint8_t irq_stat0;
	uint8_t err_cnt;
	uint8_t sync_status;
	uint8_t sync_control;
//	uint8_t cal_stat;
//	uint8_t dc_test;
//	uint8_t value_lsb;
//	uint8_t value_msb;

	ad9136_slave_select = slave_select;
	spi_init(spi_device_id, 0, 0);
	mdelay(30);

	// error monitoring

	mdelay(30);
	ad9136_spi_read(0x281, &pll_stat);
	mdelay(30);
	xil_printf("\r\nDAC SERDES PLL Status (0x%x).\r\n", pll_stat);
//	mdelay(30);
//	ad9136_spi_write(0x268, 0x62);	// equalizer
	mdelay(30);
	ad9136_spi_read(0x470, &kchar_ok);
	mdelay(30);
	xil_printf("K28.5 OK (0x%x).\r\n", kchar_ok);
	mdelay(20);
	ad9136_spi_read(0x471, &fsync_ok);
	mdelay(30);
	xil_printf("FSYNC OK (0x%x).\r\n", fsync_ok);
	mdelay(20);
	ad9136_spi_read(0x472, &chksm_ok);
	mdelay(30);
	xil_printf("CHECKSUM OK (0x%x).\r\n", chksm_ok);
	mdelay(20);
	ad9136_spi_read(0x473, &ilas_ok);
	mdelay(30);
	xil_printf("ILAS OK (0x%x).\r\n", ilas_ok);

	ad9136_spi_read(0x084, &pll_lock);
	mdelay(30);
	xil_printf("DAC PLL LOCK (0x%x).\r\n", pll_lock);
	mdelay(30);
	xil_printf("A DAC PLL is %s\r\n", pll_lock & 0x22 ? "locked" : "!!!!! unlocked !!!!!");

	ad9136_spi_read(0x023, &irq_stat0);
	mdelay(30);
	xil_printf("DAC IRQ Status0 (0x%x).\r\n", irq_stat0);
	mdelay(30);
	xil_printf("A DAC PLL is %s\r\n", irq_stat0 & 0x14 ? "locked" : "!!!!! unlocked !!!!!");

//	ad9136_spi_write(0x46B, 0x40);	//
	ad9136_spi_read(0x46D, &err_cnt);
	mdelay(30);
	xil_printf("DAC Disparity (0x%x).\r\n", err_cnt);
	mdelay(30);

//	ad9136_spi_write(0x46B, 0x41);	//
	ad9136_spi_read(0x46E, &err_cnt);
	mdelay(30);
	xil_printf("DAC Table Error (0x%x).\r\n", err_cnt);
	mdelay(30);

//	ad9136_spi_write(0x46B, 0x42);	//
	ad9136_spi_read(0x46F, &err_cnt);
	mdelay(30);
	xil_printf("DAC Char Error (0x%x).\r\n", err_cnt);
	mdelay(30);

	ad9136_spi_read(0x47A, &err_cnt);
	mdelay(30);
	xil_printf("DAC Error Flag (0x%x).\r\n", err_cnt);
	mdelay(30);

	ad9136_spi_read(0x025, &irq_stat0);
	mdelay(30);
	xil_printf("DAC IRQ Status2 (0x%x).\r\n", irq_stat0);
	mdelay(30);

	ad9136_spi_read(0x026, &irq_stat0);
	mdelay(30);
	xil_printf("DAC IRQ Status2 (0x%x).\r\n", irq_stat0);
	mdelay(30);

//	xil_printf("\r\nad9136 Disable Link \r\n");
//
//	ad9136_spi_write(0x300, 0x00);	// disable link

	ad9136_spi_write(0x008, 0x01);	// set page to DAC0
	mdelay(50);

	xil_printf(" \r\nBegin ad9136 DAC0 SYNC Status\r\n");

	mdelay(30);
	ad9136_spi_read(0x034, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Error Window (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x038, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Last Error L (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x039, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Last Error H (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03C, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Align Error (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03D, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Under/Over Error (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03A, &sync_control);
	mdelay(30);
	xil_printf("DAC LMFC Sync Control (0x%x).\r\n", sync_control);
	mdelay(30);

	mdelay(30);
	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Status before (0x%x).\r\n", sync_status);

	ad9136_spi_write(0x03a, 0x01);	// sync-one shot
	mdelay(100);
	ad9136_spi_write(0x03a, 0x81);	// sync-enable machine
	mdelay(100);
	ad9136_spi_write(0x03a, 0xc1);	// sync-arm machine
	mdelay(100);

	ad9136_spi_read(0x03A, &sync_control);
	mdelay(30);
	xil_printf("DAC LMFC Sync Control (0x%x).\r\n", sync_control);
	mdelay(30);

	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Status after (0x%x).\r\n", sync_status);

	ad9136_spi_write(0x008, 0x02);	// set page to DAC1
	mdelay(50);

	xil_printf(" \r\nBegin ad9136 DAC1 SYNC Status\r\n");

	mdelay(30);
	ad9136_spi_read(0x034, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Error Window (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x038, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Last Error L (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x039, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Last Error H (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03C, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Align Error (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03D, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Under/Over Error (0x%x).\r\n", sync_status);

	mdelay(30);
	ad9136_spi_read(0x03A, &sync_control);
	mdelay(30);
	xil_printf("DAC LMFC Sync Control (0x%x).\r\n", sync_control);
	mdelay(30);

	mdelay(30);
	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Status before (0x%x).\r\n", sync_status);

	ad9136_spi_write(0x03a, 0x01);	// sync-one shot
	mdelay(100);
	ad9136_spi_write(0x03a, 0x81);	// sync-enable machine
	mdelay(100);
	ad9136_spi_write(0x03a, 0xc1);	// sync-arm machine
	mdelay(100);

	mdelay(30);
	ad9136_spi_read(0x03A, &sync_control);
	mdelay(30);
	xil_printf("DAC LMFC Sync Control (0x%x).\r\n", sync_control);
	mdelay(30);

	ad9136_spi_read(0x03B, &sync_status);	// SYNC status
	mdelay(30);
	xil_printf("DAC LMFC Sync Status after (0x%x).\r\n", sync_status);

	xil_printf(" \r\nEnd ad9136 Register Status\r\n");

	return 0;
}


/***************************************************************************//**
* @brief ad9136_setup
*******************************************************************************/
int32_t ad9136_link_enable(uint32_t spi_device_id, uint8_t slave_select)
//						ad9136_init_param init_param)
{
	uint8_t pll_lock;
	uint8_t kchar_ok;
	uint8_t fsync_ok;
	uint8_t chksm_ok;
	uint8_t ilas_ok;
	uint8_t irq_stat0;
	uint8_t err_cnt;
//	uint8_t cal_stat;
//	uint8_t dc_test;
//	uint8_t value_lsb;
//	uint8_t value_msb;

	ad9136_slave_select = slave_select;
	spi_init(spi_device_id, 0, 0);
	mdelay(30);

	xil_printf("\r\nad9136 Enable Link \r\n");

	ad9136_spi_write(0x300, 0x01);	// enable link

	// error monitoring

	mdelay(1000);
	ad9136_spi_read(0x470, &kchar_ok);
	mdelay(30);
	xil_printf("K28.5 OK (0x%x).\r\n", kchar_ok);
	mdelay(20);
	ad9136_spi_read(0x471, &fsync_ok);
	mdelay(30);
	xil_printf("FSYNC OK (0x%x).\r\n", fsync_ok);
	mdelay(20);
	ad9136_spi_read(0x472, &chksm_ok);
	mdelay(30);
	xil_printf("CHECKSUM OK (0x%x).\r\n", chksm_ok);
	mdelay(20);
	ad9136_spi_read(0x473, &ilas_ok);
	mdelay(30);
	xil_printf("ILAS OK (0x%x).\r\n", ilas_ok);

	ad9136_spi_read(0x084, &pll_lock);
	mdelay(30);
	xil_printf("DAC PLL LOCK (0x%x).\r\n", pll_lock);
	mdelay(30);
	xil_printf("A DAC PLL is %s\r\n", pll_lock & 0x22 ? "locked" : "!!!!! unlocked !!!!!");

	ad9136_spi_read(0x023, &irq_stat0);
	mdelay(30);
	xil_printf("DAC IRQ Status0 (0x%x).\r\n", irq_stat0);
	mdelay(30);
	xil_printf("A DAC PLL is %s\r\n", irq_stat0 & 0x14 ? "locked" : "!!!!! unlocked !!!!!");

	ad9136_spi_write(0x46B, 0x40);	// subclass-1
	ad9136_spi_read(0x46B, &err_cnt);
	mdelay(30);
	xil_printf("DAC Disparity (0x%x).\r\n", err_cnt);
	mdelay(30);

	ad9136_spi_write(0x46B, 0x41);	// subclass-1
	ad9136_spi_read(0x46B, &err_cnt);
	mdelay(30);
	xil_printf("DAC Table Error (0x%x).\r\n", err_cnt);
	mdelay(30);

	ad9136_spi_write(0x46B, 0x42);	// subclass-1
	ad9136_spi_read(0x46B, &err_cnt);
	mdelay(30);
	xil_printf("DAC Char Error (0x%x).\r\n", err_cnt);
	mdelay(30);

	ad9136_spi_read(0x46D, &err_cnt);
	mdelay(30);
	xil_printf("DAC Bad Dis (0x%x).\r\n", err_cnt);
	mdelay(30);

	xil_printf("\r\nad9136 Link Enabled\r\n");

	return 0;
}
