//-----------------------------------------------------------------------------
// dram_infrastructure_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "dram_infrastructure_v1_00_a" *)
module dram_infrastructure_inst_wrapper
  (
    reset,
    clk_in,
    clk_in_locked,
    clk_out,
    dram_clk_0,
    dram_clk_90,
    dram_clk_div,
    dram_rst_0,
    dram_rst_90,
    dram_rst_div
  );
  input reset;
  input clk_in;
  input clk_in_locked;
  output clk_out;
  output dram_clk_0;
  output dram_clk_90;
  output dram_clk_div;
  output dram_rst_0;
  output dram_rst_90;
  output dram_rst_div;

  dram_infrastructure
    #(
      .CLK_FREQ ( 266 )
    )
    dram_infrastructure_inst (
      .reset ( reset ),
      .clk_in ( clk_in ),
      .clk_in_locked ( clk_in_locked ),
      .clk_out ( clk_out ),
      .dram_clk_0 ( dram_clk_0 ),
      .dram_clk_90 ( dram_clk_90 ),
      .dram_clk_div ( dram_clk_div ),
      .dram_rst_0 ( dram_rst_0 ),
      .dram_rst_90 ( dram_rst_90 ),
      .dram_rst_div ( dram_rst_div )
    );

endmodule

