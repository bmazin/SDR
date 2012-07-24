//-----------------------------------------------------------------------------
// reset_block_inst_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "reset_block_v1_00_a" *)
module reset_block_inst_wrapper
  (
    clk,
    async_reset_i,
    reset_i,
    reset_o
  );
  input clk;
  input async_reset_i;
  input reset_i;
  output reset_o;

  reset_block
    #(
      .DELAY ( 10 ),
      .WIDTH ( 50 )
    )
    reset_block_inst (
      .clk ( clk ),
      .async_reset_i ( async_reset_i ),
      .reset_i ( reset_i ),
      .reset_o ( reset_o )
    );

endmodule

