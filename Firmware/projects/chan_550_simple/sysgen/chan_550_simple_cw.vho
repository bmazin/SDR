
-------------------------------------------------------------------
-- System Generator version 11.4 VHDL source file.
--
-- Copyright(C) 2009 by Xilinx, Inc.  All rights reserved.  This
-- text/file contains proprietary, confidential information of Xilinx,
-- Inc., is distributed under license from Xilinx, Inc., and may be used,
-- copied and/or disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc.  Xilinx hereby grants you a license to use
-- this text/file solely for design, simulation, implementation and
-- creation of design files limited to Xilinx devices or technologies.
-- Use with non-Xilinx devices or technologies is expressly prohibited
-- and immediately terminates your license unless covered by a separate
-- agreement.
--
-- Xilinx is providing this design, code, or information "as is" solely
-- for use in developing programs and solutions for Xilinx devices.  By
-- providing this design, code, or information as one possible
-- implementation of this feature, application or standard, Xilinx is
-- making no representation that this implementation is free from any
-- claims of infringement.  You are responsible for obtaining any rights
-- you may require for your implementation.  Xilinx expressly disclaims
-- any warranty whatsoever with respect to the adequacy of the
-- implementation, including but not limited to warranties of
-- merchantability or fitness for a particular purpose.
--
-- Xilinx products are not intended for use in life support appliances,
-- devices, or systems.  Use in such applications is expressly prohibited.
--
-- Any modifications that are made to the source code are done at the user's
-- sole risk and will be unsupported.
--
-- This copyright and support notice must be retained as part of this
-- text at all times.  (c) Copyright 1995-2009 Xilinx, Inc.  All rights
-- reserved.
-------------------------------------------------------------------
-- The following code must appear in the VHDL architecture header:

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component chan_550_simple_cw  port (
    ce: in std_logic := '1'; 
    chan_550_simple_adc_mkid_user_data_i0: in std_logic_vector(11 downto 0); 
    chan_550_simple_adc_mkid_user_data_i1: in std_logic_vector(11 downto 0); 
    chan_550_simple_adc_mkid_user_data_q0: in std_logic_vector(11 downto 0); 
    chan_550_simple_adc_mkid_user_data_q1: in std_logic_vector(11 downto 0); 
    chan_550_simple_adc_mkid_user_sync: in std_logic; 
    chan_550_simple_avgiq_bram_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_avgiq_ctrl_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_bins_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_capture_load_thresh_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_capture_threshold_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_ch_we_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_conv_phase_centers_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_conv_phase_load_centers_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_dram_lut_dram_mem_cmd_ack: in std_logic; 
    chan_550_simple_dram_lut_dram_mem_rd_dout: in std_logic_vector(143 downto 0); 
    chan_550_simple_dram_lut_dram_mem_rd_tag: in std_logic_vector(31 downto 0); 
    chan_550_simple_dram_lut_dram_mem_rd_valid: in std_logic; 
    chan_550_simple_dram_lut_dram_phy_ready: in std_logic; 
    chan_550_simple_fir_b0b1_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b10b11_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b12b13_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b14b15_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b16b17_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b18b19_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b20b21_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b22b23_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b24b25_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b2b3_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b4b5_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b6b7_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_b8b9_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_fir_load_coeff_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_if_switch_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_lo_sle_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_load_bins_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_pulses_bram0_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_pulses_bram1_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_regs_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_ser_di_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_snapphase_bram_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_snapphase_ctrl_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_start_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_startaccumulator_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_startbuffer_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_startdac_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_startsnap_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_stb_en_user_data_out: in std_logic_vector(31 downto 0); 
    chan_550_simple_swat_le_user_data_out: in std_logic_vector(31 downto 0); 
    clk: in std_logic; -- clock period = 3.6364 ns (274.9972500274997 Mhz)
    chan_550_simple_avgiq_addr_user_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_avgiq_bram_addr: out std_logic_vector(9 downto 0); 
    chan_550_simple_avgiq_bram_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_avgiq_bram_we: out std_logic; 
    chan_550_simple_dac_mkid_dac_data_i0: out std_logic_vector(15 downto 0); 
    chan_550_simple_dac_mkid_dac_data_i1: out std_logic_vector(15 downto 0); 
    chan_550_simple_dac_mkid_dac_data_q0: out std_logic_vector(15 downto 0); 
    chan_550_simple_dac_mkid_dac_data_q1: out std_logic_vector(15 downto 0); 
    chan_550_simple_dac_mkid_dac_sync_i: out std_logic; 
    chan_550_simple_dac_mkid_dac_sync_q: out std_logic; 
    chan_550_simple_dac_mkid_not_reset: out std_logic; 
    chan_550_simple_dac_mkid_not_sdenb_i: out std_logic; 
    chan_550_simple_dac_mkid_not_sdenb_q: out std_logic; 
    chan_550_simple_dac_mkid_sclk: out std_logic; 
    chan_550_simple_dac_mkid_sdi: out std_logic; 
    chan_550_simple_dram_lut_dram_mem_cmd_address: out std_logic_vector(31 downto 0); 
    chan_550_simple_dram_lut_dram_mem_cmd_rnw: out std_logic; 
    chan_550_simple_dram_lut_dram_mem_cmd_tag: out std_logic_vector(31 downto 0); 
    chan_550_simple_dram_lut_dram_mem_cmd_valid: out std_logic; 
    chan_550_simple_dram_lut_dram_mem_rd_ack: out std_logic; 
    chan_550_simple_dram_lut_dram_mem_rst: out std_logic; 
    chan_550_simple_dram_lut_dram_mem_wr_be: out std_logic_vector(17 downto 0); 
    chan_550_simple_dram_lut_dram_mem_wr_din: out std_logic_vector(143 downto 0); 
    chan_550_simple_dram_lut_rd_valid_user_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_gpio_a0_gateway: out std_logic; 
    chan_550_simple_gpio_a1_gateway: out std_logic; 
    chan_550_simple_gpio_a2_gateway: out std_logic; 
    chan_550_simple_gpio_a3_gateway: out std_logic; 
    chan_550_simple_gpio_a5_gateway: out std_logic; 
    chan_550_simple_pulses_addr_user_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_pulses_bram0_addr: out std_logic_vector(13 downto 0); 
    chan_550_simple_pulses_bram0_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_pulses_bram0_we: out std_logic; 
    chan_550_simple_pulses_bram1_addr: out std_logic_vector(13 downto 0); 
    chan_550_simple_pulses_bram1_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_pulses_bram1_we: out std_logic; 
    chan_550_simple_seconds_user_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_snapphase_addr_user_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_snapphase_bram_addr: out std_logic_vector(9 downto 0); 
    chan_550_simple_snapphase_bram_data_in: out std_logic_vector(31 downto 0); 
    chan_550_simple_snapphase_bram_we: out std_logic
  );
end component;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body.  Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : chan_550_simple_cw
  port map (
    ce => ce,
    chan_550_simple_adc_mkid_user_data_i0 => chan_550_simple_adc_mkid_user_data_i0,
    chan_550_simple_adc_mkid_user_data_i1 => chan_550_simple_adc_mkid_user_data_i1,
    chan_550_simple_adc_mkid_user_data_q0 => chan_550_simple_adc_mkid_user_data_q0,
    chan_550_simple_adc_mkid_user_data_q1 => chan_550_simple_adc_mkid_user_data_q1,
    chan_550_simple_adc_mkid_user_sync => chan_550_simple_adc_mkid_user_sync,
    chan_550_simple_avgiq_bram_data_out => chan_550_simple_avgiq_bram_data_out,
    chan_550_simple_avgiq_ctrl_user_data_out => chan_550_simple_avgiq_ctrl_user_data_out,
    chan_550_simple_bins_user_data_out => chan_550_simple_bins_user_data_out,
    chan_550_simple_capture_load_thresh_user_data_out => chan_550_simple_capture_load_thresh_user_data_out,
    chan_550_simple_capture_threshold_user_data_out => chan_550_simple_capture_threshold_user_data_out,
    chan_550_simple_ch_we_user_data_out => chan_550_simple_ch_we_user_data_out,
    chan_550_simple_conv_phase_centers_user_data_out => chan_550_simple_conv_phase_centers_user_data_out,
    chan_550_simple_conv_phase_load_centers_user_data_out => chan_550_simple_conv_phase_load_centers_user_data_out,
    chan_550_simple_dram_lut_dram_mem_cmd_ack => chan_550_simple_dram_lut_dram_mem_cmd_ack,
    chan_550_simple_dram_lut_dram_mem_rd_dout => chan_550_simple_dram_lut_dram_mem_rd_dout,
    chan_550_simple_dram_lut_dram_mem_rd_tag => chan_550_simple_dram_lut_dram_mem_rd_tag,
    chan_550_simple_dram_lut_dram_mem_rd_valid => chan_550_simple_dram_lut_dram_mem_rd_valid,
    chan_550_simple_dram_lut_dram_phy_ready => chan_550_simple_dram_lut_dram_phy_ready,
    chan_550_simple_fir_b0b1_user_data_out => chan_550_simple_fir_b0b1_user_data_out,
    chan_550_simple_fir_b10b11_user_data_out => chan_550_simple_fir_b10b11_user_data_out,
    chan_550_simple_fir_b12b13_user_data_out => chan_550_simple_fir_b12b13_user_data_out,
    chan_550_simple_fir_b14b15_user_data_out => chan_550_simple_fir_b14b15_user_data_out,
    chan_550_simple_fir_b16b17_user_data_out => chan_550_simple_fir_b16b17_user_data_out,
    chan_550_simple_fir_b18b19_user_data_out => chan_550_simple_fir_b18b19_user_data_out,
    chan_550_simple_fir_b20b21_user_data_out => chan_550_simple_fir_b20b21_user_data_out,
    chan_550_simple_fir_b22b23_user_data_out => chan_550_simple_fir_b22b23_user_data_out,
    chan_550_simple_fir_b24b25_user_data_out => chan_550_simple_fir_b24b25_user_data_out,
    chan_550_simple_fir_b2b3_user_data_out => chan_550_simple_fir_b2b3_user_data_out,
    chan_550_simple_fir_b4b5_user_data_out => chan_550_simple_fir_b4b5_user_data_out,
    chan_550_simple_fir_b6b7_user_data_out => chan_550_simple_fir_b6b7_user_data_out,
    chan_550_simple_fir_b8b9_user_data_out => chan_550_simple_fir_b8b9_user_data_out,
    chan_550_simple_fir_load_coeff_user_data_out => chan_550_simple_fir_load_coeff_user_data_out,
    chan_550_simple_if_switch_user_data_out => chan_550_simple_if_switch_user_data_out,
    chan_550_simple_lo_sle_user_data_out => chan_550_simple_lo_sle_user_data_out,
    chan_550_simple_load_bins_user_data_out => chan_550_simple_load_bins_user_data_out,
    chan_550_simple_pulses_bram0_data_out => chan_550_simple_pulses_bram0_data_out,
    chan_550_simple_pulses_bram1_data_out => chan_550_simple_pulses_bram1_data_out,
    chan_550_simple_regs_user_data_out => chan_550_simple_regs_user_data_out,
    chan_550_simple_ser_di_user_data_out => chan_550_simple_ser_di_user_data_out,
    chan_550_simple_snapphase_bram_data_out => chan_550_simple_snapphase_bram_data_out,
    chan_550_simple_snapphase_ctrl_user_data_out => chan_550_simple_snapphase_ctrl_user_data_out,
    chan_550_simple_start_user_data_out => chan_550_simple_start_user_data_out,
    chan_550_simple_startaccumulator_user_data_out => chan_550_simple_startaccumulator_user_data_out,
    chan_550_simple_startbuffer_user_data_out => chan_550_simple_startbuffer_user_data_out,
    chan_550_simple_startdac_user_data_out => chan_550_simple_startdac_user_data_out,
    chan_550_simple_startsnap_user_data_out => chan_550_simple_startsnap_user_data_out,
    chan_550_simple_stb_en_user_data_out => chan_550_simple_stb_en_user_data_out,
    chan_550_simple_swat_le_user_data_out => chan_550_simple_swat_le_user_data_out,
    clk => clk,
    chan_550_simple_avgiq_addr_user_data_in => chan_550_simple_avgiq_addr_user_data_in,
    chan_550_simple_avgiq_bram_addr => chan_550_simple_avgiq_bram_addr,
    chan_550_simple_avgiq_bram_data_in => chan_550_simple_avgiq_bram_data_in,
    chan_550_simple_avgiq_bram_we => chan_550_simple_avgiq_bram_we,
    chan_550_simple_dac_mkid_dac_data_i0 => chan_550_simple_dac_mkid_dac_data_i0,
    chan_550_simple_dac_mkid_dac_data_i1 => chan_550_simple_dac_mkid_dac_data_i1,
    chan_550_simple_dac_mkid_dac_data_q0 => chan_550_simple_dac_mkid_dac_data_q0,
    chan_550_simple_dac_mkid_dac_data_q1 => chan_550_simple_dac_mkid_dac_data_q1,
    chan_550_simple_dac_mkid_dac_sync_i => chan_550_simple_dac_mkid_dac_sync_i,
    chan_550_simple_dac_mkid_dac_sync_q => chan_550_simple_dac_mkid_dac_sync_q,
    chan_550_simple_dac_mkid_not_reset => chan_550_simple_dac_mkid_not_reset,
    chan_550_simple_dac_mkid_not_sdenb_i => chan_550_simple_dac_mkid_not_sdenb_i,
    chan_550_simple_dac_mkid_not_sdenb_q => chan_550_simple_dac_mkid_not_sdenb_q,
    chan_550_simple_dac_mkid_sclk => chan_550_simple_dac_mkid_sclk,
    chan_550_simple_dac_mkid_sdi => chan_550_simple_dac_mkid_sdi,
    chan_550_simple_dram_lut_dram_mem_cmd_address => chan_550_simple_dram_lut_dram_mem_cmd_address,
    chan_550_simple_dram_lut_dram_mem_cmd_rnw => chan_550_simple_dram_lut_dram_mem_cmd_rnw,
    chan_550_simple_dram_lut_dram_mem_cmd_tag => chan_550_simple_dram_lut_dram_mem_cmd_tag,
    chan_550_simple_dram_lut_dram_mem_cmd_valid => chan_550_simple_dram_lut_dram_mem_cmd_valid,
    chan_550_simple_dram_lut_dram_mem_rd_ack => chan_550_simple_dram_lut_dram_mem_rd_ack,
    chan_550_simple_dram_lut_dram_mem_rst => chan_550_simple_dram_lut_dram_mem_rst,
    chan_550_simple_dram_lut_dram_mem_wr_be => chan_550_simple_dram_lut_dram_mem_wr_be,
    chan_550_simple_dram_lut_dram_mem_wr_din => chan_550_simple_dram_lut_dram_mem_wr_din,
    chan_550_simple_dram_lut_rd_valid_user_data_in => chan_550_simple_dram_lut_rd_valid_user_data_in,
    chan_550_simple_gpio_a0_gateway => chan_550_simple_gpio_a0_gateway,
    chan_550_simple_gpio_a1_gateway => chan_550_simple_gpio_a1_gateway,
    chan_550_simple_gpio_a2_gateway => chan_550_simple_gpio_a2_gateway,
    chan_550_simple_gpio_a3_gateway => chan_550_simple_gpio_a3_gateway,
    chan_550_simple_gpio_a5_gateway => chan_550_simple_gpio_a5_gateway,
    chan_550_simple_pulses_addr_user_data_in => chan_550_simple_pulses_addr_user_data_in,
    chan_550_simple_pulses_bram0_addr => chan_550_simple_pulses_bram0_addr,
    chan_550_simple_pulses_bram0_data_in => chan_550_simple_pulses_bram0_data_in,
    chan_550_simple_pulses_bram0_we => chan_550_simple_pulses_bram0_we,
    chan_550_simple_pulses_bram1_addr => chan_550_simple_pulses_bram1_addr,
    chan_550_simple_pulses_bram1_data_in => chan_550_simple_pulses_bram1_data_in,
    chan_550_simple_pulses_bram1_we => chan_550_simple_pulses_bram1_we,
    chan_550_simple_seconds_user_data_in => chan_550_simple_seconds_user_data_in,
    chan_550_simple_snapphase_addr_user_data_in => chan_550_simple_snapphase_addr_user_data_in,
    chan_550_simple_snapphase_bram_addr => chan_550_simple_snapphase_bram_addr,
    chan_550_simple_snapphase_bram_data_in => chan_550_simple_snapphase_bram_data_in,
    chan_550_simple_snapphase_bram_we => chan_550_simple_snapphase_bram_we);
-- INST_TAG_END ------ End INSTANTIATION Template ------------
