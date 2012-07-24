//-----------------------------------------------------------------------------
// async_dram_1_wrapper.v
//-----------------------------------------------------------------------------

  (* x_core_info = "async_dram_v1_00_a" *)
module async_dram_1_wrapper
  (
    dram_clk,
    dram_reset,
    dram_address,
    dram_rnw,
    dram_cmd_en,
    dram_ready,
    dram_data_o,
    dram_byte_enable,
    dram_data_i,
    dram_data_valid,
    Mem_Clk,
    Mem_Rst,
    Mem_Cmd_Address,
    Mem_Cmd_RNW,
    Mem_Cmd_Valid,
    Mem_Cmd_Tag,
    Mem_Cmd_Ack,
    Mem_Rd_Dout,
    Mem_Rd_Tag,
    Mem_Rd_Ack,
    Mem_Rd_Valid,
    Mem_Wr_Din,
    Mem_Wr_BE
  );
  input dram_clk;
  output dram_reset;
  output [31:0] dram_address;
  output dram_rnw;
  output dram_cmd_en;
  input dram_ready;
  output [143:0] dram_data_o;
  output [17:0] dram_byte_enable;
  input [143:0] dram_data_i;
  input dram_data_valid;
  input Mem_Clk;
  input Mem_Rst;
  input [31:0] Mem_Cmd_Address;
  input Mem_Cmd_RNW;
  input Mem_Cmd_Valid;
  input [31:0] Mem_Cmd_Tag;
  output Mem_Cmd_Ack;
  output [143:0] Mem_Rd_Dout;
  output [31:0] Mem_Rd_Tag;
  input Mem_Rd_Ack;
  output Mem_Rd_Valid;
  input [143:0] Mem_Wr_Din;
  input [17:0] Mem_Wr_BE;

  async_dram
    #(
      .C_WIDE_DATA ( 0 ),
      .C_HALF_BURST ( 0 ),
      .BRAM_FIFOS ( 0 ),
      .TAG_BUFFER_EN ( 0 )
    )
    async_dram_1 (
      .dram_clk ( dram_clk ),
      .dram_reset ( dram_reset ),
      .dram_address ( dram_address ),
      .dram_rnw ( dram_rnw ),
      .dram_cmd_en ( dram_cmd_en ),
      .dram_ready ( dram_ready ),
      .dram_data_o ( dram_data_o ),
      .dram_byte_enable ( dram_byte_enable ),
      .dram_data_i ( dram_data_i ),
      .dram_data_valid ( dram_data_valid ),
      .Mem_Clk ( Mem_Clk ),
      .Mem_Rst ( Mem_Rst ),
      .Mem_Cmd_Address ( Mem_Cmd_Address ),
      .Mem_Cmd_RNW ( Mem_Cmd_RNW ),
      .Mem_Cmd_Valid ( Mem_Cmd_Valid ),
      .Mem_Cmd_Tag ( Mem_Cmd_Tag ),
      .Mem_Cmd_Ack ( Mem_Cmd_Ack ),
      .Mem_Rd_Dout ( Mem_Rd_Dout ),
      .Mem_Rd_Tag ( Mem_Rd_Tag ),
      .Mem_Rd_Ack ( Mem_Rd_Ack ),
      .Mem_Rd_Valid ( Mem_Rd_Valid ),
      .Mem_Wr_Din ( Mem_Wr_Din ),
      .Mem_Wr_BE ( Mem_Wr_BE )
    );

endmodule

