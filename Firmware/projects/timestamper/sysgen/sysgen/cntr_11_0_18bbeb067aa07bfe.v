////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2009 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: L.68
//  \   \         Application: netgen
//  /   /         Filename: cntr_11_0_18bbeb067aa07bfe.v
// /___/   /\     Timestamp: Fri Oct 22 10:23:25 2010
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -w -sim -ofmt verilog ./tmp/_cg/cntr_11_0_18bbeb067aa07bfe.ngc ./tmp/_cg/cntr_11_0_18bbeb067aa07bfe.v 
// Device	: 5vlx20tff323-2
// Input file	: ./tmp/_cg/cntr_11_0_18bbeb067aa07bfe.ngc
// Output file	: ./tmp/_cg/cntr_11_0_18bbeb067aa07bfe.v
// # of Modules	: 1
// Design Name	: cntr_11_0_18bbeb067aa07bfe
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

module cntr_11_0_18bbeb067aa07bfe (
  ce, sinit, clk, q
)/* synthesis syn_black_box syn_noprune=1 */;
  input ce;
  input sinit;
  input clk;
  output [7 : 0] q;
  
  // synthesis translate_off
  
  wire \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux_rt_33 ;
  wire \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux_rt_31 ;
  wire \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux_rt_29 ;
  wire \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux_rt_27 ;
  wire \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux_rt_25 ;
  wire \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux_rt_22 ;
  wire \BU2/N0 ;
  wire \BU2/thresh0 ;
  wire NLW_VCC_P_UNCONNECTED;
  wire NLW_GND_G_UNCONNECTED;
  wire [7 : 0] NlwRenamedSig_OI_q;
  wire [0 : 0] \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum ;
  wire [6 : 0] \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple ;
  wire [7 : 0] \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple ;
  assign
    q[7] = NlwRenamedSig_OI_q[7],
    q[6] = NlwRenamedSig_OI_q[6],
    q[5] = NlwRenamedSig_OI_q[5],
    q[4] = NlwRenamedSig_OI_q[4],
    q[3] = NlwRenamedSig_OI_q[3],
    q[2] = NlwRenamedSig_OI_q[2],
    q[1] = NlwRenamedSig_OI_q[1],
    q[0] = NlwRenamedSig_OI_q[0];
  VCC   VCC_0 (
    .P(NLW_VCC_P_UNCONNECTED)
  );
  GND   GND_1 (
    .G(NLW_GND_G_UNCONNECTED)
  );
  INV   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum_not00001_INV_0  (
    .I(NlwRenamedSig_OI_q[0]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[1]),
    .O
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux_rt_33 )

  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[2]),
    .O
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux_rt_31 )

  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[3]),
    .O
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux_rt_29 )

  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[4]),
    .O
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux_rt_27 )

  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[5]),
    .O
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux_rt_25 )

  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[6]),
    .O
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux_rt_22 )

  );
  MUXCY   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.carrymux0  (
    .CI(\BU2/N0 ),
    .DI(\BU2/thresh0 ),
    .S(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0])
  );
  XORCY   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.carryxor0  (
    .CI(\BU2/N0 ),
    .LI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [0])
  );
  XORCY   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carryxortop  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [6]),
    .LI(NlwRenamedSig_OI_q[7]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [7])
  );
  MUXCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0]),
    .DI(\BU2/N0 ),
    .S
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux_rt_33 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [1])
  );
  XORCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carryxor  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0]),
    .LI
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[1].carrymux_rt_33 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [1])
  );
  MUXCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [1]),
    .DI(\BU2/N0 ),
    .S
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux_rt_31 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [2])
  );
  XORCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carryxor  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [1]),
    .LI
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[2].carrymux_rt_31 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [2])
  );
  MUXCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [2]),
    .DI(\BU2/N0 ),
    .S
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux_rt_29 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [3])
  );
  XORCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carryxor  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [2]),
    .LI
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[3].carrymux_rt_29 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [3])
  );
  MUXCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [3]),
    .DI(\BU2/N0 ),
    .S
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux_rt_27 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [4])
  );
  XORCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carryxor  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [3]),
    .LI
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[4].carrymux_rt_27 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [4])
  );
  MUXCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [4]),
    .DI(\BU2/N0 ),
    .S
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux_rt_25 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [5])
  );
  XORCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carryxor  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [4]),
    .LI
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[5].carrymux_rt_25 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [5])
  );
  MUXCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [5]),
    .DI(\BU2/N0 ),
    .S
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux_rt_22 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [6])
  );
  XORCY 
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carryxor  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [5]),
    .LI
(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carrychaingen[6].carrymux_rt_22 )
,
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [6])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_8  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [7]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[7])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_7  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [6]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[6])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_6  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [5]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[5])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_5  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [4]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[4])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_4  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [3]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[3])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_3  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [2]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[2])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_2  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [1]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_1  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/sum_simple [0]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[0])
  );
  VCC   \BU2/XST_VCC  (
    .P(\BU2/thresh0 )
  );
  GND   \BU2/XST_GND  (
    .G(\BU2/N0 )
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
