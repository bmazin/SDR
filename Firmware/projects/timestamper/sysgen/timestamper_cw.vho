
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
component timestamper_cw  port (
    ce: in std_logic := '1'; 
    clk: in std_logic; -- clock period = 3.9062 ns (256.00327684194355 Mhz)
    timestamper_adc_mkid_user_data_i0: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_data_i1: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_data_q0: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_data_q1: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_sync: in std_logic; 
    timestamper_pulses_bram0_data_out: in std_logic_vector(31 downto 0); 
    timestamper_pulses_bram1_data_out: in std_logic_vector(31 downto 0); 
    timestamper_startbuffer_user_data_out: in std_logic_vector(31 downto 0); 
    timestamper_pulses_addr_user_data_in: out std_logic_vector(31 downto 0); 
    timestamper_pulses_bram0_addr: out std_logic_vector(13 downto 0); 
    timestamper_pulses_bram0_data_in: out std_logic_vector(31 downto 0); 
    timestamper_pulses_bram0_we: out std_logic; 
    timestamper_pulses_bram1_addr: out std_logic_vector(13 downto 0); 
    timestamper_pulses_bram1_data_in: out std_logic_vector(31 downto 0); 
    timestamper_pulses_bram1_we: out std_logic; 
    timestamper_seconds_user_data_in: out std_logic_vector(31 downto 0)
  );
end component;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body.  Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : timestamper_cw
  port map (
    ce => ce,
    clk => clk,
    timestamper_adc_mkid_user_data_i0 => timestamper_adc_mkid_user_data_i0,
    timestamper_adc_mkid_user_data_i1 => timestamper_adc_mkid_user_data_i1,
    timestamper_adc_mkid_user_data_q0 => timestamper_adc_mkid_user_data_q0,
    timestamper_adc_mkid_user_data_q1 => timestamper_adc_mkid_user_data_q1,
    timestamper_adc_mkid_user_sync => timestamper_adc_mkid_user_sync,
    timestamper_pulses_bram0_data_out => timestamper_pulses_bram0_data_out,
    timestamper_pulses_bram1_data_out => timestamper_pulses_bram1_data_out,
    timestamper_startbuffer_user_data_out => timestamper_startbuffer_user_data_out,
    timestamper_pulses_addr_user_data_in => timestamper_pulses_addr_user_data_in,
    timestamper_pulses_bram0_addr => timestamper_pulses_bram0_addr,
    timestamper_pulses_bram0_data_in => timestamper_pulses_bram0_data_in,
    timestamper_pulses_bram0_we => timestamper_pulses_bram0_we,
    timestamper_pulses_bram1_addr => timestamper_pulses_bram1_addr,
    timestamper_pulses_bram1_data_in => timestamper_pulses_bram1_data_in,
    timestamper_pulses_bram1_we => timestamper_pulses_bram1_we,
    timestamper_seconds_user_data_in => timestamper_seconds_user_data_in);
-- INST_TAG_END ------ End INSTANTIATION Template ------------
