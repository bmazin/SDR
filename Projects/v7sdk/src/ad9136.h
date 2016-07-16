/*****************************************************************************
* @file
* @brief Header file of
* @author DBogdan (dragos.bogdan@analog.com)
******************************************************************************
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
* the documentation and-or other materials provided with the
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
*******************************************************************************
*****************************************************************************
* This file was modified to work with the AD9136 ****************************
* Analog Devices web-site doesn't have a driver available for the 9136 ******
* This file was modified by TZ **********************************************
*****************************************************************************
*****************************************************************************/
#ifndef AD9136_H_
#define AD9136_H_

/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>

/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#define DAC_SPI_INTFCONFA                        0x000 /* Interface configuration A */
#define DAC_CHIPTYPE                             0x003 /* Chip Type*/
#define DAC_PRODIDL                              0x004 /* Product Identification Low Byte */
#define DAC_PRODIDH                              0x005 /* Product Identification High Byte */
#define DAC_CHIPGRADE                            0x006 /* Chip Grade */
#define DAC_SPI_PAGEINDX                         0x008 /* Page Pointer or Device Index */
#define DAC_PWRCNTRL0                            0x011 /* Power Control Reg 1 */
#define DAC_TXENMASK                             0x012 /* TXenable masks */
#define DAC_PWRCNTRL3                            0x013 /* Power control register 3 */
#define DAC_GROUP_DLY                            0x014 /* Coarse Group Delay Adjustment */
#define DAC_IRQEN_STATUSMODE0                    0x01F /* Interrupt Enable */
#define DAC_IRQEN_STATUSMODE1                    0x020 /* Interrupt Enable */
#define DAC_IRQEN_STATUSMODE2                    0x021 /* Interrupt Enable */
#define DAC_IRQEN_STATUSMODE3                    0x022 /* Interrupt Enable */
#define DAC_IRQ_STATUS0                          0x023 /* Interrupt Status */
#define DAC_IRQ_STATUS1                          0x024 /* Interrupt Status */
#define DAC_IRQ_STATUS2                          0x025 /* Interrupt Status */
#define DAC_IRQ_STATUS3                          0x026 /* Interrupt Status */
#define DAC_JESD_CHECKS                          0x030 /* JESD Parameter Checking */
#define DAC_SYNC_ERRWINDOW                       0x034 /* Sync Error Window */
#define DAC_SYNC_LASTERR_L                       0x038 /* SyncLASTerror_L */
#define DAC_SYNC_LASTERR_H                       0x039 /* SyncLASTerror_H */
#define DAC_SYNC_CONTROL                         0x03A /* Sync Mode Control */
#define DAC_SYNC_STATUS                          0x03B /* Sync Alignment Flags */
#define DAC_SYNC_CURRERR_L                       0x03C /* Sync Alignment Error[7:0] */
#define DAC_SYNC_CURRERR_H                       0x03D /* Sync Alignment Error[8] */
#define DAC_GAIN0_1                              0x040 /* MSBs of Full Scale Adjust DAC */
#define DAC_GAIN0_0                              0x041 /* LSBs of Full Scale Adjust DAC */
#define DAC_GAIN1_1                              0x044 /* MSBs of Full Scale Adjust DAC */
#define DAC_GAIN1_0                              0x045 /* LSBs of Full Scale Adjust DAC */
#define DAC_CLKCFG0                              0x080 /* Clock Configuration */
#define DAC_SYSREF_ACTRL0                        0x081 /* SYSREF Analog Control 0 */
#define DAC_SYSREF_ACTRL1                        0x082 /* SYSREF Analog Control 1 */
#define DAC_PLLCNTRL                             0x083 /* Top Level Control DAC Clock PLL */
#define DAC_PLLSTATUS                            0x084 /* DAC PLL Status Bits */
#define DAC_INTEGERWORD0                         0x085 /* Feedback divider tuning word */
#define DAC_LOOPFILT1                            0x087 /* C1 and C2 control */
#define DAC_LOOPFILT2                            0x088 /* R1 and C3 control */
#define DAC_LOOPFILT3                            0x089 /* Bypass and R2 control */
#define DAC_CPCNTRL                              0x08A /* Charge Pump/Cntrl Voltage */
#define DAC_LOGENCNTRL                           0x08B /* Logen Control */
#define DAC_LDOCNTRL1                            0x08C /* LDO Control1 + Reference Divider */
#define DAC_CAL_CTRL_GLOBAL                      0x0E2 /* Global Calibration DAC Control */
#define DAC_CAL_CLKDIV                           0x0E7 /* Calibration DAC clock divide */
#define DAC_CAL_PAGE                             0x0E8 /* Calibration DAC Select */
#define DAC_CAL_CTRL                             0x0E9 /* Calibration DAC Control */
#define DAC_CAL_INIT                             0x0ED /* Calibration Init */
#define DAC_DATA_FORMAT                          0x110 /* Data format */
#define DAC_DATAPATH_CTRL                        0x111 /* Datapath Control */
#define DAC_INTERP_MODE                          0x112 /* Interpolation Mode */
#define DAC_TXEN_SM_0                            0x11F /* Transmit enable power control state machine */
#define DAC_TXEN_RISE_COUNT_0                    0x121 /* Rise Count 0 */
#define DAC_TXEN_RISE_COUNT_1                    0x122 /* Rise Count 1 */
#define DAC_TXEN_FALL_COUNT_0                    0x123 /* Fall Count 0 */
#define DAC_TXEN_FALL_COUNT_1                    0x124 /* Fall Count 1 */
#define DAC_DEVICE_CONFIG_REG_0                  0x12D /* Device Config 0 */
#define DAC_DIE_TEMP_CTRL0                       0x12F /* Die Temp Range Control */
#define DAC_DIE_TEMP0                            0x132 /* Die temp LSB */
#define DAC_DIE_TEMP1                            0x133 /* Die Temp MSB */
#define DAC_DIE_TEMP_UPDATE                      0x134 /* Die temperature update */
#define DAC_DC_OFFSET_CTRL                       0x135 /* DC Offset Control */
#define DAC_DC_OFFSET_1PART0                     0x136 /* LSB of first part of DC Offset value for I path */
#define DAC_DC_OFFSET_1PART1                     0x137 /* MSB of first part of DC Offset value for I path */
#define DAC_DC_OFFSET_2PART                      0x13A /* Second part of DC Offset value for I path */
#define DAC_DIG_GAIN0                            0x13C /* I DAC Gain LSB */
#define DAC_DIG_GAIN1                            0x13D /* I DAC Gain MSB */
#define DAC_GAIN_RAMP_UP_STEP0                   0x140 /* LSB of digital gain rises */
#define DAC_GAIN_RAMP_UP_STEP1                   0x141 /* MSB of digital gain rises */
#define DAC_GAIN_RAMP_DOWN_STEP0                 0x142 /* LSB of digital gain drops */
#define DAC_GAIN_RAMP_DOWN_STEP1                 0x143 /* MSB of digital gain drops */
#define DAC_DEVICE_CONFIG_REG_1                  0x146 /* Device Configuration 1 */
#define DAC_BSM_STAT                             0x147 /* Blanking SM control and func */
#define DAC_PRBS                                 0x14B /* PRBS Input Data Checker */
#define DAC_PRBS_ERROR                           0x14C /* PRBS Error Counter */
#define DAC_PLLT4                                0x1B4 /* VCO Cal Offset */
#define DAC_PLLT5                                0x1B5 /* ALC/Varactor control */
#define DAC_PLLT6                                0x1B6 /* VCO Amplitude Control */
#define DAC_PLLTB                                0x1BB /* VCO Bias Control */
#define DAC_PLLTD                                0x1BD /* VCO Cal control */
#define DAC_DEVICE_CONFIG_REG_2                  0x1C4 /* Device Configuration 2 */
#define DAC_MASTER_PD                            0x200 /* Master power down for Receiver PHYx */
#define DAC_PHY_PD                               0x201 /* Power down for individual Receiver PHYx */
#define DAC_GENERIC_PD                           0x203 /* Miscellaneous power down controls */
#define DAC_CDR_RESET                            0x206 /* CDR Reset */
#define DAC_CDR_OPERATING_MODE_REG_0             0x230 /* Clock and data recovery operating modes */
#define DAC_DEVICE_CONFIG_REG_3                  0x232 /* Device Configuration 3 */
#define DAC_EQ_BIAS_REG                          0x268 /* Equalizer bias control */
#define DAC_SERDES_ENABLE_CNTRL                  0x280 /* Rx PLL enable controls */
#define DAC_PLL_STATUS                           0x281 /* Rx PLL status readbacks */
#define DAC_REF_CLK_DIVIDER_LDO                  0x289 /* Rx PLL LDO control */
#define DAC_DEVICE_CONFIG_REG_5                  0x291 /* Device Configuration 5 */
#define DAC_DEVICE_CONFIG_REG_6                  0x29C /* Device Configuration 6 */
#define DAC_DEVICE_CONFIG_REG_7                  0x29F /* Device Configuration 7 */
#define DAC_DEVICE_CONFIG_REG_8                  0x2A4 /* Device Configuration 8 */
#define DAC_SYNCOUTB_SWING                       0x2A5 /* SYNCOUTB Swing Mode */
#define DAC_TERM_BLK1_CTRLREG0                   0x2A7 /* Termination Calibration */
#define DAC_DEVICE_CONFIG_REG_9                  0x2AA /* Device Configuration 9 */
#define DAC_DEVICE_CONFIG_REG_10                 0x2AB /* Device Configuration 10 */
#define DAC_TERM_BLK2_CTRLREG0                   0x2AE /* Termination Calibration */
#define DAC_DEVICE_CONFIG_REG_11                 0x2B1 /* Device Configuration 11 */
#define DAC_DEVICE_CONFIG_REG_12                 0x2B2 /* Device Configuration 12 */
#define DAC_GENERAL_JRX_CTRL_0                   0x300 /* General JRX Control Register 0 */
#define DAC_GENERAL_JRX_CTRL_1                   0x301 /* General JRX Control Register 1 */
#define DAC_DYN_LINK_LATENCY_0                   0x302 /* Dynamic Latency Link 0 */
#define DAC_DYN_LINK_LATENCY_1                   0x303 /* Dynamic Latency Link 1 */
#define DAC_LMFC_DELAY_0                         0x304 /* LMFC Delay Link 0 */
#define DAC_LMFC_DELAY_1                         0x305 /* LMFC Delay Link 1 */
#define DAC_LMFC_VAR_0                           0x306 /* Variable Delay Buffer Link 0 */
#define DAC_LMFC_VAR_1                           0x307 /* Variable Delay Buffer Link 1 */
#define DAC_XBAR_LN_0_1                          0x308 /* Logical Lane Source 0-1 */
#define DAC_XBAR_LN_2_3                          0x309 /* Logical Lane Source 2-3 */
#define DAC_XBAR_LN_4_5                          0x30A /* Logical Lane Source 4-5 */
#define DAC_XBAR_LN_6_7                          0x30B /* Logical Lane Source 6-7 */
#define DAC_FIFO_STATUS_REG_0                    0x30C /* FIFO Status Register 0 */
#define DAC_FIFO_STATUS_REG_1                    0x30D /* FIFO Status Register 1 */
#define DAC_SYNCB_GEN_1                          0x312 /* SYNCB Error Duration */
#define DAC_SERDES_SPI_REG                       0x314 /* SERDES SPI Configuration */
#define DAC_PHY_PRBS_TEST_EN                     0x315 /* PHY PRBS TEST ENABLE FOR INDIVIDUAL LANES */
#define DAC_PHY_PRBS_TEST_CTRL                   0x316 /* PHY PRBS Test Control */
#define DAC_PHY_PRBS_TEST_THRESHOLD_LOBITS       0x317 /* PHY PRBS Test Threshold Low Bits */
#define DAC_PHY_PRBS_TEST_THRESHOLD_MIDBITS      0x318 /* PHY PRBS Test Threshold Mid Bits */
#define DAC_PHY_PRBS_TEST_THRESHOLD_HIBITS       0x319 /* PHY PRBS Test Threshold High Bits */
#define DAC_PHY_PRBS_TEST_ERRCNT_LOBITS          0x31A /* PHY PRBS Test Error Count Low Bits */
#define DAC_PHY_PRBS_TEST_ERRCNT_MIDBITS         0x31B /* PHY PRBS Test Error Count Mid Bits */
#define DAC_PHY_PRBS_TEST_ERRCNT_HIBITS          0x31C /* PHY PRBS Test Error Count High Bits */
#define DAC_PHY_PRBS_TEST_STATUS                 0x31D /* PHY PRBS Test Status */
#define DAC_SHORT_TPL_TEST_0                     0x32C /* Short Transport Layer Test 0 */
#define DAC_SHORT_TPL_TEST_1                     0x32D /* Short Transport Layer Test 1 */
#define DAC_SHORT_TPL_TEST_2                     0x32E /* Short Transport Layer Test 2 */
#define DAC_SHORT_TPL_TEST_3                     0x32F /* Short Transport Layer Test 3 */
#define DAC_DEVICE_CONFIG_REG_13                 0x333 /* Device Configuration 13 */
#define DAC_JESD_BIT_INVERSE_CTRL                0x334 /* Logical Lane Invert */
#define DAC_DID_REG                              0x400 /* Device Identification */
#define DAC_BID_REG                              0x401 /* Adjustment Resolution/Blank Identification */
#define DAC_LID0_REG                             0x402 /* Lane Direction/Phase/Identification */
#define DAC_SCR_L_REG                            0x403 /* Lane Scrambling/Lanes Per Converter */
#define DAC_F_REG                                0x404 /* Number Octets Per Frame */
#define DAC_K_REG                                0x405 /* Number Frames Per Multiframe */
#define DAC_M_REG                                0x406 /* Number of Converter Per Device */
#define DAC_CS_N_REG                             0x407 /* Number of Control Bits Per Sample */
#define DAC_NP_REG                               0x408 /* Number Bits Per Sample */
#define DAC_S_REG                                0x409 /* Number Samples Per Converter Per Frame */
#define DAC_HD_CF_REG                            0x40A /* High Density/Number Control Words per Frame */
#define DAC_RES1_REG                             0x40B /* Reserved 1 */
#define DAC_RES2_REG                             0x40C /* Reserved 2 */
#define DAC_CHECKSUM_REG                         0x40D /* Checksum Link Lane 0 */
#define DAC_COMPSUM0_REG                         0x40E /* Computed Checksum Link Lane 0 */
#define DAC_LID1_REG                             0x412 /* Lane Identification Link Lane 1 */
#define DAC_CHECKSUM1_REG                        0x415 /* Checksum Link Lane 1 */
#define DAC_COMPSUM1_REG                         0x416 /* Computed Checksum Link Lane 1 */
#define DAC_LID2_REG                             0x41A /* Lane Identification Link Lane 2 */
#define DAC_CHECKSUM2_REG                        0x41D /* Checksum Link Lane 2 */
#define DAC_COMPSUM2_REG                         0x41E /* Computed Checksum Link Lane 2 */
#define DAC_LID3_REG                             0x422 /* Lane Identification Link Lane 3 */
#define DAC_CHECKSUM3_REG                        0x425 /* Checksum Link Lane 3 */
#define DAC_COMPSUM3_REG                         0x426 /* Computed Checksum Link Lane 3 */
#define DAC_LID4_REG                             0x42A /* Lane Identification Link Lane 4 */
#define DAC_CHECKSUM4_REG                        0x42D /* Checksum Link Lane 4 */
#define DAC_COMPSUM4_REG                         0x42E /* Computed Checksum Link Lane 4 */
#define DAC_LID5_REG                             0x432 /* Lane Identification Link Lane 5 */
#define DAC_CHECKSUM5_REG                        0x435 /* Checksum Link Lane 5 */
#define DAC_COMPSUM5_REG                         0x436 /* Computed Checksum Link Lane 5 */
#define DAC_LID6_REG                             0x43A /* Lane Identification Link Lane 6 */
#define DAC_CHECKSUM6_REG                        0x43D /* Checksum Link Lane 6 */
#define DAC_COMPSUM6_REG                         0x43E /* Computed Checksum Link Lane 6 */
#define DAC_LID7_REG                             0x442 /* Lane Identification Link Lane 7 */
#define DAC_CHECKSUM7_REG                        0x445 /* Checksum Link Lane 7 */
#define DAC_COMPSUM7_REG                         0x446 /* Computed Checksum Link Lane 7 */
#define DAC_ILS_DID                              0x450 /* Device Identification Number */
#define DAC_ILS_BID                              0x451 /* Adjustment Resolution/Blank Identification */
#define DAC_ILS_LID0                             0x452 /* Lane Direction/Phase/Identification */
#define DAC_ILS_SCR_L                            0x453 /* Lane Scrambling/Lanes per Converter*/
#define DAC_ILS_F                                0x455 /* Number of Octets per Lane per Frame */
#define DAC_ILS_K                                0x455 /* Number Frames per Multiframe */
#define DAC_ILS_M                                0x456 /* Number of Converter per Device */
#define DAC_ILS_CS_N                             0x457 /* Number of Control Bits Per Sample */
#define DAC_ILS_NP                               0x458 /* Number of Bits per Sample */
#define DAC_ILS_S                                0x459 /* Number Samples per Converter Per Frame */
#define DAC_ILS_HD_CF                            0x45A /* High Density/Number Control Words per Frame */
#define DAC_ILS_RES1                             0x45B /* ILS Reserved 1 */
#define DAC_ILS_RES2                             0x45C /* ILS Reserved 2 */
#define DAC_ILS_CHECKSUM                         0x45D /* Checksum Link Lane 0 */
#define DAC_ERRCNTRMON                           0x46B /* Error Counter Control - Read/Write*/
#define DAC_LANEDESKEW                           0x46C /* Lane Deskew */
#define DAC_BADDISPARITY                         0x46D /* Bad Disparity Character Error - Read/Write */
#define DAC_NIT                                  0x46E /* Not in Table Error - Read/Write */
#define DAC_UNEXPECTED_CONTROL                   0x46F /* Unexpected Control - Read/Write */
#define DAC_CODEGRPSYNCFLG                       0x470 /* Code Group Sync Flag */
#define DAC_FRAMESYNCFLG                         0x471 /* Frame Sync Flag */
#define DAC_GOODCHKSUMFLG                        0x472 /* Good Checksum Flag */
#define DAC_INITLANESYNCFLG                      0x473 /* Intial Lane Sync Flag */
#define DAC_CTRLREG1                             0x476 /* Number of Octets per Frame */
#define DAC_CTRLREG2                             0x477 /* ILAS Test Mode/Threshold Mask Enable */
#define DAC_KVAL                                 0x478 /* Number of K Multiframes during ILAS */
#define DAC_IRQVECTOR                            0x47A /* IRQ Vector Flag/IRQ Vector Mask - Read/Write */
#define DAC_SYNCASSERTIONMASK                    0x47B /* Sync Assertion Mask - Read/Write  */
#define DAC_ERRORTHRES                           0x47C /* Error Threshold - Read/Write */
#define DAC_LANEENABLE                           0x47D /* Lane Enable - Read/Write */

/*
 *      DAC_SPI_INTFCONFA
 */
#define SOFTRESET_M                          0x80 /* Soft Reset (Mirror) */
#define LSBFIRST_M                           0x40 /* LSB First (Mirror) */
#define ADDRINC_M                            0x20 /* Address Increment (Mirror) */
#define SDOACTIVE_M                          0x10 /* SDO Active (Mirror) */
#define SDOACTIVE                            0x08 /* SDO Active */
#define ADDRINC                              0x04 /* Address Increment */
#define LSBFIRST                             0x02 /* LSB First */
#define SOFTRESET                            0x01 /* Soft Reset */

/*
 *      DAC_CHIPTYPE
 */
#define PROD_GRADE(x)                        (((x) & 0xF) << 4) /* Product Grade */
#define DEV_REVISION(x)                      (((x) & 0xF) << 0) /* Device Revision */

/*
 *      DAC_SPI_PAGEINDX
 */
#define PAGEINDX(x)                          (((x) & 0x3) << 0) /* Page or Index Pointer */

/*
 *      DAC_PWRCNTRL0
 */
#define PD_BG                                0x80 /* Reference PowerDown */
#define PD_DAC_0                             0x40 /* PD Ichannel DAC 0 */
#define PD_DAC_1                             0x10 /* PD Qchannel DAC 1 */
#define PD_DACM                              0x04 /* PD Dac master Bias */

/*
 *      DAC_TXENMASK
 */
#define DAC1_MASK                            0x02 /* Dual B Dac TXen1 mask */
#define DAC0_MASK                            0x01 /* Dual A Dac TXen0 mask */

/*
 *      DAC_PWRCNTRL3
 */
#define TX_PROTECT_OUT                       0x20 /* Control PDP enable from Txen State machine */
#define SPI_PROTECT_OUT                      0x08 /* Control PDP enable via SPI */
#define SPI_PROTECT                          0x04 /* PDP on/off via SPI */
/*
 *      DAC_GROUP_DLY
 */
#define GROUP_DLY(x)                         (((x) & 0xF) << 0) /* Coarse group delay */

/*
 *      DAC_IRQEN_STATUSMODE0
 */
#define IRQEN_SMODE_CALPASS                  0x80 /* Enable Calib PASS detection */
#define IRQEN_SMODE_CALFAIL                  0x40 /* Enable Calib FAIL detection */
#define IRQEN_SMODE_DACPLLLOST               0x20 /* Enable DAC Pll Lost detection */
#define IRQEN_SMODE_DACPLLLOCK               0x10 /* Enable DAC Pll Lock detection */
#define IRQEN_SMODE_SERPLLLOST               0x08 /* Enable Serdes PLL Lost detection */
#define IRQEN_SMODE_SERPLLLOCK               0x04 /* Enable Serdes PLL Lock detection */
#define IRQEN_SMODE_LANEFIFOERR              0x02 /* Enable Lane FIFO Error detection */

/*
 *      DAC_IRQEN_STATUSMODE1
 */
#define IRQEN_SMODE_PRBS1                    0x04 /* enable PRBS DAC 1 error status mode */
#define IRQEN_SMODE_PRBS0                    0x01 /* enable PRBS DAC 0 error status mode */

/*
 *      DAC_IRQEN_STATUSMODE2
 */
#define IRQEN_SMODE_PDPERR0                  0x80 /* DAC 0 PDP Error */
#define IRQEN_SMODE_BLNKDONE0                0x20 /* DAC 0 Blanking done */
#define IRQEN_SMODE_SYNC_LOCK0               0x08 /* DAC 0 Alignment Locked */
#define IRQEN_SMODE_SYNC_ROTATE0             0x04 /* DAC 0 Alignment Rotate */
#define IRQEN_SMODE_SYNC_WLIM0               0x02 /* DAC 0 Over/Under Threshold */
#define IRQEN_SMODE_SYNC_TRIP0               0x01 /* DAC 0 Alignment Trip */

/*
 *      DAC_IRQEN_STATUSMODE3
 */
#define IRQEN_SMODE_PDPERR1                  0x80 /* DAC 1 PDP Error */
#define IRQEN_SMODE_BLNKDONE1                0x20 /* DAC 1 Blanking done */
#define IRQEN_SMODE_SYNC_LOCK1               0x08 /* DAC 1 Alignment Locked */
#define IRQEN_SMODE_SYNC_ROTATE1             0x04 /* DAC 1 Alignment Rotate */
#define IRQEN_SMODE_SYNC_WLIM1               0x02 /* DAC 1 Over/Under Threshold */
#define IRQEN_SMODE_SYNC_TRIP1               0x01 /* DAC 1 Alignment Trip */

/*
 *      DAC_IRQ_STATUS0
 */
#define CALPASS                              0x80 /* Calib PASS detection */
#define CALFAIL                              0x40 /* Calib FAIL detection */
#define DACPLLLOST                           0x20 /* DAC PLL Lost */
#define DACPLLLOCK                           0x10 /* DAC PLL Lock */
#define SERPLLLOST                           0x08 /* Serdes PLL Lost */
#define SERPLLLOCK                           0x04 /* Serdes PLL Lock */
#define LANEFIFOERR                          0x02 /* Lane Fifo Error */

/*
 *      DAC_IRQ_STATUS1
 */
#define PRBS1                                0x04 /* PRBS data check error DAC 1 real */
#define PRBS0                                0x01 /* PRBS data check error DAC 0 real */

/*
 *      DAC_IRQ_STATUS2
 */
#define PDPERR0                              0x80 /* DAC 0 PDP Error */
#define BLNKDONE0                            0x20 /* DAC 0  Blanking Done */
#define SYNC_LOCK0                           0x08 /* DAC 0 Alignment Locked */
#define SYNC_ROTATE0                         0x04 /* DAC 0 Alignment Rotate */
#define SYNC_WLIM0                           0x02 /* DAC 0 Over/Under Threshold */
#define SYNC_TRIP0                           0x01 /* DAC 0 LMFC Tripped Status */

/*
 *      DAC_IRQ_STATUS3
 */
#define PDPERR1                              0x80 /* DAC 1 PDP Error */
#define BLNKDONE1                            0x20 /* DAC 1  Blanking Done */
#define SYNC_LOCK1                           0x08 /* DAC 1 Alignment Locked */
#define SYNC_ROTATE1                         0x04 /* DAC 1 Alignment Rotate */
#define SYNC_WLIM1                           0x02 /* DAC 1 Over/Under Threshold */
#define SYNC_TRIP1                           0x01 /* DAC 1 LMFC Tripped Status */

/*
 *      DAC_JESD_CHECKS
 */
#define ERR_DLYOVER                          0x20 /* LMFC_Delay > JESD_K parameter */
#define ERR_WINLIMIT                         0x10 /* Unsupported Window Limit */
#define ERR_JESDBAD                          0x08 /* Unsupported M/L/S/F selection */
#define ERR_KUNSUPP                          0x04 /* Unsupported K values */
#define ERR_SUBCLASS                         0x02 /* Unsupported SubClassv value */
#define ERR_INTSUPP                          0x01 /* Unsupported Interpolation rate factor */

/*
 *      DAC_SYNC_ERRWINDOW
 */
#define ERRWINDOW(x)                         (((x) & 0x3) << 0) /* Sync Error Window */

/*
 *      DAC_SYNC_LASTERR_L
 */
#define LASTERROR(x)                         (((x) & 0xF) << 0) /* LMFC Sync Alignment Error */

/*
 *      DAC_SYNC_LASTERR_H
 */
#define LASTUNDER                            0x80 /* Sync Last Error Under Flag */
#define LASTOVER                             0x40 /* Sync Last Error Over Flag */

/*
 *      DAC_SYNC_CONTROL
 */
#define SYNCENABLE                           0x80 /* SyncLogic Enable */
#define SYNCARM                              0x40 /* Sync Arming Strobe */
#define SYNCCLRSTKY                          0x20 /* Sync Sticky Bit Clear */
#define SYNCCLRLAST                          0x10 /* Sync Clear LAST_ */
#define SYNCMODE(x)                          (((x) & 0xF) << 0) /* Sync Mode */

/*
 *      DAC_SYNC_STATUS
 */
#define SYNC_BUSY                            0x80 /* Sync Machine Busy */
#define SYNC_LOCK                            0x08 /* Sync Alignment Locked */
#define SYNC_ROTATE                          0x04 /* Sync Rotated */
#define SYNC_WLIM                            0x02 /* Sync Alignment Limit Range */
#define SYNC_TRIP                            0x01 /* Sync Tripped after Arming */

/*
 *      DAC_SYNC_CURRERR_L
 */
#define CURRERROR(x)                         (((x) & 0xF) << 0) /* LMFC Sync Alignment Error */

/*
 *      DAC_SYNC_CURRERR_H
 */
#define CURRUNDER                            0x80 /* Sync Current Error Under Flag */
#define CURROVER                             0x40 /* Sync Current Error Over Flag */

///*
// *      DAC_DACGAIN0_0
// */
//#define DACFSC_0[7:0](x)                     (((x) & 0xFF) << 0) /* I Channel DAC 0 gain <7:0> */
//
///*
// *      DAC_DACGAIN0_1
// */
//#define DACFSC_0[9:8](x)                     (((x) & 0x3) << 0) /* I Channel DAC 0 gain <9:8> */
//
///*
// *      DAC_DACGAIN1_0
// */
//#define DACFSC_1[7:0](x)                     (((x) & 0xFF) << 0) /* I Channel DAC 1 gain <7:0> */
//
///*
// *      DAC_DACGAIN1_1
// */
//#define DACFSC_1[9:8](x)                     (((x) & 0x3) << 0) /* I Channel DAC 1 gain <9:8> */

/*
 *      DAC_CLKCFG0
 */
#define PD_CLK0                              0x80 /* Powerdown clock for Dual A */
#define PD_CLK1                              0x40 /* Powerdown clock for Dual B */
#define PD_CLK_DIG                           0x20 /* Powerdown clocks to all DACs */
#define PD_SERDES_PCLK                       0x10 /* Cal reference/Serdes PLL clock powerdown */
#define PD_CLK_REC                           0x08 /* Clock receiver powerdown */

/*
 *      DAC_SYSREF_ACTRL0
 */
#define PD_SYSREF                            0x10 /* Powerdown SYSREF buffer */
#define HYS_ON                               0x08 /* Hysteresis enabled */
#define SYSREF_RISE                          0x04 /* Use SYSREF rising edge */
#define HYS_CNTRL1(x)                        (((x) & 0x3) << 0) /* Hysteresis control bits <9:8> */

/*
 *      DAC_DACPLLCNTRL
 */
#define RECAL_DACPLL                         0x80 /* Recalibrate VCO Band */
#define ENABLE_DACPLL                        0x10 /* Synthesizer Enable */

/*
 *      DAC_DACPLLSTATUS
 */
#define DACPLL_OVERRANGE_H                  0x80 /* DAC PLL High Overrange */
#define DACPLL_OVERRANGE_L                  0x40 /* DAC PLL Low Overrange */
#define DACPLL_CAL_VALID                    0x20 /* DAC PLL High Overrange */
#define DACPLL_LOCK                         0x02 /* DAC PLL Low Overrange */

/*
 *      DAC_DACLOOPFILT1
 */
#define LF_C2_WORD(x)                        (((x) & 0xF) << 4) /* C2 control word */
#define LF_C1_WORD(x)                        (((x) & 0xF) << 0) /* C1 control word */

/*
 *      DAC_DACLOOPFILT2
 */
#define LF_R1_WORD(x)                        (((x) & 0xF) << 4) /* R1 control word */
#define LF_C3_WORD(x)                        (((x) & 0xF) << 0) /* C3 control word */

/*
 *      DAC_DACLOOPFILT3
 */
#define LF_BYPASS_R3                         0x80 /* Bypass R3 res */
#define LF_BYPASS_R1                         0x40 /* Bypass R1 res */
#define LF_BYPASS_C2                         0x20 /* Bypass C2 cap */
#define LF_BYPASS_C1                         0x10 /* Bypass C1 cap */
#define LF_R3_WORD(x)                        (((x) & 0xF) << 0) /* R3 Control Word */

/*
 *      DAC_DACCPCNTRL
 */
#define CP_CURRENT(x)                        (((x) & 0x3F) << 0) /* Charge Pump Current Control */

/*
 *      DAC_DACLOGENCNTRL
 */
#define LO_DIV_MODE(x)                       (((x) & 0x3) << 0) /* Logen_Division */

/*
 *      DAC_DACLDOCNTRL1
 */
#define REF_DIV_MODE(x)                      (((x) & 0x7) << 0) /* Reference Clock Division Ratio */

/*
 *      DAC_CAL_CTRL_GLOBAL
 */
#define CAL_START_AVG                        0x02 /* Averaged Calibration start */
#define CAL_EN_AVG                           0x01 /* Averaged Calibration enable */

/*
 *      DAC_CAL_CLKDIV
 */
#define CAL_CLK_EN                           0x08 /* Enable Self Calibration Clock */

/*
 *      DAC_CAL_PAGE
 */
#define CAL_INDX(x)                          (((x) & 0xF) << 0) /* DAC Calibration Index paging bits */

/*
 *      DAC_CAL_CTRL
 */
#define CAL_FIN                              0x80 /* Calibration finished */
#define CAL_ACTIVE                           0x40 /* Calibration active */
#define CAL_ERRHI                            0x20 /* SAR data error: too hi */
#define CAL_ERRLO                            0x10 /* SAR data error: too lo */
#define CAL_TXDACBYDAC                       0x08 /* Calibration of TXDAC by TXDAC */
#define CAL_START                            0x02 /* Calibration start */
#define CAL_EN                               0x01 /* Calibration enable */

/*
 *      DAC_DATA_FORMAT
 */
#define BINARY_FORMAT                        0x80 /* Binary or 2's complementary format on DATA bus */

/*
 *      DAC_DATAPATH_CTRL
 */
#define INVSINC_ENABLE                       0x80 /* 1 = Enable inver sinc filter */
#define DIG_GAIN_ENABLE                      0x20 /* 1 = Enable digital gain */

/*
 *      DAC_INTERP_MODE
 */
#define INTERP_MODE(x)                       (((x) & 0x7) << 0) /* Interpolation Mode */

/*
 *      DAC_TXEN_SM_0
 */
#define FALL_COUNTERS(x)                     (((x) & 0x3) << 6) /* Fall Counters */
#define RISE_COUNTERS(x)                     (((x) & 0x3) << 4) /* Rise Counters */
#define PROTECT_OUT_INVERT                   0x04 /* PROTECT_OUTx Invert */

/*
 *      DAC_DIE_TEMP_CTRL0
 */
#define AUXADC_ENABLE                        0x01 /* AUXADC_ENABLE */

/*
 *      DAC_DIE_TEMP_UPDATE
 */
#define DIE_TEMP_UPDATE                      0x01 /* Die temperature update */

/*
 *      DAC_DC_OFFSET_CTRL
 */
#define DC_OFFSET_ON                         0x01 /* DC_OFFSET_ON */

/*
 *      DAC_DAC_DC_OFFSET_2PART
 */
#define SIXTEENTH_ OFFSET(x)                 (((x) & 0x1F) << 0) /* second part of DC Offset value for I path */

/*
 *      DAC_DAC_DIG_GAIN1
 */
#define DAC_DIG_GAIN(x)                      (((x) & 0xF) << 0) /* 4 MSB of DAC digital gain */

/*
 *      DAC_GAIN_RAMP_UP_STEP1
 */
#define GAIN_RAMP_UP_STEP(x)                 (((x) & 0xF) << 0) /* 4 MSB of digital gain rises */

/*
 *      DAC_GAIN_RAMP_DOWN_STEP1
 */
#define GAIN_RAMP_DOWN_STEP(x)               (((x) & 0xF) << 0) /* 4 MSB of digital gain drops */

/*
 *      DAC_BSM_STAT
 */
#define SOFTBLANKRB(x)                       (((x) & 0x3) << 6) /* Blanking State */

/*
 *      DAC_PRBS
 */
#define PRBS_GOOD                            0x40 /* Good data indicator real channel */
#define PRBS_MODE                            0x04 /* Polynomial Select */
#define PRBS_RESET                           0x02 /* Reset Error Counters */
#define PRBS_EN                              0x01 /* Enable PRBS Checker */

/*
 *      DAC_DACPLLT4
 */
#define VCO_CAL_OFFSET(x)                    (((x) & 0xF) << 3) /* Starting Offset for VCO Calibration */

/*
 *      DAC_DACPLLT5
 */
#define VCO_VAR(x)                           (((x) & 0xF) << 0) /* Varactor KVO Setting */

/*
 *      DAC_DACPLLT6
 */
#define VCO_LVL_OUT(x)                       (((x) & 0xF) << 0) /* VCO Amplitude Control */

/*
 *      DAC_DACPLLTB
 */
#define VCO_BIAS_TCF(x)                      (((x) & 0x7) << 3) /* Temperature Coefficient for Bias control */
#define VCO_BIAS_REF(x)                      (((x) & 0x7) << 0) /* VCO Bias control */

/*
 *      DAC_DACPLLTD
 */
#define VCO_CAL_REF_TCF(x)                   (((x) & 0x7) << 0) /* TempCo for cal ref */

/*
 *      DAC_MASTER_PD
 */
#define SPI_PD_MASTER                        0x01

/*
 *      DAC_PHY_PD
 */
#define SPI_PD_PHY                           0x01

/*
 *      DAC_GENERIC_PD
 */
#define SPI_SYNC1_PD                         0x02
#define SPI_SYNC2_PD                         0x01

/*
 *      DAC_CDR_RESET
 */
#define SPI_CDR_RESETN                       0x01

/*
 *      DAC_CDR_OPERATING_MODE_REG_0
 */
#define SPI_ENHALFRATE                       0x20
#define CDR_OVERSAMP                         0x02

/*
 *      DAC_EQ_BIAS_REG
 */
#define EQ_POWER_ MODE(x)                    (((x) & 0x3) << 6)

/*
 *      DAC_SERDES_ENABLE_CNTRL
 */
#define RECAL_SERDESPLL                       0x04
#define ENABLE_ SERDESPLL                     0x01

/*
 *      DAC_PLL_STATUS
 */
#define SERDES_PLL_OVERRANGE_H               0x20
#define SERDES_PLL_OVERRANGE_L               0x10
#define SERDES_PLL_CAL_VALID_RB              0x08
#define SERDES_PLL_LOCK_RB                   0x01

/*
 *      DAC_REF_CLK_DIVIDER_LDO
 */
#define DEVICE_CONFIG_4                      0x04
#define SERDES_PLL_DIV_MODE(x)               (((x) & 0x3) << 0)

/*
 *      DAC_SYNCOUTB_SWING
 */
#define SYNCOUTB_ SWING_MD                   0x01

/*
 *      DAC_TERM_BLK1_CTRLREG0
 */
#define RCAL_TERMBLK1                        0x01

/*
 *      DAC_TERM_BLK2_CTRLREG0
 */
#define RCAL_TERMBLK2                        0x01

/*
 *      DAC_GENERAL_JRX_CTRL_0
 */
#define CHECKSUM_MODE                        0x40 /* Checksum mode */
#define LINK_MODE                            0x08 /* Link mode */
#define LINK_PAGE                            0x04 /* Link register map selection */
#define LINK_EN(x)                           (((x) & 0x3) << 0) /* Link enable */

/*
 *      DAC_GENERAL_JRX_CTRL_1
 */
#define SUBCLASSV_LOCAL(x)                   (((x) & 0x7) << 0) /* JESD204B subclass */

/*
 *      DAC_DYN_LINK_LATENCY_0
 */
#define DYN_LINK_LATENCY_0(x)                (((x) & 0x1F) << 0) /* Dynamic link latency: Link 0 */

/*
 *      DAC_DYN_LINK_LATENCY_1
 */
#define DYN_LINK_LATENCY_1(x)                (((x) & 0x1F) << 0) /* Dynamic link latency: Link 1 */

/*
 *      DAC_LMFC_DELAY_0
 */
#define LMFC_DELAY_0(x)                      (((x) & 0x1F) << 0) /* LMFC delay: Link 0 */

/*
 *      DAC_LMFC_DELAY_1
 */
#define LMFC_DELAY_1(x)                      (((x) & 0x1F) << 0) /* LMFC delay: Link 1 */

/*
 *      DAC_LMFC_VAR_0
 */
#define LMFC_VAR_0(x)                        (((x) & 0x1F) << 0) /* Location in RX LMFC where JESD words are read out from buffer */

/*
 *      DAC_LMFC_VAR_1
 */
#define LMFC_VAR_1(x)                        (((x) & 0x1F) << 0) /* Location in RX LMFC where JESD words are read out from buffer */

/*
 *      DAC_XBAR_LN_0_1
 */
#define LOGICAL_LANE1_SRC(x)                 (((x) & 0x7) << 3) /* Logic Lane 1 source */
#define LOGICAL_LANE0_SRC(x)                 (((x) & 0x7) << 0) /* Logic Lane 0 source */

/*
 *      DAC_XBAR_LN_2_3
 */
#define LOGICAL_LANE3_SRC(x)                 (((x) & 0x7) << 3) /* Logic Lane 3 source */
#define LOGICAL_LANE2_SRC(x)                 (((x) & 0x7) << 0) /* Logic Lane 2 source */

/*
 *      DAC_XBAR_LN_4_5
 */
#define LOGICAL_LANE5_SRC(x)                 (((x) & 0x7) << 3) /* Logic Lane 5 source */
#define LOGICAL_LANE4_SRC(x)                 (((x) & 0x7) << 0) /* Logic Lane 4 source */

/*
 *      DAC_XBAR_LN_6_7
 */
#define LOGICAL_LANE7_SRC(x)                 (((x) & 0x7) << 3) /* Logic Lane 7 source */
#define LOGICAL_LANE6_SRC(x)                 (((x) & 0x7) << 0) /* Logic Lane 6 source */

/*
 *      DAC_SYNCB_GEN_1
 */
#define SYNCB_ERR_DUR(x)                     (((x) & 0xF) << 4) /* Duration of SYNCOUT low for the purpose of error reporting */

/*
 *      DAC_PHY_PRBS_TEST_CTRL
 */
#define PHY_SRC_ERR_CNT(x)                   (((x) & 0x7) << 4) /* PHY error count source */
#define PHY_PRBS_PAT_SEL(x)                  (((x) & 0x3) << 2) /* PHY PRBS pattern select */
#define PHY_TEST_START                       0x02 /* PHY PRBS test start */
#define PHY_TEST_RESET                       0x01 /* PHY PRBS test reset */

/*
 *      DAC_SHORT_TPL_TEST_0
 */
#define SHORT_TPL_SP_SEL(x)                  (((x) & 0x3) << 4) /* Short transport layer sample select */
#define SHORT_TPL_DAC_SEL(x)                 (((x) & 0x3) << 2) /* Short transport layer test DAC select */
#define SHORT_TPL_TEST_RESET                 0x02 /* Short transport layer test reset */
#define SHORT_TPL_TEST_EN                    0x01 /* Short transport layer test enable */

/*
 *      DAC_SHORT_TPL_TEST_3
 */
#define SHORT_TPL_FAIL                       0x01 /* Short transport layer test fail */

/*
 *      DAC_BID_REG
 */
#define ADJCNT_RD(x)                         (((x) & 0xF) << 4)
#define BID_RD(x)                            (((x) & 0xF) << 0)

/*
 *      DAC_LID0_REG
 */
#define ADJDIR_RD                            0x40
#define PHADJ_RD                             0x20
#define LID0_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_SCR_L_REG
 */
#define SCR_RD                               0x80
#define L_RD(x)                              (((x) & 0x1F) << 0)

/*
 *      DAC_K_REG
 */
#define K_RD(x)                              (((x) & 0x1F) << 0)

/*
 *      DAC_CS_N_REG
 */
#define CS_RD(x)                             (((x) & 0x3) << 6)
#define N_RD(x)                              (((x) & 0x1F) << 0)

/*
 *      DAC_NP_REG
 */
#define SUBCLASSV_RD(x)                      (((x) & 0x7) << 5)
#define NP_RD(x)                             (((x) & 0x1F) << 0)

/*
 *      DAC_S_REG
 */
#define JESDV_RD(x)                          (((x) & 0x7) << 5)
#define S_RD(x)                              (((x) & 0x1F) << 0)

/*
 *      DAC_HD_CF_REG
 */
#define HD_RD                                0x80
#define CF_RD(x)                             (((x) & 0x1F) << 0)

/*
 *      DAC_LID1_REG
 */
#define LID1_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_LID2_REG
 */
#define LID2_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_LID3_REG
 */
#define LID3_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_LID4_REG
 */
#define LID4_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_LID5_REG
 */
#define LID5_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_LID6_REG
 */
#define LID6_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_LID7_REG
 */
#define LID7_RD(x)                           (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_BID
 */
#define ADJCNT(x)                            (((x) & 0xF) << 4)
#define BID(x)                               (((x) & 0xF) << 0)

/*
 *      DAC_ILS_LID0
 */
#define ADJDIR                               0x40
#define PHADJ                                0x20
#define LID0(x)                              (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_SCR_L
 */
#define SCR                                  0x80
#define L(x)                                 (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_K
 */
#define K(x)                                 (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_CS_N
 */
#define CS(x)                                (((x) & 0x3) << 6)
#define N(x)                                 (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_NP
 */
#define SUBCLASSV(x)                         (((x) & 0x7) << 5)
#define NP(x)                                (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_S
 */
#define JESDV(x)                             (((x) & 0x7) << 5)
#define S(x)                                 (((x) & 0x1F) << 0)

/*
 *      DAC_ILS_HD_CF
 */
#define HD                                   0x80
#define CF(x)                                (((x) & 0x1F) << 0)

/*
 *      DAC_ERRCNTRMON
 */
#define LANESEL(x)                           (((x) & 0x7) << 4)
#define CNTRSEL(x)                           (((x) & 0x3) << 0)

/*
 *      DAC_BADDISPARITY
 */
#define RST_IRQ_DIS                          0x80
#define DIS_ERR_CNTR_DIS                     0x40
#define RST_ERR_CNTR_DIS                     0x20
#define LANE_ADDR_DIS(x)                     (((x) & 0x7) << 0)

/*
 *      DAC_NITDISPARITY
 */
#define RST_IRQ_NIT                          0x80
#define DISABLE_ERR_CNTR_NIT                 0x40
#define RST_ERR_CNTR_NIT                     0x20
#define LANE_ADDR_NIT(x)                     (((x) & 0x7) << 0)

/*
 *      DAC_UNEXPECTED_CONTROL
 */
#define RST_IRQ_UCC                          0x80
#define DISABLE_ERR_CNTR_UCC                 0x40
#define RST_ERR_CNTR_UCC                     0x20
#define LANE_ADDR_UCC(x)                     (((x) & 0x7) << 0)

/*
 *      DAC_CTRLREG2
 */
#define ILAS_MODE                            0x80
#define THRESHOLD_MASK_EN                    0x08

/*
 *      DAC_IRQVECTOR
 */
#define BADDIS_FLAG_OR_MASK                  0x80
#define NITD_FLAG_OR_MASK                    0x40
#define UCC_FLAG_OR_MASK                     0x20
#define INITIALLANESYNC_FLAG_OR_MASK         0x08
#define BADCHECKSUM_FLAG_OR_MASK             0x04
#define CODEGRPSYNC_FLAG_OR_MASK             0x01

/*
 *      DAC_SYNCASSERTIONMASK
 */
#define BADDIS_S                             0x80
#define NITDIS_S                             0x40
#define UCC_S                                0x20
#define CMM_FLAG_OR_MASK                     0x10
#define CMM_ENABLE                           0x08


#define CHIPID_AD9136 			    0x36
#define AD9136_MAX_DAC_RATE 		2000000000UL

#define AD9136_CHIP_TYPE            0x04
#define AD9136_PRODIDL              0x44
#define AD9136_PRODIDH              0x91

typedef struct
{
	uint8_t jesd_xbar_lane0_sel;
	uint8_t jesd_xbar_lane1_sel;
	uint8_t jesd_xbar_lane2_sel;
	uint8_t jesd_xbar_lane3_sel;
}ad9136_init_param;

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/
int32_t ad9136_setup(uint32_t spi_device_id, uint8_t slave_select);
//						ad9136_init_param init_param);
int32_t ad9136_spi_read(uint16_t reg_addr, uint8_t *reg_data);
int32_t ad9136_serdes_status(uint32_t spi_device_id, uint8_t slave_select);
int32_t ad9136_link_enable(uint32_t spi_device_id, uint8_t slave_select);

#endif
