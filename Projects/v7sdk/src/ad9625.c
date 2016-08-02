/***************************************************************************//**
* @file ad9625.c
* @brief Implementation of AD9625 Driver.
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

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
#include <xil_printf.h>
#include "platform_drivers.h"
#include "ad9625.h"

/******************************************************************************/
/************************ Variables Definitions *******************************/
/******************************************************************************/
uint8_t ad9625_slave_select;

/***************************************************************************//**
* @brief ad9625_spi_read
*******************************************************************************/
int32_t ad9625_spi_read(uint16_t reg_addr, uint8_t *reg_data)
{
	uint8_t buf[3];
	int32_t ret;

	buf[0] = 0x80 | (reg_addr >> 8);
	buf[1] = reg_addr & 0xFF;
	buf[2] = 0x00;

	ret = spi_write_and_read(ad9625_slave_select, buf, 3);
	*reg_data = buf[2];

	return ret;
}

/***************************************************************************//**
* @brief ad9625_spi_write
*******************************************************************************/
int32_t ad9625_spi_write(uint16_t reg_addr, uint8_t reg_data)
{
	uint8_t buf[3];
	int32_t ret;

	buf[0] = reg_addr >> 8;
	buf[1] = reg_addr & 0xFF;
	buf[2] = reg_data;

	ret = spi_write_and_read(ad9625_slave_select, buf, 3);

	return ret;
}

/***************************************************************************//**
* @brief ad9625_enter_cal_mode
*******************************************************************************/
int32_t ad9625_enter_ramp_mode(uint32_t spi_device_id, uint8_t slave_select)
{
    ad9625_slave_select = slave_select;
    spi_init(spi_device_id, 0, 0);
    ad9625_spi_write(0x00D, 0x2F); // test ramp output, for calibrating
    ad9625_spi_write(0x0FF, 0x01); // transfer register values
    mdelay(500);
    xil_printf("AD9625 set to output test ramp!\r\n");
    return 0;
}

/***************************************************************************//**
* @brief ad9625_exit_cal_mode
*******************************************************************************/
int32_t ad9625_exit_ramp_mode(uint32_t spi_device_id, uint8_t slave_select)
{
    ad9625_slave_select = slave_select;
    spi_init(spi_device_id, 0, 0);
    ad9625_spi_write(0x00D, 0x00); // turn off debugging output
    ad9625_spi_write(0x0FF, 0x01); // transfer register values
    mdelay(500);
    xil_printf("Turned off AD9625 debug output!\r\n");
    return 0;
}

/***************************************************************************//**
* @brief ad9625_setup
*******************************************************************************/
int32_t ad9625_setup(uint32_t spi_device_id, uint8_t slave_select)
{
	uint8_t chip_conf;
	uint8_t chip_id;
	uint8_t chip_grade;
	uint8_t chip_pm;
	uint8_t chip_irq;
//	commented out for testing
	uint8_t pll_stat;
	uint8_t current_status;

	ad9625_slave_select = slave_select;
	spi_init(spi_device_id, 0, 0);

//	ad9625_spi_write(AD9625_REG_CHIP_PORT_CONF, 0x24);
//	ad9625_spi_write(AD9625_REG_TRANSFER, 0x01);
//	mdelay(10);

//	ad9625_spi_write(AD9625_REG_POWER_MODE, 0x00);
//	ad9625_spi_write(AD9625_REG_TRANSFER, 0x01);
//	ad9625_spi_write(AD9625_REG_JESD204B_LINK_CNTRL_1, 0x15);
//	ad9625_spi_write(AD9625_REG_JESD204B_LANE_POWER_MODE, 0x00);
//	ad9625_spi_write(AD9625_REG_DIVCLK_OUT_CNTRL, 0x11);
//	ad9625_spi_write(AD9625_REG_TEST_CNTRL, 0x00);
//	ad9625_spi_write(AD9625_REG_OUTPUT_MODE, 0x00);
//	ad9625_spi_write(AD9625_REG_OUTPUT_ADJUST, 0x10);
//	ad9625_spi_write(AD9625_REG_JESD204B_LINK_CNTRL_1, 0x14);

	ad9625_spi_write(0x000, 0x3C); // soft reset - per page 71
//	ad9625_spi_write(0x000, 0x24); // soft reset
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 soft reset\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_write(0x008, 0x82); // digital data path standby mode
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 dig-data-path standby\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_write(0x008, 0x80); // digital data path normal mode
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 dig-data-path normal\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_write(0x008, 0x83); // digital data-path reset mode
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 dig-data-path reset\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_write(0x008, 0x80); // digital data path normal mode
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 dig-data-path normal\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_write(0x05F, 0x15); // link control register 1, shutdown jesd links
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 shutdown links \r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

// user test pattern registers
//	ad9625_spi_write(0x019, 0x11); // register1 LSB test pattern
//	ad9625_spi_write(0x01A, 0x11); // register1 MSB test pattern
//	ad9625_spi_write(0x01B, 0x22); // register2 LSB test pattern
//	ad9625_spi_write(0x01C, 0x22); // register2 MSB test pattern
//	ad9625_spi_write(0x01D, 0x33); // register3 LSB test pattern
//	ad9625_spi_write(0x01E, 0x33); // register3 MSB test pattern
//	ad9625_spi_write(0x01F, 0x44); // register1 LSB test pattern
//	ad9625_spi_write(0x020, 0x44); // register1 MSB test pattern
//	ad9625_spi_write(0x00D, 0x2F); // test ramp output, for debugging
//	ad9625_spi_write(0x0FF, 0x01); // transfer register values
//	mdelay(500);

//	ad9625_spi_write(0x05e, 0x08); // quick configuration
//	ad9625_spi_write(0x0FF, 0x01); // transfer register values
//	mdelay(1000);
	ad9625_spi_write(0x080, 0x00); // lane power mode, power up 8 lanes
	ad9625_spi_write(0x120, 0x00); // DIVCLK clock, disabled for now
	ad9625_spi_write(0x121, 0x11); // Trim Control, set to 2.0GSPS
//	ad9625_spi_write(0x00D, 0x00); // normal operation
//	ad9625_spi_write(0x014, 0x00); // offset binary
	ad9625_spi_write(0x014, 0x01); // 2's complement
	ad9625_spi_write(0x015, 0x10); // serial output adjust
//	ad9625_spi_write(0x03A, 0x40); // SYSREF control register - reset flag
	ad9625_spi_write(0x063, 0x00); // JESD configuration register - generic, is the default
	ad9625_spi_write(0x06E, 0x87); // JESD configuration register - scrambling on, 8 lanes, is default
//	ad9625_spi_write(0x06E, 0x07); // JESD configuration register - scrambling off
	ad9625_spi_write(0x072, 0x8B); // JESD configuration register - over-range and time-stamp + 12-bit resolution
//	ad9625_spi_write(0x073, 0x2F); // JESD configuration register - default subclass 1
//	ad9625_spi_write(0x073, 0x0F); // JESD configuration register - subclass 0 for now
//	ad9625_spi_write(0x008, 0x00); // normal mode, digital data path clock enabled
//	ad9625_spi_write(0x061, 0x07); // JESD link control - ramp output
//	ad9625_spi_write(0x03A, 0x86); // SYSREF control register - enable, rising edge, next valid edge, status on LSB
	ad9625_spi_write(0x03A, 0x06); // SYSREF control register - enable, rising edge, next valid edge
//	ad9625_spi_write(0x03A, 0x02); // SYSREF control register - enable, rising edge, continuous
//	ad9625_spi_write(0x03A, 0x0A); // SYSREF control register - enable, falling edge, continuous
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 configure JESD\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_write(0x05F, 0x14); // link control register 1, enable jesd links
//	ad9625_spi_write(0x008, 0x80); // normal mode
	ad9625_spi_write(0x0FF, 0x01); // transfer register values

	xil_printf("\r\nAD9625 enable JESD links\r\n");

	ad9625_spi_read(0x100, &current_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", current_status);
	mdelay(10);

	ad9625_spi_read(AD9625_REG_CHIP_PORT_CONF, &chip_conf);
	mdelay(30);
	xil_printf("ADC Chip Config (0x%x).\r\n", chip_conf);
	mdelay(30);

	ad9625_spi_read(AD9625_REG_CHIP_ID, &chip_id);
	mdelay(30);
	xil_printf("ADC Chip ID (0x%x)\r\n", chip_id);
	mdelay(30);

	ad9625_spi_read(AD9625_REG_CHIP_GRADE, &chip_grade);
	mdelay(30);
	xil_printf("ADC Chip Grade (0x%x)\r\n", chip_grade);
	mdelay(30);

	ad9625_spi_read(AD9625_REG_POWER_MODE, &chip_pm);
	mdelay(30);
	xil_printf("ADC PWR MODE (0x%x)\r\n", chip_pm);
	mdelay(30);

	ad9625_spi_read(AD9625_REG_IRQ_MASK_CONTROL, &chip_irq);
	mdelay(30);
	xil_printf("ADC IRQ MSK CTRL (0x%x)\r\n", chip_irq);
	mdelay(30);


	ad9625_spi_read(AD9625_REG_CHIP_ID, &chip_id);
//	commented out for testing
	if(chip_id != AD9625_CHIP_ID)
	{
		xil_printf("Error: Invalid CHIP ID (0x%x)\r\n", chip_id);
		return -1;
	}

	ad9625_spi_read(AD9625_REG_PLL_STATUS, &pll_stat);
	xil_printf("AD9625 PLL is %s\r\n", pll_stat & 0x80 ? "locked" : "unlocked");

	xil_printf("\r\nAD9625 initialized\r\n");

	return 0;
}

/***************************************************************************//**
* @brief ad9625_status
*******************************************************************************/
int32_t ad9625_status(uint32_t spi_device_id, uint8_t slave_select)
{
	uint8_t chip_status;

	ad9625_slave_select = slave_select;
	spi_init(spi_device_id, 0, 0);

	ad9625_spi_read(0x100, &chip_status);
	mdelay(10);
	xil_printf("\r\nADC IRQ Status before (0x%x).\r\n", chip_status);
	mdelay(10);

	ad9625_spi_read(0x03A, &chip_status);
	mdelay(10);
	xil_printf("ADC SYSREF Control before (0x%x).\r\n", chip_status);
	mdelay(10);

	ad9625_spi_write(0x03A, 0x46); // SYSREF control register - reset flags
//	ad9625_spi_write(0x03A, 0x4A); // SYSREF control register - reset flags
	ad9625_spi_write(0x0FF, 0x01); // transfer register values
	mdelay(10);

//	ad9625_spi_write(0x03A, 0x0E); // SYSREF control register - enable, falling edge, next valid edge
//	ad9625_spi_write(0x03A, 0x86); // SYSREF control register - enable, rising edge, next valid edge, status on LSB
	ad9625_spi_write(0x03A, 0x06); // SYSREF control register - enable, rising edge, next valid edge
//	ad9625_spi_write(0x03A, 0x02); // SYSREF control register - enable, rising edge, continuous
//	ad9625_spi_write(0x03A, 0x0A); // SYSREF control register - enabled, falling edge, continuous mode
//	ad9625_spi_write(0x13B, 0x00); // SYSREF increase guard-band hold time
//	ad9625_spi_write(0x13C, 0x00); // SYSREF increase guard-band setup time
	ad9625_spi_write(0x0FF, 0x01); // transfer register values
	mdelay(10);

	ad9625_spi_read(0x100, &chip_status);
	mdelay(10);
	xil_printf("ADC IRQ Status after (0x%x).\r\n", chip_status);
	mdelay(10);

	ad9625_spi_read(0x03A, &chip_status);
	mdelay(10);
	xil_printf("ADC SYSREF Control after (0x%x).\r\n", chip_status);
	mdelay(10);

	xil_printf("\r\nEnd of AD9625 register status\r\n");

//	ad9625_spi_read(AD9625_REG_CHIP_ID, &chip_id);
//	mdelay(30);
//	xil_printf("ADC Chip ID (0x%x)\r\n", chip_id);
//	mdelay(30);
//
//	ad9625_spi_read(AD9625_REG_CHIP_GRADE, &chip_grade);
//	mdelay(30);
//	xil_printf("ADC Chip Grade (0x%x)\r\n", chip_grade);
//	mdelay(30);
//
//	ad9625_spi_read(AD9625_REG_POWER_MODE, &chip_pm);
//	mdelay(30);
//	xil_printf("ADC PWR MODE (0x%x)\r\n", chip_pm);
//	mdelay(30);
//
//	ad9625_spi_read(AD9625_REG_IRQ_MASK_CONTROL, &chip_irq);
//	mdelay(30);
//	xil_printf("ADC IRQ MSK CTRL (0x%x)\r\n", chip_irq);
//	mdelay(30);

	return 0;
}
