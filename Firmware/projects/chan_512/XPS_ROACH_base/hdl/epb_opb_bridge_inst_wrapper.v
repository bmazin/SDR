//-----------------------------------------------------------------------------
// epb_opb_bridge_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "epb_opb_bridge_v1_00_a" *)
module epb_opb_bridge_inst_wrapper
  (
    sys_reset,
    epb_data_oe_n,
    epb_cs_n,
    epb_oe_n,
    epb_r_w_n,
    epb_be_n,
    epb_addr,
    epb_addr_gp,
    epb_data_i,
    epb_data_o,
    epb_rdy,
    epb_rdy_oe,
    OPB_Clk,
    OPB_Rst,
    M_request,
    M_busLock,
    M_select,
    M_RNW,
    M_BE,
    M_seqAddr,
    M_DBus,
    M_ABus,
    OPB_MGrant,
    OPB_xferAck,
    OPB_errAck,
    OPB_retry,
    OPB_timeout,
    OPB_DBus
  );
  input sys_reset;
  output epb_data_oe_n;
  input epb_cs_n;
  input epb_oe_n;
  input epb_r_w_n;
  input [1:0] epb_be_n;
  input [22:0] epb_addr;
  input [5:0] epb_addr_gp;
  input [15:0] epb_data_i;
  output [15:0] epb_data_o;
  output epb_rdy;
  output epb_rdy_oe;
  input OPB_Clk;
  input OPB_Rst;
  output M_request;
  output M_busLock;
  output M_select;
  output M_RNW;
  output [0:3] M_BE;
  output M_seqAddr;
  output [0:31] M_DBus;
  output [0:31] M_ABus;
  input OPB_MGrant;
  input OPB_xferAck;
  input OPB_errAck;
  input OPB_retry;
  input OPB_timeout;
  input [0:31] OPB_DBus;

  epb_opb_bridge
    epb_opb_bridge_inst (
      .sys_reset ( sys_reset ),
      .epb_data_oe_n ( epb_data_oe_n ),
      .epb_cs_n ( epb_cs_n ),
      .epb_oe_n ( epb_oe_n ),
      .epb_r_w_n ( epb_r_w_n ),
      .epb_be_n ( epb_be_n ),
      .epb_addr ( epb_addr ),
      .epb_addr_gp ( epb_addr_gp ),
      .epb_data_i ( epb_data_i ),
      .epb_data_o ( epb_data_o ),
      .epb_rdy ( epb_rdy ),
      .epb_rdy_oe ( epb_rdy_oe ),
      .OPB_Clk ( OPB_Clk ),
      .OPB_Rst ( OPB_Rst ),
      .M_request ( M_request ),
      .M_busLock ( M_busLock ),
      .M_select ( M_select ),
      .M_RNW ( M_RNW ),
      .M_BE ( M_BE ),
      .M_seqAddr ( M_seqAddr ),
      .M_DBus ( M_DBus ),
      .M_ABus ( M_ABus ),
      .OPB_MGrant ( OPB_MGrant ),
      .OPB_xferAck ( OPB_xferAck ),
      .OPB_errAck ( OPB_errAck ),
      .OPB_retry ( OPB_retry ),
      .OPB_timeout ( OPB_timeout ),
      .OPB_DBus ( OPB_DBus )
    );

endmodule

