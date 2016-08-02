/***************************************************************************//**
* lmk0481.h
* header file for LMK04821 Driver
* template modified by TZ
*******************************************************************************/
#ifndef LMK04821_H_
#define LMK04821_H_
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include <stdint.h>
/******************************************************************************/
/********************** Macros and Constants Definitions **********************/
/******************************************************************************/
#define LMK_RESET_CONFIG                     0x000 /* Reset and SPI Configuration Register */
#define LMK_POWERDOWN                        0x002 /* Chip Powerdown Register */
#define LMK_ID_DEVICE_TYPE                   0x003 /* Chip ID Device Type Register */
#define LMK_ID_PROD_MSB                      0x004 /* Product Identifier Register - MSB */
#define LMK_ID_PROD_LSB                      0x005 /* Product Identifier Register - LSB */
#define LMK_ID_MASKREV                       0x006 /* Product IC Version Register */
#define LMK_ID_VNDR_MSB                      0x00C /* Vendor Identifier Register - MSB */
#define LMK_ID_VNDR_LSB                      0x00D /* Vendor Identifier Register - LSB */
#define LMK_CONTROL_CLK_0_1_REG0             0x100 /* Device Clock Controls */
#define LMK_CONTROL_CLK_0_1_REG1             0x101 /* Device Clock Controls */
#define LMK_CONTROL_CLK_0_1_REG2             0x103 /* Device Clock Controls */
#define LMK_CONTROL_CLK_0_1_REG3             0x104 /* Device Clock Controls */
#define LMK_CONTROL_CLK_0_1_REG4             0x105 /* Device Clock Controls */
#define LMK_CONTROL_CLK_0_1_REG5             0x106 /* Device Clock Controls */
#define LMK_CONTROL_CLK_0_1_REG6             0x107 /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG0             0x108 /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG1             0x109 /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG2             0x10B /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG3             0x10C /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG4             0x10D /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG5             0x10E /* Device Clock Controls */
#define LMK_CONTROL_CLK_2_3_REG6             0x10F /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG0             0x110 /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG1             0x111 /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG2             0x113 /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG3             0x114 /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG4             0x115 /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG5             0x116 /* Device Clock Controls */
#define LMK_CONTROL_CLK_4_5_REG6             0x117 /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG0             0x118 /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG1             0x119 /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG2             0x11B /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG3             0x11C /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG4             0x11D /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG5             0x11E /* Device Clock Controls */
#define LMK_CONTROL_CLK_6_7_REG6             0x11F /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG0             0x120 /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG1             0x121 /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG2             0x123 /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG3             0x124 /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG4             0x125 /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG5             0x126 /* Device Clock Controls */
#define LMK_CONTROL_CLK_8_9_REG6             0x127 /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG0           0x128 /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG1           0x129 /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG2           0x12B /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG3           0x12C /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG4           0x12D /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG5           0x12E /* Device Clock Controls */
#define LMK_CONTROL_CLK_10_11_REG6           0x12F /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG0           0x130 /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG1           0x131 /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG2           0x133 /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG3           0x134 /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG4           0x135 /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG5           0x136 /* Device Clock Controls */
#define LMK_CONTROL_CLK_12_13_REG6           0x137 /* Device Clock Controls */
#define LMK_CONTROL_CLK_SOURCE               0x138 /* selects the clock distribution source */
#define LMK_CONTROL_SYSREF_MUX               0x139 /* selects source for sysref outputs */
#define LMK_SYSREF_DIVIDER_MSB               0x13A /* selects sysref output divider */
#define LMK_SYSREF_DIVIDER_LSB               0x13B /* selects sysref output divider */
#define LMK_SYSREF_DELAY_MSB                 0x13C /* selects sysref output delay */
#define LMK_SYSREF_DELAY_LSB                 0x13D /* selects sysref output delay */
#define LMK_SYSREF_PULSE_COUNT               0x13E /* selects sysref pulse count */
#define LMK_PLL_FEEDBACK_MUX                 0x13F /* selects feedback mux */
#define LMK_POWERDOWN_OSC_SYSREF             0x140 /* powerdown options for osc and sysref */
#define LMK_DELAY_ENABLE_OSC_SYSREF          0x141 /* delay enables for osc and sysref */
#define LMK_DELAY_STEP_COUNT                 0x142 /* delay adjustments */
#define LMK_SYNC_PARAMETERS                  0x143 /* set general SYNC parameters */
#define LMK_SYNC_DISABLE                     0x144 /* Sync Disable Register */
#define LMK_SET_FIXED_VALUE                  0x145 /* Fixed Value of 0x127 Register */
#define LMK_CLKIN_TYPE                       0x146 /* Clkin and Type Control Register */
#define LMK_CLKIN_CONTROL                    0x147 /* Clkin Control Register */
#define LMK_CLKIN_SELECT_CONTROL0            0x148 /* Clkin Select Control Register */
#define LMK_CLKIN_SELECT_CONTROL1            0x149 /* Clkin Select Control Register */
#define LMK_RESET_CONTROL                    0x14A /* Reset Control Register */
#define LMK_HOLDOVER_CONTROL0                0x14B /* Holdover Funtions Control Register */
#define LMK_HOLDOVER_CONTROL1                0x14C /* Holdover Funtions Control Register */
#define LMK_HOLDOVER_TRIP0                   0x14D /* Holdover Funtions Control Register */
#define LMK_HOLDOVER_TRIP1                   0x14E /* Holdover Funtions Control Register */
#define LMK_DAC_CLK_COUNTER                  0x14F /* DAC Value in Track Mode Register */
#define LMK_HOLDOVER_CONTROL2                0x150 /* DAC Value in Track Mode Register */
#define LMK_HOLDOVER_COUNT_MSB               0x151 /* Holdover Count Register */
#define LMK_HOLDOVER_COUNT_LSB               0x152 /* Holdover Count Register */
#define LMK_CLKIN0_R_DIV_MSB                 0x153 /* Clockin Divide Register */
#define LMK_CLKIN0_R_DIV_LSB                 0x154 /* Clockin Divide Register */
#define LMK_CLKIN1_R_DIV_MSB                 0x155 /* Clockin Divide Register */
#define LMK_CLKIN1_R_DIV_LSB                 0x156 /* Clockin Divide Register */
#define LMK_CLKIN2_R_DIV_MSB                 0x157 /* Clockin Divide Register */
#define LMK_CLKIN2_R_DIV_LSB                 0x158 /* Clockin Divide Register */
#define LMK_PLL1_N_DIV_MSB                   0x159 /* PLL 1 Divide Register */
#define LMK_PLL1_N_DIV_LSB                   0x15A /* PLL 1 Divide Register */
#define LMK_PLL1_PHASE_DETECTOR              0x15B /* PLL 1 Phase Detector Control Register */
#define LMK_PLL1_DELAY_CNT_MSB               0x15C /* PLL 1 Delay Count Register */
#define LMK_PLL1_DELAY_CNT_LSB               0x15D /* PLL 1 Delay Count Register */
#define LMK_PLL1_R_N_DELAY_CNT               0x15E /* PLL 1 Delay Count Register */
#define LMK_PLL1_STATUS_LD1                  0x15F /* PLL 1 Status */
#define LMK_PLL2_R_DIV_MSB                   0x160 /* PLL 2 R Divide Register */
#define LMK_PLL2_R_DIV_LSB                   0x161 /* PLL 2 R Divide Register */
#define LMK_PLL2_CONTROL                     0x162 /* PLL 2 Control Functions */
#define LMK_PLL2_N_CAL_HIGH                  0x163 /* PLL 2 Freq Calibration */
#define LMK_PLL2_N_CAL_MID                   0x164 /* PLL 2 Freq Calibration */
#define LMK_PLL2_N_CAL_LOW                   0x165 /* PLL 2 Freq Calibration */
#define LMK_PLL2_N_DIV_HIGH                  0x166 /* PLL 2 Divide Register */
#define LMK_PLL2_N_DIV_MID                   0x167 /* PLL 2 Divide Register */
#define LMK_PLL2_N_DIV_LOW                   0x168 /* PLL 2 Divide Register */
#define LMK_PLL2_PHASE_DETECTOR              0x169 /* PLL 2 Phase Detector Control Register */
#define LMK_PLL2_DELAY_CNT_MSB               0x16A /* PLL 2 Delay Count Register */
#define LMK_PLL2_DELAY_CNT_LSB               0x16B /* PLL 2 Delay Count Register */
#define LMK_PLL2_LOOP_FILTER_RES             0x16C /* PLL 2 Loop Filter Resistance Register */
#define LMK_PLL2_LOOP_FILTER_CAP             0x16D /* PLL 2 Loop Filter Capacitor Register */
#define LMK_PLL2_STATUS_LD1                  0x15F /* PLL 2 Status */
#define LMK_PLL2_POWERDOWN                   0x173 /* PLL 2 Powerdown */
#define LMK_VC01_DIVIDER                     0x174 /* VCO1 Divider */
#define LMK_VCO1_PHASE_NOISE_OPT1            0x17C /* VCO1 Optimize Phase Noise */
#define LMK_VCO1_PHASE_NOISE_OPT2            0x17D /* VCO1 Optimize Phase Noise */
#define LMK_PLL1_MISC_CONTROL1               0x182 /* PLL 1 Control Functions */
#define LMK_PLL2_MISC_CONTROL1               0x183 /* PLL 2 Control Functions */
#define LMK_CLK_MISC_CONTROL1                0x184 /* Clock Control Functions */
#define LMK_DAC_READBACK_LSB                 0x185 /* Value of the DAC */
#define LMK_DAC_HOLDOVER                     0x188 /* Value of the DAC */
#define LMK_SPI_REG_LOCK_HIGH                0x1FFD /* SPI Register Lock */
#define LMK_SPI_REG_LOCK_MID                 0x1FFE /* SPI Register Lock */
#define LMK_SPI_REG_LOCK_LOW                 0x1FFF /* SPI Register Lock */
/*
 *      LMK_RESET_CONFIG - 0x000
 */
#define RESET	                             0x80 /* RESET */
#define SPI_3WIRE_DIS                        0x10 /* 3 Wire Mode Disabled */
/*
 *      LMK_POWERDOWN - 0x002
 */
#define POWERDOWN                            0x01 /* Powerdown */
/*
 *      LMK_ID_DEVICE_TYPE - 0x003
 */
#define ID_DEVICE_TYPE                       0xFF  /* Product Device Type = 0x6 */
/*
 *      LMK_ID_PRODUCT_MSB - 0x004
 */
#define ID_PROD_MSB                          0xFF /* Product */
/*
 *      LMK_ID_PRODUCT_LSB - 0x005
 */
#define ID_PROD_LSB                          0xFF /* Product */
/*
 *      LMK_ID_MASKREV - 0x006
 */
#define ID_MASKREV                           0xFF /* Mask Revision */
/*
 *      LMK_ID_PRODUCT_MSB - 0x00C
 */
#define ID_VNDR_MSB                          0xFF /* Vendor */
/*
 *      LMK_ID_PRODUCT_LSB - 0x00D
 */
#define ID_VNDR_LSB                          0xFF /* Vendor */
/*
 *      LMK_CONTROL_CLK_0_1_REG0 - 0x100
 */
#define CLKOUT_0_1_ODL                       0x40 /* Output Drive Level */
#define CLKOUT_0_1_IDL                       0x20 /* Input Drive Level */
#define DCLKOUT_0_DIV                        0x1F /* Divider */
/*
 *      LMK_CONTROL_CLK_0_1_REG1 - 0x101
 */
#define DCLKOUT_0_DDLY_CNTH                  0xF0 /* Delay Count */
#define DCLKOUT_0_DDLY_CNTL                  0x0F /* Delay Count */
/*
 *      LMK_CONTROL_CLK_0_1_REG2 - 0x103
 */
#define DCLKOUT0_ADLY                        0xF8 /* Analog Delay Count */
#define DCLKOUT0_ADLY_MUX                    0x04 /* Analog Delay Count */
#define DCLKOUT0_MUX                         0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_0_1_REG3 - 0x104
 */
#define DCLKOUT0_HS                          0x40 /* Clock Half Step */
#define SDCLKOUT1_MUX                        0x20 /* Mux */
#define SDCLKOUT1_DDLY                       0x1E /* Delay */
#define SDCLKOUT1_HS                         0x01 /* Sysref Half Step */

/*
 *      LMK_CONTROL_CLK_0_1_REG4 - 0x105
 */
#define SDCLKOUT1_ADLY_EN                    0x10 /* Analog Delay Enable */
#define SDCLKOUT1_ADLY                       0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_0_1_REG5 - 0x106
 */
#define DCLKOUT0_DDLY_PD                     0x80 /* Powerdown digital delay */
#define DCLKOUT0_HSG_PD                      0x40 /* Powerdown half-step */
#define DCLKOUT0_ADLYG_PD                    0x20 /* Powerdown analog delay */
#define DCLKOUT0_ADLY_PD                     0x10 /* Powerdown analog delay*/
#define CLKOUT0_1_PD                         0x08 /* Powerdown clock group */
#define SDCLKOUT1_DIS_MODE                   0x06 /* SYSREF Config */
#define SDCLKOUT1_PD                         0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_0_1_REG6 - 0x107
 */
#define SDCLKOUT1_POL                        0x80 /* Clock Polarity */
#define CLKOUT1_FMT                          0x70 /* Output Format */
#define DCLKOUT0_POL                         0x08 /* Clock Polarity*/
#define CLKOUT0_FMT                          0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_2_3_REG0 - 0x108
 */
#define CLKOUT2_3_ODL                        0x40 /* Output Drive Level */
#define CLKOUT2_3_IDL                        0x20 /* Input Drive Level */
#define DCLKOUT2_DIV                         0x1F /* Divider */
/*
 *      LMK_CONTROL_CLK_2_3_REG1 - 0x109
 */
#define DCLKOUT_2_DDLY_CNTH                  0xF0 /* Digital Delay Count */
#define DCLKOUT_2_DDLY_CNTL                  0x0F /* Digital Delay Count */
/*
 *      LMK_CONTROL_CLK_2_3_REG2 - 0x10B
 */
#define DCLKOUT2_ADLY                        0xF8 /* Analog Delay Count */
#define DCLKOUT2_ADLY_MUX                    0x04 /* Analog Delay Count */
#define DCLKOUT2_MUX                         0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_2_3_REG3 - 0x10C
 */
#define DCLKOUT2_HS                          0x40 /* Clock Half Step */
#define SDCLKOUT3_MUX                        0x20 /* Mux */
#define SDCLKOUT3_DDLY                       0x1E /* Delay */
#define SDCLKOUT3_HS                         0x01 /* Sysref Half Step */
/*
 *      LMK_CONTROL_CLK_2_3_REG4 - 0x10D
 */
#define SDCLKOUT3_ADLY_EN                    0x10 /* Analog Delay Enable */
#define SDCLKOUT3_ADLY                       0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_2_3_REG5 - 0x10E
 */
#define DCLKOUT2_DDLY_PD                     0x80 /* Powerdown digital delay */
#define DCLKOUT2_HSG_PD                      0x40 /* Powerdown half-step */
#define DCLKOUT2_ADLYG_PD                    0x20 /* Powerdown analog delay */
#define DCLKOUT2_ADLY_PD                     0x10 /* Powerdown analog delay*/
#define CLKOUT2_3_PD                         0x08 /* Powerdown clock group */
#define SDCLKOUT3_DIS_MODE                   0x06 /* SYSREF Config */
#define SDCLKOUT3_PD                         0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_2_3_REG6 - 0x10F
 */
#define SDCLKOUT3_POL                        0x80 /* Clock Polarity */
#define CLKOUT3_FMT                          0x70 /* Output Format */
#define DCLKOUT2_POL                         0x08 /* Clock Polarity*/
#define CLKOUT2_FMT                          0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_4_5_REG0 - 0x110
 */
#define CLKOUT4_5_ODL                        0x40 /* Output Drive Level */
#define CLKOUT4_5_IDL                        0x20 /* Input Drive Level */
#define DCLKOUT4_DIV                         0x1F /* Divider */

/*
 *      LMK_CONTROL_CLK_4_5_REG1 - 0x111
 */
#define DCLKOUT_4_DDLY_CNTH                  0xF0 /* Digital Delay Count */
#define DCLKOUT_4_DDLY_CNTL                  0x0F /* Digital Delay Count */
/*
 *      LMK_CONTROL_CLK_4_5_REG2 - 0x113
 */
#define DCLKOUT4_ADLY                        0xF8 /* Analog Delay Count */
#define DCLKOUT4_ADLY_MUX                    0x04 /* Analog Delay Count */
#define DCLKOUT4_MUX                         0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_4_5_REG3 - 0x114
 */
#define DCLKOUT4_HS                          0x40 /* Clock Half Step */
#define SDCLKOUT5_MUX                        0x20 /* Mux */
#define SDCLKOUT5_DDLY                       0x1E /* Delay */
#define SDCLKOUT5_HS                         0x01 /* Sysref Half Step */
/*
 *      LMK_CONTROL_CLK_4_5_REG4 - 0x115
 */
#define SDCLKOUT5_ADLY_EN                    0x10 /* Analog Delay Enable */
#define SDCLKOUT5_ADLY                       0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_4_5_REG5 - 0x116
 */
#define DCLKOUT4_DDLY_PD                     0x80 /* Powerdown digital delay */
#define DCLKOUT4_HSG_PD                      0x40 /* Powerdown half-step */
#define DCLKOUT4_ADLYG_PD                    0x20 /* Powerdown analog delay */
#define DCLKOUT4_ADLY_PD                     0x10 /* Powerdown analog delay*/
#define CLKOUT4_5_PD                         0x08 /* Powerdown clock group */
#define SDCLKOUT5_DIS_MODE                   0x06 /* SYSREF Config */
#define SDCLKOUT5_PD                         0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_4_5_REG6 - 0x117
 */
#define SDCLKOUT5_POL                        0x80 /* Clock Polarity */
#define CLKOUT5_FMT                          0x70 /* Output Format */
#define DCLKOUT4_POL                         0x08 /* Clock Polarity */
#define CLKOUT4_FMT                          0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_6_7_REG0 - 0x118
 */
#define CLKOUT6_7_ODL                        0x40 /* Output Drive Level */
#define CLKOUT6_7_IDL                        0x20 /* Input Drive Level */
#define DCLKOUT6_DIV                         0x1F /* Divider */

/*
 *      LMK_CONTROL_CLK_6_7_REG1 - 0x119
 */
#define DCLKOUT_6_DDLY_CNTH                  0xF0 /* Digital Delay Count */
#define DCLKOUT_6_DDLY_CNTL                  0x0F /* Digital Delay Count */
/*
 *      LMK_CONTROL_CLK_6_7_REG2 - 0x11B
 */
#define DCLKOUT6_ADLY                        0xF8 /* Analog Delay Count */
#define DCLKOUT6_ADLY_MUX                    0x04 /* Analog Delay Count */
#define DCLKOUT6_MUX                         0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_6_7_REG3 - 0x11C
 */
#define DCLKOUT6_HS                          0x40 /* Clock Half Step */
#define SDCLKOUT7_MUX                        0x20 /* Mux */
#define SDCLKOUT7_DDLY                       0x1E /* Delay */
#define SDCLKOUT7_HS                         0x01 /* Sysref Half Step */
/*
 *      LMK_CONTROL_CLK_6_7_REG4 - 0x11D
 */
#define SDCLKOUT7_ADLY_EN                    0x10 /* Analog Delay Enable */
#define SDCLKOUT7_ADLY                       0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_6_7_REG5 - 0x11E
 */
#define DCLKOUT6_DDLY_PD                     0x80 /* Powerdown digital delay */
#define DCLKOUT6_HSG_PD                      0x40 /* Powerdown half-step */
#define DCLKOUT6_ADLYG_PD                    0x20 /* Powerdown analog delay */
#define DCLKOUT6_ADLY_PD                     0x10 /* Powerdown analog delay*/
#define CLKOUT6_7_PD                         0x08 /* Powerdown clock group */
#define SDCLKOUT7_DIS_MODE                   0x06 /* SYSREF Config */
#define SDCLKOUT7_PD                         0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_6_7_REG6 - 0x11F
 */
#define SDCLKOUT7_POL                        0x80 /* Clock Polarity */
#define CLKOUT7_FMT                          0x70 /* Output Format */
#define DCLKOUT6_POL                         0x08 /* Clock Polarity*/
#define CLKOUT6_FMT                          0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_8_9_REG0 - 0x120
 */
#define CLKOUT8_9_ODL                        0x40 /* Output Drive Level */
#define CLKOUT8_9_IDL                        0x20 /* Input Drive Level */
#define DCLKOUT8_DIV                         0x1F /* Divider */
/*
 *      LMK_CONTROL_CLK_8_9_REG1 - 0x121
 */
#define DCLKOUT_8_DDLY_CNTH                  0xF0 /* Digital Delay Count */
#define DCLKOUT_8_DDLY_CNTL                  0x0F /* Digital Delay Count */
/*
 *      LMK_CONTROL_CLK_8_9_REG2 - 0x123
 */
#define DCLKOUT8_ADLY                        0xF8 /* Analog Delay Count */
#define DCLKOUT8_ADLY_MUX                    0x04 /* Analog Delay Count */
#define DCLKOUT8_MUX                         0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_8_9_REG3 - 0x124
 */
#define DCLKOUT8_HS                          0x40 /* Clock Half Step */
#define SDCLKOUT9_MUX                        0x20 /* Mux */
#define SDCLKOUT9_DDLY                       0x1E /* Delay */
#define SDCLKOUT9_HS                         0x01 /* Sysref Half Step */
/*
 *      LMK_CONTROL_CLK_8_9_REG4 - 0x125
 */
#define SDCLKOUT9_ADLY_EN                    0x10 /* Analog Delay Enable */
#define SDCLKOUT9_ADLY                       0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_8_9_REG5 - 0x126
 */
#define DCLKOUT8_DDLY_PD                     0x80 /* Powerdown digital delay */
#define DCLKOUT8_HSG_PD                      0x40 /* Powerdown half-step */
#define DCLKOUT8_ADLYG_PD                    0x20 /* Powerdown analog delay */
#define DCLKOUT8_ADLY_PD                     0x10 /* Powerdown analog delay*/
#define CLKOUT8_9_PD                         0x08 /* Powerdown clock group */
#define SDCLKOUT9_DIS_MODE                   0x06 /* SYSREF Config */
#define SDCLKOUT9_PD                         0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_8_9_REG6 - 0x127
 */
#define SDCLKOUT9_POL                        0x80 /* Clock Polarity */
#define CLKOUT9_FMT                          0x70 /* Output Format */
#define DCLKOUT8_POL                         0x08 /* Clock Polarity*/
#define CLKOUT8_FMT                          0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_10_11_REG0 - 0x128
 */
#define CLKOUT10_11_ODL                      0x40 /* Output Drive Level */
#define CLKOUT10_11_IDL                      0x20 /* Input Drive Level */
#define DCLKOUT10_DIV                        0x1F /* Divider */
/*
 *      LMK_CONTROL_CLK_10_11_REG1 - 0x129
 */
#define DCLKOUT_10_DDLY_CNTH                 0xF0 /* Digital Delay Count */
#define DCLKOUT_10_DDLY_CNTL                 0x0F /* Digital Delay Count */
/*
 *      LMK_CONTROL_CLK_10_11_REG2 - 0x12B
 */
#define DCLKOUT10_ADLY                       0xF8 /* Analog Delay Count */
#define DCLKOUT10_ADLY_MUX                   0x04 /* Analog Delay Count */
#define DCLKOUT10_MUX                        0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_10_11_REG3 - 0x12C
 */
#define DCLKOUT10_HS                         0x40 /* Clock Half Step */
#define SDCLKOUT11_MUX                       0x20 /* Mux */
#define SDCLKOUT11_DDLY                      0x1E /* Delay */
#define SDCLKOUT11_HS                        0x01 /* Sysref Half Step */
/*
 *      LMK_CONTROL_CLK_10_11_REG4 - 0x12D
 */
#define SDCLKOUT11_ADLY_EN                   0x10 /* Analog Delay Enable */
#define SDCLKOUT11_ADLY                      0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_10_11_REG5 - 0x12E
 */
#define DCLKOUT10_DDLY_PD                    0x80 /* Powerdown digital delay */
#define DCLKOUT10_HSG_PD                     0x40 /* Powerdown half-step */
#define DCLKOUT10_ADLYG_PD                   0x20 /* Powerdown analog delay */
#define DCLKOUT10_ADLY_PD                    0x10 /* Powerdown analog delay*/
#define CLKOUT10_11_PD                       0x08 /* Powerdown clock group */
#define SDCLKOUT11_DIS_MODE                  0x06 /* SYSREF Config */
#define SDCLKOUT11_PD                        0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_10_11_REG6 - 0x12F
 */
#define SDCLKOUT11_POL                       0x80 /* Clock Polarity */
#define CLKOUT11_FMT                         0x70 /* Output Format */
#define DCLKOUT10_POL                        0x08 /* Clock Polarity*/
#define CLKOUT10_FMT                         0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_12_13_REG0 - 0x130
 */
#define CLKOUT12_13_ODL                      0x40 /* Output Drive Level */
#define CLKOUT12_13_IDL                      0x20 /* Input Drive Level */
#define DCLKOUT12_DIV                        0x1F /* Divider */
/*
 *      LMK_CONTROL_CLK_12_13_REG1 - 0x131
 */
#define DCLKOUT_12_DDLY_CNTH                 0xF0 /* Digital Delay Count */
#define DCLKOUT_12_DDLY_CNTL                 0x0F /* Digital Delay Count */
/*
 *      LMK_CONTROL_CLK_12_13_REG2 - 0x133
 */
#define DCLKOUT12_ADLY                       0xF8 /* Analog Delay Count */
#define DCLKOUT12_ADLY_MUX                   0x04 /* Analog Delay Count */
#define DCLKOUT12_MUX                        0x03 /* Mux */
/*
 *      LMK_CONTROL_CLK_12_13_REG3 - 0x134
 */
#define DCLKOUT12_HS                         0x40 /* Clock Half Step */
#define SDCLKOUT13_MUX                       0x20 /* Mux */
#define SDCLKOUT13_DDLY                      0x1E /* Delay */
#define SDCLKOUT13_HS                        0x01 /* Sysref Half Step */
/*
 *      LMK_CONTROL_CLK_12_13_REG4 - 0x135
 */
#define SDCLKOUT13_ADLY_EN                   0x10 /* Analog Delay Enable */
#define SDCLKOUT13_ADLY                      0x0F /* Analog Delay */
/*
 *      LMK_CONTROL_CLK_12_13_REG5 - 0x136
 */
#define DCLKOUT12_DDLY_PD                    0x80 /* Powerdown digital delay */
#define DCLKOUT12_HSG_PD                     0x40 /* Powerdown half-step */
#define DCLKOUT12_ADLYG_PD                   0x20 /* Powerdown analog delay */
#define DCLKOUT12_ADLY_PD                    0x10 /* Powerdown analog delay*/
#define CLKOUT12_13_PD                       0x08 /* Powerdown clock group */
#define SDCLKOUT13_DIS_MODE                  0x06 /* SYSREF Config */
#define SDCLKOUT13_PD                        0x01 /* Powerdown SDCLK */
/*
 *      LMK_CONTROL_CLK_12_13_REG6 - 0x137
 */
#define SDCLKOUT13_POL                       0x80 /* Clock Polarity */
#define CLKOUT13_FMT                         0x70 /* Output Format */
#define DCLKOUT12_POL                        0x08 /* Clock Polarity*/
#define CLKOUT12_FMT                         0x07 /* Output Format */
/*
 *      LMK_CONTROL_CLK_SOURCE - 0x138
 */
#define VCO_MUX                              0x60 /* Clock Path Source */
#define OSC_OUT_MUX                          0x10 /* Osc Output Mux */
#define OSC_OUT_FMT                          0x0F /* Osc Output Format */
/*
 *      LMK_CONTROL_SYSREF_MUX - 0x139
 */
#define SYSREF_CLKIN0_MUX                    0x04 /* Select SYSREF Output */
#define SYSREF_MUX                           0x03 /* Select SYSREF Source */
/*
 *      LMK_SYSREF_DIVIDER_MSB - 0x13A
 */
#define SYSREF_DIV_MSB                       0x1F /* Select SYSREF Source */
/*
 *      LMK_SYSREF_DIVIDER_LSB - 0x13B
 */
#define SYSREF_DIV_LSB                       0xFF /* Select SYSREF Source */
/*
 *      LMK_SYSREF_DELAY_MSB - 0x13C
 */
#define SYSREF_DDLY_MSB                      0x1F /* Select SYSREF Source */
/*
 *      LMK_SYSREF_DELAY_LSB - 0x13D
 */
#define SYSREF_DDLY_LSB                      0xFF /* Select SYSREF Source */
/*
 *      LMK_SYSREF_PULSE_COUNT - 0x13E
 */
#define SYSREF_PULSE_CNT                      0x03 /* Select Number of SYSREF Pulses */
/*
 *      LMK_PLL_FEEDBACK_MUX - 0x13F
 */
#define PLL2_NCLK_MUX                         0x10 /* Select Input to Mux */
#define PLL1_NCLK_MUX                         0x08 /* Select Input to Mux */
#define FB_MUX                                0x06 /* Select Source */
#define FB_MUX_EN                             0x01 /* Mux Enable */
/*
 *      LMK_POWERDOWN_OSC_SYSREF - 0x140
 */
#define PLL1_PD                               0x80 /* Powerdown PLL1 */
#define VCO_LDO_PD                            0x40 /* Powerdown VCO LDO */
#define VCO_PD                                0x20 /* Powerdown VCO */
#define OSC_IN_PD                             0x10 /* Powerdown Osc In Port */
#define SYSREF_GBL_PD                         0x08 /* Powerdown SYSREF Outputs */
#define SYSREF_PD                             0x04 /* Powerdown SYSREF Circuitry */
#define SYSREF_DDLY_PD                        0x02 /* Powerdown SYSREF Digital Delay */
#define SYSREF_PLSR_PD                        0x01 /* Powerdown SYSREF Pulse Generator */
/*
 *      LMK_DELAY_ENABLE_OSC_SYSREF - 0x141
 */
#define DDLY_D_SYSREF_EN                      0x80 /* Enable SYSREF Delay */
#define DDLY_D12_EN                           0x40 /* Enable DCLK12 Output Delay */
#define DDLY_D10_EN                           0x20 /* Enable DCLK10 Output Delay */
#define DDLY_D7_EN                            0x10 /* Enable DCLK7 Output Delay */
#define DDLY_D6_EN                            0x08 /* Enable DCLK6 Output Delay */
#define DDLY_D4_EN                            0x04 /* Enable DCLK4 Output Delay */
#define DDLY_D2_EN                            0x02 /* Enable DCLK2 Output Delay */
#define DDLY_D0_EN                            0x01 /* Enable DCLK0 Output Delay */
/*
 *      LMK_DELAY_STEP_COUNT - 0x142
 */
#define DDLY_D_STEP_CNT                       0x1F /* Set Number of Delay Adjustments */
/*
 *      LMK_SYNC_PARAMETERS - 0x143
 */
#define SYSREF_DDLY_CLR                       0x80 /* Set to Clear SYSREF Delay */
#define SYNC_1SHOT_EN                         0x40 /* Set SYNC One Shot Mode */
#define SYNC_POL                              0x20 /* Set SYNC Polarity */
#define SYNC_EN                               0x10 /* Set SYNC Enable */
#define SYNC_PLL2_DLD                         0x08 /* Assert SYNC Until PLL2 */
#define SYNC_PLL1_DLD                         0x04 /* Assert SYNC Until PLL1 */
#define SYNC_MODE                             0x03 /* Set Sync Mode */
/*
 *      LMK_SYNC_DISABLE - 0x144
 */
#define SYNC_DISSYSREF                        0x80 /* SYNC Disable SYSREF */
#define SYNC_DIS12                            0x40 /* SYNC Disable Clock Output */
#define SYNC_DIS10                            0x20 /* SYNC Disable Clock Output */
#define SYNC_DIS8                             0x10 /* SYNC Disable Clock Output */
#define SYNC_DIS6                             0x08 /* SYNC Disable Clock Output */
#define SYNC_DIS4                             0x04 /* SYNC Disable Clock Output */
#define SYNC_DIS2                             0x02 /* SYNC Disable Clock Output */
#define SYNC_DIS0                             0x01 /* SYNC Disable Clock Output */
/*
 *      LMK_SET_FIXED_VALUE - 0x145
 */
#define REG_FIXED127                          0x7F /* Program to 127 (0x7F) */
/*
 *      LMK_CLKIN_TYPE - 0x146
 */
#define CLKIN2_EN                             0x20 /* Enable CLKin2 For Clock Select Mode */
#define CLKIN1_EN                             0x10 /* Enable CLKin1 For Clock Select Mode */
#define CLKIN0_EN                             0x08 /* Enable CLKin0 For Clock Select Mode */
#define CLKIN2_TYPE                           0x04 /* Set CLKin2 Type */
#define CLKIN1_TYPE                           0x02 /* Set CLKin1 Type */
#define CLKIN0_TYPE                           0x01 /* Set CLKin0 Type */
/*
 *      LMK_CLKIN_CONTROL - 0x147
 */
#define CLKIN_SEL_POL                         0x80 /* Invert Clock Input Polarity */
#define CLKIN_SEL_MODE                        0x70 /* Set CLKin Mode */
#define CLKIN1_OUT_MUX                        0x0C /* Set CLK0out Mux */
#define CLKIN0_OUT_MUX                        0x03 /* Set CLK1out Mux */
/*
 *      LMK_CLKIN_SELECT_CONTROL0 - 0x148
 */
#define CLKIN_SEL0_MUX                        0x38 /* CLKin Select0 Mux */
#define CLKIN_SEL0_TYPE                       0x07 /* CLKin Select0 Type */
/*
 *      LMK_CLKIN_SELECT_CONTROL1 - 0x149
 */
#define SDIO_RDBK_TYPE                        0x70 /* Set SDIO Readback Type */
#define CLKIN_SEL1_MUX                        0x0C /* CLKin Select1 Mux */
#define CLKIN_SEL1_TYPE                       0x03 /* CLKin Select1 Type */
/*
 *      LMK_RESET_CONTROL - 0x14A
 */
#define RESET_MUX                             0x38 /* Output Value of RESET Pin */
#define RESET_TYPE                            0x07 /* Output Type of RESET Pin */
/*
 *      LMK_HOLDOVER_CONTROL0 - 0x14B
 */
#define LOS_TIMEOUT                           0xC0 /* Loss of Signal Timeout */
#define LOS_EN                                0x20 /* Enable Loss of Signal Timeout */
#define TRACK_EN                              0x10 /* Track PLL1 Tuning Voltage */
#define HOLDOVER_FORCE                        0x08 /* Forces Holdover Mode */
#define MAN_DAC_EN                            0x04 /* Set Manual DAC Mode */
#define MAN_DAC_MSB                           0x03 /* Manual DAC Mode Upper Bits */
/*
 *      LMK_HOLDOVER_CONTROL1 - 0x14C
 */
#define MAN_DAC_LSB                           0xFF /* Manual DAC Mode Lower Bits */
/*
 *      LMK_HOLDOVER_TRIP0 - 0x14D
 */
#define DAC_TRIP_LOW                          0x3F /* DAC Trip Value */
/*
 *      LMK_HOLDOVER_TRIP1 - 0x14E
 */
#define DAC_CLK_MULT                          0xC0 /* DAC Multiplier Value */
#define DAC_TRIP_HIGH                         0x3F /* DAC Trip Value */
/*
 *      LMK_DAC_CLK_COUNTER - 0x14F
 */
#define DAC_CLK_CNTR                          0xFF /* DAC Clock Counter */
/*
 *      LMK_HOLDOVER_CONTROL2 - 0x150
 */
#define CLKIN_OVERRIDE                        0x40 /* Clock Override */
#define HOLDOVER_PLL1_DET                     0x10 /* Holdover on PLL1 Detect */
#define HOLDOVER_LOS_DET                      0x08 /* Holdover on Sync Loss Detect */
#define HOLDOVER_VTUNE_DET                    0x04 /* DAC Vtune */
#define HOLDOVER_HITLESS_SWITCH               0x02 /* Hitless Switching */
#define HOLDOVER_EN                           0x01 /* Enable Holdover Mode */
/*
 *      LMK_HOLDOVER_COUNT_MSB - 0x151
 */
#define HOLDOVER_DLD_CNT_MSB                  0x3F /* Holdover Exit Counter Upper */
/*
 *      LMK_HOLDOVER_COUNT_LSB - 0x152
 */
#define HOLDOVER_DLD_CNT_LSB                  0xFF /* Holdover Exit Counter Lower */
/*
 *      LMK_CLKIN0_R_DIV_MSB - 0x153
 */
#define CLKIN0_R_MSB                         0x3F /* CLKin0 R Divider Upper */
/*
 *      LMK_CLKIN0_R_DIV_LSB - 0x154
 */
#define CLKIN0_R_LSB                         0xFF /* CLKin0 R Divider Lower */
/*
 *      LMK_CLKIN1_R_DIV_MSB - 0x155
 */
#define CLKIN1_R_MSB                         0x3F /* CLKin1 R Divider Upper */
/*
 *      LMK_CLKIN1_R_DIV_LSB - 0x156
 */
#define CLKIN1_R_LSB                         0xFF /* CLKin1 R Divider Lower */
/*
 *      LMK_CLKIN2_R_DIV_MSB - 0x157
 */
#define CLKIN2_R_MSB                         0x3F /* CLKin2 R Divider Upper */
/*
 *      LMK_CLKIN2_R_DIV_LSB - 0x158
 */
#define CLKIN2_R_LSB                         0xFF /* CLKin2 R Divider Lower */
/*
 *      LMK_PLL1_N_DIV_MSB - 0x159
 */
#define PLL1_N_MSB                           0x3F /* CLKin2 R Divider Upper */
/*
 *      LMK_PLL1_N_DIV_LSB - 0x15A
 */
#define PLL1_N_LSB                           0xFF /* CLKin2 R Divider Lower */
/*
 *      LMK_PLL1_PHASE_DETECTOR - 0x15B
 */
#define PLL1_WND_SIZE                        0xC0 /* PLL1 Window Lock Detect */
#define PLL1_CP_TRI                          0x20 /* Charge Pump Output Tristate */
#define PLL1_CP_POL                          0x10 /* Charge Pump Output Polarity */
#define PLL1_CP_GAIN                         0x0F /* Charge Pump Output Current */
/*
 *      LMK_PLL1_DELAY_CNT_MSB - 0x15C
 */
#define PLL1_DLD_CNT_MSB                     0x3F /* PLL1 DLD Counter Upper */
/*
 *      LMK_PLL1_DELAY_CNT_LSB - 0x15D
 */
#define PLL1_DLD_CNT_LSB                     0xFF /* PLL1 DLD Counter Lower */
/*
 *      LMK_PLL1_R_N_DELAY_CNT - 0x15E
 */
#define PLL1_R_DLY                           0x38 /* PLL1 R Delay */
#define PLL1_N_DLY                           0x07 /* PLL1 N Delay */
/*
 *      LMK_PLL1_STATUS_LD1 - 0x15F
 */
#define PLL1_LD_MUX                          0xF8 /* PLL1 LD Mux Output Value */
#define PLL1_LD_TYPE                         0x07 /* PLL1 LD Output Type */
/*
 *      LMK_PLL2_R_DIV_MSB - 0x160
 */
#define PLL2_R_MSB                           0x0F /* PLL2 R Divider */
/*
 *      LMK_PLL2_R_DIV_LSB - 0x161
 */
#define PLL2_R_LSB                           0xFF /* PLL2 R Divider */
/*
 *      LMK_PLL2_CONTROL - 0x162
 */
#define PLL2_P                               0xE0 /* PLL2 N Prescaler */
#define OSCIN_FREQ                           0x1C /* Osc Lock Frequency Range */
#define PLL2_XTAL_EN                         0x02 /* Enable use XTAL  */
#define PLL2_REF_2X_EN                       0x01 /* Enable PLL2 Freq Doubler */
/*
 *      LMK_PLL2_N_CAL_HIGH - 0x163
 */
#define PLL2_N_CAL_HIGH                      0x03 /* PLL2 N Calibration Divider */
/*
 *      LMK_PLL2_N_CAL_MID - 0x164
 */
#define PLL2_N_CAL_MID                       0xFF /* PLL2 N Calibration Divider */
/*
 *      LMK_PLL2_N_CAL_LOW - 0x165
 */
#define PLL2_N_CAL_LOW                       0xFF /* PLL2 N Calibration Divider */

/*
 *      LMK_PLL2_N_DIV_HIGH - 0x166
 */
#define PLL2_FCAL_DIS                        0x04 /* PLL2 Calibration Disable */
#define PLL2_N_HIGH                          0x03 /* PLL2 N Divider */
/*
 *      LMK_PLL2_N_DIV_MID - 0x167
 */
#define PLL2_N_MID                           0xFF /* PLL2 N Divider */
/*
 *      LMK_PLL2_N_DIV_LOW - 0x168
 */
#define PLL2_N_LOW                           0xFF /* PLL2 N Divider */
/*
 *      LMK_PLL2_PHASE_DETECTOR - 0x169
 */
#define PLL2_WND_SIZE                        0x60 /* PLL1 Window Lock Detect */
#define PLL2_CP_TRI                          0x18 /* Charge Pump Output Tristate */
#define PLL2_CP_POL                          0x04 /* Charge Pump Output Polarity */
#define PLL2_CP_GAIN                         0x02 /* Charge Pump Output Current */
#define PLL2_FIXED1                          0x01 /* Program with a 0x01 */
/*
 *      LMK_PLL2_DELAY_CNT_MSB - 0x16A
 */
#define SYSREF_REQ_EN                        0x40 /* Enable Continuous Pulses */
#define PLL2_DLD_CNT_MSB                     0x3F /* PLL2 DLD Counter Upper */
/*
 *      LMK_PLL2_DELAY_CNT_LSB - 0x16B
 */
#define PLL2_DLD_CNT_LSB                     0xFF /* PLL1 DLD Counter Lower */
/*
 *      LMK_PLL2_LOOP_FILTER_RES - 0x16C
 */
#define PLL2_LF_R4                           0x38 /* Loop Filter Resister4 Value */
#define PLL2_LF_R3                           0x07 /* Loop Filter Resister3 Value */
/*
 *      LMK_PLL2_LOOP_FILTER_CAP - 0x16D
 */
#define PLL2_LF_C4                           0x38 /* Loop Filter Capacitor4 Value */
#define PLL2_LF_C3                           0x07 /* Loop Filter Capacitor3 Value */
/*
 *      LMK_PLL2_STATUS_LD1 - 0x16E
 */
#define PLL2_LD_MUX                          0xF8 /* Status LD2 output select */
#define PLL2_LD_TYPE                         0x07 /* Status LD2 output type */
/*
 *      LMK_PLL2_POWERDOWN - 0x173
 */
#define PLL2_PRE_PD                          0x40 /* Powerdown PLL2 prescaler */
#define PLL2_PD                              0x20 /* Powerdown PLL2 */
/*
 *      LMK_VC01_DIVIDER - 0x174
 */
#define VCO1_DIV                             0x1F /* VCO1 Divider */
/*
 *      LMK_VCO1_PHASE_NOISE_OPT1 - 0x17C
 */
#define OPT_REG_1                            0xFF /* No Value given for LMK04821 */
/*
 *      LMK_VCO1_PHASE_NOISE_OPT2 - 0x17D
 */
#define OPT_REG_2                            0xFF /* No Value given for LMK04821 */
/*
 *      LMK_PLL1_MISC_CONTROL1 - 0x182
 */
#define RB_PLL1_LD_LOST                      0x04 /* Set when PLL1 DLD edge falls */
#define RB_PLL1_LD                           0x02 /* Is 0 When PLL1 DLD is high */
#define CLR_PLL1_LD_LOST                     0x01 /* Clear PLL1 LD Lost */
/*
 *      LMK_PLL2_MISC_CONTROL1 - 0x183
 */
#define RB_PLL2_LD_LOST                      0x04 /* Set when PLL2 DLD edge falls */
#define RB_PLL2_LD                           0x02 /* Is 0 When PLL2 DLD is high */
#define CLR_PLL2_LD_LOST                     0x01 /* Clear PLL2 LD Lost */
/*
 *      LMK_CLK_MISC_CONTROL1 - 0x184
 */
#define RB_DAC_VALUE_MSB                     0xC0 /* Readback DAC Value */
#define RB_CLKIN2_SEL                        0x20 /* When Set, CLKIN2 to PLL1 */
#define RB_CLKIN1_SEL                        0x10 /* When Set, CLKIN1 to PLL1 */
#define RB_CLKIN0_SEL                        0x08 /* When Set, CLKIN0 to PLL1 */
#define RB_CLKIN1_LOS                        0x02 /* When Set, CLKIN1 LOS */
#define RB_CLKIN0_LOS                        0x01 /* When Set, CLKIN0 LOS */
/*
 *      LMK_DAC_READBACK_LSB - 0x185
 */
#define RB_DAC_VALUE_LSB                     0xFF /* Readback DAC Value */
/*
 *      LMK_DAC_HOLDOVER - 0x188
 */
#define RB_HOLDOVER                          0x10 /* When Set, in Holdover */
/*
 *      LMK_SPI_REG_LOCK_HIGH - 0x1FD
 */
#define SPI_LOCK_HIGH                        0xFF /* When Set, Registers Locked */
/*
 *      LMK_SPI_REG_LOCK_MID - 0x1FE
 */
#define RB_HOLDOVER_MID                      0xFF /* When Set, Registers Locked */
/*
 *      LMK_SPI_REG_LOCK_LOW - 0x1FF
 */
#define RB_HOLDOVER_LOW                      0xFF /* When Set, Registers Locked */
/*
 *      IC Constants
 */
#define LMK04821_MAX_DAC_RATE 		2000000000UL
#define LMK04821_DEVICE_ID    0x06
#define LMK04821_PROD_ID_MSB  0xD0
#define LMK04821_PROD_ID_LSB  0x5B
#define LMK04821_ID_MASKREV   0x25 // value is not given in data sheet
#define LMK04821_VNDR_ID_MSB  0x51
#define LMK04821_VNDR_ID_LSB  0x04

/******************************************************************************/
/************************ Functions Declarations ******************************/
/******************************************************************************/

int32_t lmk04821_spi_read(uint16_t reg_addr, uint8_t *reg_data);
int32_t lmk04821_spi_write(uint16_t reg_addr, uint8_t reg_data);
int32_t lmk04821_setup(uint32_t spi_device_id, uint8_t slave_select);

#endif
