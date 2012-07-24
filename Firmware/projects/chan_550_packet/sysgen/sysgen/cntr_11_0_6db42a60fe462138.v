////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2009 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: L.68
//  \   \         Application: netgen
//  /   /         Filename: cntr_11_0_6db42a60fe462138.v
// /___/   /\     Timestamp: Fri Oct 22 10:26:29 2010
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -w -sim -ofmt verilog ./tmp/_cg/cntr_11_0_6db42a60fe462138.ngc ./tmp/_cg/cntr_11_0_6db42a60fe462138.v 
// Device	: 5vlx20tff323-2
// Input file	: ./tmp/_cg/cntr_11_0_6db42a60fe462138.ngc
// Output file	: ./tmp/_cg/cntr_11_0_6db42a60fe462138.v
// # of Modules	: 1
// Design Name	: cntr_11_0_6db42a60fe462138
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

module cntr_11_0_6db42a60fe462138 (
  ce, load, sinit, clk, l, q
)/* synthesis syn_black_box syn_noprune=1 */;
  input ce;
  input load;
  input sinit;
  input clk;
  input [1 : 0] l;
  output [1 : 0] q;
  
  // synthesis translate_off
  
  wire \BU2/thresh0 ;
  wire NLW_VCC_P_UNCONNECTED;
  wire NLW_GND_G_UNCONNECTED;
  wire [1 : 0] NlwRenamedSig_OI_q;
  wire [1 : 0] \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum ;
  wire [0 : 0] \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple ;
  wire [1 : 0] \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/s ;
  assign
    q[1] = NlwRenamedSig_OI_q[1],
    q[0] = NlwRenamedSig_OI_q[0];
  VCC   VCC_0 (
    .P(NLW_VCC_P_UNCONNECTED)
  );
  GND   GND_1 (
    .G(NLW_GND_G_UNCONNECTED)
  );
  LUT3 #(
    .INIT ( 8'h72 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum(0)1  (
    .I0(load),
    .I1(l[0]),
    .I2(NlwRenamedSig_OI_q[0]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0])
  );
  LUT3 #(
    .INIT ( 8'h27 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum(1)1  (
    .I0(load),
    .I1(l[1]),
    .I2(NlwRenamedSig_OI_q[1]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [1])
  );
  MUXCY   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.carrymux0  (
    .CI(\BU2/thresh0 ),
    .DI(load),
    .S(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0])
  );
  XORCY   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.carryxor0  (
    .CI(\BU2/thresh0 ),
    .LI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [0]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/s [0])
  );
  XORCY   \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_simple_model.i_gt_1.carryxortop  (
    .CI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/carry_simple [0]),
    .LI(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/halfsum [1]),
    .O(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/s [1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_1  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/s [0]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[0])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/no_pipelining.the_addsub/i_lut6.i_lut6_addsub/i_q.i_simple.qreg/fd/output_2  (
    .C(clk),
    .CE(ce),
    .D(\BU2/U0/i_baseblox.i_baseblox_counter/the_addsub/s [1]),
    .R(sinit),
    .Q(NlwRenamedSig_OI_q[1])
  );
  VCC   \BU2/XST_VCC  (
    .P(\BU2/thresh0 )
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
