//-----------------------------------------------------------------------------
// dram_controller_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "dram_controller_v1_00_a" *)
module dram_controller_inst_wrapper
  (
    phy_rdy,
    cal_fail,
    clk0,
    clk90,
    clkdiv0,
    rst0,
    rst90,
    rstdiv0,
    app_cmd_addr,
    app_cmd_rnw,
    app_cmd_valid,
    app_wr_data,
    app_wr_be,
    app_rd_data,
    app_rd_valid,
    app_fifo_ready,
    dram_ck,
    dram_ck_n,
    dram_a,
    dram_ba,
    dram_ras_n,
    dram_cas_n,
    dram_we_n,
    dram_cs_n,
    dram_cke,
    dram_odt,
    dram_dm,
    dram_dqs,
    dram_dqs_n,
    dram_dq,
    dram_reset_n
  );
  output phy_rdy;
  output cal_fail;
  input clk0;
  input clk90;
  input clkdiv0;
  input rst0;
  input rst90;
  input rstdiv0;
  input [31:0] app_cmd_addr;
  input app_cmd_rnw;
  input app_cmd_valid;
  input [143:0] app_wr_data;
  input [17:0] app_wr_be;
  output [143:0] app_rd_data;
  output app_rd_valid;
  output app_fifo_ready;
  output [2:0] dram_ck;
  output [2:0] dram_ck_n;
  output [15:0] dram_a;
  output [2:0] dram_ba;
  output dram_ras_n;
  output dram_cas_n;
  output dram_we_n;
  output [1:0] dram_cs_n;
  output [1:0] dram_cke;
  output [1:0] dram_odt;
  output [8:0] dram_dm;
  inout [8:0] dram_dqs;
  inout [8:0] dram_dqs_n;
  inout [71:0] dram_dq;
  output dram_reset_n;

  dram_controller
    #(
      .CLK_FREQ ( 266 )
    )
    dram_controller_inst (
      .phy_rdy ( phy_rdy ),
      .cal_fail ( cal_fail ),
      .clk0 ( clk0 ),
      .clk90 ( clk90 ),
      .clkdiv0 ( clkdiv0 ),
      .rst0 ( rst0 ),
      .rst90 ( rst90 ),
      .rstdiv0 ( rstdiv0 ),
      .app_cmd_addr ( app_cmd_addr ),
      .app_cmd_rnw ( app_cmd_rnw ),
      .app_cmd_valid ( app_cmd_valid ),
      .app_wr_data ( app_wr_data ),
      .app_wr_be ( app_wr_be ),
      .app_rd_data ( app_rd_data ),
      .app_rd_valid ( app_rd_valid ),
      .app_fifo_ready ( app_fifo_ready ),
      .dram_ck ( dram_ck ),
      .dram_ck_n ( dram_ck_n ),
      .dram_a ( dram_a ),
      .dram_ba ( dram_ba ),
      .dram_ras_n ( dram_ras_n ),
      .dram_cas_n ( dram_cas_n ),
      .dram_we_n ( dram_we_n ),
      .dram_cs_n ( dram_cs_n ),
      .dram_cke ( dram_cke ),
      .dram_odt ( dram_odt ),
      .dram_dm ( dram_dm ),
      .dram_dqs ( dram_dqs ),
      .dram_dqs_n ( dram_dqs_n ),
      .dram_dq ( dram_dq ),
      .dram_reset_n ( dram_reset_n )
    );

endmodule

