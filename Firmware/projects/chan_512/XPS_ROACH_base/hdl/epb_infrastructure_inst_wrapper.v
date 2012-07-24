//-----------------------------------------------------------------------------
// epb_infrastructure_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "epb_infrastructure_v1_00_a" *)
module epb_infrastructure_inst_wrapper
  (
    epb_data_buf,
    epb_data_oe_n_i,
    epb_data_out_i,
    epb_data_in_o,
    epb_oe_n_buf,
    epb_oe_n,
    epb_cs_n_buf,
    epb_cs_n,
    epb_r_w_n_buf,
    epb_r_w_n,
    epb_be_n_buf,
    epb_be_n,
    epb_addr_buf,
    epb_addr,
    epb_addr_gp_buf,
    epb_addr_gp,
    epb_rdy_buf,
    epb_rdy,
    epb_rdy_oe
  );
  inout [15:0] epb_data_buf;
  input epb_data_oe_n_i;
  input [15:0] epb_data_out_i;
  output [15:0] epb_data_in_o;
  input epb_oe_n_buf;
  output epb_oe_n;
  input epb_cs_n_buf;
  output epb_cs_n;
  input epb_r_w_n_buf;
  output epb_r_w_n;
  input [1:0] epb_be_n_buf;
  output [1:0] epb_be_n;
  input [22:0] epb_addr_buf;
  output [22:0] epb_addr;
  input [5:0] epb_addr_gp_buf;
  output [5:0] epb_addr_gp;
  output epb_rdy_buf;
  input epb_rdy;
  input epb_rdy_oe;

  epb_infrastructure
    epb_infrastructure_inst (
      .epb_data_buf ( epb_data_buf ),
      .epb_data_oe_n_i ( epb_data_oe_n_i ),
      .epb_data_out_i ( epb_data_out_i ),
      .epb_data_in_o ( epb_data_in_o ),
      .epb_oe_n_buf ( epb_oe_n_buf ),
      .epb_oe_n ( epb_oe_n ),
      .epb_cs_n_buf ( epb_cs_n_buf ),
      .epb_cs_n ( epb_cs_n ),
      .epb_r_w_n_buf ( epb_r_w_n_buf ),
      .epb_r_w_n ( epb_r_w_n ),
      .epb_be_n_buf ( epb_be_n_buf ),
      .epb_be_n ( epb_be_n ),
      .epb_addr_buf ( epb_addr_buf ),
      .epb_addr ( epb_addr ),
      .epb_addr_gp_buf ( epb_addr_gp_buf ),
      .epb_addr_gp ( epb_addr_gp ),
      .epb_rdy_buf ( epb_rdy_buf ),
      .epb_rdy ( epb_rdy ),
      .epb_rdy_oe ( epb_rdy_oe )
    );

endmodule

