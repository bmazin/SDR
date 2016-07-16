/***************************************************************************//**
* @file dac_core.h
* @brief Header file of DAC Core Driver.
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
#ifndef DAC_CORE_H_
#define DAC_CORE_H_

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#define DAC_REG_VERSION					0x0000
#define DAC_VERSION(x)					(((x) & 0xffffffff) << 0)
#define DAC_VERSION_IS(x,y,z)			((x) << 16 | (y) << 8 | (z))
#define DAC_PCORE_VERSION_MAJOR(x)		((x) >> 16)

#define DAC_REG_ID						0x0004
#define DAC_ID(x)						(((x) & 0xffffffff) << 0)

#define DAC_REG_SCRATCH					0x0008
#define DAC_SCRATCH(x)					(((x) & 0xffffffff) << 0)

#define DAC_REG_RSTN					0x040
#define DAC_MMCM_RSTN					(1 << 1)
#define DAC_RSTN						(1 << 0)

#define DAC_REG_CNTRL_1					0x0044
#define DAC_ENABLE						(1 << 0) /* v7.0 */
#define DAC_SYNC						(1 << 0) /* v8.0 */

#define ADI_REG_CNTRL_2					0x0048
#define ADI_PAR_TYPE					(1 << 7)
#define ADI_PAR_ENB						(1 << 6)
#define ADI_R1_MODE						(1 << 5)
#define ADI_DATA_FORMAT					(1 << 4)
#define ADI_DATA_SEL(x)					(((x) & 0xF) << 0) /* v7.0 */
#define ADI_TO_DATA_SEL(x)				(((x) >> 0) & 0xF) /* v7.0 */

#define DAC_REG_RATECNTRL				0x004C
#define DAC_RATE(x)						(((x) & 0xFF) << 0)
#define DAC_TO_RATE(x)					(((x) >> 0) & 0xFF)

#define DAC_REG_CLK_FREQ				0x0054
#define DAC_CLK_FREQ(x)					(((x) & 0xFFFFFFFF) << 0)
#define DAC_TO_CLK_FREQ(x)				(((x) >> 0) & 0xFFFFFFFF)

#define DAC_REG_CLK_RATIO				0x0058
#define DAC_CLK_RATIO(x)				(((x) & 0xFFFFFFFF) << 0)
#define DAC_TO_CLK_RATIO(x)				(((x) >> 0) & 0xFFFFFFFF)

#define DAC_REG_STATUS					0x005C
#define DAC_MUX_PN_ERR					(1 << 3)
#define DAC_MUX_PN_OOS					(1 << 2)
#define DAC_MUX_OVER_RANGE				(1 << 1)
#define DAC_STATUS						(1 << 0)

#define DAC_REG_CHAN_CNTRL_1_IIOCHAN(x)	(0x0400 + ((x) >> 1) * 0x40 + ((x) & 1) * 0x8)
#define DAC_DDS_SCALE(x)				(((x) & 0xFFFF) << 0)
#define DAC_TO_DDS_SCALE(x)				(((x) >> 0) & 0xFFFF)

#define DAC_REG_CHAN_CNTRL_2_IIOCHAN(x)	(0x0404 + ((x) >> 1) * 0x40 + ((x) & 1) * 0x8)
#define DAC_DDS_INIT(x)					(((x) & 0xFFFF) << 16)
#define DAC_TO_DDS_INIT(x)				(((x) >> 16) & 0xFFFF)
#define DAC_DDS_INCR(x)					(((x) & 0xFFFF) << 0)
#define DAC_TO_DDS_INCR(x)				(((x) >> 0) & 0xFFFF)

#define DAC_REG_CHAN_CNTRL_7(c)			(0x0418 + (c) * 0x40) /* v8.0 */
#define DAC_DAC_DDS_SEL(x)				(((x) & 0xF) << 0)
#define DAC_TO_DAC_DDS_SEL(x)			(((x) >> 0) & 0xF)

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/
int32_t dac_read(uint32_t reg_addr, uint32_t *reg_data);
int32_t dac_write(uint32_t reg_addr, uint32_t reg_data);
int32_t dac_setup(uint32_t baseaddr);
int32_t dds_set_frequency(uint32_t chan, uint32_t freq);
int32_t dds_set_phase(uint32_t chan, uint32_t phase);
int32_t dds_set_scale(uint32_t chan, int32_t scale_micro_units);

#endif
