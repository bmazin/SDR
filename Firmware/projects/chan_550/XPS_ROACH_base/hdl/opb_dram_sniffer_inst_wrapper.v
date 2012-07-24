//-----------------------------------------------------------------------------
// opb_dram_sniffer_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "opb_dram_sniffer_v1_00_a" *)
module opb_dram_sniffer_inst_wrapper
  (
    ctrl_OPB_Clk,
    ctrl_OPB_Rst,
    ctrl_Sl_DBus,
    ctrl_Sl_errAck,
    ctrl_Sl_retry,
    ctrl_Sl_toutSup,
    ctrl_Sl_xferAck,
    ctrl_OPB_ABus,
    ctrl_OPB_BE,
    ctrl_OPB_DBus,
    ctrl_OPB_RNW,
    ctrl_OPB_select,
    ctrl_OPB_seqAddr,
    mem_OPB_Clk,
    mem_OPB_Rst,
    mem_Sl_DBus,
    mem_Sl_errAck,
    mem_Sl_retry,
    mem_Sl_toutSup,
    mem_Sl_xferAck,
    mem_OPB_ABus,
    mem_OPB_BE,
    mem_OPB_DBus,
    mem_OPB_RNW,
    mem_OPB_select,
    mem_OPB_seqAddr,
    dram_clk,
    dram_rst,
    phy_ready,
    dram_cmd_addr,
    dram_cmd_rnw,
    dram_cmd_valid,
    dram_wr_data,
    dram_wr_be,
    dram_rd_data,
    dram_rd_valid,
    dram_fifo_ready,
    app_cmd_addr,
    app_cmd_rnw,
    app_cmd_valid,
    app_cmd_ack,
    app_wr_data,
    app_wr_be,
    app_rd_data,
    app_rd_valid
  );
  input ctrl_OPB_Clk;
  input ctrl_OPB_Rst;
  output [0:31] ctrl_Sl_DBus;
  output ctrl_Sl_errAck;
  output ctrl_Sl_retry;
  output ctrl_Sl_toutSup;
  output ctrl_Sl_xferAck;
  input [0:31] ctrl_OPB_ABus;
  input [0:3] ctrl_OPB_BE;
  input [0:31] ctrl_OPB_DBus;
  input ctrl_OPB_RNW;
  input ctrl_OPB_select;
  input ctrl_OPB_seqAddr;
  input mem_OPB_Clk;
  input mem_OPB_Rst;
  output [0:31] mem_Sl_DBus;
  output mem_Sl_errAck;
  output mem_Sl_retry;
  output mem_Sl_toutSup;
  output mem_Sl_xferAck;
  input [0:31] mem_OPB_ABus;
  input [0:3] mem_OPB_BE;
  input [0:31] mem_OPB_DBus;
  input mem_OPB_RNW;
  input mem_OPB_select;
  input mem_OPB_seqAddr;
  input dram_clk;
  input dram_rst;
  input phy_ready;
  output [31:0] dram_cmd_addr;
  output dram_cmd_rnw;
  output dram_cmd_valid;
  output [143:0] dram_wr_data;
  output [17:0] dram_wr_be;
  input [143:0] dram_rd_data;
  input dram_rd_valid;
  input dram_fifo_ready;
  input [31:0] app_cmd_addr;
  input app_cmd_rnw;
  input app_cmd_valid;
  output app_cmd_ack;
  input [143:0] app_wr_data;
  input [17:0] app_wr_be;
  output [143:0] app_rd_data;
  output app_rd_valid;

  opb_dram_sniffer
    #(
      .MEM_C_BASEADDR ( 32'h04000000 ),
      .MEM_C_HIGHADDR ( 32'h07FFFFFF ),
      .CTRL_C_BASEADDR ( 32'h00050000 ),
      .CTRL_C_HIGHADDR ( 32'h0005FFFF ),
      .ENABLE ( 1 )
    )
    opb_dram_sniffer_inst (
      .ctrl_OPB_Clk ( ctrl_OPB_Clk ),
      .ctrl_OPB_Rst ( ctrl_OPB_Rst ),
      .ctrl_Sl_DBus ( ctrl_Sl_DBus ),
      .ctrl_Sl_errAck ( ctrl_Sl_errAck ),
      .ctrl_Sl_retry ( ctrl_Sl_retry ),
      .ctrl_Sl_toutSup ( ctrl_Sl_toutSup ),
      .ctrl_Sl_xferAck ( ctrl_Sl_xferAck ),
      .ctrl_OPB_ABus ( ctrl_OPB_ABus ),
      .ctrl_OPB_BE ( ctrl_OPB_BE ),
      .ctrl_OPB_DBus ( ctrl_OPB_DBus ),
      .ctrl_OPB_RNW ( ctrl_OPB_RNW ),
      .ctrl_OPB_select ( ctrl_OPB_select ),
      .ctrl_OPB_seqAddr ( ctrl_OPB_seqAddr ),
      .mem_OPB_Clk ( mem_OPB_Clk ),
      .mem_OPB_Rst ( mem_OPB_Rst ),
      .mem_Sl_DBus ( mem_Sl_DBus ),
      .mem_Sl_errAck ( mem_Sl_errAck ),
      .mem_Sl_retry ( mem_Sl_retry ),
      .mem_Sl_toutSup ( mem_Sl_toutSup ),
      .mem_Sl_xferAck ( mem_Sl_xferAck ),
      .mem_OPB_ABus ( mem_OPB_ABus ),
      .mem_OPB_BE ( mem_OPB_BE ),
      .mem_OPB_DBus ( mem_OPB_DBus ),
      .mem_OPB_RNW ( mem_OPB_RNW ),
      .mem_OPB_select ( mem_OPB_select ),
      .mem_OPB_seqAddr ( mem_OPB_seqAddr ),
      .dram_clk ( dram_clk ),
      .dram_rst ( dram_rst ),
      .phy_ready ( phy_ready ),
      .dram_cmd_addr ( dram_cmd_addr ),
      .dram_cmd_rnw ( dram_cmd_rnw ),
      .dram_cmd_valid ( dram_cmd_valid ),
      .dram_wr_data ( dram_wr_data ),
      .dram_wr_be ( dram_wr_be ),
      .dram_rd_data ( dram_rd_data ),
      .dram_rd_valid ( dram_rd_valid ),
      .dram_fifo_ready ( dram_fifo_ready ),
      .app_cmd_addr ( app_cmd_addr ),
      .app_cmd_rnw ( app_cmd_rnw ),
      .app_cmd_valid ( app_cmd_valid ),
      .app_cmd_ack ( app_cmd_ack ),
      .app_wr_data ( app_wr_data ),
      .app_wr_be ( app_wr_be ),
      .app_rd_data ( app_rd_data ),
      .app_rd_valid ( app_rd_valid )
    );

endmodule

