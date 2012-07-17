//-----------------------------------------------------------------------------
// chan_packet_bins_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "opb_register_ppc2simulink_v1_00_a" *)
module chan_packet_bins_wrapper
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
    user_data_out,
    user_clk
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
  output [31:0] user_data_out;
  input user_clk;

  opb_register_ppc2simulink
    #(
      .C_BASEADDR ( 32'h01003100 ),
      .C_HIGHADDR ( 32'h010031FF ),
      .C_OPB_AWIDTH ( 32 ),
      .C_OPB_DWIDTH ( 32 ),
      .C_FAMILY ( "virtex5" )
    )
    chan_packet_bins (
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
      .user_data_out ( user_data_out ),
      .user_clk ( user_clk )
    );

endmodule

