////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2009 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: L.68
//  \   \         Application: netgen
//  /   /         Filename: addsb_11_0_9db836eedcd20079.v
// /___/   /\     Timestamp: Tue Jun 26 17:55:00 2012
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -w -sim -ofmt verilog ./tmp/_cg/addsb_11_0_9db836eedcd20079.ngc ./tmp/_cg/addsb_11_0_9db836eedcd20079.v 
// Device	: 5vlx20tff323-2
// Input file	: ./tmp/_cg/addsb_11_0_9db836eedcd20079.ngc
// Output file	: ./tmp/_cg/addsb_11_0_9db836eedcd20079.v
// # of Modules	: 1
// Design Name	: addsb_11_0_9db836eedcd20079
// Xilinx        : /opt/Xilinx/11.1/ISE
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module addsb_11_0_9db836eedcd20079 (
  ce, clk, a, b, s
)/* synthesis syn_black_box syn_noprune=1 */;
  input ce;
  input clk;
  input [16 : 0] a;
  input [16 : 0] b;
  output [16 : 0] s;
  
  // synthesis translate_off
  
  wire \BU2/N1 ;
  wire \BU2/c_out ;
  wire NLW_VCC_P_UNCONNECTED;
  wire NLW_GND_G_UNCONNECTED;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PATTERNBDETECT_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PATTERNDETECT_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_OVERFLOW_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_UNDERFLOW_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYCASCOUT_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_MULTSIGNOUT_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(47)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(46)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(45)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(44)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(43)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(42)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(41)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(40)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(39)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(38)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(37)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(36)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(35)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(34)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(33)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(32)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(31)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(30)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(29)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(28)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(27)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(26)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(25)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(24)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(23)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(22)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(21)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(20)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(19)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(18)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(17)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(16)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(15)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(14)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(13)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(12)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(11)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(10)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(9)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(8)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(7)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(6)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(5)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(4)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(3)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(2)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(1)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(0)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(47)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(46)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(45)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(44)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(43)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(42)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(41)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(40)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(39)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(38)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(37)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(36)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(35)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(34)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(33)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(32)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(31)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(30)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(29)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(28)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(27)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(26)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(25)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(24)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(23)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(22)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(21)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(20)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(19)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(18)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(17)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(17)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(16)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(15)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(14)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(13)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(12)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(11)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(10)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(9)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(8)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(7)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(6)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(5)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(4)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(3)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(2)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(1)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(0)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(29)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(28)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(27)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(26)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(25)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(24)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(23)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(22)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(21)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(20)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(19)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(18)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(17)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(16)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(15)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(14)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(13)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(12)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(11)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(10)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(9)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(8)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(7)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(6)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(5)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(4)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(3)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(2)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(1)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(0)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(3)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(2)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(1)_UNCONNECTED ;
  wire \NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(0)_UNCONNECTED ;
  VCC   VCC_0 (
    .P(NLW_VCC_P_UNCONNECTED)
  );
  GND   GND_1 (
    .G(NLW_GND_G_UNCONNECTED)
  );
  DSP48E #(
    .ACASCREG ( 1 ),
    .ALUMODEREG ( 1 ),
    .AREG ( 1 ),
    .AUTORESET_PATTERN_DETECT ( "FALSE" ),
    .AUTORESET_PATTERN_DETECT_OPTINV ( "MATCH" ),
    .A_INPUT ( "DIRECT" ),
    .BCASCREG ( 1 ),
    .BREG ( 1 ),
    .B_INPUT ( "DIRECT" ),
    .CARRYINREG ( 1 ),
    .CARRYINSELREG ( 1 ),
    .CREG ( 1 ),
    .PATTERN ( 48'h000000000000 ),
    .MREG ( 0 ),
    .MULTCARRYINREG ( 0 ),
    .OPMODEREG ( 1 ),
    .PREG ( 1 ),
    .SEL_MASK ( "MASK" ),
    .SEL_PATTERN ( "PATTERN" ),
    .SEL_ROUNDING_MASK ( "SEL_MASK" ),
    .SIM_MODE ( "SAFE" ),
    .USE_MULT ( "NONE" ),
    .USE_PATTERN_DETECT ( "NO_PATDET" ),
    .USE_SIMD ( "ONE48" ),
    .MASK ( 48'h3FFFFFFFFFFF ))
  \BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive  (
    .CARRYIN(\BU2/c_out ),
    .CEA1(\BU2/c_out ),
    .CEA2(ce),
    .CEB1(\BU2/c_out ),
    .CEB2(ce),
    .CEC(ce),
    .CECTRL(ce),
    .CEP(ce),
    .CEM(\BU2/c_out ),
    .CECARRYIN(ce),
    .CEMULTCARRYIN(\BU2/c_out ),
    .CLK(clk),
    .RSTA(\BU2/c_out ),
    .RSTB(\BU2/c_out ),
    .RSTC(\BU2/c_out ),
    .RSTCTRL(\BU2/c_out ),
    .RSTP(\BU2/c_out ),
    .RSTM(\BU2/c_out ),
    .RSTALLCARRYIN(\BU2/c_out ),
    .CEALUMODE(ce),
    .RSTALUMODE(\BU2/c_out ),
    .PATTERNBDETECT
(\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PATTERNBDETECT_UNCONNECTED )
,
    .PATTERNDETECT
(\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PATTERNDETECT_UNCONNECTED )
,
    .OVERFLOW
(\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_OVERFLOW_UNCONNECTED )
,
    .UNDERFLOW
(\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_UNDERFLOW_UNCONNECTED )
,
    .CARRYCASCIN(\BU2/c_out ),
    .CARRYCASCOUT
(\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYCASCOUT_UNCONNECTED )
,
    .MULTSIGNIN(\BU2/N1 ),
    .MULTSIGNOUT
(\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_MULTSIGNOUT_UNCONNECTED )
,
    .A({b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], 
b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16], b[16]}),
    .PCIN({\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out }),
    .B({b[16], b[16], b[15], b[14], b[13], b[12], b[11], b[10], b[9], b[8], b[7], b[6], b[5], b[4], b[3], b[2], b[1], b[0]}),
    .C({a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], 
a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[16], a[15], a[14], a[13], a[12], a[11], a[10], a[9], a[8], a[7], a[6], 
a[5], a[4], a[3], a[2], a[1], a[0]}),
    .CARRYINSEL({\BU2/c_out , \BU2/c_out , \BU2/c_out }),
    .OPMODE({\BU2/c_out , \BU2/N1 , \BU2/N1 , \BU2/c_out , \BU2/c_out , \BU2/N1 , \BU2/N1 }),
    .BCIN({\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out }),
    .ALUMODE({\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out }),
    .PCOUT({
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(47)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(46)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(45)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(44)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(43)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(42)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(41)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(40)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(39)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(38)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(37)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(36)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(35)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(34)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(33)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(32)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(31)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(30)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(29)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(28)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(27)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(26)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(25)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(24)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(23)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(22)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(21)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(20)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(19)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(18)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(17)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(16)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(15)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(14)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(13)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(12)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(11)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(10)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(9)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(8)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(7)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(6)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(5)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(4)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(3)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(2)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(1)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_PCOUT(0)_UNCONNECTED 
}),
    .P({
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(47)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(46)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(45)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(44)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(43)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(42)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(41)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(40)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(39)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(38)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(37)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(36)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(35)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(34)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(33)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(32)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(31)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(30)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(29)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(28)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(27)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(26)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(25)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(24)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(23)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(22)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(21)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(20)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(19)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(18)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_P(17)_UNCONNECTED 
, s[16], s[15], s[14], s[13], s[12], s[11], s[10], s[9], s[8], s[7], s[6], s[5], s[4], s[3], s[2], s[1], s[0]}),
    .BCOUT({
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(17)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(16)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(15)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(14)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(13)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(12)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(11)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(10)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(9)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(8)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(7)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(6)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(5)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(4)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(3)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(2)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(1)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_BCOUT(0)_UNCONNECTED 
}),
    .ACIN({\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , 
\BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out , \BU2/c_out }),
    .ACOUT({
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(29)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(28)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(27)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(26)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(25)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(24)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(23)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(22)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(21)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(20)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(19)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(18)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(17)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(16)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(15)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(14)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(13)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(12)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(11)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(10)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(9)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(8)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(7)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(6)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(5)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(4)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(3)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(2)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(1)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_ACOUT(0)_UNCONNECTED 
}),
    .CARRYOUT({
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(3)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(2)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(1)_UNCONNECTED 
, 
\NLW_BU2/U0/xbip_addsub.i_a_b_nogrowth.i_xbip_addsub/addsub_usecase.i_addsub/i_synth_option.i_synth_model/opt_vx5.i_uniwrap/i_primitive_CARRYOUT(0)_UNCONNECTED 
})
  );
  VCC   \BU2/XST_VCC  (
    .P(\BU2/N1 )
  );
  GND   \BU2/XST_GND  (
    .G(\BU2/c_out )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

    wire GSR;
    wire GTS;
    wire PRLD;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
