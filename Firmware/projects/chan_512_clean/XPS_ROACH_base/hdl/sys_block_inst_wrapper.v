//-----------------------------------------------------------------------------
// sys_block_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "sys_block_v1_00_a" *)
module sys_block_inst_wrapper
  (
    OPB_Clk,
    OPB_Rst,
    Sl_DBus,
    Sl_errAck,
    Sl_retry,
    Sl_toutSup,
    Sl_xferAck,
    OPB_ABus,
    OPB_BE,
    OPB_DBus,
    OPB_RNW,
    OPB_select,
    OPB_seqAddr,
    soft_reset,
    irq_n,
    app_irq,
    fab_clk
  );
  input OPB_Clk;
  input OPB_Rst;
  output [0:31] Sl_DBus;
  output Sl_errAck;
  output Sl_retry;
  output Sl_toutSup;
  output Sl_xferAck;
  input [0:31] OPB_ABus;
  input [0:3] OPB_BE;
  input [0:31] OPB_DBus;
  input OPB_RNW;
  input OPB_select;
  input OPB_seqAddr;
  output soft_reset;
  output irq_n;
  input [15:0] app_irq;
  input fab_clk;

  sys_block
    #(
      .C_BASEADDR ( 32'h00000000 ),
      .C_HIGHADDR ( 32'h0000FFFF ),
      .C_OPB_AWIDTH ( 32 ),
      .C_OPB_DWIDTH ( 32 ),
      .BOARD_ID ( 'hB00B ),
      .REV_MAJOR ( 'h1 ),
      .REV_MINOR ( 'h0 ),
      .REV_RCS ( 'h0 ),
      .RCS_UPTODATE ( 'h0 )
    )
    sys_block_inst (
      .OPB_Clk ( OPB_Clk ),
      .OPB_Rst ( OPB_Rst ),
      .Sl_DBus ( Sl_DBus ),
      .Sl_errAck ( Sl_errAck ),
      .Sl_retry ( Sl_retry ),
      .Sl_toutSup ( Sl_toutSup ),
      .Sl_xferAck ( Sl_xferAck ),
      .OPB_ABus ( OPB_ABus ),
      .OPB_BE ( OPB_BE ),
      .OPB_DBus ( OPB_DBus ),
      .OPB_RNW ( OPB_RNW ),
      .OPB_select ( OPB_select ),
      .OPB_seqAddr ( OPB_seqAddr ),
      .soft_reset ( soft_reset ),
      .irq_n ( irq_n ),
      .app_irq ( app_irq ),
      .fab_clk ( fab_clk )
    );

endmodule

