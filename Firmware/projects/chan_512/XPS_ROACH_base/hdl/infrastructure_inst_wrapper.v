//-----------------------------------------------------------------------------
// infrastructure_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "roach_infrastructure_v1_00_a" *)
module infrastructure_inst_wrapper
  (
    sys_clk_n,
    sys_clk_p,
    dly_clk_n,
    dly_clk_p,
    aux0_clk_n,
    aux0_clk_p,
    aux1_clk_n,
    aux1_clk_p,
    epb_clk_in,
    sys_clk,
    sys_clk90,
    sys_clk180,
    sys_clk270,
    sys_clk_lock,
    sys_clk2x,
    sys_clk2x90,
    sys_clk2x180,
    sys_clk2x270,
    dly_clk,
    aux0_clk,
    aux0_clk90,
    aux0_clk180,
    aux0_clk270,
    aux1_clk,
    aux1_clk90,
    aux1_clk180,
    aux1_clk270,
    aux0_clk2x,
    aux0_clk2x90,
    aux0_clk2x180,
    aux0_clk2x270,
    epb_clk,
    idelay_rst,
    idelay_rdy
  );
  input sys_clk_n;
  input sys_clk_p;
  input dly_clk_n;
  input dly_clk_p;
  input aux0_clk_n;
  input aux0_clk_p;
  input aux1_clk_n;
  input aux1_clk_p;
  input epb_clk_in;
  output sys_clk;
  output sys_clk90;
  output sys_clk180;
  output sys_clk270;
  output sys_clk_lock;
  output sys_clk2x;
  output sys_clk2x90;
  output sys_clk2x180;
  output sys_clk2x270;
  output dly_clk;
  output aux0_clk;
  output aux0_clk90;
  output aux0_clk180;
  output aux0_clk270;
  output aux1_clk;
  output aux1_clk90;
  output aux1_clk180;
  output aux1_clk270;
  output aux0_clk2x;
  output aux0_clk2x90;
  output aux0_clk2x180;
  output aux0_clk2x270;
  output epb_clk;
  input idelay_rst;
  output idelay_rdy;

  roach_infrastructure
    #(
      .CLK_FREQ ( 256 )
    )
    infrastructure_inst (
      .sys_clk_n ( sys_clk_n ),
      .sys_clk_p ( sys_clk_p ),
      .dly_clk_n ( dly_clk_n ),
      .dly_clk_p ( dly_clk_p ),
      .aux0_clk_n ( aux0_clk_n ),
      .aux0_clk_p ( aux0_clk_p ),
      .aux1_clk_n ( aux1_clk_n ),
      .aux1_clk_p ( aux1_clk_p ),
      .epb_clk_in ( epb_clk_in ),
      .sys_clk ( sys_clk ),
      .sys_clk90 ( sys_clk90 ),
      .sys_clk180 ( sys_clk180 ),
      .sys_clk270 ( sys_clk270 ),
      .sys_clk_lock ( sys_clk_lock ),
      .sys_clk2x ( sys_clk2x ),
      .sys_clk2x90 ( sys_clk2x90 ),
      .sys_clk2x180 ( sys_clk2x180 ),
      .sys_clk2x270 ( sys_clk2x270 ),
      .dly_clk ( dly_clk ),
      .aux0_clk ( aux0_clk ),
      .aux0_clk90 ( aux0_clk90 ),
      .aux0_clk180 ( aux0_clk180 ),
      .aux0_clk270 ( aux0_clk270 ),
      .aux1_clk ( aux1_clk ),
      .aux1_clk90 ( aux1_clk90 ),
      .aux1_clk180 ( aux1_clk180 ),
      .aux1_clk270 ( aux1_clk270 ),
      .aux0_clk2x ( aux0_clk2x ),
      .aux0_clk2x90 ( aux0_clk2x90 ),
      .aux0_clk2x180 ( aux0_clk2x180 ),
      .aux0_clk2x270 ( aux0_clk2x270 ),
      .epb_clk ( epb_clk ),
      .idelay_rst ( idelay_rst ),
      .idelay_rdy ( idelay_rdy )
    );

endmodule

