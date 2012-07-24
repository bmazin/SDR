--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2009 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file addsb_11_0_e718a54d08a86e8b.vhd when simulating
-- the core, addsb_11_0_e718a54d08a86e8b. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
Library XilinxCoreLib;
-- synthesis translate_on
ENTITY addsb_11_0_e718a54d08a86e8b IS
	port (
	a: IN std_logic_VECTOR(28 downto 0);
	b: IN std_logic_VECTOR(28 downto 0);
	clk: IN std_logic;
	ce: IN std_logic;
	s: OUT std_logic_VECTOR(28 downto 0));
END addsb_11_0_e718a54d08a86e8b;

ARCHITECTURE addsb_11_0_e718a54d08a86e8b_a OF addsb_11_0_e718a54d08a86e8b IS
-- synthesis translate_off
component wrapped_addsb_11_0_e718a54d08a86e8b
	port (
	a: IN std_logic_VECTOR(28 downto 0);
	b: IN std_logic_VECTOR(28 downto 0);
	clk: IN std_logic;
	ce: IN std_logic;
	s: OUT std_logic_VECTOR(28 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_addsb_11_0_e718a54d08a86e8b use entity XilinxCoreLib.c_addsub_v11_0(behavioral)
		generic map(
			c_a_width => 29,
			c_out_width => 29,
			c_add_mode => 1,
			c_has_c_out => 0,
			c_b_type => 0,
			c_borrow_low => 1,
			c_ce_overrides_sclr => 0,
			c_implementation => 1,
			c_has_sclr => 0,
			c_verbosity => 0,
			c_latency => 2,
			c_has_bypass => 0,
			c_ainit_val => "0",
			c_bypass_low => 0,
			c_has_ce => 1,
			c_sclr_overrides_sset => 0,
			c_sinit_val => "0",
			c_has_sset => 0,
			c_has_c_in => 0,
			c_has_sinit => 0,
			c_b_constant => 0,
			c_ce_overrides_bypass => 1,
			c_xdevicefamily => "virtex5",
			c_a_type => 0,
			c_b_width => 29,
			c_b_value => "00000000000000000000000000000");
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_addsb_11_0_e718a54d08a86e8b
		port map (
			a => a,
			b => b,
			clk => clk,
			ce => ce,
			s => s);
-- synthesis translate_on

END addsb_11_0_e718a54d08a86e8b_a;

