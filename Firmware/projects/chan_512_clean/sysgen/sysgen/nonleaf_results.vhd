library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/BufferedSwitch/ram_buff"

entity ram_buff_entity_088be69e4f is
  port (
    addr: in std_logic_vector(7 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(143 downto 0); 
    we: in std_logic; 
    data_out: out std_logic_vector(143 downto 0)
  );
end ram_buff_entity_088be69e4f;

architecture structural of ram_buff_entity_088be69e4f is
  signal ce_1_sg_x0: std_logic;
  signal clk_1_sg_x0: std_logic;
  signal concat_y_net_x0: std_logic_vector(143 downto 0);
  signal delay13_q_net_x0: std_logic_vector(143 downto 0);
  signal delay14_q_net_x0: std_logic;
  signal mux3_y_net_x0: std_logic_vector(7 downto 0);
  signal ram1_data_out_net: std_logic_vector(71 downto 0);
  signal ram3_data_out_net: std_logic_vector(71 downto 0);
  signal slice2_y_net: std_logic_vector(71 downto 0);
  signal slice4_y_net: std_logic_vector(71 downto 0);

begin
  mux3_y_net_x0 <= addr;
  ce_1_sg_x0 <= ce_1;
  clk_1_sg_x0 <= clk_1;
  delay13_q_net_x0 <= data_in;
  delay14_q_net_x0 <= we;
  data_out <= concat_y_net_x0;

  concat: entity work.concat_364e99894a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => ram1_data_out_net,
      in1 => ram3_data_out_net,
      y => concat_y_net_x0
    );

  ram1: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 72,
      core_name0 => "bmg_33_e1dc07e48a247c2a",
      latency => 2
    )
    port map (
      addr => mux3_y_net_x0,
      ce => ce_1_sg_x0,
      clk => clk_1_sg_x0,
      data_in => slice4_y_net,
      en => "1",
      rst => "0",
      we(0) => delay14_q_net_x0,
      data_out => ram1_data_out_net
    );

  ram3: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 72,
      core_name0 => "bmg_33_e1dc07e48a247c2a",
      latency => 2
    )
    port map (
      addr => mux3_y_net_x0,
      ce => ce_1_sg_x0,
      clk => clk_1_sg_x0,
      data_in => slice2_y_net,
      en => "1",
      rst => "0",
      we(0) => delay14_q_net_x0,
      data_out => ram3_data_out_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 71,
      x_width => 144,
      y_width => 72
    )
    port map (
      x => delay13_q_net_x0,
      y => slice2_y_net
    );

  slice4: entity work.xlslice
    generic map (
      new_lsb => 72,
      new_msb => 143,
      x_width => 144,
      y_width => 72
    )
    port map (
      x => delay13_q_net_x0,
      y => slice4_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/BufferedSwitch"

entity bufferedswitch_entity_5a7620c24d is
  port (
    ce_1: in std_logic; 
    ch_in: in std_logic_vector(7 downto 0); 
    clk_1: in std_logic; 
    data_rdy: in std_logic; 
    fft_bin: in std_logic_vector(8 downto 0); 
    fft_data: in std_logic_vector(143 downto 0); 
    ch_out: out std_logic_vector(7 downto 0); 
    data_out: out std_logic_vector(71 downto 0)
  );
end bufferedswitch_entity_5a7620c24d;

architecture structural of bufferedswitch_entity_5a7620c24d is
  signal adress_counter1_op_net: std_logic_vector(7 downto 0);
  signal adress_counter2_op_net: std_logic_vector(7 downto 0);
  signal ce_1_sg_x2: std_logic;
  signal clk_1_sg_x2: std_logic;
  signal concat_y_net_x0: std_logic_vector(143 downto 0);
  signal concat_y_net_x1: std_logic_vector(143 downto 0);
  signal convert1_dout_net: std_logic;
  signal delay10_q_net: std_logic;
  signal delay11_q_net: std_logic_vector(143 downto 0);
  signal delay12_q_net: std_logic;
  signal delay12_q_net_x1: std_logic;
  signal delay13_q_net_x1: std_logic_vector(143 downto 0);
  signal delay14_q_net_x0: std_logic;
  signal delay14_q_net_x1: std_logic_vector(7 downto 0);
  signal delay15_q_net: std_logic;
  signal delay15_q_net_x1: std_logic_vector(143 downto 0);
  signal delay16_q_net_x0: std_logic_vector(8 downto 0);
  signal delay18_q_net: std_logic;
  signal delay1_q_net_x0: std_logic_vector(7 downto 0);
  signal delay3_q_net: std_logic;
  signal delay5_q_net: std_logic;
  signal delay6_q_net: std_logic_vector(143 downto 0);
  signal delay7_q_net: std_logic;
  signal delay8_q_net: std_logic_vector(71 downto 0);
  signal delay9_q_net: std_logic_vector(71 downto 0);
  signal inverter1_op_net: std_logic;
  signal inverter2_op_net: std_logic;
  signal inverter4_op_net_x0: std_logic;
  signal mux1_y_net: std_logic_vector(71 downto 0);
  signal mux2_y_net_x0: std_logic_vector(71 downto 0);
  signal mux3_y_net_x0: std_logic_vector(7 downto 0);
  signal mux4_y_net_x0: std_logic_vector(7 downto 0);
  signal mux5_y_net: std_logic_vector(71 downto 0);
  signal selector_op_net: std_logic;
  signal slice1_y_net: std_logic_vector(71 downto 0);
  signal slice3_y_net: std_logic_vector(71 downto 0);
  signal slice5_y_net: std_logic_vector(71 downto 0);
  signal slice7_y_net: std_logic_vector(71 downto 0);
  signal slice8_y_net: std_logic;
  signal slice9_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x2 <= ce_1;
  delay14_q_net_x1 <= ch_in;
  clk_1_sg_x2 <= clk_1;
  delay12_q_net_x1 <= data_rdy;
  delay16_q_net_x0 <= fft_bin;
  delay15_q_net_x1 <= fft_data;
  ch_out <= delay1_q_net_x0;
  data_out <= mux2_y_net_x0;

  adress_counter1: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      en(0) => inverter1_op_net,
      rst(0) => delay12_q_net_x1,
      op => adress_counter1_op_net
    );

  adress_counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      en(0) => convert1_dout_net,
      rst(0) => delay12_q_net_x1,
      op => adress_counter2_op_net
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => selector_op_net,
      dout(0) => convert1_dout_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 263,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d => delay14_q_net_x1,
      en => '1',
      q => delay1_q_net_x0
    );

  delay10: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => delay3_q_net,
      en => '1',
      q(0) => delay10_q_net
    );

  delay11: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d => concat_y_net_x1,
      en => '1',
      q => delay11_q_net
    );

  delay12: entity work.xldelay
    generic map (
      latency => 5,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => convert1_dout_net,
      en => '1',
      q(0) => delay12_q_net
    );

  delay13: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d => delay15_q_net_x1,
      en => '1',
      q => delay13_q_net_x1
    );

  delay14: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => convert1_dout_net,
      en => '1',
      q(0) => delay14_q_net_x0
    );

  delay15: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => slice8_y_net,
      en => '1',
      q(0) => delay15_q_net
    );

  delay18: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => convert1_dout_net,
      en => '1',
      q(0) => delay18_q_net
    );

  delay3: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => delay15_q_net,
      en => '1',
      q(0) => delay3_q_net
    );

  delay5: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => delay3_q_net,
      en => '1',
      q(0) => delay5_q_net
    );

  delay6: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d => concat_y_net_x0,
      en => '1',
      q => delay6_q_net
    );

  delay7: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d(0) => delay12_q_net,
      en => '1',
      q(0) => delay7_q_net
    );

  delay8: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 72
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d => mux1_y_net,
      en => '1',
      q => delay8_q_net
    );

  delay9: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 72
    )
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      d => mux5_y_net,
      en => '1',
      q => delay9_q_net
    );

  inverter1: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      ip(0) => convert1_dout_net,
      op(0) => inverter1_op_net
    );

  inverter2: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      ip(0) => convert1_dout_net,
      op(0) => inverter2_op_net
    );

  inverter4: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      ip(0) => delay18_q_net,
      op(0) => inverter4_op_net_x0
    );

  mux1: entity work.mux_d9d73cf9c8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0 => slice3_y_net,
      d1 => slice1_y_net,
      sel(0) => delay5_q_net,
      y => mux1_y_net
    );

  mux2: entity work.mux_674531f69e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0 => delay8_q_net,
      d1 => delay9_q_net,
      sel(0) => delay7_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_cc14a035dc
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      d0 => slice9_y_net,
      d1 => adress_counter2_op_net,
      sel(0) => convert1_dout_net,
      y => mux3_y_net_x0
    );

  mux4: entity work.mux_cc14a035dc
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      d0 => slice9_y_net,
      d1 => adress_counter1_op_net,
      sel(0) => inverter2_op_net,
      y => mux4_y_net_x0
    );

  mux5: entity work.mux_d9d73cf9c8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0 => slice7_y_net,
      d1 => slice5_y_net,
      sel(0) => delay10_q_net,
      y => mux5_y_net
    );

  ram_buff1_599cb5f597: entity work.ram_buff_entity_088be69e4f
    port map (
      addr => mux4_y_net_x0,
      ce_1 => ce_1_sg_x2,
      clk_1 => clk_1_sg_x2,
      data_in => delay13_q_net_x1,
      we => inverter4_op_net_x0,
      data_out => concat_y_net_x1
    );

  ram_buff_088be69e4f: entity work.ram_buff_entity_088be69e4f
    port map (
      addr => mux3_y_net_x0,
      ce_1 => ce_1_sg_x2,
      clk_1 => clk_1_sg_x2,
      data_in => delay13_q_net_x1,
      we => delay14_q_net_x0,
      data_out => concat_y_net_x0
    );

  selector: entity work.counter_2943023fcf
    port map (
      ce => ce_1_sg_x2,
      clk => clk_1_sg_x2,
      clr => '0',
      en(0) => delay12_q_net_x1,
      op(0) => selector_op_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 72,
      new_msb => 143,
      x_width => 144,
      y_width => 72
    )
    port map (
      x => delay6_q_net,
      y => slice1_y_net
    );

  slice3: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 71,
      x_width => 144,
      y_width => 72
    )
    port map (
      x => delay6_q_net,
      y => slice3_y_net
    );

  slice5: entity work.xlslice
    generic map (
      new_lsb => 72,
      new_msb => 143,
      x_width => 144,
      y_width => 72
    )
    port map (
      x => delay11_q_net,
      y => slice5_y_net
    );

  slice7: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 71,
      x_width => 144,
      y_width => 72
    )
    port map (
      x => delay11_q_net,
      y => slice7_y_net
    );

  slice8: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 9,
      y_width => 1
    )
    port map (
      x => delay16_q_net_x0,
      y(0) => slice8_y_net
    );

  slice9: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 8,
      x_width => 9,
      y_width => 8
    )
    port map (
      x => delay16_q_net_x0,
      y => slice9_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/DRAM_LUT/dram"

entity dram_entity_3e48a1ef9e is
  port (
    address: in std_logic_vector(31 downto 0); 
    chan_512_clean_dram_lut_dram_mem_rd_dout: in std_logic_vector(143 downto 0); 
    chan_512_clean_dram_lut_dram_mem_rd_valid: in std_logic; 
    cmd_tag: in std_logic_vector(31 downto 0); 
    cmd_valid: in std_logic; 
    data_in: in std_logic_vector(143 downto 0); 
    rst: in std_logic; 
    rwn: in std_logic; 
    wr_be: in std_logic_vector(35 downto 0); 
    convert_address_x0: out std_logic_vector(31 downto 0); 
    convert_cmd_tag_x0: out std_logic_vector(31 downto 0); 
    convert_cmd_valid_x0: out std_logic; 
    convert_rd_ack_x0: out std_logic; 
    convert_rst_x0: out std_logic; 
    convert_rwn_x0: out std_logic; 
    convert_wr_be_x0: out std_logic_vector(17 downto 0); 
    data_out: out std_logic_vector(143 downto 0); 
    force_data_in_x0: out std_logic_vector(143 downto 0); 
    rd_valid: out std_logic
  );
end dram_entity_3e48a1ef9e;

architecture structural of dram_entity_3e48a1ef9e is
  signal assert_cmd_addr_dout_net: std_logic_vector(31 downto 0);
  signal assert_cmd_rnw_dout_net: std_logic;
  signal assert_cmd_tag_dout_net: std_logic_vector(31 downto 0);
  signal assert_cmd_valid_dout_net: std_logic;
  signal assert_rd_ack_dout_net: std_logic;
  signal assert_rst_dout_net: std_logic;
  signal assert_wr_be_dout_net: std_logic_vector(35 downto 0);
  signal assert_wr_din_dout_net: std_logic_vector(143 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_rd_dout_net_x0: std_logic_vector(143 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_rd_valid_net_x0: std_logic;
  signal constant1_op_net_x0: std_logic;
  signal constant2_op_net_x0: std_logic_vector(143 downto 0);
  signal constant3_op_net_x0: std_logic_vector(35 downto 0);
  signal constant4_op_net_x0: std_logic_vector(31 downto 0);
  signal constant_op_net_x0: std_logic;
  signal convert1_dout_net_x0: std_logic_vector(31 downto 0);
  signal convert_address_dout_net_x0: std_logic_vector(31 downto 0);
  signal convert_cmd_tag_dout_net_x0: std_logic_vector(31 downto 0);
  signal convert_cmd_valid_dout_net_x0: std_logic;
  signal convert_data_in_dout_net: std_logic_vector(143 downto 0);
  signal convert_rd_ack_dout_net_x0: std_logic;
  signal convert_rst_dout_net_x0: std_logic;
  signal convert_rwn_dout_net_x0: std_logic;
  signal convert_wr_be_dout_net_x0: std_logic_vector(17 downto 0);
  signal delay1_q_net_x0: std_logic;
  signal force_data_in_output_port_net_x0: std_logic_vector(143 downto 0);
  signal force_rd_dout_output_port_net_x0: std_logic_vector(143 downto 0);
  signal simulation_multiplexer1_dout_net: std_logic_vector(143 downto 0);
  signal simulation_multiplexer3_dout_net_x0: std_logic;

begin
  convert1_dout_net_x0 <= address;
  chan_512_clean_dram_lut_dram_mem_rd_dout_net_x0 <= chan_512_clean_dram_lut_dram_mem_rd_dout;
  chan_512_clean_dram_lut_dram_mem_rd_valid_net_x0 <= chan_512_clean_dram_lut_dram_mem_rd_valid;
  constant4_op_net_x0 <= cmd_tag;
  delay1_q_net_x0 <= cmd_valid;
  constant2_op_net_x0 <= data_in;
  constant_op_net_x0 <= rst;
  constant1_op_net_x0 <= rwn;
  constant3_op_net_x0 <= wr_be;
  convert_address_x0 <= convert_address_dout_net_x0;
  convert_cmd_tag_x0 <= convert_cmd_tag_dout_net_x0;
  convert_cmd_valid_x0 <= convert_cmd_valid_dout_net_x0;
  convert_rd_ack_x0 <= convert_rd_ack_dout_net_x0;
  convert_rst_x0 <= convert_rst_dout_net_x0;
  convert_rwn_x0 <= convert_rwn_dout_net_x0;
  convert_wr_be_x0 <= convert_wr_be_dout_net_x0;
  data_out <= force_rd_dout_output_port_net_x0;
  force_data_in_x0 <= force_data_in_output_port_net_x0;
  rd_valid <= simulation_multiplexer3_dout_net_x0;

  assert_cmd_addr: entity work.xlpassthrough
    generic map (
      din_width => 32,
      dout_width => 32
    )
    port map (
      din => convert1_dout_net_x0,
      dout => assert_cmd_addr_dout_net
    );

  assert_cmd_rnw: entity work.xlpassthrough
    generic map (
      din_width => 1,
      dout_width => 1
    )
    port map (
      din(0) => constant1_op_net_x0,
      dout(0) => assert_cmd_rnw_dout_net
    );

  assert_cmd_tag: entity work.xlpassthrough
    generic map (
      din_width => 32,
      dout_width => 32
    )
    port map (
      din => constant4_op_net_x0,
      dout => assert_cmd_tag_dout_net
    );

  assert_cmd_valid: entity work.xlpassthrough
    generic map (
      din_width => 1,
      dout_width => 1
    )
    port map (
      din(0) => delay1_q_net_x0,
      dout(0) => assert_cmd_valid_dout_net
    );

  assert_rd_ack: entity work.xlpassthrough
    generic map (
      din_width => 1,
      dout_width => 1
    )
    port map (
      din(0) => constant1_op_net_x0,
      dout(0) => assert_rd_ack_dout_net
    );

  assert_rst: entity work.xlpassthrough
    generic map (
      din_width => 1,
      dout_width => 1
    )
    port map (
      din(0) => constant_op_net_x0,
      dout(0) => assert_rst_dout_net
    );

  assert_wr_be: entity work.xlpassthrough
    generic map (
      din_width => 36,
      dout_width => 36
    )
    port map (
      din => constant3_op_net_x0,
      dout => assert_wr_be_dout_net
    );

  assert_wr_din: entity work.xlpassthrough
    generic map (
      din_width => 144,
      dout_width => 144
    )
    port map (
      din => constant2_op_net_x0,
      dout => assert_wr_din_dout_net
    );

  convert_address: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 32,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => assert_cmd_addr_dout_net,
      dout => convert_address_dout_net_x0
    );

  convert_cmd_tag: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 32,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => assert_cmd_tag_dout_net,
      dout => convert_cmd_tag_dout_net_x0
    );

  convert_cmd_valid: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => assert_cmd_valid_dout_net,
      dout(0) => convert_cmd_valid_dout_net_x0
    );

  convert_data_in: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 144,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 144,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => assert_wr_din_dout_net,
      dout => convert_data_in_dout_net
    );

  convert_rd_ack: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => assert_rd_ack_dout_net,
      dout(0) => convert_rd_ack_dout_net_x0
    );

  convert_rst: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => assert_rst_dout_net,
      dout(0) => convert_rst_dout_net_x0
    );

  convert_rwn: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => assert_cmd_rnw_dout_net,
      dout(0) => convert_rwn_dout_net_x0
    );

  convert_wr_be: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 36,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => assert_wr_be_dout_net,
      dout => convert_wr_be_dout_net_x0
    );

  force_data_in: entity work.reinterpret_d35711d5ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert_data_in_dout_net,
      output_port => force_data_in_output_port_net_x0
    );

  force_rd_dout: entity work.reinterpret_d35711d5ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => simulation_multiplexer1_dout_net,
      output_port => force_rd_dout_output_port_net_x0
    );

  simulation_multiplexer1: entity work.xlpassthrough
    generic map (
      din_width => 144,
      dout_width => 144
    )
    port map (
      din => chan_512_clean_dram_lut_dram_mem_rd_dout_net_x0,
      dout => simulation_multiplexer1_dout_net
    );

  simulation_multiplexer3: entity work.xlpassthrough
    generic map (
      din_width => 1,
      dout_width => 1
    )
    port map (
      din(0) => chan_512_clean_dram_lut_dram_mem_rd_valid_net_x0,
      dout(0) => simulation_multiplexer3_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/DRAM_LUT/rd_valid"

entity rd_valid_entity_a0091712c4 is
  port (
    reg_out: in std_logic_vector(13 downto 0); 
    convert_x0: out std_logic_vector(31 downto 0)
  );
end rd_valid_entity_a0091712c4;

architecture structural of rd_valid_entity_a0091712c4 is
  signal convert_dout_net_x0: std_logic_vector(31 downto 0);
  signal counter1_op_net_x0: std_logic_vector(13 downto 0);

begin
  counter1_op_net_x0 <= reg_out;
  convert_x0 <= convert_dout_net_x0;

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 14,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => counter1_op_net_x0,
      dout => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/DRAM_LUT"

entity dram_lut_entity_639411377c is
  port (
    ce_1: in std_logic; 
    chan_512_clean_dram_lut_dram_mem_rd_dout: in std_logic_vector(143 downto 0); 
    chan_512_clean_dram_lut_dram_mem_rd_valid: in std_logic; 
    clk_1: in std_logic; 
    startdac: in std_logic; 
    data_i0: out std_logic_vector(15 downto 0); 
    data_i1: out std_logic_vector(15 downto 0); 
    data_q0: out std_logic_vector(15 downto 0); 
    data_q1: out std_logic_vector(15 downto 0); 
    dds_i0: out std_logic_vector(15 downto 0); 
    dds_i1: out std_logic_vector(15 downto 0); 
    dds_q0: out std_logic_vector(15 downto 0); 
    dds_q1: out std_logic_vector(15 downto 0); 
    dram: out std_logic_vector(31 downto 0); 
    dram_x0: out std_logic_vector(31 downto 0); 
    dram_x1: out std_logic; 
    dram_x2: out std_logic; 
    dram_x3: out std_logic; 
    dram_x4: out std_logic; 
    dram_x5: out std_logic_vector(17 downto 0); 
    dram_x6: out std_logic_vector(143 downto 0); 
    rd_valid: out std_logic_vector(31 downto 0)
  );
end dram_lut_entity_639411377c;

architecture structural of dram_lut_entity_639411377c is
  signal ce_1_sg_x3: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_rd_dout_net_x1: std_logic_vector(143 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_rd_valid_net_x1: std_logic;
  signal clk_1_sg_x3: std_logic;
  signal constant1_op_net_x0: std_logic;
  signal constant2_op_net_x0: std_logic_vector(143 downto 0);
  signal constant3_op_net_x0: std_logic_vector(35 downto 0);
  signal constant4_op_net_x0: std_logic_vector(31 downto 0);
  signal constant_op_net_x0: std_logic;
  signal convert1_dout_net_x0: std_logic_vector(31 downto 0);
  signal convert_address_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_cmd_tag_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_cmd_valid_dout_net_x1: std_logic;
  signal convert_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_rd_ack_dout_net_x1: std_logic;
  signal convert_rst_dout_net_x1: std_logic;
  signal convert_rwn_dout_net_x1: std_logic;
  signal convert_wr_be_dout_net_x1: std_logic_vector(17 downto 0);
  signal counter1_op_net_x0: std_logic_vector(13 downto 0);
  signal counter2_op_net: std_logic_vector(13 downto 0);
  signal counter5_op_net: std_logic;
  signal delay1_q_net_x0: std_logic;
  signal delay2_q_net: std_logic_vector(143 downto 0);
  signal delay4_q_net: std_logic;
  signal delay5_q_net: std_logic;
  signal force_data_in_output_port_net_x1: std_logic_vector(143 downto 0);
  signal force_rd_dout_output_port_net_x0: std_logic_vector(143 downto 0);
  signal inverter1_op_net: std_logic;
  signal inverter2_op_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical_y_net: std_logic;
  signal reinterpret1_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret2_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret3_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret4_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret5_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret6_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret7_output_port_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret8_output_port_net_x0: std_logic_vector(15 downto 0);
  signal simulation_multiplexer3_dout_net_x0: std_logic;
  signal slice10_y_net: std_logic_vector(15 downto 0);
  signal slice16_y_net: std_logic_vector(15 downto 0);
  signal slice17_y_net: std_logic_vector(15 downto 0);
  signal slice2_y_net: std_logic_vector(63 downto 0);
  signal slice3_y_net: std_logic_vector(63 downto 0);
  signal slice3_y_net_x1: std_logic;
  signal slice4_y_net: std_logic_vector(15 downto 0);
  signal slice5_y_net: std_logic;
  signal slice6_y_net: std_logic_vector(15 downto 0);
  signal slice7_y_net: std_logic_vector(15 downto 0);
  signal slice8_y_net: std_logic_vector(15 downto 0);
  signal slice9_y_net: std_logic_vector(15 downto 0);

begin
  ce_1_sg_x3 <= ce_1;
  chan_512_clean_dram_lut_dram_mem_rd_dout_net_x1 <= chan_512_clean_dram_lut_dram_mem_rd_dout;
  chan_512_clean_dram_lut_dram_mem_rd_valid_net_x1 <= chan_512_clean_dram_lut_dram_mem_rd_valid;
  clk_1_sg_x3 <= clk_1;
  slice3_y_net_x1 <= startdac;
  data_i0 <= reinterpret4_output_port_net_x0;
  data_i1 <= reinterpret1_output_port_net_x0;
  data_q0 <= reinterpret8_output_port_net_x0;
  data_q1 <= reinterpret7_output_port_net_x0;
  dds_i0 <= reinterpret5_output_port_net_x0;
  dds_i1 <= reinterpret6_output_port_net_x0;
  dds_q0 <= reinterpret3_output_port_net_x0;
  dds_q1 <= reinterpret2_output_port_net_x0;
  dram <= convert_address_dout_net_x1;
  dram_x0 <= convert_cmd_tag_dout_net_x1;
  dram_x1 <= convert_cmd_valid_dout_net_x1;
  dram_x2 <= convert_rd_ack_dout_net_x1;
  dram_x3 <= convert_rst_dout_net_x1;
  dram_x4 <= convert_rwn_dout_net_x1;
  dram_x5 <= convert_wr_be_dout_net_x1;
  dram_x6 <= force_data_in_output_port_net_x1;
  rd_valid <= convert_dout_net_x1;

  constant1: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant1_op_net_x0
    );

  constant2: entity work.constant_0a095deda6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net_x0
    );

  constant3: entity work.constant_bbd7b31fe5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant3_op_net_x0
    );

  constant4: entity work.constant_37567836aa
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant4_op_net_x0
    );

  constant_x0: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant_op_net_x0
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 14,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => counter2_op_net,
      dout => convert1_dout_net_x0
    );

  counter1: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_82b9fd0243bf8494",
      op_arith => xlUnsigned,
      op_width => 14
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      en(0) => logical_y_net,
      rst(0) => inverter2_op_net,
      op => counter1_op_net_x0
    );

  counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_82b9fd0243bf8494",
      op_arith => xlUnsigned,
      op_width => 14
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      en(0) => slice5_y_net,
      rst(0) => inverter1_op_net,
      op => counter2_op_net
    );

  counter5: entity work.counter_2943023fcf
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      en(0) => slice3_y_net_x1,
      op(0) => counter5_op_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      d(0) => delay4_q_net,
      en => '1',
      q(0) => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      d => force_rd_dout_output_port_net_x0,
      en => '1',
      q => delay2_q_net
    );

  delay4: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      d(0) => slice5_y_net,
      en => '1',
      q(0) => delay4_q_net
    );

  delay5: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      d(0) => simulation_multiplexer3_dout_net_x0,
      en => '1',
      q(0) => delay5_q_net
    );

  dram_3e48a1ef9e: entity work.dram_entity_3e48a1ef9e
    port map (
      address => convert1_dout_net_x0,
      chan_512_clean_dram_lut_dram_mem_rd_dout => chan_512_clean_dram_lut_dram_mem_rd_dout_net_x1,
      chan_512_clean_dram_lut_dram_mem_rd_valid => chan_512_clean_dram_lut_dram_mem_rd_valid_net_x1,
      cmd_tag => constant4_op_net_x0,
      cmd_valid => delay1_q_net_x0,
      data_in => constant2_op_net_x0,
      rst => constant_op_net_x0,
      rwn => constant1_op_net_x0,
      wr_be => constant3_op_net_x0,
      convert_address_x0 => convert_address_dout_net_x1,
      convert_cmd_tag_x0 => convert_cmd_tag_dout_net_x1,
      convert_cmd_valid_x0 => convert_cmd_valid_dout_net_x1,
      convert_rd_ack_x0 => convert_rd_ack_dout_net_x1,
      convert_rst_x0 => convert_rst_dout_net_x1,
      convert_rwn_x0 => convert_rwn_dout_net_x1,
      convert_wr_be_x0 => convert_wr_be_dout_net_x1,
      data_out => force_rd_dout_output_port_net_x0,
      force_data_in_x0 => force_data_in_output_port_net_x1,
      rd_valid => simulation_multiplexer3_dout_net_x0
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      ip(0) => delay5_q_net,
      op(0) => inverter_op_net
    );

  inverter1: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      ip(0) => slice3_y_net_x1,
      op(0) => inverter1_op_net
    );

  inverter2: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      ip(0) => slice3_y_net_x1,
      op(0) => inverter2_op_net
    );

  logical: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => inverter_op_net,
      d1(0) => slice3_y_net_x1,
      y(0) => logical_y_net
    );

  rd_valid_a0091712c4: entity work.rd_valid_entity_a0091712c4
    port map (
      reg_out => counter1_op_net_x0,
      convert_x0 => convert_dout_net_x1
    );

  reinterpret1: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice6_y_net,
      output_port => reinterpret1_output_port_net_x0
    );

  reinterpret2: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice8_y_net,
      output_port => reinterpret2_output_port_net_x0
    );

  reinterpret3: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice7_y_net,
      output_port => reinterpret3_output_port_net_x0
    );

  reinterpret4: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice4_y_net,
      output_port => reinterpret4_output_port_net_x0
    );

  reinterpret5: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice9_y_net,
      output_port => reinterpret5_output_port_net_x0
    );

  reinterpret6: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice10_y_net,
      output_port => reinterpret6_output_port_net_x0
    );

  reinterpret7: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice17_y_net,
      output_port => reinterpret7_output_port_net_x0
    );

  reinterpret8: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice16_y_net,
      output_port => reinterpret8_output_port_net_x0
    );

  slice10: entity work.xlslice
    generic map (
      new_lsb => 48,
      new_msb => 63,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice2_y_net,
      y => slice10_y_net
    );

  slice16: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 15,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice3_y_net,
      y => slice16_y_net
    );

  slice17: entity work.xlslice
    generic map (
      new_lsb => 16,
      new_msb => 31,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice3_y_net,
      y => slice17_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 63,
      x_width => 144,
      y_width => 64
    )
    port map (
      x => delay2_q_net,
      y => slice2_y_net
    );

  slice3: entity work.xlslice
    generic map (
      new_lsb => 72,
      new_msb => 135,
      x_width => 144,
      y_width => 64
    )
    port map (
      x => delay2_q_net,
      y => slice3_y_net
    );

  slice4: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 15,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice2_y_net,
      y => slice4_y_net
    );

  slice5: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 1,
      y_width => 1
    )
    port map (
      x(0) => counter5_op_net,
      y(0) => slice5_y_net
    );

  slice6: entity work.xlslice
    generic map (
      new_lsb => 16,
      new_msb => 31,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice2_y_net,
      y => slice6_y_net
    );

  slice7: entity work.xlslice
    generic map (
      new_lsb => 32,
      new_msb => 47,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice3_y_net,
      y => slice7_y_net
    );

  slice8: entity work.xlslice
    generic map (
      new_lsb => 48,
      new_msb => 63,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice3_y_net,
      y => slice8_y_net
    );

  slice9: entity work.xlslice
    generic map (
      new_lsb => 32,
      new_msb => 47,
      x_width => 64,
      y_width => 16
    )
    port map (
      x => slice2_y_net,
      y => slice9_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/FIR"

entity fir_entity_1abae60b67 is
  port (
    ce_1: in std_logic; 
    ch_in: in std_logic_vector(7 downto 0); 
    chan_512_clean_fir_b0b1_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b10b11_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b12b13_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b14b15_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b16b17_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b18b19_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b20b21_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b22b23_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b24b25_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b2b3_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b4b5_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b6b7_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b8b9_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_load_coeff_user_data_out: in std_logic_vector(31 downto 0); 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(11 downto 0); 
    ch_out: out std_logic_vector(7 downto 0); 
    data_out: out std_logic_vector(11 downto 0)
  );
end fir_entity_1abae60b67;

architecture structural of fir_entity_1abae60b67 is
  signal addsub10_s_net: std_logic_vector(24 downto 0);
  signal addsub11_s_net: std_logic_vector(24 downto 0);
  signal addsub12_s_net: std_logic_vector(24 downto 0);
  signal addsub13_s_net: std_logic_vector(25 downto 0);
  signal addsub14_s_net: std_logic_vector(25 downto 0);
  signal addsub15_s_net: std_logic_vector(25 downto 0);
  signal addsub16_s_net: std_logic_vector(25 downto 0);
  signal addsub17_s_net: std_logic_vector(25 downto 0);
  signal addsub18_s_net: std_logic_vector(25 downto 0);
  signal addsub19_s_net: std_logic_vector(26 downto 0);
  signal addsub1_s_net: std_logic_vector(24 downto 0);
  signal addsub20_s_net: std_logic_vector(26 downto 0);
  signal addsub21_s_net: std_logic_vector(26 downto 0);
  signal addsub22_s_net: std_logic_vector(27 downto 0);
  signal addsub23_s_net: std_logic_vector(27 downto 0);
  signal addsub25_s_net: std_logic_vector(24 downto 0);
  signal addsub2_s_net: std_logic_vector(24 downto 0);
  signal addsub3_s_net: std_logic_vector(24 downto 0);
  signal addsub40_s_net_x0: std_logic_vector(11 downto 0);
  signal addsub4_s_net: std_logic_vector(24 downto 0);
  signal addsub5_s_net: std_logic_vector(24 downto 0);
  signal addsub6_s_net: std_logic_vector(24 downto 0);
  signal addsub7_s_net: std_logic_vector(24 downto 0);
  signal addsub8_s_net: std_logic_vector(24 downto 0);
  signal addsub9_s_net: std_logic_vector(24 downto 0);
  signal ce_1_sg_x4: std_logic;
  signal chan_512_clean_fir_b0b1_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b10b11_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b12b13_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b14b15_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b16b17_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b18b19_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b20b21_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b22b23_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b24b25_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b2b3_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b4b5_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b6b7_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b8b9_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_load_coeff_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal clk_1_sg_x4: std_logic;
  signal delay10_q_net_x0: std_logic_vector(11 downto 0);
  signal delay10_q_net_x1: std_logic_vector(11 downto 0);
  signal delay11_q_net: std_logic_vector(11 downto 0);
  signal delay12_q_net: std_logic_vector(11 downto 0);
  signal delay13_q_net: std_logic_vector(11 downto 0);
  signal delay14_q_net: std_logic_vector(11 downto 0);
  signal delay15_q_net: std_logic_vector(11 downto 0);
  signal delay16_q_net: std_logic_vector(11 downto 0);
  signal delay17_q_net: std_logic_vector(11 downto 0);
  signal delay18_q_net: std_logic_vector(11 downto 0);
  signal delay19_q_net: std_logic_vector(11 downto 0);
  signal delay1_q_net: std_logic_vector(11 downto 0);
  signal delay20_q_net: std_logic_vector(11 downto 0);
  signal delay21_q_net: std_logic_vector(11 downto 0);
  signal delay22_q_net: std_logic_vector(11 downto 0);
  signal delay23_q_net: std_logic_vector(11 downto 0);
  signal delay24_q_net_x0: std_logic_vector(7 downto 0);
  signal delay25_q_net: std_logic_vector(11 downto 0);
  signal delay26_q_net: std_logic_vector(11 downto 0);
  signal delay27_q_net: std_logic_vector(24 downto 0);
  signal delay28_q_net: std_logic_vector(25 downto 0);
  signal delay29_q_net: std_logic_vector(11 downto 0);
  signal delay2_q_net: std_logic_vector(11 downto 0);
  signal delay30_q_net: std_logic;
  signal delay31_q_net: std_logic_vector(31 downto 0);
  signal delay32_q_net: std_logic_vector(31 downto 0);
  signal delay33_q_net: std_logic_vector(31 downto 0);
  signal delay34_q_net: std_logic_vector(31 downto 0);
  signal delay35_q_net: std_logic_vector(31 downto 0);
  signal delay36_q_net: std_logic_vector(31 downto 0);
  signal delay37_q_net: std_logic_vector(31 downto 0);
  signal delay38_q_net: std_logic_vector(31 downto 0);
  signal delay39_q_net: std_logic_vector(31 downto 0);
  signal delay3_q_net: std_logic_vector(11 downto 0);
  signal delay40_q_net: std_logic_vector(31 downto 0);
  signal delay41_q_net: std_logic_vector(31 downto 0);
  signal delay42_q_net: std_logic_vector(31 downto 0);
  signal delay43_q_net: std_logic_vector(31 downto 0);
  signal delay44_q_net: std_logic_vector(31 downto 0);
  signal delay46_q_net: std_logic_vector(11 downto 0);
  signal delay4_q_net: std_logic_vector(11 downto 0);
  signal delay5_q_net: std_logic_vector(11 downto 0);
  signal delay6_q_net: std_logic_vector(11 downto 0);
  signal delay7_q_net: std_logic_vector(11 downto 0);
  signal delay8_q_net: std_logic_vector(11 downto 0);
  signal delay9_q_net_x0: std_logic_vector(11 downto 0);
  signal delay9_q_net_x1: std_logic_vector(7 downto 0);
  signal mult10_p_net: std_logic_vector(23 downto 0);
  signal mult11_p_net: std_logic_vector(23 downto 0);
  signal mult12_p_net: std_logic_vector(23 downto 0);
  signal mult13_p_net: std_logic_vector(23 downto 0);
  signal mult14_p_net: std_logic_vector(23 downto 0);
  signal mult15_p_net: std_logic_vector(23 downto 0);
  signal mult16_p_net: std_logic_vector(23 downto 0);
  signal mult17_p_net: std_logic_vector(23 downto 0);
  signal mult18_p_net: std_logic_vector(23 downto 0);
  signal mult19_p_net: std_logic_vector(23 downto 0);
  signal mult1_p_net: std_logic_vector(23 downto 0);
  signal mult20_p_net: std_logic_vector(23 downto 0);
  signal mult21_p_net: std_logic_vector(23 downto 0);
  signal mult22_p_net: std_logic_vector(23 downto 0);
  signal mult23_p_net: std_logic_vector(23 downto 0);
  signal mult24_p_net: std_logic_vector(23 downto 0);
  signal mult25_p_net: std_logic_vector(23 downto 0);
  signal mult2_p_net: std_logic_vector(23 downto 0);
  signal mult3_p_net: std_logic_vector(23 downto 0);
  signal mult4_p_net: std_logic_vector(23 downto 0);
  signal mult5_p_net: std_logic_vector(23 downto 0);
  signal mult6_p_net: std_logic_vector(23 downto 0);
  signal mult7_p_net: std_logic_vector(23 downto 0);
  signal mult8_p_net: std_logic_vector(23 downto 0);
  signal mult9_p_net: std_logic_vector(23 downto 0);
  signal mult_p_net: std_logic_vector(23 downto 0);
  signal mux2_y_net: std_logic_vector(7 downto 0);
  signal reinterpret10_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret11_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret12_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret13_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret14_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret15_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret16_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret17_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret18_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret19_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret20_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret21_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret22_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret23_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret24_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret25_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret26_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret27_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret2_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret3_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret4_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret5_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret6_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret7_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret8_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret9_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram10_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram11_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram12_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram13_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram1_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram2_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram3_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram4_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram5_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram6_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram7_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram8_data_out_net: std_logic_vector(23 downto 0);
  signal single_port_ram9_data_out_net: std_logic_vector(23 downto 0);
  signal slice10_y_net: std_logic_vector(11 downto 0);
  signal slice11_y_net: std_logic_vector(11 downto 0);
  signal slice13_y_net: std_logic_vector(11 downto 0);
  signal slice14_y_net: std_logic_vector(11 downto 0);
  signal slice15_y_net: std_logic_vector(11 downto 0);
  signal slice16_y_net: std_logic_vector(11 downto 0);
  signal slice17_y_net: std_logic_vector(11 downto 0);
  signal slice18_y_net: std_logic_vector(11 downto 0);
  signal slice19_y_net: std_logic_vector(11 downto 0);
  signal slice20_y_net: std_logic_vector(11 downto 0);
  signal slice21_y_net: std_logic_vector(11 downto 0);
  signal slice22_y_net: std_logic_vector(11 downto 0);
  signal slice23_y_net: std_logic;
  signal slice24_y_net: std_logic_vector(7 downto 0);
  signal slice25_y_net: std_logic_vector(11 downto 0);
  signal slice26_y_net: std_logic_vector(11 downto 0);
  signal slice27_y_net: std_logic_vector(11 downto 0);
  signal slice28_y_net: std_logic_vector(11 downto 0);
  signal slice29_y_net: std_logic_vector(11 downto 0);
  signal slice2_y_net: std_logic_vector(11 downto 0);
  signal slice30_y_net: std_logic_vector(11 downto 0);
  signal slice31_y_net: std_logic_vector(23 downto 0);
  signal slice32_y_net: std_logic_vector(23 downto 0);
  signal slice33_y_net: std_logic_vector(23 downto 0);
  signal slice34_y_net: std_logic_vector(23 downto 0);
  signal slice35_y_net: std_logic_vector(23 downto 0);
  signal slice36_y_net: std_logic_vector(23 downto 0);
  signal slice37_y_net: std_logic_vector(23 downto 0);
  signal slice38_y_net: std_logic_vector(23 downto 0);
  signal slice39_y_net: std_logic_vector(23 downto 0);
  signal slice3_y_net: std_logic_vector(11 downto 0);
  signal slice40_y_net: std_logic_vector(23 downto 0);
  signal slice41_y_net: std_logic_vector(23 downto 0);
  signal slice42_y_net: std_logic_vector(23 downto 0);
  signal slice43_y_net: std_logic_vector(23 downto 0);
  signal slice4_y_net: std_logic_vector(11 downto 0);
  signal slice5_y_net: std_logic_vector(11 downto 0);
  signal slice6_y_net: std_logic_vector(11 downto 0);
  signal slice7_y_net: std_logic_vector(11 downto 0);
  signal slice8_y_net: std_logic_vector(11 downto 0);
  signal slice9_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x4 <= ce_1;
  delay9_q_net_x1 <= ch_in;
  chan_512_clean_fir_b0b1_user_data_out_net_x0 <= chan_512_clean_fir_b0b1_user_data_out;
  chan_512_clean_fir_b10b11_user_data_out_net_x0 <= chan_512_clean_fir_b10b11_user_data_out;
  chan_512_clean_fir_b12b13_user_data_out_net_x0 <= chan_512_clean_fir_b12b13_user_data_out;
  chan_512_clean_fir_b14b15_user_data_out_net_x0 <= chan_512_clean_fir_b14b15_user_data_out;
  chan_512_clean_fir_b16b17_user_data_out_net_x0 <= chan_512_clean_fir_b16b17_user_data_out;
  chan_512_clean_fir_b18b19_user_data_out_net_x0 <= chan_512_clean_fir_b18b19_user_data_out;
  chan_512_clean_fir_b20b21_user_data_out_net_x0 <= chan_512_clean_fir_b20b21_user_data_out;
  chan_512_clean_fir_b22b23_user_data_out_net_x0 <= chan_512_clean_fir_b22b23_user_data_out;
  chan_512_clean_fir_b24b25_user_data_out_net_x0 <= chan_512_clean_fir_b24b25_user_data_out;
  chan_512_clean_fir_b2b3_user_data_out_net_x0 <= chan_512_clean_fir_b2b3_user_data_out;
  chan_512_clean_fir_b4b5_user_data_out_net_x0 <= chan_512_clean_fir_b4b5_user_data_out;
  chan_512_clean_fir_b6b7_user_data_out_net_x0 <= chan_512_clean_fir_b6b7_user_data_out;
  chan_512_clean_fir_b8b9_user_data_out_net_x0 <= chan_512_clean_fir_b8b9_user_data_out;
  chan_512_clean_fir_load_coeff_user_data_out_net_x0 <= chan_512_clean_fir_load_coeff_user_data_out;
  clk_1_sg_x4 <= clk_1;
  delay10_q_net_x1 <= data_in;
  ch_out <= delay24_q_net_x0;
  data_out <= addsub40_s_net_x0;

  addsub1: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult2_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub1_s_net
    );

  addsub10: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult20_p_net,
      b => mult21_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub10_s_net
    );

  addsub11: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult22_p_net,
      b => mult23_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub11_s_net
    );

  addsub12: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult24_p_net,
      b => mult25_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub12_s_net
    );

  addsub13: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 26,
      core_name0 => "addsb_11_0_6407470611dcff3a",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 26
    )
    port map (
      a => addsub11_s_net,
      b => addsub12_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub13_s_net
    );

  addsub14: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 26,
      core_name0 => "addsb_11_0_6407470611dcff3a",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 26
    )
    port map (
      a => addsub9_s_net,
      b => addsub10_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub14_s_net
    );

  addsub15: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 26,
      core_name0 => "addsb_11_0_6407470611dcff3a",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 26
    )
    port map (
      a => addsub6_s_net,
      b => addsub8_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub15_s_net
    );

  addsub16: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 26,
      core_name0 => "addsb_11_0_6407470611dcff3a",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 26
    )
    port map (
      a => addsub7_s_net,
      b => addsub5_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub16_s_net
    );

  addsub17: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 26,
      core_name0 => "addsb_11_0_6407470611dcff3a",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 26
    )
    port map (
      a => addsub3_s_net,
      b => addsub4_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub17_s_net
    );

  addsub18: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 26,
      core_name0 => "addsb_11_0_6407470611dcff3a",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 26
    )
    port map (
      a => addsub1_s_net,
      b => addsub2_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub18_s_net
    );

  addsub19: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 26,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 27,
      core_name0 => "addsb_11_0_610003d72ed4acc9",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 27,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 27
    )
    port map (
      a => delay27_q_net,
      b => addsub18_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub19_s_net
    );

  addsub2: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult4_p_net,
      b => mult5_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub2_s_net
    );

  addsub20: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 26,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 26,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 27,
      core_name0 => "addsb_11_0_610003d72ed4acc9",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 27,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 27
    )
    port map (
      a => addsub17_s_net,
      b => addsub16_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub20_s_net
    );

  addsub21: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 26,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 26,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 27,
      core_name0 => "addsb_11_0_610003d72ed4acc9",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 27,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 27
    )
    port map (
      a => addsub15_s_net,
      b => addsub14_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub21_s_net
    );

  addsub22: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 27,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 26,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 28,
      core_name0 => "addsb_11_0_15f3be9ad2414bc9",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 28,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 28
    )
    port map (
      a => addsub21_s_net,
      b => delay28_q_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub22_s_net
    );

  addsub23: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 27,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 27,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 28,
      core_name0 => "addsb_11_0_15f3be9ad2414bc9",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 28,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 28
    )
    port map (
      a => addsub20_s_net,
      b => addsub19_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub23_s_net
    );

  addsub25: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult_p_net,
      b => mult1_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub25_s_net
    );

  addsub3: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult6_p_net,
      b => mult7_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub3_s_net
    );

  addsub4: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult8_p_net,
      b => mult9_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub4_s_net
    );

  addsub40: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 28,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 28,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 29,
      core_name0 => "addsb_11_0_13b3320717a8ab08",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 29,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 9,
      s_width => 12
    )
    port map (
      a => addsub23_s_net,
      b => addsub22_s_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub40_s_net_x0
    );

  addsub5: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult12_p_net,
      b => mult13_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub5_s_net
    );

  addsub6: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult14_p_net,
      b => mult15_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub6_s_net
    );

  addsub7: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult10_p_net,
      b => mult11_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub7_s_net
    );

  addsub8: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult16_p_net,
      b => mult17_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub8_s_net
    );

  addsub9: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 20,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 20,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 25,
      core_name0 => "addsb_11_0_3c81f668c73fe3bc",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 20,
      s_width => 25
    )
    port map (
      a => mult18_p_net,
      b => mult19_p_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      en => "1",
      s => addsub9_s_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay16_q_net,
      en => '1',
      q => delay1_q_net
    );

  delay10: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay9_q_net_x0,
      en => '1',
      q => delay10_q_net_x0
    );

  delay11: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay10_q_net_x0,
      en => '1',
      q => delay11_q_net
    );

  delay12: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay11_q_net,
      en => '1',
      q => delay12_q_net
    );

  delay13: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay46_q_net,
      en => '1',
      q => delay13_q_net
    );

  delay14: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay29_q_net,
      en => '1',
      q => delay14_q_net
    );

  delay15: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay13_q_net,
      en => '1',
      q => delay15_q_net
    );

  delay16: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay15_q_net,
      en => '1',
      q => delay16_q_net
    );

  delay17: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay12_q_net,
      en => '1',
      q => delay17_q_net
    );

  delay18: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay17_q_net,
      en => '1',
      q => delay18_q_net
    );

  delay19: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay18_q_net,
      en => '1',
      q => delay19_q_net
    );

  delay2: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay1_q_net,
      en => '1',
      q => delay2_q_net
    );

  delay20: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay19_q_net,
      en => '1',
      q => delay20_q_net
    );

  delay21: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay20_q_net,
      en => '1',
      q => delay21_q_net
    );

  delay22: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay21_q_net,
      en => '1',
      q => delay22_q_net
    );

  delay23: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay10_q_net_x1,
      en => '1',
      q => delay23_q_net
    );

  delay24: entity work.xldelay
    generic map (
      latency => 24,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay9_q_net_x1,
      en => '1',
      q => delay24_q_net_x0
    );

  delay25: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay4_q_net,
      en => '1',
      q => delay25_q_net
    );

  delay26: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay25_q_net,
      en => '1',
      q => delay26_q_net
    );

  delay27: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 25
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => addsub25_s_net,
      en => '1',
      q => delay27_q_net
    );

  delay28: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 26
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => addsub13_s_net,
      en => '1',
      q => delay28_q_net
    );

  delay29: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay23_q_net,
      en => '1',
      q => delay29_q_net
    );

  delay3: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay14_q_net,
      en => '1',
      q => delay3_q_net
    );

  delay30: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d(0) => slice23_y_net,
      en => '1',
      q(0) => delay30_q_net
    );

  delay31: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_load_coeff_user_data_out_net_x0,
      en => '1',
      q => delay31_q_net
    );

  delay32: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b0b1_user_data_out_net_x0,
      en => '1',
      q => delay32_q_net
    );

  delay33: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b2b3_user_data_out_net_x0,
      en => '1',
      q => delay33_q_net
    );

  delay34: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b4b5_user_data_out_net_x0,
      en => '1',
      q => delay34_q_net
    );

  delay35: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b6b7_user_data_out_net_x0,
      en => '1',
      q => delay35_q_net
    );

  delay36: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b8b9_user_data_out_net_x0,
      en => '1',
      q => delay36_q_net
    );

  delay37: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b10b11_user_data_out_net_x0,
      en => '1',
      q => delay37_q_net
    );

  delay38: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b12b13_user_data_out_net_x0,
      en => '1',
      q => delay38_q_net
    );

  delay39: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b14b15_user_data_out_net_x0,
      en => '1',
      q => delay39_q_net
    );

  delay4: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay2_q_net,
      en => '1',
      q => delay4_q_net
    );

  delay40: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b16b17_user_data_out_net_x0,
      en => '1',
      q => delay40_q_net
    );

  delay41: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b18b19_user_data_out_net_x0,
      en => '1',
      q => delay41_q_net
    );

  delay42: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b20b21_user_data_out_net_x0,
      en => '1',
      q => delay42_q_net
    );

  delay43: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b22b23_user_data_out_net_x0,
      en => '1',
      q => delay43_q_net
    );

  delay44: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 32
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => chan_512_clean_fir_b24b25_user_data_out_net_x0,
      en => '1',
      q => delay44_q_net
    );

  delay46: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay22_q_net,
      en => '1',
      q => delay46_q_net
    );

  delay5: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay3_q_net,
      en => '1',
      q => delay5_q_net
    );

  delay6: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay5_q_net,
      en => '1',
      q => delay6_q_net
    );

  delay7: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay6_q_net,
      en => '1',
      q => delay7_q_net
    );

  delay8: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay7_q_net,
      en => '1',
      q => delay8_q_net
    );

  delay9: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 12
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d => delay8_q_net,
      en => '1',
      q => delay9_q_net_x0
    );

  mult: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay29_q_net,
      b => reinterpret3_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult_p_net
    );

  mult1: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay14_q_net,
      b => reinterpret2_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult1_p_net
    );

  mult10: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay12_q_net,
      b => reinterpret13_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult10_p_net
    );

  mult11: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay17_q_net,
      b => reinterpret12_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult11_p_net
    );

  mult12: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay18_q_net,
      b => reinterpret15_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult12_p_net
    );

  mult13: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay19_q_net,
      b => reinterpret14_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult13_p_net
    );

  mult14: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay20_q_net,
      b => reinterpret17_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult14_p_net
    );

  mult15: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay21_q_net,
      b => reinterpret16_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult15_p_net
    );

  mult16: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay22_q_net,
      b => reinterpret19_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult16_p_net
    );

  mult17: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay46_q_net,
      b => reinterpret18_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult17_p_net
    );

  mult18: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay13_q_net,
      b => reinterpret21_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult18_p_net
    );

  mult19: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay15_q_net,
      b => reinterpret20_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult19_p_net
    );

  mult2: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay3_q_net,
      b => reinterpret5_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult2_p_net
    );

  mult20: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay16_q_net,
      b => reinterpret23_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult20_p_net
    );

  mult21: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay1_q_net,
      b => reinterpret22_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult21_p_net
    );

  mult22: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay2_q_net,
      b => reinterpret25_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult22_p_net
    );

  mult23: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay4_q_net,
      b => reinterpret24_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult23_p_net
    );

  mult24: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay25_q_net,
      b => reinterpret27_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult24_p_net
    );

  mult25: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay26_q_net,
      b => reinterpret26_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult25_p_net
    );

  mult3: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay5_q_net,
      b => reinterpret4_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult3_p_net
    );

  mult4: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay6_q_net,
      b => reinterpret7_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult4_p_net
    );

  mult5: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay7_q_net,
      b => reinterpret6_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult5_p_net
    );

  mult6: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay8_q_net,
      b => reinterpret9_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult6_p_net
    );

  mult7: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay9_q_net_x0,
      b => reinterpret8_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult7_p_net
    );

  mult8: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay10_q_net_x0,
      b => reinterpret11_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult8_p_net
    );

  mult9: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 9,
      a_width => 12,
      b_arith => xlSigned,
      b_bin_pt => 11,
      b_width => 12,
      c_a_type => 0,
      c_a_width => 12,
      c_b_type => 0,
      c_b_width => 12,
      c_baat => 12,
      c_output_width => 24,
      c_type => 0,
      core_name0 => "mlt_11_2_0c13abc32fd5d8d9",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 20,
      p_width => 24,
      quantization => 1
    )
    port map (
      a => delay11_q_net,
      b => reinterpret10_output_port_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      core_ce => ce_1_sg_x4,
      core_clk => clk_1_sg_x4,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult9_p_net
    );

  mux2: entity work.mux_cc14a035dc
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      clr => '0',
      d0 => delay9_q_net_x1,
      d1 => slice24_y_net,
      sel(0) => slice23_y_net,
      y => mux2_y_net
    );

  reinterpret10: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice11_y_net,
      output_port => reinterpret10_output_port_net
    );

  reinterpret11: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice10_y_net,
      output_port => reinterpret11_output_port_net
    );

  reinterpret12: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice14_y_net,
      output_port => reinterpret12_output_port_net
    );

  reinterpret13: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice13_y_net,
      output_port => reinterpret13_output_port_net
    );

  reinterpret14: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice16_y_net,
      output_port => reinterpret14_output_port_net
    );

  reinterpret15: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice15_y_net,
      output_port => reinterpret15_output_port_net
    );

  reinterpret16: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice18_y_net,
      output_port => reinterpret16_output_port_net
    );

  reinterpret17: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice17_y_net,
      output_port => reinterpret17_output_port_net
    );

  reinterpret18: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice20_y_net,
      output_port => reinterpret18_output_port_net
    );

  reinterpret19: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice19_y_net,
      output_port => reinterpret19_output_port_net
    );

  reinterpret2: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice3_y_net,
      output_port => reinterpret2_output_port_net
    );

  reinterpret20: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice22_y_net,
      output_port => reinterpret20_output_port_net
    );

  reinterpret21: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice21_y_net,
      output_port => reinterpret21_output_port_net
    );

  reinterpret22: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice26_y_net,
      output_port => reinterpret22_output_port_net
    );

  reinterpret23: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice25_y_net,
      output_port => reinterpret23_output_port_net
    );

  reinterpret24: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice28_y_net,
      output_port => reinterpret24_output_port_net
    );

  reinterpret25: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice27_y_net,
      output_port => reinterpret25_output_port_net
    );

  reinterpret26: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice30_y_net,
      output_port => reinterpret26_output_port_net
    );

  reinterpret27: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice29_y_net,
      output_port => reinterpret27_output_port_net
    );

  reinterpret3: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice2_y_net,
      output_port => reinterpret3_output_port_net
    );

  reinterpret4: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice5_y_net,
      output_port => reinterpret4_output_port_net
    );

  reinterpret5: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice4_y_net,
      output_port => reinterpret5_output_port_net
    );

  reinterpret6: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice7_y_net,
      output_port => reinterpret6_output_port_net
    );

  reinterpret7: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice6_y_net,
      output_port => reinterpret7_output_port_net
    );

  reinterpret8: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice9_y_net,
      output_port => reinterpret8_output_port_net
    );

  reinterpret9: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice8_y_net,
      output_port => reinterpret9_output_port_net
    );

  single_port_ram1: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice34_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram1_data_out_net
    );

  single_port_ram10: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice40_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram10_data_out_net
    );

  single_port_ram11: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice41_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram11_data_out_net
    );

  single_port_ram12: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e67a48b1c0b67489",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice42_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram12_data_out_net
    );

  single_port_ram13: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_45e45a6b0b32f614",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice43_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram13_data_out_net
    );

  single_port_ram2: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_867ea1042efc7235",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice31_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram2_data_out_net
    );

  single_port_ram3: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice32_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram3_data_out_net
    );

  single_port_ram4: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice33_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram4_data_out_net
    );

  single_port_ram5: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice35_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram5_data_out_net
    );

  single_port_ram6: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice36_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram6_data_out_net
    );

  single_port_ram7: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice37_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram7_data_out_net
    );

  single_port_ram8: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice38_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram8_data_out_net
    );

  single_port_ram9: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_e5c8c619115aa07c",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      data_in => slice39_y_net,
      en => "1",
      rst => "0",
      we(0) => delay30_q_net,
      data_out => single_port_ram9_data_out_net
    );

  slice10: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram5_data_out_net,
      y => slice10_y_net
    );

  slice11: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram5_data_out_net,
      y => slice11_y_net
    );

  slice13: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram6_data_out_net,
      y => slice13_y_net
    );

  slice14: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram6_data_out_net,
      y => slice14_y_net
    );

  slice15: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram7_data_out_net,
      y => slice15_y_net
    );

  slice16: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram7_data_out_net,
      y => slice16_y_net
    );

  slice17: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram8_data_out_net,
      y => slice17_y_net
    );

  slice18: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram8_data_out_net,
      y => slice18_y_net
    );

  slice19: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram9_data_out_net,
      y => slice19_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram2_data_out_net,
      y => slice2_y_net
    );

  slice20: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram9_data_out_net,
      y => slice20_y_net
    );

  slice21: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram10_data_out_net,
      y => slice21_y_net
    );

  slice22: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram10_data_out_net,
      y => slice22_y_net
    );

  slice23: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => delay31_q_net,
      y(0) => slice23_y_net
    );

  slice24: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 8,
      x_width => 32,
      y_width => 8
    )
    port map (
      x => delay31_q_net,
      y => slice24_y_net
    );

  slice25: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram11_data_out_net,
      y => slice25_y_net
    );

  slice26: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram11_data_out_net,
      y => slice26_y_net
    );

  slice27: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram12_data_out_net,
      y => slice27_y_net
    );

  slice28: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram12_data_out_net,
      y => slice28_y_net
    );

  slice29: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram13_data_out_net,
      y => slice29_y_net
    );

  slice3: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram2_data_out_net,
      y => slice3_y_net
    );

  slice30: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram13_data_out_net,
      y => slice30_y_net
    );

  slice31: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay32_q_net,
      y => slice31_y_net
    );

  slice32: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay33_q_net,
      y => slice32_y_net
    );

  slice33: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay34_q_net,
      y => slice33_y_net
    );

  slice34: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay35_q_net,
      y => slice34_y_net
    );

  slice35: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay36_q_net,
      y => slice35_y_net
    );

  slice36: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay37_q_net,
      y => slice36_y_net
    );

  slice37: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay38_q_net,
      y => slice37_y_net
    );

  slice38: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay39_q_net,
      y => slice38_y_net
    );

  slice39: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay40_q_net,
      y => slice39_y_net
    );

  slice4: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram3_data_out_net,
      y => slice4_y_net
    );

  slice40: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay41_q_net,
      y => slice40_y_net
    );

  slice41: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay42_q_net,
      y => slice41_y_net
    );

  slice42: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay43_q_net,
      y => slice42_y_net
    );

  slice43: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 32,
      y_width => 24
    )
    port map (
      x => delay44_q_net,
      y => slice43_y_net
    );

  slice5: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram3_data_out_net,
      y => slice5_y_net
    );

  slice6: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram4_data_out_net,
      y => slice6_y_net
    );

  slice7: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram4_data_out_net,
      y => slice7_y_net
    );

  slice8: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram1_data_out_net,
      y => slice8_y_net
    );

  slice9: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => single_port_ram1_data_out_net,
      y => slice9_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/Gen FFT_block ready"

entity gen_fft_block_ready_entity_65e3c5b8d9 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync_in: in std_logic; 
    data_ready: out std_logic
  );
end gen_fft_block_ready_entity_65e3c5b8d9;

architecture structural of gen_fft_block_ready_entity_65e3c5b8d9 is
  signal ce_1_sg_x5: std_logic;
  signal clk_1_sg_x5: std_logic;
  signal constant1_op_net: std_logic_vector(8 downto 0);
  signal constant2_op_net: std_logic;
  signal convert_dout_net: std_logic;
  signal fft_bin_counter_op_net: std_logic_vector(7 downto 0);
  signal logical1_y_net: std_logic;
  signal logical3_y_net_x0: std_logic;
  signal post_sync_delay_q_net_x0: std_logic;
  signal register_q_net: std_logic;
  signal relational3_op_net: std_logic;

begin
  ce_1_sg_x5 <= ce_1;
  clk_1_sg_x5 <= clk_1;
  post_sync_delay_q_net_x0 <= sync_in;
  data_ready <= logical3_y_net_x0;

  constant1: entity work.constant_523908e9ca
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => register_q_net,
      dout(0) => convert_dout_net
    );

  fft_bin_counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_3141ead9d4e5a33a",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x5,
      clk => clk_1_sg_x5,
      clr => '0',
      en(0) => convert_dout_net,
      rst(0) => logical1_y_net,
      op => fft_bin_counter_op_net
    );

  logical1: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => post_sync_delay_q_net_x0,
      d1(0) => logical3_y_net_x0,
      y(0) => logical1_y_net
    );

  logical3: entity work.logical_89333b145c
    port map (
      ce => ce_1_sg_x5,
      clk => clk_1_sg_x5,
      clr => '0',
      d0(0) => post_sync_delay_q_net_x0,
      d1(0) => relational3_op_net,
      y(0) => logical3_y_net_x0
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x5,
      clk => clk_1_sg_x5,
      d(0) => constant2_op_net,
      en(0) => post_sync_delay_q_net_x0,
      rst => "0",
      q(0) => register_q_net
    );

  relational3: entity work.relational_20f7810fc0
    port map (
      a => fft_bin_counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational3_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/c_to_ri1"

entity c_to_ri1_entity_91f65b6f7a is
  port (
    c: in std_logic_vector(35 downto 0); 
    im: out std_logic_vector(17 downto 0); 
    re: out std_logic_vector(17 downto 0)
  );
end c_to_ri1_entity_91f65b6f7a;

architecture structural of c_to_ri1_entity_91f65b6f7a is
  signal bram1_data_out_net_x0: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal slice_im_y_net: std_logic_vector(17 downto 0);
  signal slice_re_y_net: std_logic_vector(17 downto 0);

begin
  bram1_data_out_net_x0 <= c;
  im <= force_im_output_port_net_x0;
  re <= force_re_output_port_net_x0;

  force_im: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_im_y_net,
      output_port => force_im_output_port_net_x0
    );

  force_re: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_re_y_net,
      output_port => force_re_output_port_net_x0
    );

  slice_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 17,
      x_width => 36,
      y_width => 18
    )
    port map (
      x => bram1_data_out_net_x0,
      y => slice_im_y_net
    );

  slice_re: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 35,
      x_width => 36,
      y_width => 18
    )
    port map (
      x => bram1_data_out_net_x0,
      y => slice_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/c_to_ri3"

entity c_to_ri3_entity_9f372b9ce8 is
  port (
    c: in std_logic_vector(23 downto 0); 
    im: out std_logic_vector(11 downto 0); 
    re: out std_logic_vector(11 downto 0)
  );
end c_to_ri3_entity_9f372b9ce8;

architecture structural of c_to_ri3_entity_9f372b9ce8 is
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal register1_q_net_x0: std_logic_vector(23 downto 0);
  signal slice_im_y_net: std_logic_vector(11 downto 0);
  signal slice_re_y_net: std_logic_vector(11 downto 0);

begin
  register1_q_net_x0 <= c;
  im <= force_im_output_port_net_x0;
  re <= force_re_output_port_net_x0;

  force_im: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_im_y_net,
      output_port => force_im_output_port_net_x0
    );

  force_re: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_re_y_net,
      output_port => force_re_output_port_net_x0
    );

  slice_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => register1_q_net_x0,
      y => slice_im_y_net
    );

  slice_re: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => register1_q_net_x0,
      y => slice_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/butterfly_direct/cadd"

entity cadd_entity_fe10c9a76f is
  port (
    a_im: in std_logic_vector(17 downto 0); 
    a_re: in std_logic_vector(17 downto 0); 
    b_im: in std_logic_vector(17 downto 0); 
    b_re: in std_logic_vector(17 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    c_im: out std_logic_vector(18 downto 0); 
    c_re: out std_logic_vector(18 downto 0)
  );
end cadd_entity_fe10c9a76f;

architecture structural of cadd_entity_fe10c9a76f is
  signal alumode_op_net: std_logic_vector(3 downto 0);
  signal carryin_op_net: std_logic;
  signal carryinsel_op_net: std_logic_vector(2 downto 0);
  signal cast_c_im_dout_net_x0: std_logic_vector(18 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(18 downto 0);
  signal ce_1_sg_x6: std_logic;
  signal clk_1_sg_x6: std_logic;
  signal concat_a_y_net: std_logic_vector(47 downto 0);
  signal concat_b_y_net: std_logic_vector(47 downto 0);
  signal dsp48e_p_net: std_logic_vector(47 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x2: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x2: std_logic_vector(17 downto 0);
  signal opmode_op_net: std_logic_vector(6 downto 0);
  signal realign_a_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_a_re_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_re_dout_net: std_logic_vector(23 downto 0);
  signal reinterp_a_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_a_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterpret_a_output_port_net: std_logic_vector(29 downto 0);
  signal reinterpret_b_output_port_net: std_logic_vector(17 downto 0);
  signal reinterpret_c_output_port_net: std_logic_vector(47 downto 0);
  signal slice_a_y_net: std_logic_vector(29 downto 0);
  signal slice_b_y_net: std_logic_vector(17 downto 0);
  signal slice_c_im_y_net: std_logic_vector(23 downto 0);
  signal slice_c_re_y_net: std_logic_vector(23 downto 0);

begin
  force_im_output_port_net_x1 <= a_im;
  force_re_output_port_net_x1 <= a_re;
  force_im_output_port_net_x2 <= b_im;
  force_re_output_port_net_x2 <= b_re;
  ce_1_sg_x6 <= ce_1;
  clk_1_sg_x6 <= clk_1;
  c_im <= cast_c_im_dout_net_x0;
  c_re <= cast_c_re_dout_net_x0;

  alumode: entity work.constant_4c449dd556
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => alumode_op_net
    );

  carryin: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => carryin_op_net
    );

  carryinsel: entity work.constant_822933f89b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => carryinsel_op_net
    );

  cast_c_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 21,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 19,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_im_output_port_net,
      dout => cast_c_im_dout_net_x0
    );

  cast_c_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 21,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 19,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_re_output_port_net,
      dout => cast_c_re_dout_net_x0
    );

  concat_a: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_a_re_output_port_net,
      in1 => reinterp_a_im_output_port_net,
      y => concat_a_y_net
    );

  concat_b: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_b_re_output_port_net,
      in1 => reinterp_b_im_output_port_net,
      y => concat_b_y_net
    );

  dsp48e: entity work.xldsp48e
    generic map (
      a_input => "DIRECT",
      acascreg => 1,
      alumodereg => 1,
      areg => 1,
      autoreset_pattern_detect => FALSE,
      autoreset_pattern_detect_optinv => "MATCH",
      b_input => "DIRECT",
      bcascreg => 1,
      breg => 1,
      carryinreg => 1,
      carryinselreg => 1,
      carryout_width => 4,
      creg => 1,
      mreg => 1,
      opmodereg => 1,
      preg => 1,
      sel_mask => "MASK",
      sel_pattern => "PATTERN",
      use_c_port => 1,
      use_mult => "MULT_S",
      use_op => 0,
      use_pattern_detect => "NO_PATDET",
      use_simd => "TWO24"
    )
    port map (
      a => reinterpret_a_output_port_net,
      alumode => alumode_op_net,
      b => reinterpret_b_output_port_net,
      c => reinterpret_c_output_port_net,
      carryin(0) => carryin_op_net,
      carryinsel => carryinsel_op_net,
      ce => ce_1_sg_x6,
      cea1 => "1",
      cea2 => "1",
      cealumode => "1",
      ceb1 => "1",
      ceb2 => "1",
      cec => "1",
      cecarryin => "1",
      cectrl => "1",
      cem => "1",
      cemultcarryin => "1",
      cep => "1",
      clk => clk_1_sg_x6,
      en => "1",
      opmode => opmode_op_net,
      rst => "0",
      rsta => "0",
      rstalumode => "0",
      rstb => "0",
      rstc => "0",
      rstcarryin => "0",
      rstctrl => "0",
      rstm => "0",
      rstp => "0",
      p => dsp48e_p_net
    );

  opmode: entity work.constant_270746ab47
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => opmode_op_net
    );

  realign_a_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x1,
      dout => realign_a_im_dout_net
    );

  realign_a_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x1,
      dout => realign_a_re_dout_net
    );

  realign_b_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x2,
      dout => realign_b_im_dout_net
    );

  realign_b_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x2,
      dout => realign_b_re_dout_net
    );

  reinterp_a_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_im_dout_net,
      output_port => reinterp_a_im_output_port_net
    );

  reinterp_a_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_re_dout_net,
      output_port => reinterp_a_re_output_port_net
    );

  reinterp_b_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_im_dout_net,
      output_port => reinterp_b_im_output_port_net
    );

  reinterp_b_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_re_dout_net,
      output_port => reinterp_b_re_output_port_net
    );

  reinterp_c_im: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_im_y_net,
      output_port => reinterp_c_im_output_port_net
    );

  reinterp_c_re: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_re_y_net,
      output_port => reinterp_c_re_output_port_net
    );

  reinterpret_a: entity work.reinterpret_eb03bc3377
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_a_y_net,
      output_port => reinterpret_a_output_port_net
    );

  reinterpret_b: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_b_y_net,
      output_port => reinterpret_b_output_port_net
    );

  reinterpret_c: entity work.reinterpret_7ea107432a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => concat_a_y_net,
      output_port => reinterpret_c_output_port_net
    );

  slice_a: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 47,
      x_width => 48,
      y_width => 30
    )
    port map (
      x => concat_b_y_net,
      y => slice_a_y_net
    );

  slice_b: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 17,
      x_width => 48,
      y_width => 18
    )
    port map (
      x => concat_b_y_net,
      y => slice_b_y_net
    );

  slice_c_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_im_y_net
    );

  slice_c_re: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 47,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/butterfly_direct/convert_of0"

entity convert_of0_entity_61a33b5e8a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(19 downto 0); 
    dout: out std_logic_vector(17 downto 0)
  );
end convert_of0_entity_61a33b5e8a;

architecture structural of convert_of0_entity_61a33b5e8a is
  signal ce_1_sg_x7: std_logic;
  signal clk_1_sg_x7: std_logic;
  signal convert_dout_net_x0: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(19 downto 0);

begin
  ce_1_sg_x7 <= ce_1;
  clk_1_sg_x7 <= clk_1;
  mux0_y_net_x0 <= din;
  dout <= convert_dout_net_x0;

  convert: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 18,
      din_width => 20,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x7,
      clk => clk_1_sg_x7,
      clr => '0',
      din => mux0_y_net_x0,
      dout => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/butterfly_direct/csub"

entity csub_entity_dab52e1868 is
  port (
    a_im: in std_logic_vector(17 downto 0); 
    a_re: in std_logic_vector(17 downto 0); 
    b_im: in std_logic_vector(17 downto 0); 
    b_re: in std_logic_vector(17 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    c_im: out std_logic_vector(18 downto 0); 
    c_re: out std_logic_vector(18 downto 0)
  );
end csub_entity_dab52e1868;

architecture structural of csub_entity_dab52e1868 is
  signal alumode_op_net: std_logic_vector(3 downto 0);
  signal carryin_op_net: std_logic;
  signal carryinsel_op_net: std_logic_vector(2 downto 0);
  signal cast_c_im_dout_net_x0: std_logic_vector(18 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(18 downto 0);
  signal ce_1_sg_x11: std_logic;
  signal clk_1_sg_x11: std_logic;
  signal concat_a_y_net: std_logic_vector(47 downto 0);
  signal concat_b_y_net: std_logic_vector(47 downto 0);
  signal dsp48e_p_net: std_logic_vector(47 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x4: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x4: std_logic_vector(17 downto 0);
  signal opmode_op_net: std_logic_vector(6 downto 0);
  signal realign_a_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_a_re_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_re_dout_net: std_logic_vector(23 downto 0);
  signal reinterp_a_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_a_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterpret_a_output_port_net: std_logic_vector(29 downto 0);
  signal reinterpret_b_output_port_net: std_logic_vector(17 downto 0);
  signal reinterpret_c_output_port_net: std_logic_vector(47 downto 0);
  signal slice_a_y_net: std_logic_vector(29 downto 0);
  signal slice_b_y_net: std_logic_vector(17 downto 0);
  signal slice_c_im_y_net: std_logic_vector(23 downto 0);
  signal slice_c_re_y_net: std_logic_vector(23 downto 0);

begin
  force_im_output_port_net_x3 <= a_im;
  force_re_output_port_net_x3 <= a_re;
  force_im_output_port_net_x4 <= b_im;
  force_re_output_port_net_x4 <= b_re;
  ce_1_sg_x11 <= ce_1;
  clk_1_sg_x11 <= clk_1;
  c_im <= cast_c_im_dout_net_x0;
  c_re <= cast_c_re_dout_net_x0;

  alumode: entity work.constant_8038205d89
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => alumode_op_net
    );

  carryin: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => carryin_op_net
    );

  carryinsel: entity work.constant_822933f89b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => carryinsel_op_net
    );

  cast_c_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 21,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 19,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_im_output_port_net,
      dout => cast_c_im_dout_net_x0
    );

  cast_c_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 21,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 19,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_re_output_port_net,
      dout => cast_c_re_dout_net_x0
    );

  concat_a: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_a_re_output_port_net,
      in1 => reinterp_a_im_output_port_net,
      y => concat_a_y_net
    );

  concat_b: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_b_re_output_port_net,
      in1 => reinterp_b_im_output_port_net,
      y => concat_b_y_net
    );

  dsp48e: entity work.xldsp48e
    generic map (
      a_input => "DIRECT",
      acascreg => 1,
      alumodereg => 1,
      areg => 1,
      autoreset_pattern_detect => FALSE,
      autoreset_pattern_detect_optinv => "MATCH",
      b_input => "DIRECT",
      bcascreg => 1,
      breg => 1,
      carryinreg => 1,
      carryinselreg => 1,
      carryout_width => 4,
      creg => 1,
      mreg => 1,
      opmodereg => 1,
      preg => 1,
      sel_mask => "MASK",
      sel_pattern => "PATTERN",
      use_c_port => 1,
      use_mult => "MULT_S",
      use_op => 0,
      use_pattern_detect => "NO_PATDET",
      use_simd => "TWO24"
    )
    port map (
      a => reinterpret_a_output_port_net,
      alumode => alumode_op_net,
      b => reinterpret_b_output_port_net,
      c => reinterpret_c_output_port_net,
      carryin(0) => carryin_op_net,
      carryinsel => carryinsel_op_net,
      ce => ce_1_sg_x11,
      cea1 => "1",
      cea2 => "1",
      cealumode => "1",
      ceb1 => "1",
      ceb2 => "1",
      cec => "1",
      cecarryin => "1",
      cectrl => "1",
      cem => "1",
      cemultcarryin => "1",
      cep => "1",
      clk => clk_1_sg_x11,
      en => "1",
      opmode => opmode_op_net,
      rst => "0",
      rsta => "0",
      rstalumode => "0",
      rstb => "0",
      rstc => "0",
      rstcarryin => "0",
      rstctrl => "0",
      rstm => "0",
      rstp => "0",
      p => dsp48e_p_net
    );

  opmode: entity work.constant_270746ab47
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => opmode_op_net
    );

  realign_a_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x3,
      dout => realign_a_im_dout_net
    );

  realign_a_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x3,
      dout => realign_a_re_dout_net
    );

  realign_b_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x4,
      dout => realign_b_im_dout_net
    );

  realign_b_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 21,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x4,
      dout => realign_b_re_dout_net
    );

  reinterp_a_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_im_dout_net,
      output_port => reinterp_a_im_output_port_net
    );

  reinterp_a_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_re_dout_net,
      output_port => reinterp_a_re_output_port_net
    );

  reinterp_b_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_im_dout_net,
      output_port => reinterp_b_im_output_port_net
    );

  reinterp_b_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_re_dout_net,
      output_port => reinterp_b_re_output_port_net
    );

  reinterp_c_im: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_im_y_net,
      output_port => reinterp_c_im_output_port_net
    );

  reinterp_c_re: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_re_y_net,
      output_port => reinterp_c_re_output_port_net
    );

  reinterpret_a: entity work.reinterpret_eb03bc3377
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_a_y_net,
      output_port => reinterpret_a_output_port_net
    );

  reinterpret_b: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_b_y_net,
      output_port => reinterpret_b_output_port_net
    );

  reinterpret_c: entity work.reinterpret_7ea107432a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => concat_a_y_net,
      output_port => reinterpret_c_output_port_net
    );

  slice_a: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 47,
      x_width => 48,
      y_width => 30
    )
    port map (
      x => concat_b_y_net,
      y => slice_a_y_net
    );

  slice_b: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 17,
      x_width => 48,
      y_width => 18
    )
    port map (
      x => concat_b_y_net,
      y => slice_b_y_net
    );

  slice_c_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_im_y_net
    );

  slice_c_re: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 47,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/butterfly_direct/ri_to_c01"

entity ri_to_c01_entity_cc24d6b27a is
  port (
    im: in std_logic_vector(17 downto 0); 
    re: in std_logic_vector(17 downto 0); 
    c: out std_logic_vector(35 downto 0)
  );
end ri_to_c01_entity_cc24d6b27a;

architecture structural of ri_to_c01_entity_cc24d6b27a is
  signal concat_y_net_x0: std_logic_vector(35 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal force_im_output_port_net: std_logic_vector(17 downto 0);
  signal force_re_output_port_net: std_logic_vector(17 downto 0);

begin
  convert_dout_net_x3 <= im;
  convert_dout_net_x2 <= re;
  c <= concat_y_net_x0;

  concat: entity work.concat_b198bd62b0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => force_re_output_port_net,
      in1 => force_im_output_port_net,
      y => concat_y_net_x0
    );

  force_im: entity work.reinterpret_580feec131
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert_dout_net_x3,
      output_port => force_im_output_port_net
    );

  force_re: entity work.reinterpret_580feec131
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert_dout_net_x2,
      output_port => force_re_output_port_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/butterfly_direct/twiddle_pass_through"

entity twiddle_pass_through_entity_e29317f462 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(17 downto 0); 
    bw_re: out std_logic_vector(17 downto 0)
  );
end twiddle_pass_through_entity_e29317f462;

architecture structural of twiddle_pass_through_entity_e29317f462 is
  signal force_im_output_port_net_x6: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x7: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x6: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x7: std_logic_vector(17 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x1: std_logic_vector(35 downto 0);

begin
  single_port_ram_data_out_net_x1 <= a;
  mux_y_net_x1 <= b;
  a_im <= force_im_output_port_net_x6;
  a_re <= force_re_output_port_net_x6;
  bw_im <= force_im_output_port_net_x7;
  bw_re <= force_re_output_port_net_x7;

  c_to_ri1_fb210ce2e8: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => mux_y_net_x1,
      im => force_im_output_port_net_x7,
      re => force_re_output_port_net_x7
    );

  c_to_ri_33af9906b7: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => single_port_ram_data_out_net_x1,
      im => force_im_output_port_net_x6,
      re => force_re_output_port_net_x6
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/butterfly_direct"

entity butterfly_direct_entity_3cab01cdac is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_3cab01cdac;

architecture structural of butterfly_direct_entity_3cab01cdac is
  signal cast_c_im_dout_net_x0: std_logic_vector(18 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(18 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(18 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(18 downto 0);
  signal ce_1_sg_x12: std_logic;
  signal clk_1_sg_x12: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x6: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x7: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x6: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x7: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(19 downto 0);
  signal mux1_y_net_x0: std_logic_vector(19 downto 0);
  signal mux2_y_net_x0: std_logic_vector(19 downto 0);
  signal mux3_y_net_x0: std_logic_vector(19 downto 0);
  signal mux_y_net_x0: std_logic;
  signal mux_y_net_x2: std_logic_vector(35 downto 0);
  signal scale0_op_net: std_logic_vector(18 downto 0);
  signal scale1_op_net: std_logic_vector(18 downto 0);
  signal scale2_op_net: std_logic_vector(18 downto 0);
  signal scale3_op_net: std_logic_vector(18 downto 0);
  signal shift_delay_q_net: std_logic;
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  single_port_ram_data_out_net_x2 <= a;
  mux_y_net_x2 <= b;
  ce_1_sg_x12 <= ce_1;
  clk_1_sg_x12 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x0 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_fe10c9a76f: entity work.cadd_entity_fe10c9a76f
    port map (
      a_im => force_im_output_port_net_x6,
      a_re => force_re_output_port_net_x6,
      b_im => force_im_output_port_net_x7,
      b_re => force_re_output_port_net_x7,
      ce_1 => ce_1_sg_x12,
      clk_1 => clk_1_sg_x12,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_61a33b5e8a: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x12,
      clk_1 => clk_1_sg_x12,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_26d07d6478: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x12,
      clk_1 => clk_1_sg_x12,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_ab7f43eeb2: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x12,
      clk_1 => clk_1_sg_x12,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_23a2582f33: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x12,
      clk_1 => clk_1_sg_x12,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_dab52e1868: entity work.csub_entity_dab52e1868
    port map (
      a_im => force_im_output_port_net_x6,
      a_re => force_re_output_port_net_x6,
      b_im => force_im_output_port_net_x7,
      b_re => force_re_output_port_net_x7,
      ce_1 => ce_1_sg_x12,
      clk_1 => clk_1_sg_x12,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x12,
      clk => clk_1_sg_x12,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x12,
      clk => clk_1_sg_x12,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x12,
      clk => clk_1_sg_x12,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x12,
      clk => clk_1_sg_x12,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_cc24d6b27a: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_ac927b3ea4: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x12,
      clk => clk_1_sg_x12,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x12,
      clk => clk_1_sg_x12,
      clr => '0',
      d(0) => mux_y_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_pass_through_e29317f462: entity work.twiddle_pass_through_entity_e29317f462
    port map (
      a => single_port_ram_data_out_net_x2,
      b => mux_y_net_x2,
      a_im => force_im_output_port_net_x6,
      a_re => force_re_output_port_net_x6,
      bw_im => force_im_output_port_net_x7,
      bw_re => force_re_output_port_net_x7
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/delay_b"

entity delay_b_entity_ff5e0572da is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_ff5e0572da;

architecture structural of delay_b_entity_ff5e0572da is
  signal ce_1_sg_x13: std_logic;
  signal clk_1_sg_x13: std_logic;
  signal constant2_op_net: std_logic;
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x3: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x13 <= ce_1;
  clk_1_sg_x13 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= single_port_ram_data_out_net_x3;

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 124,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      en => "1",
      rst => "0",
      op => counter_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 7,
      c_width => 36,
      core_name0 => "bmg_33_48da6872a2de2862",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      data_in => mux1_y_net_x0,
      en => "1",
      rst => "0",
      we(0) => constant2_op_net,
      data_out => single_port_ram_data_out_net_x3
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1/sync_delay"

entity sync_delay_entity_e3d123a84a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_e3d123a84a;

architecture structural of sync_delay_entity_e3d123a84a is
  signal ce_1_sg_x15: std_logic;
  signal clk_1_sg_x15: std_logic;
  signal constant1_op_net: std_logic_vector(7 downto 0);
  signal constant2_op_net: std_logic_vector(7 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(7 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x1: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x15 <= ce_1;
  clk_1_sg_x15 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x1;

  constant1: entity work.constant_91ef1678ca
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_e8aae5d3bb
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_b437b02512
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_9cd1168730d276e8",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x15,
      clk => clk_1_sg_x15,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x1
    );

  relational: entity work.relational_54048c8b02
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_16235eb2bf
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_1"

entity fft_stage_1_entity_514d753017 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_1_entity_514d753017;

architecture structural of fft_stage_1_entity_514d753017 is
  signal ce_1_sg_x16: std_logic;
  signal clk_1_sg_x16: std_logic;
  signal concat_y_net_x4: std_logic_vector(35 downto 0);
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal constant1_op_net_x0: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay16_q_net_x1: std_logic_vector(35 downto 0);
  signal delay17_q_net_x0: std_logic_vector(35 downto 0);
  signal delay9_q_net_x0: std_logic;
  signal delay_q_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic;
  signal mux_y_net_x2: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x3: std_logic_vector(35 downto 0);
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x1: std_logic;

begin
  ce_1_sg_x16 <= ce_1;
  clk_1_sg_x16 <= clk_1;
  delay17_q_net_x0 <= in1;
  delay16_q_net_x1 <= in2;
  constant1_op_net_x0 <= shift;
  delay9_q_net_x0 <= sync;
  out1 <= concat_y_net_x4;
  out2 <= concat_y_net_x5;
  sync_out <= sync_delay_q_net_x1;

  butterfly_direct_3cab01cdac: entity work.butterfly_direct_entity_3cab01cdac
    port map (
      a => single_port_ram_data_out_net_x3,
      b => mux_y_net_x2,
      ce_1 => ce_1_sg_x16,
      clk_1 => clk_1_sg_x16,
      shift => slice_y_net_x0,
      sync => mux_y_net_x1,
      a_bw => concat_y_net_x4,
      a_bw_x0 => concat_y_net_x5,
      sync_out => sync_delay_q_net_x1
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x16,
      clk => clk_1_sg_x16,
      clr => '0',
      en => "1",
      rst(0) => delay9_q_net_x0,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x16,
      clk => clk_1_sg_x16,
      d(0) => delay9_q_net_x0,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_ff5e0572da: entity work.delay_b_entity_ff5e0572da
    port map (
      ce_1 => ce_1_sg_x16,
      clk_1 => clk_1_sg_x16,
      in1 => mux1_y_net_x0,
      out1 => single_port_ram_data_out_net_x3
    );

  delay_f_c9be62df52: entity work.delay_b_entity_ff5e0572da
    port map (
      ce_1 => ce_1_sg_x16,
      clk_1 => clk_1_sg_x16,
      in1 => delay16_q_net_x1,
      out1 => single_port_ram_data_out_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x16,
      clk => clk_1_sg_x16,
      clr => '0',
      d0 => single_port_ram_data_out_net_x0,
      d1 => delay17_q_net_x0,
      sel(0) => slice1_y_net,
      y => mux_y_net_x2
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x16,
      clk => clk_1_sg_x16,
      clr => '0',
      d0 => delay17_q_net_x0,
      d1 => single_port_ram_data_out_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x0,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 7,
      new_msb => 7,
      x_width => 8,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_e3d123a84a: entity work.sync_delay_entity_e3d123a84a
    port map (
      ce_1 => ce_1_sg_x16,
      clk_1 => clk_1_sg_x16,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_2/butterfly_direct/twiddle_stage_2"

entity twiddle_stage_2_entity_30e453baa4 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(17 downto 0); 
    bw_re: out std_logic_vector(17 downto 0); 
    sync_out: out std_logic
  );
end twiddle_stage_2_entity_30e453baa4;

architecture structural of twiddle_stage_2_entity_30e453baa4 is
  signal ce_1_sg_x23: std_logic;
  signal clk_1_sg_x23: std_logic;
  signal convert_dout_net: std_logic_vector(17 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal delay0_q_net_x2: std_logic_vector(17 downto 0);
  signal delay1_q_net_x2: std_logic_vector(17 downto 0);
  signal delay2_q_net: std_logic;
  signal delay3_q_net: std_logic_vector(17 downto 0);
  signal delay4_q_net: std_logic_vector(17 downto 0);
  signal delay5_q_net: std_logic_vector(17 downto 0);
  signal delay6_q_net: std_logic_vector(17 downto 0);
  signal delay7_q_net: std_logic;
  signal delay8_q_net_x0: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal mux0_y_net_x2: std_logic_vector(17 downto 0);
  signal mux1_y_net_x2: std_logic_vector(17 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;
  signal negate_op_net: std_logic_vector(18 downto 0);
  signal single_port_ram_data_out_net_x1: std_logic_vector(35 downto 0);
  signal slice_y_net: std_logic;

begin
  single_port_ram_data_out_net_x1 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x23 <= ce_1;
  clk_1_sg_x23 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= delay1_q_net_x2;
  a_re <= delay0_q_net_x2;
  bw_im <= mux1_y_net_x2;
  bw_re <= mux0_y_net_x2;
  sync_out <= delay8_q_net_x0;

  c_to_ri1_891d467123: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => mux_y_net_x1,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  c_to_ri_a31fd4c6a4: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => single_port_ram_data_out_net_x1,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  convert: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 19,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 2,
      overflow => xlSaturate,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      din => negate_op_net,
      dout => convert_dout_net
    );

  counter: entity work.counter_aaa565147f
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      rst(0) => delay7_q_net,
      op => counter_op_net
    );

  delay0: entity work.delay_47d75ae775
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d => force_re_output_port_net_x0,
      q => delay0_q_net_x2
    );

  delay1: entity work.delay_47d75ae775
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d => force_im_output_port_net_x0,
      q => delay1_q_net_x2
    );

  delay2: entity work.delay_43bd805056
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d(0) => slice_y_net,
      q(0) => delay2_q_net
    );

  delay3: entity work.delay_c462a80bee
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d => delay6_q_net,
      q => delay3_q_net
    );

  delay4: entity work.delay_c462a80bee
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d => convert_dout_net,
      q => delay4_q_net
    );

  delay5: entity work.delay_328e8ebbb5
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d => force_re_output_port_net_x1,
      q => delay5_q_net
    );

  delay6: entity work.delay_328e8ebbb5
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d => force_im_output_port_net_x1,
      q => delay6_q_net
    );

  delay7: entity work.delay_23d71a76f2
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d(0) => mux_y_net_x2,
      q(0) => delay7_q_net
    );

  delay8: entity work.delay_aab7b18c27
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d(0) => delay7_q_net,
      q(0) => delay8_q_net_x0
    );

  mux0: entity work.mux_621a1c5abf
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d0 => delay5_q_net,
      d1 => delay6_q_net,
      sel(0) => slice_y_net,
      y => mux0_y_net_x2
    );

  mux1: entity work.mux_181e58d842
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      d0 => delay3_q_net,
      d1 => delay4_q_net,
      sel(0) => delay2_q_net,
      y => mux1_y_net_x2
    );

  negate: entity work.negate_e1a9d1ade1
    port map (
      ce => ce_1_sg_x23,
      clk => clk_1_sg_x23,
      clr => '0',
      ip => force_re_output_port_net_x1,
      op => negate_op_net
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 6,
      new_msb => 6,
      x_width => 7,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_2/butterfly_direct"

entity butterfly_direct_entity_6265bd49fe is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_6265bd49fe;

architecture structural of butterfly_direct_entity_6265bd49fe is
  signal cast_c_im_dout_net_x0: std_logic_vector(18 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(18 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(18 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(18 downto 0);
  signal ce_1_sg_x24: std_logic;
  signal clk_1_sg_x24: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay0_q_net_x2: std_logic_vector(17 downto 0);
  signal delay1_q_net_x2: std_logic_vector(17 downto 0);
  signal delay8_q_net_x0: std_logic;
  signal mux0_y_net_x0: std_logic_vector(19 downto 0);
  signal mux0_y_net_x2: std_logic_vector(17 downto 0);
  signal mux1_y_net_x0: std_logic_vector(19 downto 0);
  signal mux1_y_net_x2: std_logic_vector(17 downto 0);
  signal mux2_y_net_x0: std_logic_vector(19 downto 0);
  signal mux3_y_net_x0: std_logic_vector(19 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(18 downto 0);
  signal scale1_op_net: std_logic_vector(18 downto 0);
  signal scale2_op_net: std_logic_vector(18 downto 0);
  signal scale3_op_net: std_logic_vector(18 downto 0);
  signal shift_delay_q_net: std_logic;
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  single_port_ram_data_out_net_x2 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x24 <= ce_1;
  clk_1_sg_x24 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_0e144f09c8: entity work.cadd_entity_fe10c9a76f
    port map (
      a_im => delay1_q_net_x2,
      a_re => delay0_q_net_x2,
      b_im => mux1_y_net_x2,
      b_re => mux0_y_net_x2,
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_d9f976cd34: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_c9e3871a4a: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_1711b2e2f7: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_aa2e48bf52: entity work.convert_of0_entity_61a33b5e8a
    port map (
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_36b01010b9: entity work.csub_entity_dab52e1868
    port map (
      a_im => delay1_q_net_x2,
      a_re => delay0_q_net_x2,
      b_im => mux1_y_net_x2,
      b_re => mux0_y_net_x2,
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x24,
      clk => clk_1_sg_x24,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x24,
      clk => clk_1_sg_x24,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x24,
      clk => clk_1_sg_x24,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_610aab71b1
    port map (
      ce => ce_1_sg_x24,
      clk => clk_1_sg_x24,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_931b79d4d5: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_ff9390c273: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_9f61027ba4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x24,
      clk => clk_1_sg_x24,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x24,
      clk => clk_1_sg_x24,
      clr => '0',
      d(0) => delay8_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_stage_2_30e453baa4: entity work.twiddle_stage_2_entity_30e453baa4
    port map (
      a => single_port_ram_data_out_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x24,
      clk_1 => clk_1_sg_x24,
      sync => mux_y_net_x4,
      a_im => delay1_q_net_x2,
      a_re => delay0_q_net_x2,
      bw_im => mux1_y_net_x2,
      bw_re => mux0_y_net_x2,
      sync_out => delay8_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_2/delay_b"

entity delay_b_entity_dc4c0df527 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_dc4c0df527;

architecture structural of delay_b_entity_dc4c0df527 is
  signal ce_1_sg_x25: std_logic;
  signal clk_1_sg_x25: std_logic;
  signal constant2_op_net: std_logic;
  signal counter_op_net: std_logic_vector(5 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x3: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x25 <= ce_1;
  clk_1_sg_x25 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= single_port_ram_data_out_net_x3;

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 60,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_7d2d2ebbf32c6bf7",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 6
    )
    port map (
      ce => ce_1_sg_x25,
      clk => clk_1_sg_x25,
      clr => '0',
      en => "1",
      rst => "0",
      op => counter_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 6,
      c_width => 36,
      core_name0 => "bmg_33_7f9bb833f81c2e5a",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x25,
      clk => clk_1_sg_x25,
      data_in => mux1_y_net_x0,
      en => "1",
      rst => "0",
      we(0) => constant2_op_net,
      data_out => single_port_ram_data_out_net_x3
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_2/sync_delay"

entity sync_delay_entity_bdd78100e2 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_bdd78100e2;

architecture structural of sync_delay_entity_bdd78100e2 is
  signal ce_1_sg_x27: std_logic;
  signal clk_1_sg_x27: std_logic;
  signal constant1_op_net: std_logic_vector(6 downto 0);
  signal constant2_op_net: std_logic_vector(6 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(6 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x27 <= ce_1;
  clk_1_sg_x27 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_7244cd602b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_7b07120b87
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_180df391de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_f693a2757b61b862",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x27,
      clk => clk_1_sg_x27,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_9a3978c602
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_23065a6aa3
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_2"

entity fft_stage_2_entity_2a93e1c051 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_2_entity_2a93e1c051;

architecture structural of fft_stage_2_entity_2a93e1c051 is
  signal ce_1_sg_x28: std_logic;
  signal clk_1_sg_x28: std_logic;
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal concat_y_net_x7: std_logic_vector(35 downto 0);
  signal concat_y_net_x8: std_logic_vector(35 downto 0);
  signal concat_y_net_x9: std_logic_vector(35 downto 0);
  signal constant1_op_net_x1: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal delay_q_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x3: std_logic_vector(35 downto 0);
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x2: std_logic;
  signal sync_delay_q_net_x3: std_logic;

begin
  ce_1_sg_x28 <= ce_1;
  clk_1_sg_x28 <= clk_1;
  concat_y_net_x5 <= in1;
  concat_y_net_x7 <= in2;
  constant1_op_net_x1 <= shift;
  sync_delay_q_net_x2 <= sync;
  out1 <= concat_y_net_x8;
  out2 <= concat_y_net_x9;
  sync_out <= sync_delay_q_net_x3;

  butterfly_direct_6265bd49fe: entity work.butterfly_direct_entity_6265bd49fe
    port map (
      a => single_port_ram_data_out_net_x3,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x28,
      clk_1 => clk_1_sg_x28,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x8,
      a_bw_x0 => concat_y_net_x9,
      sync_out => sync_delay_q_net_x3
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x28,
      clk => clk_1_sg_x28,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x2,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x28,
      clk => clk_1_sg_x28,
      d(0) => sync_delay_q_net_x2,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_dc4c0df527: entity work.delay_b_entity_dc4c0df527
    port map (
      ce_1 => ce_1_sg_x28,
      clk_1 => clk_1_sg_x28,
      in1 => mux1_y_net_x0,
      out1 => single_port_ram_data_out_net_x3
    );

  delay_f_308fb32c18: entity work.delay_b_entity_dc4c0df527
    port map (
      ce_1 => ce_1_sg_x28,
      clk_1 => clk_1_sg_x28,
      in1 => concat_y_net_x7,
      out1 => single_port_ram_data_out_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x28,
      clk => clk_1_sg_x28,
      clr => '0',
      d0 => single_port_ram_data_out_net_x0,
      d1 => concat_y_net_x5,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x28,
      clk => clk_1_sg_x28,
      clr => '0',
      d0 => concat_y_net_x5,
      d1 => single_port_ram_data_out_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 1,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x1,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 6,
      new_msb => 6,
      x_width => 7,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_bdd78100e2: entity work.sync_delay_entity_bdd78100e2
    port map (
      ce_1 => ce_1_sg_x28,
      clk_1 => clk_1_sg_x28,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/cadd"

entity cadd_entity_c49d0d70b5 is
  port (
    a_im: in std_logic_vector(17 downto 0); 
    a_re: in std_logic_vector(17 downto 0); 
    b_im: in std_logic_vector(21 downto 0); 
    b_re: in std_logic_vector(21 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    c_im: out std_logic_vector(22 downto 0); 
    c_re: out std_logic_vector(22 downto 0)
  );
end cadd_entity_c49d0d70b5;

architecture structural of cadd_entity_c49d0d70b5 is
  signal alumode_op_net: std_logic_vector(3 downto 0);
  signal carryin_op_net: std_logic;
  signal carryinsel_op_net: std_logic_vector(2 downto 0);
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal ce_1_sg_x29: std_logic;
  signal clk_1_sg_x29: std_logic;
  signal concat_a_y_net: std_logic_vector(47 downto 0);
  signal concat_b_y_net: std_logic_vector(47 downto 0);
  signal convert0_dout_net_x0: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x0: std_logic_vector(21 downto 0);
  signal dsp48e_p_net: std_logic_vector(47 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal opmode_op_net: std_logic_vector(6 downto 0);
  signal realign_a_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_a_re_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_re_dout_net: std_logic_vector(23 downto 0);
  signal reinterp_a_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_a_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterpret_a_output_port_net: std_logic_vector(29 downto 0);
  signal reinterpret_b_output_port_net: std_logic_vector(17 downto 0);
  signal reinterpret_c_output_port_net: std_logic_vector(47 downto 0);
  signal slice_a_y_net: std_logic_vector(29 downto 0);
  signal slice_b_y_net: std_logic_vector(17 downto 0);
  signal slice_c_im_y_net: std_logic_vector(23 downto 0);
  signal slice_c_re_y_net: std_logic_vector(23 downto 0);

begin
  force_im_output_port_net_x0 <= a_im;
  force_re_output_port_net_x0 <= a_re;
  convert1_dout_net_x0 <= b_im;
  convert0_dout_net_x0 <= b_re;
  ce_1_sg_x29 <= ce_1;
  clk_1_sg_x29 <= clk_1;
  c_im <= cast_c_im_dout_net_x0;
  c_re <= cast_c_re_dout_net_x0;

  alumode: entity work.constant_4c449dd556
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => alumode_op_net
    );

  carryin: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => carryin_op_net
    );

  carryinsel: entity work.constant_822933f89b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => carryinsel_op_net
    );

  cast_c_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 23,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_im_output_port_net,
      dout => cast_c_im_dout_net_x0
    );

  cast_c_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 23,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_re_output_port_net,
      dout => cast_c_re_dout_net_x0
    );

  concat_a: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_a_re_output_port_net,
      in1 => reinterp_a_im_output_port_net,
      y => concat_a_y_net
    );

  concat_b: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_b_re_output_port_net,
      in1 => reinterp_b_im_output_port_net,
      y => concat_b_y_net
    );

  dsp48e: entity work.xldsp48e
    generic map (
      a_input => "DIRECT",
      acascreg => 1,
      alumodereg => 1,
      areg => 1,
      autoreset_pattern_detect => FALSE,
      autoreset_pattern_detect_optinv => "MATCH",
      b_input => "DIRECT",
      bcascreg => 1,
      breg => 1,
      carryinreg => 1,
      carryinselreg => 1,
      carryout_width => 4,
      creg => 1,
      mreg => 1,
      opmodereg => 1,
      preg => 1,
      sel_mask => "MASK",
      sel_pattern => "PATTERN",
      use_c_port => 1,
      use_mult => "MULT_S",
      use_op => 0,
      use_pattern_detect => "NO_PATDET",
      use_simd => "TWO24"
    )
    port map (
      a => reinterpret_a_output_port_net,
      alumode => alumode_op_net,
      b => reinterpret_b_output_port_net,
      c => reinterpret_c_output_port_net,
      carryin(0) => carryin_op_net,
      carryinsel => carryinsel_op_net,
      ce => ce_1_sg_x29,
      cea1 => "1",
      cea2 => "1",
      cealumode => "1",
      ceb1 => "1",
      ceb2 => "1",
      cec => "1",
      cecarryin => "1",
      cectrl => "1",
      cem => "1",
      cemultcarryin => "1",
      cep => "1",
      clk => clk_1_sg_x29,
      en => "1",
      opmode => opmode_op_net,
      rst => "0",
      rsta => "0",
      rstalumode => "0",
      rstb => "0",
      rstc => "0",
      rstcarryin => "0",
      rstctrl => "0",
      rstm => "0",
      rstp => "0",
      p => dsp48e_p_net
    );

  opmode: entity work.constant_270746ab47
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => opmode_op_net
    );

  realign_a_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x0,
      dout => realign_a_im_dout_net
    );

  realign_a_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x0,
      dout => realign_a_re_dout_net
    );

  realign_b_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 22,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => convert1_dout_net_x0,
      dout => realign_b_im_dout_net
    );

  realign_b_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 22,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => convert0_dout_net_x0,
      dout => realign_b_re_dout_net
    );

  reinterp_a_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_im_dout_net,
      output_port => reinterp_a_im_output_port_net
    );

  reinterp_a_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_re_dout_net,
      output_port => reinterp_a_re_output_port_net
    );

  reinterp_b_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_im_dout_net,
      output_port => reinterp_b_im_output_port_net
    );

  reinterp_b_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_re_dout_net,
      output_port => reinterp_b_re_output_port_net
    );

  reinterp_c_im: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_im_y_net,
      output_port => reinterp_c_im_output_port_net
    );

  reinterp_c_re: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_re_y_net,
      output_port => reinterp_c_re_output_port_net
    );

  reinterpret_a: entity work.reinterpret_eb03bc3377
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_a_y_net,
      output_port => reinterpret_a_output_port_net
    );

  reinterpret_b: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_b_y_net,
      output_port => reinterpret_b_output_port_net
    );

  reinterpret_c: entity work.reinterpret_7ea107432a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => concat_a_y_net,
      output_port => reinterpret_c_output_port_net
    );

  slice_a: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 47,
      x_width => 48,
      y_width => 30
    )
    port map (
      x => concat_b_y_net,
      y => slice_a_y_net
    );

  slice_b: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 17,
      x_width => 48,
      y_width => 18
    )
    port map (
      x => concat_b_y_net,
      y => slice_b_y_net
    );

  slice_c_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_im_y_net
    );

  slice_c_re: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 47,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/convert_of0"

entity convert_of0_entity_c5a79c8e94 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(23 downto 0); 
    dout: out std_logic_vector(17 downto 0)
  );
end convert_of0_entity_c5a79c8e94;

architecture structural of convert_of0_entity_c5a79c8e94 is
  signal ce_1_sg_x30: std_logic;
  signal clk_1_sg_x30: std_logic;
  signal convert_dout_net_x0: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);

begin
  ce_1_sg_x30 <= ce_1;
  clk_1_sg_x30 <= clk_1;
  mux0_y_net_x0 <= din;
  dout <= convert_dout_net_x0;

  convert: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 20,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x30,
      clk => clk_1_sg_x30,
      clr => '0',
      din => mux0_y_net_x0,
      dout => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/csub"

entity csub_entity_31e94c9537 is
  port (
    a_im: in std_logic_vector(17 downto 0); 
    a_re: in std_logic_vector(17 downto 0); 
    b_im: in std_logic_vector(21 downto 0); 
    b_re: in std_logic_vector(21 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    c_im: out std_logic_vector(22 downto 0); 
    c_re: out std_logic_vector(22 downto 0)
  );
end csub_entity_31e94c9537;

architecture structural of csub_entity_31e94c9537 is
  signal alumode_op_net: std_logic_vector(3 downto 0);
  signal carryin_op_net: std_logic;
  signal carryinsel_op_net: std_logic_vector(2 downto 0);
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal ce_1_sg_x34: std_logic;
  signal clk_1_sg_x34: std_logic;
  signal concat_a_y_net: std_logic_vector(47 downto 0);
  signal concat_b_y_net: std_logic_vector(47 downto 0);
  signal convert0_dout_net_x1: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x1: std_logic_vector(21 downto 0);
  signal dsp48e_p_net: std_logic_vector(47 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal opmode_op_net: std_logic_vector(6 downto 0);
  signal realign_a_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_a_re_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_im_dout_net: std_logic_vector(23 downto 0);
  signal realign_b_re_dout_net: std_logic_vector(23 downto 0);
  signal reinterp_a_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_a_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_b_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_im_output_port_net: std_logic_vector(23 downto 0);
  signal reinterp_c_re_output_port_net: std_logic_vector(23 downto 0);
  signal reinterpret_a_output_port_net: std_logic_vector(29 downto 0);
  signal reinterpret_b_output_port_net: std_logic_vector(17 downto 0);
  signal reinterpret_c_output_port_net: std_logic_vector(47 downto 0);
  signal slice_a_y_net: std_logic_vector(29 downto 0);
  signal slice_b_y_net: std_logic_vector(17 downto 0);
  signal slice_c_im_y_net: std_logic_vector(23 downto 0);
  signal slice_c_re_y_net: std_logic_vector(23 downto 0);

begin
  force_im_output_port_net_x1 <= a_im;
  force_re_output_port_net_x1 <= a_re;
  convert1_dout_net_x1 <= b_im;
  convert0_dout_net_x1 <= b_re;
  ce_1_sg_x34 <= ce_1;
  clk_1_sg_x34 <= clk_1;
  c_im <= cast_c_im_dout_net_x0;
  c_re <= cast_c_re_dout_net_x0;

  alumode: entity work.constant_8038205d89
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => alumode_op_net
    );

  carryin: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => carryin_op_net
    );

  carryinsel: entity work.constant_822933f89b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => carryinsel_op_net
    );

  cast_c_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 23,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_im_output_port_net,
      dout => cast_c_im_dout_net_x0
    );

  cast_c_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 24,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 23,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterp_c_re_output_port_net,
      dout => cast_c_re_dout_net_x0
    );

  concat_a: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_a_re_output_port_net,
      in1 => reinterp_a_im_output_port_net,
      y => concat_a_y_net
    );

  concat_b: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterp_b_re_output_port_net,
      in1 => reinterp_b_im_output_port_net,
      y => concat_b_y_net
    );

  dsp48e: entity work.xldsp48e
    generic map (
      a_input => "DIRECT",
      acascreg => 1,
      alumodereg => 1,
      areg => 1,
      autoreset_pattern_detect => FALSE,
      autoreset_pattern_detect_optinv => "MATCH",
      b_input => "DIRECT",
      bcascreg => 1,
      breg => 1,
      carryinreg => 1,
      carryinselreg => 1,
      carryout_width => 4,
      creg => 1,
      mreg => 1,
      opmodereg => 1,
      preg => 1,
      sel_mask => "MASK",
      sel_pattern => "PATTERN",
      use_c_port => 1,
      use_mult => "MULT_S",
      use_op => 0,
      use_pattern_detect => "NO_PATDET",
      use_simd => "TWO24"
    )
    port map (
      a => reinterpret_a_output_port_net,
      alumode => alumode_op_net,
      b => reinterpret_b_output_port_net,
      c => reinterpret_c_output_port_net,
      carryin(0) => carryin_op_net,
      carryinsel => carryinsel_op_net,
      ce => ce_1_sg_x34,
      cea1 => "1",
      cea2 => "1",
      cealumode => "1",
      ceb1 => "1",
      ceb2 => "1",
      cec => "1",
      cecarryin => "1",
      cectrl => "1",
      cem => "1",
      cemultcarryin => "1",
      cep => "1",
      clk => clk_1_sg_x34,
      en => "1",
      opmode => opmode_op_net,
      rst => "0",
      rsta => "0",
      rstalumode => "0",
      rstb => "0",
      rstc => "0",
      rstcarryin => "0",
      rstctrl => "0",
      rstm => "0",
      rstp => "0",
      p => dsp48e_p_net
    );

  opmode: entity work.constant_270746ab47
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => opmode_op_net
    );

  realign_a_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x1,
      dout => realign_a_im_dout_net
    );

  realign_a_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 17,
      din_width => 18,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x1,
      dout => realign_a_re_dout_net
    );

  realign_b_im: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 22,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => convert1_dout_net_x1,
      dout => realign_b_im_dout_net
    );

  realign_b_re: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 19,
      din_width => 22,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 24,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => convert0_dout_net_x1,
      dout => realign_b_re_dout_net
    );

  reinterp_a_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_im_dout_net,
      output_port => reinterp_a_im_output_port_net
    );

  reinterp_a_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_a_re_dout_net,
      output_port => reinterp_a_re_output_port_net
    );

  reinterp_b_im: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_im_dout_net,
      output_port => reinterp_b_im_output_port_net
    );

  reinterp_b_re: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => realign_b_re_dout_net,
      output_port => reinterp_b_re_output_port_net
    );

  reinterp_c_im: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_im_y_net,
      output_port => reinterp_c_im_output_port_net
    );

  reinterp_c_re: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_c_re_y_net,
      output_port => reinterp_c_re_output_port_net
    );

  reinterpret_a: entity work.reinterpret_eb03bc3377
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_a_y_net,
      output_port => reinterpret_a_output_port_net
    );

  reinterpret_b: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_b_y_net,
      output_port => reinterpret_b_output_port_net
    );

  reinterpret_c: entity work.reinterpret_7ea107432a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => concat_a_y_net,
      output_port => reinterpret_c_output_port_net
    );

  slice_a: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 47,
      x_width => 48,
      y_width => 30
    )
    port map (
      x => concat_b_y_net,
      y => slice_a_y_net
    );

  slice_b: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 17,
      x_width => 48,
      y_width => 18
    )
    port map (
      x => concat_b_y_net,
      y => slice_b_y_net
    );

  slice_c_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_im_y_net
    );

  slice_c_re: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 47,
      x_width => 48,
      y_width => 24
    )
    port map (
      x => dsp48e_p_net,
      y => slice_c_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/twiddle_general_4mult/c_to_ri2"

entity c_to_ri2_entity_2085ece8b6 is
  port (
    c: in std_logic_vector(35 downto 0); 
    im: out std_logic_vector(17 downto 0); 
    re: out std_logic_vector(17 downto 0)
  );
end c_to_ri2_entity_2085ece8b6;

architecture structural of c_to_ri2_entity_2085ece8b6 is
  signal concat_y_net_x0: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal slice_im_y_net: std_logic_vector(17 downto 0);
  signal slice_re_y_net: std_logic_vector(17 downto 0);

begin
  concat_y_net_x0 <= c;
  im <= force_im_output_port_net_x0;
  re <= force_re_output_port_net_x0;

  force_im: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_im_y_net,
      output_port => force_im_output_port_net_x0
    );

  force_re: entity work.reinterpret_9a0fa0f632
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_re_y_net,
      output_port => force_re_output_port_net_x0
    );

  slice_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 17,
      x_width => 36,
      y_width => 18
    )
    port map (
      x => concat_y_net_x0,
      y => slice_im_y_net
    );

  slice_re: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 35,
      x_width => 36,
      y_width => 18
    )
    port map (
      x => concat_y_net_x0,
      y => slice_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/twiddle_general_4mult/coeff_gen/ri_to_c"

entity ri_to_c_entity_20104ade43 is
  port (
    im: in std_logic_vector(17 downto 0); 
    re: in std_logic_vector(17 downto 0); 
    c: out std_logic_vector(35 downto 0)
  );
end ri_to_c_entity_20104ade43;

architecture structural of ri_to_c_entity_20104ade43 is
  signal concat_y_net_x1: std_logic_vector(35 downto 0);
  signal force_im_output_port_net: std_logic_vector(17 downto 0);
  signal force_re_output_port_net: std_logic_vector(17 downto 0);
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);

begin
  rom1_data_net_x0 <= im;
  rom_data_net_x0 <= re;
  c <= concat_y_net_x1;

  concat: entity work.concat_b198bd62b0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => force_re_output_port_net,
      in1 => force_im_output_port_net,
      y => concat_y_net_x1
    );

  force_im: entity work.reinterpret_580feec131
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom1_data_net_x0,
      output_port => force_im_output_port_net
    );

  force_re: entity work.reinterpret_580feec131
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom_data_net_x0,
      output_port => force_re_output_port_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_d22f239a72 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_d22f239a72;

architecture structural of coeff_gen_entity_d22f239a72 is
  signal ce_1_sg_x35: std_logic;
  signal clk_1_sg_x35: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux_y_net_x0: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(1 downto 0);

begin
  ce_1_sg_x35 <= ce_1;
  clk_1_sg_x35 <= clk_1;
  mux_y_net_x0 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x35,
      clk => clk_1_sg_x35,
      clr => '0',
      en => "1",
      rst(0) => mux_y_net_x0,
      op => counter_op_net
    );

  ri_to_c_20104ade43: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom_dist
    generic map (
      addr_width => 2,
      c_address_width => 4,
      c_width => 18,
      core_name0 => "dmg_43_f7074f739a815d7c",
      latency => 3
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x35,
      clk => clk_1_sg_x35,
      en => "1",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom_dist
    generic map (
      addr_width => 2,
      c_address_width => 4,
      c_width => 18,
      core_name0 => "dmg_43_3127414ad7a714f4",
      latency => 3
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x35,
      clk => clk_1_sg_x35,
      en => "1",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 5,
      new_msb => 6,
      x_width => 7,
      y_width => 2
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct/twiddle_general_4mult"

entity twiddle_general_4mult_entity_3e33d31208 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_3e33d31208;

architecture structural of twiddle_general_4mult_entity_3e33d31208 is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x36: std_logic;
  signal clk_1_sg_x36: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);

begin
  single_port_ram_data_out_net_x0 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x36 <= ce_1;
  clk_1_sg_x36 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_f51c7d582b: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_2085ece8b6: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_93c9474798: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_d22f239a72: entity work.coeff_gen_entity_d22f239a72
    port map (
      ce_1 => ce_1_sg_x36,
      clk_1 => clk_1_sg_x36,
      rst => mux_y_net_x2,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      d => single_port_ram_data_out_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      d => mux_y_net_x1,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      d(0) => mux_y_net_x2,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x36,
      clk => clk_1_sg_x36,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/butterfly_direct"

entity butterfly_direct_entity_4fb4b3443f is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_4fb4b3443f;

architecture structural of butterfly_direct_entity_4fb4b3443f is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x37: std_logic;
  signal clk_1_sg_x37: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal single_port_ram_data_out_net_x1: std_logic_vector(35 downto 0);
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  single_port_ram_data_out_net_x1 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x37 <= ce_1;
  clk_1_sg_x37 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_c49d0d70b5: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_c5a79c8e94: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_fd3655c033: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_8d45b07242: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_d2d97f77e0: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_31e94c9537: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x37,
      clk => clk_1_sg_x37,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x37,
      clk => clk_1_sg_x37,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x37,
      clk => clk_1_sg_x37,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x37,
      clk => clk_1_sg_x37,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_9a4951877e: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_6b18a9b88e: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x37,
      clk => clk_1_sg_x37,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x37,
      clk => clk_1_sg_x37,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_3e33d31208: entity work.twiddle_general_4mult_entity_3e33d31208
    port map (
      a => single_port_ram_data_out_net_x1,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x37,
      clk_1 => clk_1_sg_x37,
      sync => mux_y_net_x4,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/delay_b"

entity delay_b_entity_66a6ba7354 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_66a6ba7354;

architecture structural of delay_b_entity_66a6ba7354 is
  signal ce_1_sg_x38: std_logic;
  signal clk_1_sg_x38: std_logic;
  signal constant2_op_net: std_logic;
  signal counter_op_net: std_logic_vector(4 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x38 <= ce_1;
  clk_1_sg_x38 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= single_port_ram_data_out_net_x2;

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 28,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_2ac7fb319983676e",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 5
    )
    port map (
      ce => ce_1_sg_x38,
      clk => clk_1_sg_x38,
      clr => '0',
      en => "1",
      rst => "0",
      op => counter_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 5,
      c_width => 36,
      core_name0 => "bmg_33_31944f959b70ca96",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x38,
      clk => clk_1_sg_x38,
      data_in => mux1_y_net_x0,
      en => "1",
      rst => "0",
      we(0) => constant2_op_net,
      data_out => single_port_ram_data_out_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3/sync_delay"

entity sync_delay_entity_47135bf212 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_47135bf212;

architecture structural of sync_delay_entity_47135bf212 is
  signal ce_1_sg_x40: std_logic;
  signal clk_1_sg_x40: std_logic;
  signal constant1_op_net: std_logic_vector(5 downto 0);
  signal constant2_op_net: std_logic_vector(5 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(5 downto 0);
  signal counter_op_net: std_logic_vector(5 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x40 <= ce_1;
  clk_1_sg_x40 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_7ea0f2fff7
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_961b61f8a1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_a267c870be
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_19e9aa05886dcbfe",
      op_arith => xlUnsigned,
      op_width => 6
    )
    port map (
      ce => ce_1_sg_x40,
      clk => clk_1_sg_x40,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_931d61fb72
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_fe487ce1c7
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_3"

entity fft_stage_3_entity_d34e21166d is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_3_entity_d34e21166d;

architecture structural of fft_stage_3_entity_d34e21166d is
  signal ce_1_sg_x41: std_logic;
  signal clk_1_sg_x41: std_logic;
  signal concat_y_net_x11: std_logic_vector(35 downto 0);
  signal concat_y_net_x12: std_logic_vector(35 downto 0);
  signal concat_y_net_x13: std_logic_vector(35 downto 0);
  signal concat_y_net_x9: std_logic_vector(35 downto 0);
  signal constant1_op_net_x2: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(5 downto 0);
  signal delay_q_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x4: std_logic;
  signal sync_delay_q_net_x5: std_logic;

begin
  ce_1_sg_x41 <= ce_1;
  clk_1_sg_x41 <= clk_1;
  concat_y_net_x9 <= in1;
  concat_y_net_x11 <= in2;
  constant1_op_net_x2 <= shift;
  sync_delay_q_net_x4 <= sync;
  out1 <= concat_y_net_x12;
  out2 <= concat_y_net_x13;
  sync_out <= sync_delay_q_net_x5;

  butterfly_direct_4fb4b3443f: entity work.butterfly_direct_entity_4fb4b3443f
    port map (
      a => single_port_ram_data_out_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x41,
      clk_1 => clk_1_sg_x41,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x12,
      a_bw_x0 => concat_y_net_x13,
      sync_out => sync_delay_q_net_x5
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_7d2d2ebbf32c6bf7",
      op_arith => xlUnsigned,
      op_width => 6
    )
    port map (
      ce => ce_1_sg_x41,
      clk => clk_1_sg_x41,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x4,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x41,
      clk => clk_1_sg_x41,
      d(0) => sync_delay_q_net_x4,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_66a6ba7354: entity work.delay_b_entity_66a6ba7354
    port map (
      ce_1 => ce_1_sg_x41,
      clk_1 => clk_1_sg_x41,
      in1 => mux1_y_net_x0,
      out1 => single_port_ram_data_out_net_x2
    );

  delay_f_4b63a975c7: entity work.delay_b_entity_66a6ba7354
    port map (
      ce_1 => ce_1_sg_x41,
      clk_1 => clk_1_sg_x41,
      in1 => concat_y_net_x11,
      out1 => single_port_ram_data_out_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x41,
      clk => clk_1_sg_x41,
      clr => '0',
      d0 => single_port_ram_data_out_net_x0,
      d1 => concat_y_net_x9,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x41,
      clk => clk_1_sg_x41,
      clr => '0',
      d0 => concat_y_net_x9,
      d1 => single_port_ram_data_out_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 2,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x2,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 5,
      new_msb => 5,
      x_width => 6,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_47135bf212: entity work.sync_delay_entity_47135bf212
    port map (
      ce_1 => ce_1_sg_x41,
      clk_1 => clk_1_sg_x41,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_4/butterfly_direct/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_634c98da15 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_634c98da15;

architecture structural of coeff_gen_entity_634c98da15 is
  signal ce_1_sg_x48: std_logic;
  signal clk_1_sg_x48: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux_y_net_x0: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(2 downto 0);

begin
  ce_1_sg_x48 <= ce_1;
  clk_1_sg_x48 <= clk_1;
  mux_y_net_x0 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x48,
      clk => clk_1_sg_x48,
      clr => '0',
      en => "1",
      rst(0) => mux_y_net_x0,
      op => counter_op_net
    );

  ri_to_c_aec5d81b21: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom
    generic map (
      c_address_width => 3,
      c_width => 18,
      core_name0 => "bmg_33_1e208a1bd987979c",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x48,
      clk => clk_1_sg_x48,
      en => "1",
      rst => "0",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 3,
      c_width => 18,
      core_name0 => "bmg_33_5e5c5cdbadc20d89",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x48,
      clk => clk_1_sg_x48,
      en => "1",
      rst => "0",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 4,
      new_msb => 6,
      x_width => 7,
      y_width => 3
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_4/butterfly_direct/twiddle_general_4mult"

entity twiddle_general_4mult_entity_f773af9e63 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_f773af9e63;

architecture structural of twiddle_general_4mult_entity_f773af9e63 is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x49: std_logic;
  signal clk_1_sg_x49: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);

begin
  single_port_ram_data_out_net_x0 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x49 <= ce_1;
  clk_1_sg_x49 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_9e83d41a93: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_1c5571378c: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_95798fd723: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_634c98da15: entity work.coeff_gen_entity_634c98da15
    port map (
      ce_1 => ce_1_sg_x49,
      clk_1 => clk_1_sg_x49,
      rst => mux_y_net_x2,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      d => single_port_ram_data_out_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      d => mux_y_net_x1,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      d(0) => mux_y_net_x2,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x49,
      clk => clk_1_sg_x49,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_4/butterfly_direct"

entity butterfly_direct_entity_2942e6d9ae is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_2942e6d9ae;

architecture structural of butterfly_direct_entity_2942e6d9ae is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x50: std_logic;
  signal clk_1_sg_x50: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal single_port_ram_data_out_net_x1: std_logic_vector(35 downto 0);
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  single_port_ram_data_out_net_x1 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x50 <= ce_1;
  clk_1_sg_x50 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_09f1264cf5: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_571bde14b5: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_682a12538d: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_5165a1125b: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_bef9701528: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_3b2051b356: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x50,
      clk => clk_1_sg_x50,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x50,
      clk => clk_1_sg_x50,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x50,
      clk => clk_1_sg_x50,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x50,
      clk => clk_1_sg_x50,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_a5167d1999: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_c9e88337e3: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x50,
      clk => clk_1_sg_x50,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x50,
      clk => clk_1_sg_x50,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_f773af9e63: entity work.twiddle_general_4mult_entity_f773af9e63
    port map (
      a => single_port_ram_data_out_net_x1,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x50,
      clk_1 => clk_1_sg_x50,
      sync => mux_y_net_x4,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_4/delay_b"

entity delay_b_entity_1301740d9d is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_1301740d9d;

architecture structural of delay_b_entity_1301740d9d is
  signal ce_1_sg_x51: std_logic;
  signal clk_1_sg_x51: std_logic;
  signal constant2_op_net: std_logic;
  signal counter_op_net: std_logic_vector(3 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x51 <= ce_1;
  clk_1_sg_x51 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= single_port_ram_data_out_net_x2;

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 12,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_28c081f5221f14ee",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 4
    )
    port map (
      ce => ce_1_sg_x51,
      clk => clk_1_sg_x51,
      clr => '0',
      en => "1",
      rst => "0",
      op => counter_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 4,
      c_width => 36,
      core_name0 => "bmg_33_103575db1cb8906d",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x51,
      clk => clk_1_sg_x51,
      data_in => mux1_y_net_x0,
      en => "1",
      rst => "0",
      we(0) => constant2_op_net,
      data_out => single_port_ram_data_out_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_4/sync_delay"

entity sync_delay_entity_7fd3522c33 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_7fd3522c33;

architecture structural of sync_delay_entity_7fd3522c33 is
  signal ce_1_sg_x53: std_logic;
  signal clk_1_sg_x53: std_logic;
  signal constant1_op_net: std_logic_vector(4 downto 0);
  signal constant2_op_net: std_logic_vector(4 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(4 downto 0);
  signal counter_op_net: std_logic_vector(4 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x53 <= ce_1;
  clk_1_sg_x53 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_fe72737ca0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_ef0e2e5fc6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_582a3706dd
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_e38d2846faa17a96",
      op_arith => xlUnsigned,
      op_width => 5
    )
    port map (
      ce => ce_1_sg_x53,
      clk => clk_1_sg_x53,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_9ece3c8c4e
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_dc5bc996c9
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_4"

entity fft_stage_4_entity_11654ca280 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_4_entity_11654ca280;

architecture structural of fft_stage_4_entity_11654ca280 is
  signal ce_1_sg_x54: std_logic;
  signal clk_1_sg_x54: std_logic;
  signal concat_y_net_x13: std_logic_vector(35 downto 0);
  signal concat_y_net_x15: std_logic_vector(35 downto 0);
  signal concat_y_net_x4: std_logic_vector(35 downto 0);
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal constant1_op_net_x3: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(4 downto 0);
  signal delay_q_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x1: std_logic;
  signal sync_delay_q_net_x6: std_logic;

begin
  ce_1_sg_x54 <= ce_1;
  clk_1_sg_x54 <= clk_1;
  concat_y_net_x13 <= in1;
  concat_y_net_x15 <= in2;
  constant1_op_net_x3 <= shift;
  sync_delay_q_net_x6 <= sync;
  out1 <= concat_y_net_x4;
  out2 <= concat_y_net_x5;
  sync_out <= sync_delay_q_net_x1;

  butterfly_direct_2942e6d9ae: entity work.butterfly_direct_entity_2942e6d9ae
    port map (
      a => single_port_ram_data_out_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x54,
      clk_1 => clk_1_sg_x54,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x4,
      a_bw_x0 => concat_y_net_x5,
      sync_out => sync_delay_q_net_x1
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_2ac7fb319983676e",
      op_arith => xlUnsigned,
      op_width => 5
    )
    port map (
      ce => ce_1_sg_x54,
      clk => clk_1_sg_x54,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x6,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x54,
      clk => clk_1_sg_x54,
      d(0) => sync_delay_q_net_x6,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_1301740d9d: entity work.delay_b_entity_1301740d9d
    port map (
      ce_1 => ce_1_sg_x54,
      clk_1 => clk_1_sg_x54,
      in1 => mux1_y_net_x0,
      out1 => single_port_ram_data_out_net_x2
    );

  delay_f_f749efca44: entity work.delay_b_entity_1301740d9d
    port map (
      ce_1 => ce_1_sg_x54,
      clk_1 => clk_1_sg_x54,
      in1 => concat_y_net_x15,
      out1 => single_port_ram_data_out_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x54,
      clk => clk_1_sg_x54,
      clr => '0',
      d0 => single_port_ram_data_out_net_x0,
      d1 => concat_y_net_x13,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x54,
      clk => clk_1_sg_x54,
      clr => '0',
      d0 => concat_y_net_x13,
      d1 => single_port_ram_data_out_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 3,
      new_msb => 3,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x3,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 4,
      new_msb => 4,
      x_width => 5,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_7fd3522c33: entity work.sync_delay_entity_7fd3522c33
    port map (
      ce_1 => ce_1_sg_x54,
      clk_1 => clk_1_sg_x54,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_5/butterfly_direct/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_a8eed2b088 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_a8eed2b088;

architecture structural of coeff_gen_entity_a8eed2b088 is
  signal ce_1_sg_x61: std_logic;
  signal clk_1_sg_x61: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux_y_net_x0: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(3 downto 0);

begin
  ce_1_sg_x61 <= ce_1;
  clk_1_sg_x61 <= clk_1;
  mux_y_net_x0 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x61,
      clk => clk_1_sg_x61,
      clr => '0',
      en => "1",
      rst(0) => mux_y_net_x0,
      op => counter_op_net
    );

  ri_to_c_3d7e666eb2: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom
    generic map (
      c_address_width => 4,
      c_width => 18,
      core_name0 => "bmg_33_6ada03306a140765",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x61,
      clk => clk_1_sg_x61,
      en => "1",
      rst => "0",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 4,
      c_width => 18,
      core_name0 => "bmg_33_536316c7eed93d8d",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x61,
      clk => clk_1_sg_x61,
      en => "1",
      rst => "0",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 3,
      new_msb => 6,
      x_width => 7,
      y_width => 4
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_5/butterfly_direct/twiddle_general_4mult"

entity twiddle_general_4mult_entity_76cde8a5e6 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_76cde8a5e6;

architecture structural of twiddle_general_4mult_entity_76cde8a5e6 is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x62: std_logic;
  signal clk_1_sg_x62: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);

begin
  single_port_ram_data_out_net_x0 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x62 <= ce_1;
  clk_1_sg_x62 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_f666f292fd: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_2000570f08: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_b493d2c501: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_a8eed2b088: entity work.coeff_gen_entity_a8eed2b088
    port map (
      ce_1 => ce_1_sg_x62,
      clk_1 => clk_1_sg_x62,
      rst => mux_y_net_x2,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      d => single_port_ram_data_out_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      d => mux_y_net_x1,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      d(0) => mux_y_net_x2,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x62,
      clk => clk_1_sg_x62,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_5/butterfly_direct"

entity butterfly_direct_entity_ec4c151b7c is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_ec4c151b7c;

architecture structural of butterfly_direct_entity_ec4c151b7c is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x63: std_logic;
  signal clk_1_sg_x63: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal single_port_ram_data_out_net_x1: std_logic_vector(35 downto 0);
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  single_port_ram_data_out_net_x1 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x63 <= ce_1;
  clk_1_sg_x63 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_87f0504184: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_08a4efdf78: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_3d2a3cdda0: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_1f6cc2f46f: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_dbfb797fd9: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_c8c08181e6: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x63,
      clk => clk_1_sg_x63,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x63,
      clk => clk_1_sg_x63,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x63,
      clk => clk_1_sg_x63,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x63,
      clk => clk_1_sg_x63,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_9f69dd223c: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_f664cbed46: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x63,
      clk => clk_1_sg_x63,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x63,
      clk => clk_1_sg_x63,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_76cde8a5e6: entity work.twiddle_general_4mult_entity_76cde8a5e6
    port map (
      a => single_port_ram_data_out_net_x1,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x63,
      clk_1 => clk_1_sg_x63,
      sync => mux_y_net_x4,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_5/delay_b"

entity delay_b_entity_84f2e26183 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_84f2e26183;

architecture structural of delay_b_entity_84f2e26183 is
  signal ce_1_sg_x64: std_logic;
  signal clk_1_sg_x64: std_logic;
  signal constant2_op_net: std_logic;
  signal counter_op_net: std_logic_vector(2 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x64 <= ce_1;
  clk_1_sg_x64 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= single_port_ram_data_out_net_x2;

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 4,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_dc3e762e4909a8fc",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 3
    )
    port map (
      ce => ce_1_sg_x64,
      clk => clk_1_sg_x64,
      clr => '0',
      en => "1",
      rst => "0",
      op => counter_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 3,
      c_width => 36,
      core_name0 => "bmg_33_71a507aea6e3ab6e",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x64,
      clk => clk_1_sg_x64,
      data_in => mux1_y_net_x0,
      en => "1",
      rst => "0",
      we(0) => constant2_op_net,
      data_out => single_port_ram_data_out_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_5/sync_delay"

entity sync_delay_entity_83fe5e629b is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_83fe5e629b;

architecture structural of sync_delay_entity_83fe5e629b is
  signal ce_1_sg_x66: std_logic;
  signal clk_1_sg_x66: std_logic;
  signal constant1_op_net: std_logic_vector(3 downto 0);
  signal constant2_op_net: std_logic_vector(3 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(3 downto 0);
  signal counter_op_net: std_logic_vector(3 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x66 <= ce_1;
  clk_1_sg_x66 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_4c449dd556
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_145086465d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_67ad97ca70
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_5146ef1d6551d4bd",
      op_arith => xlUnsigned,
      op_width => 4
    )
    port map (
      ce => ce_1_sg_x66,
      clk => clk_1_sg_x66,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_4d3cfceaf4
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_d930162434
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_5"

entity fft_stage_5_entity_3285069e78 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_5_entity_3285069e78;

architecture structural of fft_stage_5_entity_3285069e78 is
  signal ce_1_sg_x67: std_logic;
  signal clk_1_sg_x67: std_logic;
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal concat_y_net_x7: std_logic_vector(35 downto 0);
  signal concat_y_net_x8: std_logic_vector(35 downto 0);
  signal concat_y_net_x9: std_logic_vector(35 downto 0);
  signal constant1_op_net_x4: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(3 downto 0);
  signal delay_q_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal single_port_ram_data_out_net_x0: std_logic_vector(35 downto 0);
  signal single_port_ram_data_out_net_x2: std_logic_vector(35 downto 0);
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x2: std_logic;
  signal sync_delay_q_net_x3: std_logic;

begin
  ce_1_sg_x67 <= ce_1;
  clk_1_sg_x67 <= clk_1;
  concat_y_net_x5 <= in1;
  concat_y_net_x7 <= in2;
  constant1_op_net_x4 <= shift;
  sync_delay_q_net_x2 <= sync;
  out1 <= concat_y_net_x8;
  out2 <= concat_y_net_x9;
  sync_out <= sync_delay_q_net_x3;

  butterfly_direct_ec4c151b7c: entity work.butterfly_direct_entity_ec4c151b7c
    port map (
      a => single_port_ram_data_out_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x67,
      clk_1 => clk_1_sg_x67,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x8,
      a_bw_x0 => concat_y_net_x9,
      sync_out => sync_delay_q_net_x3
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_28c081f5221f14ee",
      op_arith => xlUnsigned,
      op_width => 4
    )
    port map (
      ce => ce_1_sg_x67,
      clk => clk_1_sg_x67,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x2,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x67,
      clk => clk_1_sg_x67,
      d(0) => sync_delay_q_net_x2,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_84f2e26183: entity work.delay_b_entity_84f2e26183
    port map (
      ce_1 => ce_1_sg_x67,
      clk_1 => clk_1_sg_x67,
      in1 => mux1_y_net_x0,
      out1 => single_port_ram_data_out_net_x2
    );

  delay_f_8bf97b69b8: entity work.delay_b_entity_84f2e26183
    port map (
      ce_1 => ce_1_sg_x67,
      clk_1 => clk_1_sg_x67,
      in1 => concat_y_net_x7,
      out1 => single_port_ram_data_out_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x67,
      clk => clk_1_sg_x67,
      clr => '0',
      d0 => single_port_ram_data_out_net_x0,
      d1 => concat_y_net_x5,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x67,
      clk => clk_1_sg_x67,
      clr => '0',
      d0 => concat_y_net_x5,
      d1 => single_port_ram_data_out_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 4,
      new_msb => 4,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x4,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 3,
      new_msb => 3,
      x_width => 4,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_83fe5e629b: entity work.sync_delay_entity_83fe5e629b
    port map (
      ce_1 => ce_1_sg_x67,
      clk_1 => clk_1_sg_x67,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_6/butterfly_direct/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_0a833cbfa7 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_0a833cbfa7;

architecture structural of coeff_gen_entity_0a833cbfa7 is
  signal ce_1_sg_x74: std_logic;
  signal clk_1_sg_x74: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux_y_net_x0: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(4 downto 0);

begin
  ce_1_sg_x74 <= ce_1;
  clk_1_sg_x74 <= clk_1;
  mux_y_net_x0 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x74,
      clk => clk_1_sg_x74,
      clr => '0',
      en => "1",
      rst(0) => mux_y_net_x0,
      op => counter_op_net
    );

  ri_to_c_9bc8fa8ae9: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom
    generic map (
      c_address_width => 5,
      c_width => 18,
      core_name0 => "bmg_33_89fa326be153087b",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x74,
      clk => clk_1_sg_x74,
      en => "1",
      rst => "0",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 5,
      c_width => 18,
      core_name0 => "bmg_33_c74cf11560359eb3",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x74,
      clk => clk_1_sg_x74,
      en => "1",
      rst => "0",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 6,
      x_width => 7,
      y_width => 5
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_6/butterfly_direct/twiddle_general_4mult"

entity twiddle_general_4mult_entity_ea55cdf0a1 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_ea55cdf0a1;

architecture structural of twiddle_general_4mult_entity_ea55cdf0a1 is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x75: std_logic;
  signal clk_1_sg_x75: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_slr_q_net_x0: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;

begin
  delay_slr_q_net_x0 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x75 <= ce_1;
  clk_1_sg_x75 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_e47379b9e5: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_d9dd67c241: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_880740ff2f: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_0a833cbfa7: entity work.coeff_gen_entity_0a833cbfa7
    port map (
      ce_1 => ce_1_sg_x75,
      clk_1 => clk_1_sg_x75,
      rst => mux_y_net_x2,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      d => delay_slr_q_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      d => mux_y_net_x1,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      d(0) => mux_y_net_x2,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x75,
      clk => clk_1_sg_x75,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_6/butterfly_direct"

entity butterfly_direct_entity_50471ceb05 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_50471ceb05;

architecture structural of butterfly_direct_entity_50471ceb05 is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x76: std_logic;
  signal clk_1_sg_x76: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_slr_q_net_x1: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  delay_slr_q_net_x1 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x76 <= ce_1;
  clk_1_sg_x76 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_e66d1a337b: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_131c1f793a: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_5994b92fa0: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_017d33ab1f: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_51618e294c: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_2008d503ef: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x76,
      clk => clk_1_sg_x76,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x76,
      clk => clk_1_sg_x76,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x76,
      clk => clk_1_sg_x76,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x76,
      clk => clk_1_sg_x76,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_f149f893bc: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_2beaadb5e2: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x76,
      clk => clk_1_sg_x76,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x76,
      clk => clk_1_sg_x76,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_ea55cdf0a1: entity work.twiddle_general_4mult_entity_ea55cdf0a1
    port map (
      a => delay_slr_q_net_x1,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x76,
      clk_1 => clk_1_sg_x76,
      sync => mux_y_net_x4,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_6/delay_b"

entity delay_b_entity_6a45ddd986 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_6a45ddd986;

architecture structural of delay_b_entity_6a45ddd986 is
  signal ce_1_sg_x77: std_logic;
  signal clk_1_sg_x77: std_logic;
  signal delay_slr_q_net_x2: std_logic_vector(35 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x77 <= ce_1;
  clk_1_sg_x77 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= delay_slr_q_net_x2;

  delay_slr: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x77,
      clk => clk_1_sg_x77,
      d => mux1_y_net_x0,
      en => '1',
      q => delay_slr_q_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_6/sync_delay"

entity sync_delay_entity_d524366326 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_d524366326;

architecture structural of sync_delay_entity_d524366326 is
  signal ce_1_sg_x79: std_logic;
  signal clk_1_sg_x79: std_logic;
  signal constant1_op_net: std_logic_vector(2 downto 0);
  signal constant2_op_net: std_logic_vector(2 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(2 downto 0);
  signal counter_op_net: std_logic_vector(2 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x79 <= ce_1;
  clk_1_sg_x79 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_822933f89b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_469094441c
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_a1c496ea88
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_6ad1a52b2c418917",
      op_arith => xlUnsigned,
      op_width => 3
    )
    port map (
      ce => ce_1_sg_x79,
      clk => clk_1_sg_x79,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_8fc7f5539b
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_47b317dab6
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_6"

entity fft_stage_6_entity_d513a8e826 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_6_entity_d513a8e826;

architecture structural of fft_stage_6_entity_d513a8e826 is
  signal ce_1_sg_x80: std_logic;
  signal clk_1_sg_x80: std_logic;
  signal concat_y_net_x11: std_logic_vector(35 downto 0);
  signal concat_y_net_x12: std_logic_vector(35 downto 0);
  signal concat_y_net_x13: std_logic_vector(35 downto 0);
  signal concat_y_net_x9: std_logic_vector(35 downto 0);
  signal constant1_op_net_x5: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(2 downto 0);
  signal delay_q_net_x0: std_logic;
  signal delay_slr_q_net_x0: std_logic_vector(35 downto 0);
  signal delay_slr_q_net_x2: std_logic_vector(35 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x4: std_logic;
  signal sync_delay_q_net_x5: std_logic;

begin
  ce_1_sg_x80 <= ce_1;
  clk_1_sg_x80 <= clk_1;
  concat_y_net_x9 <= in1;
  concat_y_net_x11 <= in2;
  constant1_op_net_x5 <= shift;
  sync_delay_q_net_x4 <= sync;
  out1 <= concat_y_net_x12;
  out2 <= concat_y_net_x13;
  sync_out <= sync_delay_q_net_x5;

  butterfly_direct_50471ceb05: entity work.butterfly_direct_entity_50471ceb05
    port map (
      a => delay_slr_q_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x80,
      clk_1 => clk_1_sg_x80,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x12,
      a_bw_x0 => concat_y_net_x13,
      sync_out => sync_delay_q_net_x5
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_dc3e762e4909a8fc",
      op_arith => xlUnsigned,
      op_width => 3
    )
    port map (
      ce => ce_1_sg_x80,
      clk => clk_1_sg_x80,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x4,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x80,
      clk => clk_1_sg_x80,
      d(0) => sync_delay_q_net_x4,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_6a45ddd986: entity work.delay_b_entity_6a45ddd986
    port map (
      ce_1 => ce_1_sg_x80,
      clk_1 => clk_1_sg_x80,
      in1 => mux1_y_net_x0,
      out1 => delay_slr_q_net_x2
    );

  delay_f_4aeb9ae8ea: entity work.delay_b_entity_6a45ddd986
    port map (
      ce_1 => ce_1_sg_x80,
      clk_1 => clk_1_sg_x80,
      in1 => concat_y_net_x11,
      out1 => delay_slr_q_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x80,
      clk => clk_1_sg_x80,
      clr => '0',
      d0 => delay_slr_q_net_x0,
      d1 => concat_y_net_x9,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x80,
      clk => clk_1_sg_x80,
      clr => '0',
      d0 => concat_y_net_x9,
      d1 => delay_slr_q_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 5,
      new_msb => 5,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x5,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 2,
      x_width => 3,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_d524366326: entity work.sync_delay_entity_d524366326
    port map (
      ce_1 => ce_1_sg_x80,
      clk_1 => clk_1_sg_x80,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_7/butterfly_direct/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_013e86e906 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_013e86e906;

architecture structural of coeff_gen_entity_013e86e906 is
  signal ce_1_sg_x87: std_logic;
  signal clk_1_sg_x87: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux_y_net_x0: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(5 downto 0);

begin
  ce_1_sg_x87 <= ce_1;
  clk_1_sg_x87 <= clk_1;
  mux_y_net_x0 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x87,
      clk => clk_1_sg_x87,
      clr => '0',
      en => "1",
      rst(0) => mux_y_net_x0,
      op => counter_op_net
    );

  ri_to_c_d43710977a: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom
    generic map (
      c_address_width => 6,
      c_width => 18,
      core_name0 => "bmg_33_8a6bca5e2fc06fa6",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x87,
      clk => clk_1_sg_x87,
      en => "1",
      rst => "0",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 6,
      c_width => 18,
      core_name0 => "bmg_33_e8dcf4214e56e3f5",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x87,
      clk => clk_1_sg_x87,
      en => "1",
      rst => "0",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 6,
      x_width => 7,
      y_width => 6
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_7/butterfly_direct/twiddle_general_4mult"

entity twiddle_general_4mult_entity_13fd73b862 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_13fd73b862;

architecture structural of twiddle_general_4mult_entity_13fd73b862 is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x88: std_logic;
  signal clk_1_sg_x88: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_slr_q_net_x0: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;

begin
  delay_slr_q_net_x0 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x88 <= ce_1;
  clk_1_sg_x88 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_14522fa6ea: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_ad9944f92f: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_f23c6af153: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_013e86e906: entity work.coeff_gen_entity_013e86e906
    port map (
      ce_1 => ce_1_sg_x88,
      clk_1 => clk_1_sg_x88,
      rst => mux_y_net_x2,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      d => delay_slr_q_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      d => mux_y_net_x1,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      d(0) => mux_y_net_x2,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x88,
      clk => clk_1_sg_x88,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_7/butterfly_direct"

entity butterfly_direct_entity_32c98a704f is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_32c98a704f;

architecture structural of butterfly_direct_entity_32c98a704f is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x89: std_logic;
  signal clk_1_sg_x89: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_slr_q_net_x1: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  delay_slr_q_net_x1 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x89 <= ce_1;
  clk_1_sg_x89 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_705e742c01: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_4d4c011d3b: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_d173dae0d3: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_f290f6b4cf: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_2f24f7c3ac: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_bfc89078f1: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x89,
      clk => clk_1_sg_x89,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x89,
      clk => clk_1_sg_x89,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x89,
      clk => clk_1_sg_x89,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x89,
      clk => clk_1_sg_x89,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_b603107fb6: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_67cc97fcc6: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x89,
      clk => clk_1_sg_x89,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x89,
      clk => clk_1_sg_x89,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_13fd73b862: entity work.twiddle_general_4mult_entity_13fd73b862
    port map (
      a => delay_slr_q_net_x1,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x89,
      clk_1 => clk_1_sg_x89,
      sync => mux_y_net_x4,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_7/delay_b"

entity delay_b_entity_4edd615e56 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_4edd615e56;

architecture structural of delay_b_entity_4edd615e56 is
  signal ce_1_sg_x90: std_logic;
  signal clk_1_sg_x90: std_logic;
  signal delay_slr_q_net_x2: std_logic_vector(35 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x90 <= ce_1;
  clk_1_sg_x90 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= delay_slr_q_net_x2;

  delay_slr: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x90,
      clk => clk_1_sg_x90,
      d => mux1_y_net_x0,
      en => '1',
      q => delay_slr_q_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_7/sync_delay"

entity sync_delay_entity_a587f64a34 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_a587f64a34;

architecture structural of sync_delay_entity_a587f64a34 is
  signal ce_1_sg_x92: std_logic;
  signal clk_1_sg_x92: std_logic;
  signal constant1_op_net: std_logic_vector(1 downto 0);
  signal constant2_op_net: std_logic_vector(1 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(1 downto 0);
  signal counter_op_net: std_logic_vector(1 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x92 <= ce_1;
  clk_1_sg_x92 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_cda50df78a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_e8ddc079e9
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_a7e2bb9e12
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_6db42a60fe462138",
      op_arith => xlUnsigned,
      op_width => 2
    )
    port map (
      ce => ce_1_sg_x92,
      clk => clk_1_sg_x92,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_5f1eb17108
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_f9928864ea
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_7"

entity fft_stage_7_entity_09435731e8 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_7_entity_09435731e8;

architecture structural of fft_stage_7_entity_09435731e8 is
  signal ce_1_sg_x93: std_logic;
  signal clk_1_sg_x93: std_logic;
  signal concat_y_net_x13: std_logic_vector(35 downto 0);
  signal concat_y_net_x15: std_logic_vector(35 downto 0);
  signal concat_y_net_x4: std_logic_vector(35 downto 0);
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal constant1_op_net_x6: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic_vector(1 downto 0);
  signal delay_q_net_x0: std_logic;
  signal delay_slr_q_net_x0: std_logic_vector(35 downto 0);
  signal delay_slr_q_net_x2: std_logic_vector(35 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x1: std_logic;
  signal sync_delay_q_net_x6: std_logic;

begin
  ce_1_sg_x93 <= ce_1;
  clk_1_sg_x93 <= clk_1;
  concat_y_net_x13 <= in1;
  concat_y_net_x15 <= in2;
  constant1_op_net_x6 <= shift;
  sync_delay_q_net_x6 <= sync;
  out1 <= concat_y_net_x4;
  out2 <= concat_y_net_x5;
  sync_out <= sync_delay_q_net_x1;

  butterfly_direct_32c98a704f: entity work.butterfly_direct_entity_32c98a704f
    port map (
      a => delay_slr_q_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x93,
      clk_1 => clk_1_sg_x93,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x4,
      a_bw_x0 => concat_y_net_x5,
      sync_out => sync_delay_q_net_x1
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_80077642ae38aa96",
      op_arith => xlUnsigned,
      op_width => 2
    )
    port map (
      ce => ce_1_sg_x93,
      clk => clk_1_sg_x93,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x6,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x93,
      clk => clk_1_sg_x93,
      d(0) => sync_delay_q_net_x6,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_4edd615e56: entity work.delay_b_entity_4edd615e56
    port map (
      ce_1 => ce_1_sg_x93,
      clk_1 => clk_1_sg_x93,
      in1 => mux1_y_net_x0,
      out1 => delay_slr_q_net_x2
    );

  delay_f_9dc0bfa85f: entity work.delay_b_entity_4edd615e56
    port map (
      ce_1 => ce_1_sg_x93,
      clk_1 => clk_1_sg_x93,
      in1 => concat_y_net_x15,
      out1 => delay_slr_q_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x93,
      clk => clk_1_sg_x93,
      clr => '0',
      d0 => delay_slr_q_net_x0,
      d1 => concat_y_net_x13,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x93,
      clk => clk_1_sg_x93,
      clr => '0',
      d0 => concat_y_net_x13,
      d1 => delay_slr_q_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 6,
      new_msb => 6,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x6,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 1,
      x_width => 2,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_a587f64a34: entity work.sync_delay_entity_a587f64a34
    port map (
      ce_1 => ce_1_sg_x93,
      clk_1 => clk_1_sg_x93,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_8/butterfly_direct/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_61f6d8d06a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_61f6d8d06a;

architecture structural of coeff_gen_entity_61f6d8d06a is
  signal ce_1_sg_x100: std_logic;
  signal clk_1_sg_x100: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(6 downto 0);
  signal mux_y_net_x0: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(6 downto 0);

begin
  ce_1_sg_x100 <= ce_1;
  clk_1_sg_x100 <= clk_1;
  mux_y_net_x0 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_64b6c809edee1e81",
      op_arith => xlUnsigned,
      op_width => 7
    )
    port map (
      ce => ce_1_sg_x100,
      clk => clk_1_sg_x100,
      clr => '0',
      en => "1",
      rst(0) => mux_y_net_x0,
      op => counter_op_net
    );

  ri_to_c_bf36656257: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom
    generic map (
      c_address_width => 7,
      c_width => 18,
      core_name0 => "bmg_33_00210a008487e75b",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x100,
      clk => clk_1_sg_x100,
      en => "1",
      rst => "0",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 7,
      c_width => 18,
      core_name0 => "bmg_33_6dcf1ebba9a69c95",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x100,
      clk => clk_1_sg_x100,
      en => "1",
      rst => "0",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 6,
      x_width => 7,
      y_width => 7
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_8/butterfly_direct/twiddle_general_4mult"

entity twiddle_general_4mult_entity_b938dcb59f is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_b938dcb59f;

architecture structural of twiddle_general_4mult_entity_b938dcb59f is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x101: std_logic;
  signal clk_1_sg_x101: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_slr_q_net_x0: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal mux_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net_x2: std_logic;

begin
  delay_slr_q_net_x0 <= a;
  mux_y_net_x1 <= b;
  ce_1_sg_x101 <= ce_1;
  clk_1_sg_x101 <= clk_1;
  mux_y_net_x2 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_99edba5720: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_ed8675e898: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_4c18e10f33: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_61f6d8d06a: entity work.coeff_gen_entity_61f6d8d06a
    port map (
      ce_1 => ce_1_sg_x101,
      clk_1 => clk_1_sg_x101,
      rst => mux_y_net_x2,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      d => delay_slr_q_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      d => mux_y_net_x1,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      d(0) => mux_y_net_x2,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x101,
      clk => clk_1_sg_x101,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_8/butterfly_direct"

entity butterfly_direct_entity_4ec1f28854 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly_direct_entity_4ec1f28854;

architecture structural of butterfly_direct_entity_4ec1f28854 is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x102: std_logic;
  signal clk_1_sg_x102: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_slr_q_net_x1: std_logic_vector(35 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x4: std_logic;
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  delay_slr_q_net_x1 <= a;
  mux_y_net_x3 <= b;
  ce_1_sg_x102 <= ce_1;
  clk_1_sg_x102 <= clk_1;
  slice_y_net_x0 <= shift;
  mux_y_net_x4 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_d3710f1da7: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_06c48bd2c2: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_22099ae594: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_381308b551: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_57d53417ae: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_574bb3bb7a: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x102,
      clk => clk_1_sg_x102,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x102,
      clk => clk_1_sg_x102,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x102,
      clk => clk_1_sg_x102,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x102,
      clk => clk_1_sg_x102,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_f99cb2c9f2: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_6d1cef8fdb: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x102,
      clk => clk_1_sg_x102,
      d(0) => slice_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x102,
      clk => clk_1_sg_x102,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_b938dcb59f: entity work.twiddle_general_4mult_entity_b938dcb59f
    port map (
      a => delay_slr_q_net_x1,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x102,
      clk_1 => clk_1_sg_x102,
      sync => mux_y_net_x4,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_8/delay_b"

entity delay_b_entity_f8a05b8f61 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end delay_b_entity_f8a05b8f61;

architecture structural of delay_b_entity_f8a05b8f61 is
  signal ce_1_sg_x103: std_logic;
  signal clk_1_sg_x103: std_logic;
  signal delay_slr_q_net_x2: std_logic_vector(35 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x103 <= ce_1;
  clk_1_sg_x103 <= clk_1;
  mux1_y_net_x0 <= in1;
  out1 <= delay_slr_q_net_x2;

  delay_slr: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x103,
      clk => clk_1_sg_x103,
      d => mux1_y_net_x0,
      en => '1',
      q => delay_slr_q_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_8/sync_delay"

entity sync_delay_entity_bc59ab8422 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_bc59ab8422;

architecture structural of sync_delay_entity_bc59ab8422 is
  signal ce_1_sg_x105: std_logic;
  signal clk_1_sg_x105: std_logic;
  signal constant1_op_net: std_logic_vector(1 downto 0);
  signal constant2_op_net: std_logic_vector(1 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(1 downto 0);
  signal counter_op_net: std_logic_vector(1 downto 0);
  signal delay_q_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x5: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x105 <= ce_1;
  clk_1_sg_x105 <= clk_1;
  delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x5;

  constant1: entity work.constant_cda50df78a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_a7e2bb9e12
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_a7e2bb9e12
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_6db42a60fe462138",
      op_arith => xlUnsigned,
      op_width => 2
    )
    port map (
      ce => ce_1_sg_x105,
      clk => clk_1_sg_x105,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x5
    );

  relational: entity work.relational_5f1eb17108
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_f9928864ea
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core/fft_stage_8"

entity fft_stage_8_entity_27599bc52e is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_stage_8_entity_27599bc52e;

architecture structural of fft_stage_8_entity_27599bc52e is
  signal ce_1_sg_x106: std_logic;
  signal clk_1_sg_x106: std_logic;
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal concat_y_net_x7: std_logic_vector(35 downto 0);
  signal concat_y_net_x8: std_logic_vector(35 downto 0);
  signal concat_y_net_x9: std_logic_vector(35 downto 0);
  signal constant1_op_net_x7: std_logic_vector(31 downto 0);
  signal counter_op_net: std_logic;
  signal delay_q_net_x0: std_logic;
  signal delay_slr_q_net_x0: std_logic_vector(35 downto 0);
  signal delay_slr_q_net_x2: std_logic_vector(35 downto 0);
  signal mux1_y_net_x0: std_logic_vector(35 downto 0);
  signal mux_y_net_x3: std_logic_vector(35 downto 0);
  signal mux_y_net_x5: std_logic;
  signal slice1_y_net: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x2: std_logic;
  signal sync_delay_q_net_x3: std_logic;

begin
  ce_1_sg_x106 <= ce_1;
  clk_1_sg_x106 <= clk_1;
  concat_y_net_x5 <= in1;
  concat_y_net_x7 <= in2;
  constant1_op_net_x7 <= shift;
  sync_delay_q_net_x2 <= sync;
  out1 <= concat_y_net_x8;
  out2 <= concat_y_net_x9;
  sync_out <= sync_delay_q_net_x3;

  butterfly_direct_4ec1f28854: entity work.butterfly_direct_entity_4ec1f28854
    port map (
      a => delay_slr_q_net_x2,
      b => mux_y_net_x3,
      ce_1 => ce_1_sg_x106,
      clk_1 => clk_1_sg_x106,
      shift => slice_y_net_x0,
      sync => mux_y_net_x5,
      a_bw => concat_y_net_x8,
      a_bw_x0 => concat_y_net_x9,
      sync_out => sync_delay_q_net_x3
    );

  counter: entity work.counter_9b03e3d644
    port map (
      ce => ce_1_sg_x106,
      clk => clk_1_sg_x106,
      clr => '0',
      rst(0) => sync_delay_q_net_x2,
      op(0) => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x106,
      clk => clk_1_sg_x106,
      d(0) => sync_delay_q_net_x2,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay_b_f8a05b8f61: entity work.delay_b_entity_f8a05b8f61
    port map (
      ce_1 => ce_1_sg_x106,
      clk_1 => clk_1_sg_x106,
      in1 => mux1_y_net_x0,
      out1 => delay_slr_q_net_x2
    );

  delay_f_13301f17e8: entity work.delay_b_entity_f8a05b8f61
    port map (
      ce_1 => ce_1_sg_x106,
      clk_1 => clk_1_sg_x106,
      in1 => concat_y_net_x7,
      out1 => delay_slr_q_net_x0
    );

  mux: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x106,
      clk => clk_1_sg_x106,
      clr => '0',
      d0 => delay_slr_q_net_x0,
      d1 => concat_y_net_x5,
      sel(0) => slice1_y_net,
      y => mux_y_net_x3
    );

  mux1: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x106,
      clk => clk_1_sg_x106,
      clr => '0',
      d0 => concat_y_net_x5,
      d1 => delay_slr_q_net_x0,
      sel(0) => slice1_y_net,
      y => mux1_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 7,
      new_msb => 7,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x7,
      y(0) => slice_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 1,
      y_width => 1
    )
    port map (
      x(0) => counter_op_net,
      y(0) => slice1_y_net
    );

  sync_delay_bc59ab8422: entity work.sync_delay_entity_bc59ab8422
    port map (
      ce_1 => ce_1_sg_x106,
      clk_1 => clk_1_sg_x106,
      in_x0 => delay_q_net_x0,
      out_x0 => mux_y_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_core"

entity biplex_core_entity_395992e382 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pol1: in std_logic_vector(35 downto 0); 
    pol2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end biplex_core_entity_395992e382;

architecture structural of biplex_core_entity_395992e382 is
  signal ce_1_sg_x107: std_logic;
  signal clk_1_sg_x107: std_logic;
  signal concat_y_net_x10: std_logic_vector(35 downto 0);
  signal concat_y_net_x11: std_logic_vector(35 downto 0);
  signal concat_y_net_x12: std_logic_vector(35 downto 0);
  signal concat_y_net_x13: std_logic_vector(35 downto 0);
  signal concat_y_net_x14: std_logic_vector(35 downto 0);
  signal concat_y_net_x15: std_logic_vector(35 downto 0);
  signal concat_y_net_x16: std_logic_vector(35 downto 0);
  signal concat_y_net_x17: std_logic_vector(35 downto 0);
  signal concat_y_net_x18: std_logic_vector(35 downto 0);
  signal concat_y_net_x21: std_logic_vector(35 downto 0);
  signal concat_y_net_x22: std_logic_vector(35 downto 0);
  signal concat_y_net_x5: std_logic_vector(35 downto 0);
  signal concat_y_net_x6: std_logic_vector(35 downto 0);
  signal concat_y_net_x7: std_logic_vector(35 downto 0);
  signal concat_y_net_x8: std_logic_vector(35 downto 0);
  signal concat_y_net_x9: std_logic_vector(35 downto 0);
  signal constant1_op_net_x8: std_logic_vector(31 downto 0);
  signal delay16_q_net_x2: std_logic_vector(35 downto 0);
  signal delay17_q_net_x1: std_logic_vector(35 downto 0);
  signal delay9_q_net_x1: std_logic;
  signal sync_delay_q_net_x10: std_logic;
  signal sync_delay_q_net_x2: std_logic;
  signal sync_delay_q_net_x3: std_logic;
  signal sync_delay_q_net_x4: std_logic;
  signal sync_delay_q_net_x5: std_logic;
  signal sync_delay_q_net_x6: std_logic;
  signal sync_delay_q_net_x7: std_logic;
  signal sync_delay_q_net_x8: std_logic;

begin
  ce_1_sg_x107 <= ce_1;
  clk_1_sg_x107 <= clk_1;
  delay17_q_net_x1 <= pol1;
  delay16_q_net_x2 <= pol2;
  constant1_op_net_x8 <= shift;
  delay9_q_net_x1 <= sync;
  out1 <= concat_y_net_x21;
  out2 <= concat_y_net_x22;
  sync_out <= sync_delay_q_net_x10;

  fft_stage_1_514d753017: entity work.fft_stage_1_entity_514d753017
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => delay17_q_net_x1,
      in2 => delay16_q_net_x2,
      shift => constant1_op_net_x8,
      sync => delay9_q_net_x1,
      out1 => concat_y_net_x5,
      out2 => concat_y_net_x7,
      sync_out => sync_delay_q_net_x2
    );

  fft_stage_2_2a93e1c051: entity work.fft_stage_2_entity_2a93e1c051
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x5,
      in2 => concat_y_net_x7,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x2,
      out1 => concat_y_net_x9,
      out2 => concat_y_net_x11,
      sync_out => sync_delay_q_net_x4
    );

  fft_stage_3_d34e21166d: entity work.fft_stage_3_entity_d34e21166d
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x9,
      in2 => concat_y_net_x11,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x4,
      out1 => concat_y_net_x13,
      out2 => concat_y_net_x15,
      sync_out => sync_delay_q_net_x6
    );

  fft_stage_4_11654ca280: entity work.fft_stage_4_entity_11654ca280
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x13,
      in2 => concat_y_net_x15,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x6,
      out1 => concat_y_net_x6,
      out2 => concat_y_net_x8,
      sync_out => sync_delay_q_net_x3
    );

  fft_stage_5_3285069e78: entity work.fft_stage_5_entity_3285069e78
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x6,
      in2 => concat_y_net_x8,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x3,
      out1 => concat_y_net_x10,
      out2 => concat_y_net_x12,
      sync_out => sync_delay_q_net_x5
    );

  fft_stage_6_d513a8e826: entity work.fft_stage_6_entity_d513a8e826
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x10,
      in2 => concat_y_net_x12,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x5,
      out1 => concat_y_net_x14,
      out2 => concat_y_net_x16,
      sync_out => sync_delay_q_net_x7
    );

  fft_stage_7_09435731e8: entity work.fft_stage_7_entity_09435731e8
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x14,
      in2 => concat_y_net_x16,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x7,
      out1 => concat_y_net_x17,
      out2 => concat_y_net_x18,
      sync_out => sync_delay_q_net_x8
    );

  fft_stage_8_27599bc52e: entity work.fft_stage_8_entity_27599bc52e
    port map (
      ce_1 => ce_1_sg_x107,
      clk_1 => clk_1_sg_x107,
      in1 => concat_y_net_x17,
      in2 => concat_y_net_x18,
      shift => constant1_op_net_x8,
      sync => sync_delay_q_net_x8,
      out1 => concat_y_net_x21,
      out2 => concat_y_net_x22,
      sync_out => sync_delay_q_net_x10
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_cplx_unscrambler/barrel_switcher"

entity barrel_switcher_entity_2089a09de6 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    sel: in std_logic; 
    sync_in: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end barrel_switcher_entity_2089a09de6;

architecture structural of barrel_switcher_entity_2089a09de6 is
  signal ce_1_sg_x108: std_logic;
  signal clk_1_sg_x108: std_logic;
  signal concat_y_net_x23: std_logic_vector(35 downto 0);
  signal concat_y_net_x24: std_logic_vector(35 downto 0);
  signal convert_dout_net_x0: std_logic;
  signal delay_sync_q_net_x0: std_logic;
  signal mux11_y_net_x0: std_logic_vector(35 downto 0);
  signal mux21_y_net_x0: std_logic_vector(35 downto 0);
  signal slice1_y_net: std_logic;
  signal sync_delay_q_net_x11: std_logic;

begin
  ce_1_sg_x108 <= ce_1;
  clk_1_sg_x108 <= clk_1;
  concat_y_net_x23 <= in1;
  concat_y_net_x24 <= in2;
  convert_dout_net_x0 <= sel;
  sync_delay_q_net_x11 <= sync_in;
  out1 <= mux11_y_net_x0;
  out2 <= mux21_y_net_x0;
  sync_out <= delay_sync_q_net_x0;

  delay_sync: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x108,
      clk => clk_1_sg_x108,
      d(0) => sync_delay_q_net_x11,
      en => '1',
      q(0) => delay_sync_q_net_x0
    );

  mux11: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x108,
      clk => clk_1_sg_x108,
      clr => '0',
      d0 => concat_y_net_x23,
      d1 => concat_y_net_x24,
      sel(0) => slice1_y_net,
      y => mux11_y_net_x0
    );

  mux21: entity work.mux_4bb6f691f7
    port map (
      ce => ce_1_sg_x108,
      clk => clk_1_sg_x108,
      clr => '0',
      d0 => concat_y_net_x24,
      d1 => concat_y_net_x23,
      sel(0) => slice1_y_net,
      y => mux21_y_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 1,
      y_width => 1
    )
    port map (
      x(0) => convert_dout_net_x0,
      y(0) => slice1_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_cplx_unscrambler/reorder/sync_delay_en"

entity sync_delay_en_entity_643cafbd6b is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    en: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_en_entity_643cafbd6b;

architecture structural of sync_delay_en_entity_643cafbd6b is
  signal ce_1_sg_x110: std_logic;
  signal clk_1_sg_x110: std_logic;
  signal constant1_op_net: std_logic_vector(8 downto 0);
  signal constant2_op_net: std_logic_vector(8 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net_x0: std_logic_vector(8 downto 0);
  signal constant_op_net_x1: std_logic;
  signal counter_op_net: std_logic_vector(8 downto 0);
  signal logical1_y_net: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x0: std_logic;
  signal pre_sync_delay_q_net_x0: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x110 <= ce_1;
  clk_1_sg_x110 <= clk_1;
  constant_op_net_x1 <= en;
  pre_sync_delay_q_net_x0 <= in_x0;
  out_x0 <= mux_y_net_x0;

  constant1: entity work.constant_fd85eb7067
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_4a391b9a0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_b4ec9de7d1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net_x0
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_a5266c67e2bfae25",
      op_arith => xlUnsigned,
      op_width => 9
    )
    port map (
      ce => ce_1_sg_x110,
      clk => clk_1_sg_x110,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical1_y_net,
      load(0) => pre_sync_delay_q_net_x0,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => pre_sync_delay_q_net_x0,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  logical1: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => logical_y_net,
      d1(0) => constant_op_net_x1,
      y(0) => logical1_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => pre_sync_delay_q_net_x0,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x0
    );

  relational: entity work.relational_6c3ee657fa
    port map (
      a => constant_op_net_x0,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_78eac2928d
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_cplx_unscrambler/reorder"

entity reorder_entity_0f8d07129a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din0: in std_logic_vector(35 downto 0); 
    en: in std_logic; 
    sync: in std_logic; 
    dout0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end reorder_entity_0f8d07129a;

architecture structural of reorder_entity_0f8d07129a is
  signal bram0_data_out_net_x2: std_logic_vector(35 downto 0);
  signal ce_1_sg_x111: std_logic;
  signal clk_1_sg_x111: std_logic;
  signal constant_op_net_x2: std_logic;
  signal counter_op_net: std_logic_vector(8 downto 0);
  signal delay_d0_q_net: std_logic_vector(7 downto 0);
  signal delay_din0_q_net: std_logic_vector(35 downto 0);
  signal delay_map1_q_net: std_logic_vector(7 downto 0);
  signal delay_sel_q_net: std_logic;
  signal delay_sync_q_net_x1: std_logic;
  signal delay_we_q_net: std_logic;
  signal map1_data_net: std_logic_vector(7 downto 0);
  signal mux11_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net: std_logic_vector(7 downto 0);
  signal mux_y_net_x0: std_logic;
  signal post_sync_delay_q_net_x1: std_logic;
  signal pre_sync_delay_q_net_x0: std_logic;
  signal slice1_y_net: std_logic;
  signal slice2_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x111 <= ce_1;
  clk_1_sg_x111 <= clk_1;
  mux11_y_net_x1 <= din0;
  constant_op_net_x2 <= en;
  delay_sync_q_net_x1 <= sync;
  dout0 <= bram0_data_out_net_x2;
  sync_out <= post_sync_delay_q_net_x1;

  bram0: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 36,
      core_name0 => "bmg_33_06133fa01183b95a",
      latency => 2
    )
    port map (
      addr => mux_y_net,
      ce => ce_1_sg_x111,
      clk => clk_1_sg_x111,
      data_in => delay_din0_q_net,
      en => "1",
      rst => "0",
      we(0) => delay_we_q_net,
      data_out => bram0_data_out_net_x2
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 511,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_7dbd4dbcd9455acc",
      count_limited => 0,
      op_arith => xlUnsigned,
      op_width => 9
    )
    port map (
      ce => ce_1_sg_x111,
      clk => clk_1_sg_x111,
      clr => '0',
      en(0) => constant_op_net_x2,
      rst(0) => delay_sync_q_net_x1,
      op => counter_op_net
    );

  delay_d0: entity work.delay_423c6c1400
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => slice2_y_net,
      q => delay_d0_q_net
    );

  delay_din0: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x111,
      clk => clk_1_sg_x111,
      d => mux11_y_net_x1,
      en => '1',
      q => delay_din0_q_net
    );

  delay_map1: entity work.delay_423c6c1400
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => map1_data_net,
      q => delay_map1_q_net
    );

  delay_sel: entity work.delay_21355083c1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d(0) => slice1_y_net,
      q(0) => delay_sel_q_net
    );

  delay_we: entity work.delay_0341f7be44
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d(0) => constant_op_net_x2,
      q(0) => delay_we_q_net
    );

  map1: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_d096f6e8cb5e3310",
      latency => 0
    )
    port map (
      addr => slice2_y_net,
      ce => ce_1_sg_x111,
      clk => clk_1_sg_x111,
      en => "1",
      data => map1_data_net
    );

  mux: entity work.mux_7f6b7da686
    port map (
      ce => ce_1_sg_x111,
      clk => clk_1_sg_x111,
      clr => '0',
      d0 => delay_d0_q_net,
      d1 => delay_map1_q_net,
      sel(0) => delay_sel_q_net,
      y => mux_y_net
    );

  post_sync_delay: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x111,
      clk => clk_1_sg_x111,
      d(0) => mux_y_net_x0,
      en => '1',
      q(0) => post_sync_delay_q_net_x1
    );

  pre_sync_delay: entity work.delay_0341f7be44
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d(0) => delay_sync_q_net_x1,
      q(0) => pre_sync_delay_q_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 8,
      x_width => 9,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 7,
      x_width => 9,
      y_width => 8
    )
    port map (
      x => counter_op_net,
      y => slice2_y_net
    );

  sync_delay_en_643cafbd6b: entity work.sync_delay_en_entity_643cafbd6b
    port map (
      ce_1 => ce_1_sg_x111,
      clk_1 => clk_1_sg_x111,
      en => constant_op_net_x2,
      in_x0 => pre_sync_delay_q_net_x0,
      out_x0 => mux_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_cplx_unscrambler/reorder1"

entity reorder1_entity_97ced26a43 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din0: in std_logic_vector(35 downto 0); 
    en: in std_logic; 
    sync: in std_logic; 
    dout0: out std_logic_vector(35 downto 0)
  );
end reorder1_entity_97ced26a43;

architecture structural of reorder1_entity_97ced26a43 is
  signal bram0_data_out_net_x3: std_logic_vector(35 downto 0);
  signal ce_1_sg_x112: std_logic;
  signal clk_1_sg_x112: std_logic;
  signal constant_op_net_x3: std_logic;
  signal counter_op_net: std_logic_vector(8 downto 0);
  signal delay_d0_q_net: std_logic_vector(7 downto 0);
  signal delay_din0_q_net: std_logic_vector(35 downto 0);
  signal delay_map1_q_net: std_logic_vector(7 downto 0);
  signal delay_sel_q_net: std_logic;
  signal delay_sync_q_net_x2: std_logic;
  signal delay_we_q_net: std_logic;
  signal map1_data_net: std_logic_vector(7 downto 0);
  signal mux21_y_net_x1: std_logic_vector(35 downto 0);
  signal mux_y_net: std_logic_vector(7 downto 0);
  signal slice1_y_net: std_logic;
  signal slice2_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x112 <= ce_1;
  clk_1_sg_x112 <= clk_1;
  mux21_y_net_x1 <= din0;
  constant_op_net_x3 <= en;
  delay_sync_q_net_x2 <= sync;
  dout0 <= bram0_data_out_net_x3;

  bram0: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 36,
      core_name0 => "bmg_33_06133fa01183b95a",
      latency => 2
    )
    port map (
      addr => mux_y_net,
      ce => ce_1_sg_x112,
      clk => clk_1_sg_x112,
      data_in => delay_din0_q_net,
      en => "1",
      rst => "0",
      we(0) => delay_we_q_net,
      data_out => bram0_data_out_net_x3
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 511,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_7dbd4dbcd9455acc",
      count_limited => 0,
      op_arith => xlUnsigned,
      op_width => 9
    )
    port map (
      ce => ce_1_sg_x112,
      clk => clk_1_sg_x112,
      clr => '0',
      en(0) => constant_op_net_x3,
      rst(0) => delay_sync_q_net_x2,
      op => counter_op_net
    );

  delay_d0: entity work.delay_423c6c1400
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => slice2_y_net,
      q => delay_d0_q_net
    );

  delay_din0: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x112,
      clk => clk_1_sg_x112,
      d => mux21_y_net_x1,
      en => '1',
      q => delay_din0_q_net
    );

  delay_map1: entity work.delay_423c6c1400
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => map1_data_net,
      q => delay_map1_q_net
    );

  delay_sel: entity work.delay_21355083c1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d(0) => slice1_y_net,
      q(0) => delay_sel_q_net
    );

  delay_we: entity work.delay_0341f7be44
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d(0) => constant_op_net_x3,
      q(0) => delay_we_q_net
    );

  map1: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_2c84d7ed8ee6aa83",
      latency => 0
    )
    port map (
      addr => slice2_y_net,
      ce => ce_1_sg_x112,
      clk => clk_1_sg_x112,
      en => "1",
      data => map1_data_net
    );

  mux: entity work.mux_7f6b7da686
    port map (
      ce => ce_1_sg_x112,
      clk => clk_1_sg_x112,
      clr => '0',
      d0 => delay_d0_q_net,
      d1 => delay_map1_q_net,
      sel(0) => delay_sel_q_net,
      y => mux_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 8,
      x_width => 9,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice1_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 7,
      x_width => 9,
      y_width => 8
    )
    port map (
      x => counter_op_net,
      y => slice2_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0/biplex_cplx_unscrambler"

entity biplex_cplx_unscrambler_entity_8a0a189ed6 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    even: in std_logic_vector(35 downto 0); 
    odd: in std_logic_vector(35 downto 0); 
    sync: in std_logic; 
    pol1: out std_logic_vector(35 downto 0); 
    pol2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end biplex_cplx_unscrambler_entity_8a0a189ed6;

architecture structural of biplex_cplx_unscrambler_entity_8a0a189ed6 is
  signal bram0_data_out_net_x2: std_logic_vector(35 downto 0);
  signal bram0_data_out_net_x3: std_logic_vector(35 downto 0);
  signal ce_1_sg_x113: std_logic;
  signal clk_1_sg_x113: std_logic;
  signal concat_y_net_x25: std_logic_vector(35 downto 0);
  signal concat_y_net_x26: std_logic_vector(35 downto 0);
  signal constant1_op_net: std_logic_vector(7 downto 0);
  signal constant2_op_net: std_logic_vector(7 downto 0);
  signal constant_op_net_x3: std_logic;
  signal convert1_dout_net_x0: std_logic;
  signal convert_dout_net_x0: std_logic;
  signal counter1_op_net: std_logic_vector(7 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay_sync_q_net_x1: std_logic;
  signal delay_sync_q_net_x2: std_logic;
  signal mux11_y_net_x1: std_logic_vector(35 downto 0);
  signal mux11_y_net_x2: std_logic_vector(35 downto 0);
  signal mux21_y_net_x1: std_logic_vector(35 downto 0);
  signal mux21_y_net_x2: std_logic_vector(35 downto 0);
  signal post_sync_delay_q_net_x1: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;
  signal sync_delay_q_net_x12: std_logic;

begin
  ce_1_sg_x113 <= ce_1;
  clk_1_sg_x113 <= clk_1;
  concat_y_net_x25 <= even;
  concat_y_net_x26 <= odd;
  sync_delay_q_net_x12 <= sync;
  pol1 <= mux11_y_net_x2;
  pol2 <= mux21_y_net_x2;
  sync_out <= delay_sync_q_net_x1;

  barrel_switcher1_9e8f6ed6bf: entity work.barrel_switcher_entity_2089a09de6
    port map (
      ce_1 => ce_1_sg_x113,
      clk_1 => clk_1_sg_x113,
      in1 => bram0_data_out_net_x2,
      in2 => bram0_data_out_net_x3,
      sel => convert1_dout_net_x0,
      sync_in => post_sync_delay_q_net_x1,
      out1 => mux11_y_net_x2,
      out2 => mux21_y_net_x2,
      sync_out => delay_sync_q_net_x1
    );

  barrel_switcher_2089a09de6: entity work.barrel_switcher_entity_2089a09de6
    port map (
      ce_1 => ce_1_sg_x113,
      clk_1 => clk_1_sg_x113,
      in1 => concat_y_net_x25,
      in2 => concat_y_net_x26,
      sel => convert_dout_net_x0,
      sync_in => sync_delay_q_net_x12,
      out1 => mux11_y_net_x1,
      out2 => mux21_y_net_x1,
      sync_out => delay_sync_q_net_x2
    );

  constant1: entity work.constant_e8aae5d3bb
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_e8aae5d3bb
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant_x0: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant_op_net_x3
    );

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => relational_op_net,
      dout(0) => convert_dout_net_x0
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => relational1_op_net,
      dout(0) => convert1_dout_net_x0
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x113,
      clk => clk_1_sg_x113,
      clr => '0',
      en => "1",
      rst(0) => sync_delay_q_net_x12,
      op => counter_op_net
    );

  counter1: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x113,
      clk => clk_1_sg_x113,
      clr => '0',
      en => "1",
      rst(0) => post_sync_delay_q_net_x1,
      op => counter1_op_net
    );

  relational: entity work.relational_2d417722ee
    port map (
      a => constant1_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_2d417722ee
    port map (
      a => constant2_op_net,
      b => counter1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

  reorder1_97ced26a43: entity work.reorder1_entity_97ced26a43
    port map (
      ce_1 => ce_1_sg_x113,
      clk_1 => clk_1_sg_x113,
      din0 => mux21_y_net_x1,
      en => constant_op_net_x3,
      sync => delay_sync_q_net_x2,
      dout0 => bram0_data_out_net_x3
    );

  reorder_0f8d07129a: entity work.reorder_entity_0f8d07129a
    port map (
      ce_1 => ce_1_sg_x113,
      clk_1 => clk_1_sg_x113,
      din0 => mux11_y_net_x1,
      en => constant_op_net_x3,
      sync => delay_sync_q_net_x2,
      dout0 => bram0_data_out_net_x2,
      sync_out => post_sync_delay_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_biplex0"

entity fft_biplex0_entity_b8d0b78258 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pol1: in std_logic_vector(35 downto 0); 
    pol2: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    pol1_out: out std_logic_vector(35 downto 0); 
    pol2_out: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_biplex0_entity_b8d0b78258;

architecture structural of fft_biplex0_entity_b8d0b78258 is
  signal ce_1_sg_x114: std_logic;
  signal clk_1_sg_x114: std_logic;
  signal concat_y_net_x25: std_logic_vector(35 downto 0);
  signal concat_y_net_x26: std_logic_vector(35 downto 0);
  signal constant1_op_net_x9: std_logic_vector(31 downto 0);
  signal delay16_q_net_x3: std_logic_vector(35 downto 0);
  signal delay17_q_net_x2: std_logic_vector(35 downto 0);
  signal delay9_q_net_x2: std_logic;
  signal delay_sync_q_net_x2: std_logic;
  signal mux11_y_net_x3: std_logic_vector(35 downto 0);
  signal mux21_y_net_x3: std_logic_vector(35 downto 0);
  signal sync_delay_q_net_x12: std_logic;

begin
  ce_1_sg_x114 <= ce_1;
  clk_1_sg_x114 <= clk_1;
  delay17_q_net_x2 <= pol1;
  delay16_q_net_x3 <= pol2;
  constant1_op_net_x9 <= shift;
  delay9_q_net_x2 <= sync;
  pol1_out <= mux11_y_net_x3;
  pol2_out <= mux21_y_net_x3;
  sync_out <= delay_sync_q_net_x2;

  biplex_core_395992e382: entity work.biplex_core_entity_395992e382
    port map (
      ce_1 => ce_1_sg_x114,
      clk_1 => clk_1_sg_x114,
      pol1 => delay17_q_net_x2,
      pol2 => delay16_q_net_x3,
      shift => constant1_op_net_x9,
      sync => delay9_q_net_x2,
      out1 => concat_y_net_x25,
      out2 => concat_y_net_x26,
      sync_out => sync_delay_q_net_x12
    );

  biplex_cplx_unscrambler_8a0a189ed6: entity work.biplex_cplx_unscrambler_entity_8a0a189ed6
    port map (
      ce_1 => ce_1_sg_x114,
      clk_1 => clk_1_sg_x114,
      even => concat_y_net_x25,
      odd => concat_y_net_x26,
      sync => sync_delay_q_net_x12,
      pol1 => mux11_y_net_x3,
      pol2 => mux21_y_net_x3,
      sync_out => delay_sync_q_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_direct/butterfly1_0/twiddle_general_4mult/coeff_gen"

entity coeff_gen_entity_5c10eed696 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    rst: in std_logic; 
    w: out std_logic_vector(35 downto 0)
  );
end coeff_gen_entity_5c10eed696;

architecture structural of coeff_gen_entity_5c10eed696 is
  signal ce_1_sg_x121: std_logic;
  signal clk_1_sg_x121: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay_sync_q_net_x3: std_logic;
  signal rom1_data_net_x0: std_logic_vector(17 downto 0);
  signal rom_data_net_x0: std_logic_vector(17 downto 0);
  signal slice_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x121 <= ce_1;
  clk_1_sg_x121 <= clk_1;
  delay_sync_q_net_x3 <= rst;
  w <= concat_y_net_x2;

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x121,
      clk => clk_1_sg_x121,
      clr => '0',
      en => "1",
      rst(0) => delay_sync_q_net_x3,
      op => counter_op_net
    );

  ri_to_c_ac33d8cfe5: entity work.ri_to_c_entity_20104ade43
    port map (
      im => rom1_data_net_x0,
      re => rom_data_net_x0,
      c => concat_y_net_x2
    );

  rom: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 18,
      core_name0 => "bmg_33_e9e540b1ba40437d",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x121,
      clk => clk_1_sg_x121,
      en => "1",
      rst => "0",
      data => rom_data_net_x0
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 18,
      core_name0 => "bmg_33_e77502d71aea64a1",
      latency => 2
    )
    port map (
      addr => slice_y_net,
      ce => ce_1_sg_x121,
      clk => clk_1_sg_x121,
      en => "1",
      rst => "0",
      data => rom1_data_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 7,
      x_width => 8,
      y_width => 8
    )
    port map (
      x => counter_op_net,
      y => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_direct/butterfly1_0/twiddle_general_4mult"

entity twiddle_general_4mult_entity_b702cb16d0 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync: in std_logic; 
    a_im: out std_logic_vector(17 downto 0); 
    a_re: out std_logic_vector(17 downto 0); 
    bw_im: out std_logic_vector(21 downto 0); 
    bw_re: out std_logic_vector(21 downto 0); 
    sync_out: out std_logic
  );
end twiddle_general_4mult_entity_b702cb16d0;

architecture structural of twiddle_general_4mult_entity_b702cb16d0 is
  signal addsub1_s_net: std_logic_vector(36 downto 0);
  signal addsub_s_net: std_logic_vector(36 downto 0);
  signal ce_1_sg_x122: std_logic;
  signal clk_1_sg_x122: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal delay0_q_net_x0: std_logic_vector(35 downto 0);
  signal delay1_q_net_x0: std_logic_vector(35 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_sync_q_net_x4: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(35 downto 0);
  signal mult2_p_net: std_logic_vector(35 downto 0);
  signal mult3_p_net: std_logic_vector(35 downto 0);
  signal mult_p_net: std_logic_vector(35 downto 0);
  signal node0_0_q_net_x0: std_logic_vector(35 downto 0);
  signal node0_1_q_net_x0: std_logic_vector(35 downto 0);

begin
  node0_0_q_net_x0 <= a;
  node0_1_q_net_x0 <= b;
  ce_1_sg_x122 <= ce_1;
  clk_1_sg_x122 <= clk_1;
  delay_sync_q_net_x4 <= sync;
  a_im <= force_im_output_port_net_x3;
  a_re <= force_re_output_port_net_x3;
  bw_im <= convert1_dout_net_x2;
  bw_re <= convert0_dout_net_x2;
  sync_out <= delay2_q_net_x0;

  addsub: entity work.addsub_be8c56327e
    port map (
      a => mult_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      s => addsub_s_net
    );

  addsub1: entity work.addsub_eb2273ac28
    port map (
      a => mult1_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      s => addsub1_s_net
    );

  c_to_ri1_afcdccdb77: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay0_q_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri2_9188855109: entity work.c_to_ri2_entity_2085ece8b6
    port map (
      c => concat_y_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_ff329216b4: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => delay1_q_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  coeff_gen_5c10eed696: entity work.coeff_gen_entity_5c10eed696
    port map (
      ce_1 => ce_1_sg_x122,
      clk_1 => clk_1_sg_x122,
      rst => delay_sync_q_net_x4,
      w => concat_y_net_x2
    );

  convert0: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      din => addsub_s_net,
      dout => convert0_dout_net_x2
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 33,
      din_width => 37,
      dout_arith => 2,
      dout_bin_pt => 19,
      dout_width => 22,
      latency => 2,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      din => addsub1_s_net,
      dout => convert1_dout_net_x2
    );

  delay0: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      d => node0_0_q_net_x0,
      en => '1',
      q => delay0_q_net_x0
    );

  delay1: entity work.delay_4b00a70dea
    port map (
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      d => node0_1_q_net_x0,
      q => delay1_q_net_x0
    );

  delay2: entity work.xldelay
    generic map (
      latency => 9,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      d(0) => delay_sync_q_net_x4,
      en => '1',
      q(0) => delay2_q_net_x0
    );

  mult: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      p => mult_p_net
    );

  mult1: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_re_output_port_net_x0,
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      p => mult1_p_net
    );

  mult2: entity work.mult_f295e5f0f2
    port map (
      a => force_im_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      p => mult2_p_net
    );

  mult3: entity work.mult_f295e5f0f2
    port map (
      a => force_re_output_port_net_x1,
      b => force_im_output_port_net_x0,
      ce => ce_1_sg_x122,
      clk => clk_1_sg_x122,
      clr => '0',
      p => mult3_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_direct/butterfly1_0"

entity butterfly1_0_entity_a89b6d99e5 is
  port (
    a: in std_logic_vector(35 downto 0); 
    b: in std_logic_vector(35 downto 0); 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    shift: in std_logic; 
    sync: in std_logic; 
    a_bw: out std_logic_vector(35 downto 0); 
    a_bw_x0: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end butterfly1_0_entity_a89b6d99e5;

architecture structural of butterfly1_0_entity_a89b6d99e5 is
  signal cast_c_im_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_im_dout_net_x1: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x0: std_logic_vector(22 downto 0);
  signal cast_c_re_dout_net_x1: std_logic_vector(22 downto 0);
  signal ce_1_sg_x123: std_logic;
  signal clk_1_sg_x123: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal convert0_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert1_dout_net_x2: std_logic_vector(21 downto 0);
  signal convert_dout_net_x2: std_logic_vector(17 downto 0);
  signal convert_dout_net_x3: std_logic_vector(17 downto 0);
  signal convert_dout_net_x4: std_logic_vector(17 downto 0);
  signal convert_dout_net_x5: std_logic_vector(17 downto 0);
  signal delay2_q_net_x0: std_logic;
  signal delay_sync_q_net_x5: std_logic;
  signal force_im_output_port_net_x3: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(17 downto 0);
  signal mux0_y_net_x0: std_logic_vector(23 downto 0);
  signal mux1_y_net_x0: std_logic_vector(23 downto 0);
  signal mux2_y_net_x0: std_logic_vector(23 downto 0);
  signal mux3_y_net_x0: std_logic_vector(23 downto 0);
  signal node0_0_q_net_x1: std_logic_vector(35 downto 0);
  signal node0_1_q_net_x1: std_logic_vector(35 downto 0);
  signal scale0_op_net: std_logic_vector(22 downto 0);
  signal scale1_op_net: std_logic_vector(22 downto 0);
  signal scale2_op_net: std_logic_vector(22 downto 0);
  signal scale3_op_net: std_logic_vector(22 downto 0);
  signal shift_delay_q_net: std_logic;
  signal slice0_y_net_x0: std_logic;
  signal sync_delay_q_net_x0: std_logic;

begin
  node0_0_q_net_x1 <= a;
  node0_1_q_net_x1 <= b;
  ce_1_sg_x123 <= ce_1;
  clk_1_sg_x123 <= clk_1;
  slice0_y_net_x0 <= shift;
  delay_sync_q_net_x5 <= sync;
  a_bw <= concat_y_net_x2;
  a_bw_x0 <= concat_y_net_x3;
  sync_out <= sync_delay_q_net_x0;

  cadd_a8138f5caf: entity work.cadd_entity_c49d0d70b5
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      c_im => cast_c_im_dout_net_x0,
      c_re => cast_c_re_dout_net_x0
    );

  convert_of0_132c3f6f0a: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      din => mux0_y_net_x0,
      dout => convert_dout_net_x2
    );

  convert_of1_e34dba818d: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      din => mux1_y_net_x0,
      dout => convert_dout_net_x3
    );

  convert_of2_bf11d1b497: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      din => mux2_y_net_x0,
      dout => convert_dout_net_x4
    );

  convert_of3_e2d5504368: entity work.convert_of0_entity_c5a79c8e94
    port map (
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      din => mux3_y_net_x0,
      dout => convert_dout_net_x5
    );

  csub_b173a4456a: entity work.csub_entity_31e94c9537
    port map (
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      b_im => convert1_dout_net_x2,
      b_re => convert0_dout_net_x2,
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      c_im => cast_c_im_dout_net_x1,
      c_re => cast_c_re_dout_net_x1
    );

  mux0: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x123,
      clk => clk_1_sg_x123,
      clr => '0',
      d0 => cast_c_re_dout_net_x0,
      d1 => scale0_op_net,
      sel(0) => shift_delay_q_net,
      y => mux0_y_net_x0
    );

  mux1: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x123,
      clk => clk_1_sg_x123,
      clr => '0',
      d0 => cast_c_im_dout_net_x0,
      d1 => scale1_op_net,
      sel(0) => shift_delay_q_net,
      y => mux1_y_net_x0
    );

  mux2: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x123,
      clk => clk_1_sg_x123,
      clr => '0',
      d0 => cast_c_re_dout_net_x1,
      d1 => scale2_op_net,
      sel(0) => shift_delay_q_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_0c5c160d49
    port map (
      ce => ce_1_sg_x123,
      clk => clk_1_sg_x123,
      clr => '0',
      d0 => cast_c_im_dout_net_x1,
      d1 => scale3_op_net,
      sel(0) => shift_delay_q_net,
      y => mux3_y_net_x0
    );

  ri_to_c01_24df126c0b: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x3,
      re => convert_dout_net_x2,
      c => concat_y_net_x2
    );

  ri_to_c23_f37a5e5a82: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => convert_dout_net_x5,
      re => convert_dout_net_x4,
      c => concat_y_net_x3
    );

  scale0: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x0,
      op => scale0_op_net
    );

  scale1: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_re_dout_net_x1,
      op => scale2_op_net
    );

  scale3: entity work.scale_e5d0b4a1ec
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => cast_c_im_dout_net_x1,
      op => scale3_op_net
    );

  shift_delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x123,
      clk => clk_1_sg_x123,
      d(0) => slice0_y_net_x0,
      en => '1',
      q(0) => shift_delay_q_net
    );

  sync_delay: entity work.delay_a14e3dd1bd
    port map (
      ce => ce_1_sg_x123,
      clk => clk_1_sg_x123,
      clr => '0',
      d(0) => delay2_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

  twiddle_general_4mult_b702cb16d0: entity work.twiddle_general_4mult_entity_b702cb16d0
    port map (
      a => node0_0_q_net_x1,
      b => node0_1_q_net_x1,
      ce_1 => ce_1_sg_x123,
      clk_1 => clk_1_sg_x123,
      sync => delay_sync_q_net_x5,
      a_im => force_im_output_port_net_x3,
      a_re => force_re_output_port_net_x3,
      bw_im => convert1_dout_net_x2,
      bw_re => convert0_dout_net_x2,
      sync_out => delay2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_direct"

entity fft_direct_entity_44fa89ae89 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in0: in std_logic_vector(35 downto 0); 
    in1: in std_logic_vector(35 downto 0); 
    shift: in std_logic; 
    sync: in std_logic; 
    out0: out std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_direct_entity_44fa89ae89;

architecture structural of fft_direct_entity_44fa89ae89 is
  signal ce_1_sg_x124: std_logic;
  signal clk_1_sg_x124: std_logic;
  signal concat_y_net_x2: std_logic_vector(35 downto 0);
  signal concat_y_net_x3: std_logic_vector(35 downto 0);
  signal delay_sync_q_net_x6: std_logic;
  signal mux11_y_net_x4: std_logic_vector(35 downto 0);
  signal mux21_y_net_x4: std_logic_vector(35 downto 0);
  signal node0_0_q_net_x1: std_logic_vector(35 downto 0);
  signal node0_1_q_net_x1: std_logic_vector(35 downto 0);
  signal node1_0_q_net_x0: std_logic_vector(35 downto 0);
  signal node1_1_q_net_x0: std_logic_vector(35 downto 0);
  signal slice0_y_net_x0: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x1: std_logic;

begin
  ce_1_sg_x124 <= ce_1;
  clk_1_sg_x124 <= clk_1;
  mux11_y_net_x4 <= in0;
  mux21_y_net_x4 <= in1;
  slice_y_net_x0 <= shift;
  delay_sync_q_net_x6 <= sync;
  out0 <= node1_0_q_net_x0;
  out1 <= node1_1_q_net_x0;
  sync_out <= sync_delay_q_net_x1;

  butterfly1_0_a89b6d99e5: entity work.butterfly1_0_entity_a89b6d99e5
    port map (
      a => node0_0_q_net_x1,
      b => node0_1_q_net_x1,
      ce_1 => ce_1_sg_x124,
      clk_1 => clk_1_sg_x124,
      shift => slice0_y_net_x0,
      sync => delay_sync_q_net_x6,
      a_bw => concat_y_net_x2,
      a_bw_x0 => concat_y_net_x3,
      sync_out => sync_delay_q_net_x1
    );

  node0_0: entity work.delay_0c0a0420a6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => mux11_y_net_x4,
      q => node0_0_q_net_x1
    );

  node0_1: entity work.delay_0c0a0420a6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => mux21_y_net_x4,
      q => node0_1_q_net_x1
    );

  node1_0: entity work.delay_0c0a0420a6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => concat_y_net_x2,
      q => node1_0_q_net_x0
    );

  node1_1: entity work.delay_0c0a0420a6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => concat_y_net_x3,
      q => node1_1_q_net_x0
    );

  slice0: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 1,
      y_width => 1
    )
    port map (
      x(0) => slice_y_net_x0,
      y(0) => slice0_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_unscrambler/reorder"

entity reorder_entity_4a64b101ea is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din0: in std_logic_vector(35 downto 0); 
    din1: in std_logic_vector(35 downto 0); 
    en: in std_logic; 
    sync: in std_logic; 
    dout0: out std_logic_vector(35 downto 0); 
    dout1: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end reorder_entity_4a64b101ea;

architecture structural of reorder_entity_4a64b101ea is
  signal bram0_data_out_net_x0: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x0: std_logic_vector(35 downto 0);
  signal ce_1_sg_x126: std_logic;
  signal clk_1_sg_x126: std_logic;
  signal const_op_net_x1: std_logic;
  signal counter_op_net: std_logic_vector(10 downto 0);
  signal delay0_q_net_x0: std_logic;
  signal delay_d0_q_net: std_logic_vector(7 downto 0);
  signal delay_din0_q_net: std_logic_vector(35 downto 0);
  signal delay_din1_q_net: std_logic_vector(35 downto 0);
  signal delay_map1_q_net: std_logic_vector(7 downto 0);
  signal delay_map2_q_net: std_logic_vector(7 downto 0);
  signal delay_map3_q_net: std_logic_vector(7 downto 0);
  signal delay_map4_q_net: std_logic_vector(7 downto 0);
  signal delay_map5_q_net: std_logic_vector(7 downto 0);
  signal delay_map6_q_net: std_logic_vector(7 downto 0);
  signal delay_map7_q_net: std_logic_vector(7 downto 0);
  signal delay_sel_q_net: std_logic_vector(2 downto 0);
  signal delay_we_q_net: std_logic;
  signal delayb1_q_net_x0: std_logic_vector(35 downto 0);
  signal delayb2_q_net_x0: std_logic_vector(35 downto 0);
  signal map1_data_net: std_logic_vector(7 downto 0);
  signal map2_data_net: std_logic_vector(7 downto 0);
  signal map3_data_net: std_logic_vector(7 downto 0);
  signal map4_data_net: std_logic_vector(7 downto 0);
  signal map5_data_net: std_logic_vector(7 downto 0);
  signal map6_data_net: std_logic_vector(7 downto 0);
  signal map7_data_net: std_logic_vector(7 downto 0);
  signal mux_y_net: std_logic_vector(7 downto 0);
  signal mux_y_net_x0: std_logic;
  signal post_sync_delay_q_net_x1: std_logic;
  signal pre_sync_delay_q_net_x0: std_logic;
  signal slice1_y_net: std_logic_vector(2 downto 0);
  signal slice2_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x126 <= ce_1;
  clk_1_sg_x126 <= clk_1;
  delayb1_q_net_x0 <= din0;
  delayb2_q_net_x0 <= din1;
  const_op_net_x1 <= en;
  delay0_q_net_x0 <= sync;
  dout0 <= bram0_data_out_net_x0;
  dout1 <= bram1_data_out_net_x0;
  sync_out <= post_sync_delay_q_net_x1;

  bram0: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 36,
      core_name0 => "bmg_33_06133fa01183b95a",
      latency => 2
    )
    port map (
      addr => mux_y_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      data_in => delay_din0_q_net,
      en => "1",
      rst => "0",
      we(0) => delay_we_q_net,
      data_out => bram0_data_out_net_x0
    );

  bram1: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 36,
      core_name0 => "bmg_33_06133fa01183b95a",
      latency => 2
    )
    port map (
      addr => mux_y_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      data_in => delay_din1_q_net,
      en => "1",
      rst => "0",
      we(0) => delay_we_q_net,
      data_out => bram1_data_out_net_x0
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 2047,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_da764ffec3b80b68",
      count_limited => 0,
      op_arith => xlUnsigned,
      op_width => 11
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      clr => '0',
      en(0) => const_op_net_x1,
      rst(0) => delay0_q_net_x0,
      op => counter_op_net
    );

  delay_d0: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => slice2_y_net,
      en => '1',
      q => delay_d0_q_net
    );

  delay_din0: entity work.xldelay
    generic map (
      latency => 8,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => delayb1_q_net_x0,
      en => '1',
      q => delay_din0_q_net
    );

  delay_din1: entity work.xldelay
    generic map (
      latency => 8,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => delayb2_q_net_x0,
      en => '1',
      q => delay_din1_q_net
    );

  delay_map1: entity work.xldelay
    generic map (
      latency => 6,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => map1_data_net,
      en => '1',
      q => delay_map1_q_net
    );

  delay_map2: entity work.xldelay
    generic map (
      latency => 5,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => map2_data_net,
      en => '1',
      q => delay_map2_q_net
    );

  delay_map3: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => map3_data_net,
      en => '1',
      q => delay_map3_q_net
    );

  delay_map4: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => map4_data_net,
      en => '1',
      q => delay_map4_q_net
    );

  delay_map5: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => map5_data_net,
      en => '1',
      q => delay_map5_q_net
    );

  delay_map6: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => map6_data_net,
      en => '1',
      q => delay_map6_q_net
    );

  delay_map7: entity work.delay_423c6c1400
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => map7_data_net,
      q => delay_map7_q_net
    );

  delay_sel: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 3
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d => slice1_y_net,
      en => '1',
      q => delay_sel_q_net
    );

  delay_we: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d(0) => const_op_net_x1,
      en => '1',
      q(0) => delay_we_q_net
    );

  map1: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => slice2_y_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map1_data_net
    );

  map2: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map1_data_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map2_data_net
    );

  map3: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map2_data_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map3_data_net
    );

  map4: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map3_data_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map4_data_net
    );

  map5: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map4_data_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map5_data_net
    );

  map6: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map5_data_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map6_data_net
    );

  map7: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map6_data_net,
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      en => "1",
      data => map7_data_net
    );

  mux: entity work.mux_87d2a53357
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      clr => '0',
      d0 => delay_d0_q_net,
      d1 => delay_map1_q_net,
      d2 => delay_map2_q_net,
      d3 => delay_map3_q_net,
      d4 => delay_map4_q_net,
      d5 => delay_map5_q_net,
      d6 => delay_map6_q_net,
      d7 => delay_map7_q_net,
      sel => delay_sel_q_net,
      y => mux_y_net
    );

  post_sync_delay: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d(0) => mux_y_net_x0,
      en => '1',
      q(0) => post_sync_delay_q_net_x1
    );

  pre_sync_delay: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x126,
      clk => clk_1_sg_x126,
      d(0) => delay0_q_net_x0,
      en => '1',
      q(0) => pre_sync_delay_q_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 10,
      x_width => 11,
      y_width => 3
    )
    port map (
      x => counter_op_net,
      y => slice1_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 7,
      x_width => 11,
      y_width => 8
    )
    port map (
      x => counter_op_net,
      y => slice2_y_net
    );

  sync_delay_en_3e4ee6d18e: entity work.sync_delay_en_entity_643cafbd6b
    port map (
      ce_1 => ce_1_sg_x126,
      clk_1 => clk_1_sg_x126,
      en => const_op_net_x1,
      in_x0 => pre_sync_delay_q_net_x0,
      out_x0 => mux_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_unscrambler/square_transposer"

entity square_transposer_entity_a972db8b03 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end square_transposer_entity_a972db8b03;

architecture structural of square_transposer_entity_a972db8b03 is
  signal ce_1_sg_x128: std_logic;
  signal clk_1_sg_x128: std_logic;
  signal counter_op_net_x0: std_logic;
  signal delay0_q_net_x1: std_logic;
  signal delay_sync_q_net_x0: std_logic;
  signal delayb1_q_net_x1: std_logic_vector(35 downto 0);
  signal delayb2_q_net_x1: std_logic_vector(35 downto 0);
  signal delayf1_q_net_x0: std_logic_vector(35 downto 0);
  signal delayf2_q_net_x0: std_logic_vector(35 downto 0);
  signal mux11_y_net_x0: std_logic_vector(35 downto 0);
  signal mux21_y_net_x0: std_logic_vector(35 downto 0);
  signal node1_0_q_net_x1: std_logic_vector(35 downto 0);
  signal node1_1_q_net_x1: std_logic_vector(35 downto 0);
  signal sync_delay_q_net_x3: std_logic;

begin
  ce_1_sg_x128 <= ce_1;
  clk_1_sg_x128 <= clk_1;
  node1_0_q_net_x1 <= in1;
  node1_1_q_net_x1 <= in2;
  sync_delay_q_net_x3 <= sync;
  out1 <= delayb1_q_net_x1;
  out2 <= delayb2_q_net_x1;
  sync_out <= delay0_q_net_x1;

  barrel_switcher_c932dda7b5: entity work.barrel_switcher_entity_2089a09de6
    port map (
      ce_1 => ce_1_sg_x128,
      clk_1 => clk_1_sg_x128,
      in1 => delayf1_q_net_x0,
      in2 => delayf2_q_net_x0,
      sel => counter_op_net_x0,
      sync_in => sync_delay_q_net_x3,
      out1 => mux11_y_net_x0,
      out2 => mux21_y_net_x0,
      sync_out => delay_sync_q_net_x0
    );

  counter: entity work.counter_0009e314f5
    port map (
      ce => ce_1_sg_x128,
      clk => clk_1_sg_x128,
      clr => '0',
      rst(0) => sync_delay_q_net_x3,
      op(0) => counter_op_net_x0
    );

  delay0: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x128,
      clk => clk_1_sg_x128,
      d(0) => delay_sync_q_net_x0,
      en => '1',
      q(0) => delay0_q_net_x1
    );

  delayb1: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x128,
      clk => clk_1_sg_x128,
      d => mux11_y_net_x0,
      en => '1',
      q => delayb1_q_net_x1
    );

  delayb2: entity work.delay_0c0a0420a6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => mux21_y_net_x0,
      q => delayb2_q_net_x1
    );

  delayf1: entity work.delay_0c0a0420a6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => node1_0_q_net_x1,
      q => delayf1_q_net_x0
    );

  delayf2: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x128,
      clk => clk_1_sg_x128,
      d => node1_1_q_net_x1,
      en => '1',
      q => delayf2_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft/fft_unscrambler"

entity fft_unscrambler_entity_5a5b26899c is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_unscrambler_entity_5a5b26899c;

architecture structural of fft_unscrambler_entity_5a5b26899c is
  signal bram0_data_out_net_x1: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x1: std_logic_vector(35 downto 0);
  signal ce_1_sg_x129: std_logic;
  signal clk_1_sg_x129: std_logic;
  signal const_op_net_x1: std_logic;
  signal delay0_q_net_x1: std_logic;
  signal delayb1_q_net_x1: std_logic_vector(35 downto 0);
  signal delayb2_q_net_x1: std_logic_vector(35 downto 0);
  signal node1_0_q_net_x2: std_logic_vector(35 downto 0);
  signal node1_1_q_net_x2: std_logic_vector(35 downto 0);
  signal post_sync_delay_q_net_x2: std_logic;
  signal sync_delay_q_net_x4: std_logic;

begin
  ce_1_sg_x129 <= ce_1;
  clk_1_sg_x129 <= clk_1;
  node1_0_q_net_x2 <= in1;
  node1_1_q_net_x2 <= in2;
  sync_delay_q_net_x4 <= sync;
  out1 <= bram0_data_out_net_x1;
  out2 <= bram1_data_out_net_x1;
  sync_out <= post_sync_delay_q_net_x2;

  const: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => const_op_net_x1
    );

  reorder_4a64b101ea: entity work.reorder_entity_4a64b101ea
    port map (
      ce_1 => ce_1_sg_x129,
      clk_1 => clk_1_sg_x129,
      din0 => delayb1_q_net_x1,
      din1 => delayb2_q_net_x1,
      en => const_op_net_x1,
      sync => delay0_q_net_x1,
      dout0 => bram0_data_out_net_x1,
      dout1 => bram1_data_out_net_x1,
      sync_out => post_sync_delay_q_net_x2
    );

  square_transposer_a972db8b03: entity work.square_transposer_entity_a972db8b03
    port map (
      ce_1 => ce_1_sg_x129,
      clk_1 => clk_1_sg_x129,
      in1 => node1_0_q_net_x2,
      in2 => node1_1_q_net_x2,
      sync => sync_delay_q_net_x4,
      out1 => delayb1_q_net_x1,
      out2 => delayb2_q_net_x1,
      sync_out => delay0_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft"

entity fft_entity_39b4a5d56a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in0: in std_logic_vector(35 downto 0); 
    in1: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out0: out std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0); 
    sync_out: out std_logic
  );
end fft_entity_39b4a5d56a;

architecture structural of fft_entity_39b4a5d56a is
  signal bram0_data_out_net_x2: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x2: std_logic_vector(35 downto 0);
  signal ce_1_sg_x130: std_logic;
  signal clk_1_sg_x130: std_logic;
  signal constant1_op_net_x10: std_logic_vector(31 downto 0);
  signal delay16_q_net_x4: std_logic_vector(35 downto 0);
  signal delay17_q_net_x3: std_logic_vector(35 downto 0);
  signal delay9_q_net_x3: std_logic;
  signal delay_sync_q_net_x6: std_logic;
  signal mux11_y_net_x4: std_logic_vector(35 downto 0);
  signal mux21_y_net_x4: std_logic_vector(35 downto 0);
  signal node1_0_q_net_x2: std_logic_vector(35 downto 0);
  signal node1_1_q_net_x2: std_logic_vector(35 downto 0);
  signal post_sync_delay_q_net_x3: std_logic;
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x4: std_logic;

begin
  ce_1_sg_x130 <= ce_1;
  clk_1_sg_x130 <= clk_1;
  delay17_q_net_x3 <= in0;
  delay16_q_net_x4 <= in1;
  constant1_op_net_x10 <= shift;
  delay9_q_net_x3 <= sync;
  out0 <= bram0_data_out_net_x2;
  out1 <= bram1_data_out_net_x2;
  sync_out <= post_sync_delay_q_net_x3;

  fft_biplex0_b8d0b78258: entity work.fft_biplex0_entity_b8d0b78258
    port map (
      ce_1 => ce_1_sg_x130,
      clk_1 => clk_1_sg_x130,
      pol1 => delay17_q_net_x3,
      pol2 => delay16_q_net_x4,
      shift => constant1_op_net_x10,
      sync => delay9_q_net_x3,
      pol1_out => mux11_y_net_x4,
      pol2_out => mux21_y_net_x4,
      sync_out => delay_sync_q_net_x6
    );

  fft_direct_44fa89ae89: entity work.fft_direct_entity_44fa89ae89
    port map (
      ce_1 => ce_1_sg_x130,
      clk_1 => clk_1_sg_x130,
      in0 => mux11_y_net_x4,
      in1 => mux21_y_net_x4,
      shift => slice_y_net_x0,
      sync => delay_sync_q_net_x6,
      out0 => node1_0_q_net_x2,
      out1 => node1_1_q_net_x2,
      sync_out => sync_delay_q_net_x4
    );

  fft_unscrambler_5a5b26899c: entity work.fft_unscrambler_entity_5a5b26899c
    port map (
      ce_1 => ce_1_sg_x130,
      clk_1 => clk_1_sg_x130,
      in1 => node1_0_q_net_x2,
      in2 => node1_1_q_net_x2,
      sync => sync_delay_q_net_x4,
      out1 => bram0_data_out_net_x2,
      out2 => bram1_data_out_net_x2,
      sync_out => post_sync_delay_q_net_x3
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 8,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant1_op_net_x10,
      y(0) => slice_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft1/fft_unscrambler/reorder"

entity reorder_entity_956c18abc1 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din0: in std_logic_vector(35 downto 0); 
    din1: in std_logic_vector(35 downto 0); 
    en: in std_logic; 
    sync: in std_logic; 
    dout0: out std_logic_vector(35 downto 0); 
    dout1: out std_logic_vector(35 downto 0)
  );
end reorder_entity_956c18abc1;

architecture structural of reorder_entity_956c18abc1 is
  signal bram0_data_out_net_x0: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x1: std_logic_vector(35 downto 0);
  signal ce_1_sg_x250: std_logic;
  signal clk_1_sg_x250: std_logic;
  signal const_op_net_x0: std_logic;
  signal counter_op_net: std_logic_vector(10 downto 0);
  signal delay0_q_net_x0: std_logic;
  signal delay_d0_q_net: std_logic_vector(7 downto 0);
  signal delay_din0_q_net: std_logic_vector(35 downto 0);
  signal delay_din1_q_net: std_logic_vector(35 downto 0);
  signal delay_map1_q_net: std_logic_vector(7 downto 0);
  signal delay_map2_q_net: std_logic_vector(7 downto 0);
  signal delay_map3_q_net: std_logic_vector(7 downto 0);
  signal delay_map4_q_net: std_logic_vector(7 downto 0);
  signal delay_map5_q_net: std_logic_vector(7 downto 0);
  signal delay_map6_q_net: std_logic_vector(7 downto 0);
  signal delay_map7_q_net: std_logic_vector(7 downto 0);
  signal delay_sel_q_net: std_logic_vector(2 downto 0);
  signal delay_we_q_net: std_logic;
  signal delayb1_q_net_x0: std_logic_vector(35 downto 0);
  signal delayb2_q_net_x0: std_logic_vector(35 downto 0);
  signal map1_data_net: std_logic_vector(7 downto 0);
  signal map2_data_net: std_logic_vector(7 downto 0);
  signal map3_data_net: std_logic_vector(7 downto 0);
  signal map4_data_net: std_logic_vector(7 downto 0);
  signal map5_data_net: std_logic_vector(7 downto 0);
  signal map6_data_net: std_logic_vector(7 downto 0);
  signal map7_data_net: std_logic_vector(7 downto 0);
  signal mux_y_net: std_logic_vector(7 downto 0);
  signal slice1_y_net: std_logic_vector(2 downto 0);
  signal slice2_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x250 <= ce_1;
  clk_1_sg_x250 <= clk_1;
  delayb1_q_net_x0 <= din0;
  delayb2_q_net_x0 <= din1;
  const_op_net_x0 <= en;
  delay0_q_net_x0 <= sync;
  dout0 <= bram0_data_out_net_x0;
  dout1 <= bram1_data_out_net_x1;

  bram0: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 36,
      core_name0 => "bmg_33_06133fa01183b95a",
      latency => 2
    )
    port map (
      addr => mux_y_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      data_in => delay_din0_q_net,
      en => "1",
      rst => "0",
      we(0) => delay_we_q_net,
      data_out => bram0_data_out_net_x0
    );

  bram1: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 36,
      core_name0 => "bmg_33_06133fa01183b95a",
      latency => 2
    )
    port map (
      addr => mux_y_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      data_in => delay_din1_q_net,
      en => "1",
      rst => "0",
      we(0) => delay_we_q_net,
      data_out => bram1_data_out_net_x1
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 2047,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_da764ffec3b80b68",
      count_limited => 0,
      op_arith => xlUnsigned,
      op_width => 11
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      clr => '0',
      en(0) => const_op_net_x0,
      rst(0) => delay0_q_net_x0,
      op => counter_op_net
    );

  delay_d0: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => slice2_y_net,
      en => '1',
      q => delay_d0_q_net
    );

  delay_din0: entity work.xldelay
    generic map (
      latency => 8,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => delayb1_q_net_x0,
      en => '1',
      q => delay_din0_q_net
    );

  delay_din1: entity work.xldelay
    generic map (
      latency => 8,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => delayb2_q_net_x0,
      en => '1',
      q => delay_din1_q_net
    );

  delay_map1: entity work.xldelay
    generic map (
      latency => 6,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => map1_data_net,
      en => '1',
      q => delay_map1_q_net
    );

  delay_map2: entity work.xldelay
    generic map (
      latency => 5,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => map2_data_net,
      en => '1',
      q => delay_map2_q_net
    );

  delay_map3: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => map3_data_net,
      en => '1',
      q => delay_map3_q_net
    );

  delay_map4: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => map4_data_net,
      en => '1',
      q => delay_map4_q_net
    );

  delay_map5: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => map5_data_net,
      en => '1',
      q => delay_map5_q_net
    );

  delay_map6: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => map6_data_net,
      en => '1',
      q => delay_map6_q_net
    );

  delay_map7: entity work.delay_423c6c1400
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d => map7_data_net,
      q => delay_map7_q_net
    );

  delay_sel: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 3
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d => slice1_y_net,
      en => '1',
      q => delay_sel_q_net
    );

  delay_we: entity work.xldelay
    generic map (
      latency => 7,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      d(0) => const_op_net_x0,
      en => '1',
      q(0) => delay_we_q_net
    );

  map1: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => slice2_y_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map1_data_net
    );

  map2: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map1_data_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map2_data_net
    );

  map3: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map2_data_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map3_data_net
    );

  map4: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map3_data_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map4_data_net
    );

  map5: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map4_data_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map5_data_net
    );

  map6: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map5_data_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map6_data_net
    );

  map7: entity work.xlsprom_dist
    generic map (
      addr_width => 8,
      c_address_width => 8,
      c_width => 8,
      core_name0 => "dmg_43_e6e3b75fe9b7a583",
      latency => 1
    )
    port map (
      addr => map6_data_net,
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      en => "1",
      data => map7_data_net
    );

  mux: entity work.mux_87d2a53357
    port map (
      ce => ce_1_sg_x250,
      clk => clk_1_sg_x250,
      clr => '0',
      d0 => delay_d0_q_net,
      d1 => delay_map1_q_net,
      d2 => delay_map2_q_net,
      d3 => delay_map3_q_net,
      d4 => delay_map4_q_net,
      d5 => delay_map5_q_net,
      d6 => delay_map6_q_net,
      d7 => delay_map7_q_net,
      sel => delay_sel_q_net,
      y => mux_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 10,
      x_width => 11,
      y_width => 3
    )
    port map (
      x => counter_op_net,
      y => slice1_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 7,
      x_width => 11,
      y_width => 8
    )
    port map (
      x => counter_op_net,
      y => slice2_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft1/fft_unscrambler"

entity fft_unscrambler_entity_b8a7db7523 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(35 downto 0); 
    in2: in std_logic_vector(35 downto 0); 
    sync: in std_logic; 
    out1: out std_logic_vector(35 downto 0); 
    out2: out std_logic_vector(35 downto 0)
  );
end fft_unscrambler_entity_b8a7db7523;

architecture structural of fft_unscrambler_entity_b8a7db7523 is
  signal bram0_data_out_net_x1: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x2: std_logic_vector(35 downto 0);
  signal ce_1_sg_x253: std_logic;
  signal clk_1_sg_x253: std_logic;
  signal const_op_net_x0: std_logic;
  signal delay0_q_net_x1: std_logic;
  signal delayb1_q_net_x1: std_logic_vector(35 downto 0);
  signal delayb2_q_net_x1: std_logic_vector(35 downto 0);
  signal node1_0_q_net_x2: std_logic_vector(35 downto 0);
  signal node1_1_q_net_x2: std_logic_vector(35 downto 0);
  signal sync_delay_q_net_x4: std_logic;

begin
  ce_1_sg_x253 <= ce_1;
  clk_1_sg_x253 <= clk_1;
  node1_0_q_net_x2 <= in1;
  node1_1_q_net_x2 <= in2;
  sync_delay_q_net_x4 <= sync;
  out1 <= bram0_data_out_net_x1;
  out2 <= bram1_data_out_net_x2;

  const: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => const_op_net_x0
    );

  reorder_956c18abc1: entity work.reorder_entity_956c18abc1
    port map (
      ce_1 => ce_1_sg_x253,
      clk_1 => clk_1_sg_x253,
      din0 => delayb1_q_net_x1,
      din1 => delayb2_q_net_x1,
      en => const_op_net_x0,
      sync => delay0_q_net_x1,
      dout0 => bram0_data_out_net_x1,
      dout1 => bram1_data_out_net_x2
    );

  square_transposer_fc9b603177: entity work.square_transposer_entity_a972db8b03
    port map (
      ce_1 => ce_1_sg_x253,
      clk_1 => clk_1_sg_x253,
      in1 => node1_0_q_net_x2,
      in2 => node1_1_q_net_x2,
      sync => sync_delay_q_net_x4,
      out1 => delayb1_q_net_x1,
      out2 => delayb2_q_net_x1,
      sync_out => delay0_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/fft1"

entity fft1_entity_e5227511b0 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in0: in std_logic_vector(35 downto 0); 
    in1: in std_logic_vector(35 downto 0); 
    shift: in std_logic_vector(31 downto 0); 
    sync: in std_logic; 
    out0: out std_logic_vector(35 downto 0); 
    out1: out std_logic_vector(35 downto 0)
  );
end fft1_entity_e5227511b0;

architecture structural of fft1_entity_e5227511b0 is
  signal bram0_data_out_net_x2: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x3: std_logic_vector(35 downto 0);
  signal ce_1_sg_x254: std_logic;
  signal clk_1_sg_x254: std_logic;
  signal constant2_op_net_x10: std_logic_vector(31 downto 0);
  signal delay10_q_net_x3: std_logic;
  signal delay18_q_net_x3: std_logic_vector(35 downto 0);
  signal delay19_q_net_x4: std_logic_vector(35 downto 0);
  signal delay_sync_q_net_x6: std_logic;
  signal mux11_y_net_x4: std_logic_vector(35 downto 0);
  signal mux21_y_net_x4: std_logic_vector(35 downto 0);
  signal node1_0_q_net_x2: std_logic_vector(35 downto 0);
  signal node1_1_q_net_x2: std_logic_vector(35 downto 0);
  signal slice_y_net_x0: std_logic;
  signal sync_delay_q_net_x4: std_logic;

begin
  ce_1_sg_x254 <= ce_1;
  clk_1_sg_x254 <= clk_1;
  delay18_q_net_x3 <= in0;
  delay19_q_net_x4 <= in1;
  constant2_op_net_x10 <= shift;
  delay10_q_net_x3 <= sync;
  out0 <= bram0_data_out_net_x2;
  out1 <= bram1_data_out_net_x3;

  fft_biplex0_5cccd5487f: entity work.fft_biplex0_entity_b8d0b78258
    port map (
      ce_1 => ce_1_sg_x254,
      clk_1 => clk_1_sg_x254,
      pol1 => delay18_q_net_x3,
      pol2 => delay19_q_net_x4,
      shift => constant2_op_net_x10,
      sync => delay10_q_net_x3,
      pol1_out => mux11_y_net_x4,
      pol2_out => mux21_y_net_x4,
      sync_out => delay_sync_q_net_x6
    );

  fft_direct_cb22b02980: entity work.fft_direct_entity_44fa89ae89
    port map (
      ce_1 => ce_1_sg_x254,
      clk_1 => clk_1_sg_x254,
      in0 => mux11_y_net_x4,
      in1 => mux21_y_net_x4,
      shift => slice_y_net_x0,
      sync => delay_sync_q_net_x6,
      out0 => node1_0_q_net_x2,
      out1 => node1_1_q_net_x2,
      sync_out => sync_delay_q_net_x4
    );

  fft_unscrambler_b8a7db7523: entity work.fft_unscrambler_entity_b8a7db7523
    port map (
      ce_1 => ce_1_sg_x254,
      clk_1 => clk_1_sg_x254,
      in1 => node1_0_q_net_x2,
      in2 => node1_1_q_net_x2,
      sync => sync_delay_q_net_x4,
      out1 => bram0_data_out_net_x2,
      out2 => bram1_data_out_net_x3
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 8,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => constant2_op_net_x10,
      y(0) => slice_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_first_tap/delay_bram"

entity delay_bram_entity_859df8fd39 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(23 downto 0); 
    out1: out std_logic_vector(23 downto 0)
  );
end delay_bram_entity_859df8fd39;

architecture structural of delay_bram_entity_859df8fd39 is
  signal ce_1_sg_x255: std_logic;
  signal clk_1_sg_x255: std_logic;
  signal constant2_op_net: std_logic;
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay1_q_net_x1: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x0: std_logic_vector(23 downto 0);

begin
  ce_1_sg_x255 <= ce_1;
  clk_1_sg_x255 <= clk_1;
  delay1_q_net_x1 <= in1;
  out1 <= single_port_ram_data_out_net_x0;

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  counter: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 252,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x255,
      clk => clk_1_sg_x255,
      clr => '0',
      en => "1",
      rst => "0",
      op => counter_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 24,
      core_name0 => "bmg_33_1c6b512a486a4179",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x255,
      clk => clk_1_sg_x255,
      data_in => delay1_q_net_x1,
      en => "1",
      rst => "0",
      we(0) => constant2_op_net,
      data_out => single_port_ram_data_out_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_first_tap/pfb_coeff_gen"

entity pfb_coeff_gen_entity_307cbdd8f8 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    coeff: out std_logic_vector(47 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic
  );
end pfb_coeff_gen_entity_307cbdd8f8;

architecture structural of pfb_coeff_gen_entity_307cbdd8f8 is
  signal ce_1_sg_x256: std_logic;
  signal clk_1_sg_x256: std_logic;
  signal concat_y_net: std_logic_vector(47 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay1_q_net_x0: std_logic;
  signal delay1_q_net_x2: std_logic_vector(23 downto 0);
  signal delay5_q_net_x0: std_logic_vector(23 downto 0);
  signal delay_q_net_x0: std_logic;
  signal register_q_net_x0: std_logic_vector(47 downto 0);
  signal reinterpret1_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret2_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret3_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret4_output_port_net: std_logic_vector(11 downto 0);
  signal rom1_data_net: std_logic_vector(11 downto 0);
  signal rom2_data_net: std_logic_vector(11 downto 0);
  signal rom3_data_net: std_logic_vector(11 downto 0);
  signal rom4_data_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x256 <= ce_1;
  clk_1_sg_x256 <= clk_1;
  delay5_q_net_x0 <= din;
  delay1_q_net_x0 <= sync;
  coeff <= register_q_net_x0;
  dout <= delay1_q_net_x2;
  sync_out <= delay_q_net_x0;

  concat: entity work.concat_08ed6107eb
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterpret1_output_port_net,
      in1 => reinterpret2_output_port_net,
      in2 => reinterpret3_output_port_net,
      in3 => reinterpret4_output_port_net,
      y => concat_y_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      clr => '0',
      en => "1",
      rst(0) => delay1_q_net_x0,
      op => counter_op_net
    );

  delay: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      d(0) => delay1_q_net_x0,
      en => '1',
      q(0) => delay_q_net_x0
    );

  delay1: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 24
    )
    port map (
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      d => delay5_q_net_x0,
      en => '1',
      q => delay1_q_net_x2
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 48,
      init_value => b"000000000000000000000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      d => concat_y_net,
      en => "1",
      rst => "0",
      q => register_q_net_x0
    );

  reinterpret1: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom1_data_net,
      output_port => reinterpret1_output_port_net
    );

  reinterpret2: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom2_data_net,
      output_port => reinterpret2_output_port_net
    );

  reinterpret3: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom3_data_net,
      output_port => reinterpret3_output_port_net
    );

  reinterpret4: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom4_data_net,
      output_port => reinterpret4_output_port_net
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_1d1a16587f3fc0f3",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      en => "1",
      rst => "0",
      data => rom1_data_net
    );

  rom2: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_93af047bc31ed975",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      en => "1",
      rst => "0",
      data => rom2_data_net
    );

  rom3: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_203e27e931eb1cbc",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      en => "1",
      rst => "0",
      data => rom3_data_net
    );

  rom4: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_b8c4b30b3d42cadf",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x256,
      clk => clk_1_sg_x256,
      en => "1",
      rst => "0",
      data => rom4_data_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_first_tap/ri_to_c"

entity ri_to_c_entity_b8de34e185 is
  port (
    im: in std_logic_vector(23 downto 0); 
    re: in std_logic_vector(23 downto 0); 
    c: out std_logic_vector(47 downto 0)
  );
end ri_to_c_entity_b8de34e185;

architecture structural of ri_to_c_entity_b8de34e185 is
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal reinterpret1_output_port_net: std_logic_vector(23 downto 0);
  signal reinterpret_output_port_net: std_logic_vector(23 downto 0);

begin
  mult_p_net_x0 <= im;
  mult1_p_net_x0 <= re;
  c <= concat_y_net_x0;

  concat: entity work.concat_b57c4be2de
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterpret_output_port_net,
      in1 => reinterpret1_output_port_net,
      y => concat_y_net_x0
    );

  reinterpret: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => mult1_p_net_x0,
      output_port => reinterpret_output_port_net
    );

  reinterpret1: entity work.reinterpret_3fb4604c01
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => mult_p_net_x0,
      output_port => reinterpret1_output_port_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_first_tap/sync_delay"

entity sync_delay_entity_9be8e6727f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end sync_delay_entity_9be8e6727f;

architecture structural of sync_delay_entity_9be8e6727f is
  signal ce_1_sg_x257: std_logic;
  signal clk_1_sg_x257: std_logic;
  signal constant1_op_net: std_logic_vector(8 downto 0);
  signal constant2_op_net: std_logic_vector(8 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(8 downto 0);
  signal counter_op_net: std_logic_vector(8 downto 0);
  signal delay_q_net_x1: std_logic;
  signal logical_y_net: std_logic;
  signal mux_y_net_x0: std_logic;
  signal relational1_op_net: std_logic;
  signal relational_op_net: std_logic;

begin
  ce_1_sg_x257 <= ce_1;
  clk_1_sg_x257 <= clk_1;
  delay_q_net_x1 <= in_x0;
  out_x0 <= mux_y_net_x0;

  constant1: entity work.constant_fd85eb7067
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_4a391b9a0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_b4ec9de7d1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_a5266c67e2bfae25",
      op_arith => xlUnsigned,
      op_width => 9
    )
    port map (
      ce => ce_1_sg_x257,
      clk => clk_1_sg_x257,
      clr => '0',
      din => constant2_op_net,
      en(0) => logical_y_net,
      load(0) => delay_q_net_x1,
      rst => "0",
      op => counter_op_net
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x1,
      d1(0) => relational1_op_net,
      y(0) => logical_y_net
    );

  mux: entity work.mux_1bef4ba0e4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net_x1,
      d1(0) => relational_op_net,
      sel(0) => constant3_op_net,
      y(0) => mux_y_net_x0
    );

  relational: entity work.relational_6c3ee657fa
    port map (
      a => constant_op_net,
      b => counter_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_78eac2928d
    port map (
      a => counter_op_net,
      b => constant1_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational1_op_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_first_tap"

entity pol1_in1_first_tap_entity_0976804e8e is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    coeff_out: out std_logic_vector(35 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic; 
    taps_out: out std_logic_vector(47 downto 0)
  );
end pol1_in1_first_tap_entity_0976804e8e;

architecture structural of pol1_in1_first_tap_entity_0976804e8e is
  signal ce_1_sg_x258: std_logic;
  signal clk_1_sg_x258: std_logic;
  signal concat_y_net_x1: std_logic_vector(47 downto 0);
  signal delay1_q_net_x1: std_logic;
  signal delay1_q_net_x2: std_logic_vector(23 downto 0);
  signal delay5_q_net_x1: std_logic_vector(23 downto 0);
  signal delay_q_net_x1: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x1: std_logic;
  signal register_q_net_x0: std_logic_vector(47 downto 0);
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x1: std_logic_vector(23 downto 0);
  signal slice1_y_net_x0: std_logic_vector(35 downto 0);
  signal slice_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x258 <= ce_1;
  clk_1_sg_x258 <= clk_1;
  delay5_q_net_x1 <= din;
  delay1_q_net_x1 <= sync;
  coeff_out <= slice1_y_net_x0;
  dout <= single_port_ram_data_out_net_x1;
  sync_out <= mux_y_net_x1;
  taps_out <= concat_y_net_x1;

  c_to_ri_aed1c7c1fa: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => delay1_q_net_x2,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  delay_bram_859df8fd39: entity work.delay_bram_entity_859df8fd39
    port map (
      ce_1 => ce_1_sg_x258,
      clk_1 => clk_1_sg_x258,
      in1 => delay1_q_net_x2,
      out1 => single_port_ram_data_out_net_x1
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x258,
      clk => clk_1_sg_x258,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x258,
      clk => clk_1_sg_x258,
      clr => '0',
      p => mult1_p_net_x0
    );

  pfb_coeff_gen_307cbdd8f8: entity work.pfb_coeff_gen_entity_307cbdd8f8
    port map (
      ce_1 => ce_1_sg_x258,
      clk_1 => clk_1_sg_x258,
      din => delay5_q_net_x1,
      sync => delay1_q_net_x1,
      coeff => register_q_net_x0,
      dout => delay1_q_net_x2,
      sync_out => delay_q_net_x1
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_y_net,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_b8de34e185: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x1
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 48,
      y_width => 12
    )
    port map (
      x => register_q_net_x0,
      y => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 47,
      x_width => 48,
      y_width => 36
    )
    port map (
      x => register_q_net_x0,
      y => slice1_y_net_x0
    );

  sync_delay_9be8e6727f: entity work.sync_delay_entity_9be8e6727f
    port map (
      ce_1 => ce_1_sg_x258,
      clk_1 => clk_1_sg_x258,
      in_x0 => delay_q_net_x1,
      out_x0 => mux_y_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_last_tap/pfb_add_tree/adder_tree1"

entity adder_tree1_entity_3272365a05 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din1: in std_logic_vector(23 downto 0); 
    din2: in std_logic_vector(23 downto 0); 
    din3: in std_logic_vector(23 downto 0); 
    din4: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    dout: out std_logic_vector(25 downto 0); 
    sync_out: out std_logic
  );
end adder_tree1_entity_3272365a05;

architecture structural of adder_tree1_entity_3272365a05 is
  signal addr1_s_net: std_logic_vector(24 downto 0);
  signal addr2_s_net: std_logic_vector(24 downto 0);
  signal addr3_s_net_x0: std_logic_vector(25 downto 0);
  signal ce_1_sg_x259: std_logic;
  signal clk_1_sg_x259: std_logic;
  signal delay_q_net_x0: std_logic;
  signal reint0_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint1_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint2_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint3_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal sync_delay_q_net_x0: std_logic;

begin
  ce_1_sg_x259 <= ce_1;
  clk_1_sg_x259 <= clk_1;
  reint0_1_output_port_net_x0 <= din1;
  reint1_1_output_port_net_x0 <= din2;
  reint2_1_output_port_net_x0 <= din3;
  reint3_1_output_port_net_x0 <= din4;
  delay_q_net_x0 <= sync;
  dout <= addr3_s_net_x0;
  sync_out <= sync_delay_q_net_x0;

  addr1: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 22,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 22,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 1,
      c_output_width => 25,
      core_name0 => "addsb_11_0_36867e5c7fbbc361",
      extra_registers => 0,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 1,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 22,
      s_width => 25
    )
    port map (
      a => reint0_1_output_port_net_x0,
      b => reint1_1_output_port_net_x0,
      ce => ce_1_sg_x259,
      clk => clk_1_sg_x259,
      clr => '0',
      en => "1",
      s => addr1_s_net
    );

  addr2: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 22,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 22,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 1,
      c_output_width => 25,
      core_name0 => "addsb_11_0_36867e5c7fbbc361",
      extra_registers => 0,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 1,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 22,
      s_width => 25
    )
    port map (
      a => reint2_1_output_port_net_x0,
      b => reint3_1_output_port_net_x0,
      ce => ce_1_sg_x259,
      clk => clk_1_sg_x259,
      clr => '0',
      en => "1",
      s => addr2_s_net
    );

  addr3: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 22,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 22,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 1,
      c_output_width => 26,
      core_name0 => "addsb_11_0_8f8320a8378855a3",
      extra_registers => 0,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 1,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 22,
      s_width => 26
    )
    port map (
      a => addr1_s_net,
      b => addr2_s_net,
      ce => ce_1_sg_x259,
      clk => clk_1_sg_x259,
      clr => '0',
      en => "1",
      s => addr3_s_net_x0
    );

  sync_delay: entity work.delay_e18fb31a3d
    port map (
      ce => ce_1_sg_x259,
      clk => clk_1_sg_x259,
      clr => '0',
      d(0) => delay_q_net_x0,
      q(0) => sync_delay_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_last_tap/pfb_add_tree/adder_tree2"

entity adder_tree2_entity_4bc9f9d933 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din1: in std_logic_vector(23 downto 0); 
    din2: in std_logic_vector(23 downto 0); 
    din3: in std_logic_vector(23 downto 0); 
    din4: in std_logic_vector(23 downto 0); 
    dout: out std_logic_vector(25 downto 0)
  );
end adder_tree2_entity_4bc9f9d933;

architecture structural of adder_tree2_entity_4bc9f9d933 is
  signal addr1_s_net: std_logic_vector(24 downto 0);
  signal addr2_s_net: std_logic_vector(24 downto 0);
  signal addr3_s_net_x0: std_logic_vector(25 downto 0);
  signal ce_1_sg_x260: std_logic;
  signal clk_1_sg_x260: std_logic;
  signal reint0_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint1_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint2_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint3_2_output_port_net_x0: std_logic_vector(23 downto 0);

begin
  ce_1_sg_x260 <= ce_1;
  clk_1_sg_x260 <= clk_1;
  reint0_2_output_port_net_x0 <= din1;
  reint1_2_output_port_net_x0 <= din2;
  reint2_2_output_port_net_x0 <= din3;
  reint3_2_output_port_net_x0 <= din4;
  dout <= addr3_s_net_x0;

  addr1: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 22,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 22,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 1,
      c_output_width => 25,
      core_name0 => "addsb_11_0_36867e5c7fbbc361",
      extra_registers => 0,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 1,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 22,
      s_width => 25
    )
    port map (
      a => reint0_2_output_port_net_x0,
      b => reint1_2_output_port_net_x0,
      ce => ce_1_sg_x260,
      clk => clk_1_sg_x260,
      clr => '0',
      en => "1",
      s => addr1_s_net
    );

  addr2: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 22,
      a_width => 24,
      b_arith => xlSigned,
      b_bin_pt => 22,
      b_width => 24,
      c_has_c_out => 0,
      c_latency => 1,
      c_output_width => 25,
      core_name0 => "addsb_11_0_36867e5c7fbbc361",
      extra_registers => 0,
      full_s_arith => 2,
      full_s_width => 25,
      latency => 1,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 22,
      s_width => 25
    )
    port map (
      a => reint2_2_output_port_net_x0,
      b => reint3_2_output_port_net_x0,
      ce => ce_1_sg_x260,
      clk => clk_1_sg_x260,
      clr => '0',
      en => "1",
      s => addr2_s_net
    );

  addr3: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 22,
      a_width => 25,
      b_arith => xlSigned,
      b_bin_pt => 22,
      b_width => 25,
      c_has_c_out => 0,
      c_latency => 1,
      c_output_width => 26,
      core_name0 => "addsb_11_0_8f8320a8378855a3",
      extra_registers => 0,
      full_s_arith => 2,
      full_s_width => 26,
      latency => 1,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 22,
      s_width => 26
    )
    port map (
      a => addr1_s_net,
      b => addr2_s_net,
      ce => ce_1_sg_x260,
      clk => clk_1_sg_x260,
      clr => '0',
      en => "1",
      s => addr3_s_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_last_tap/pfb_add_tree/ri_to_c"

entity ri_to_c_entity_141ab06f3d is
  port (
    im: in std_logic_vector(11 downto 0); 
    re: in std_logic_vector(11 downto 0); 
    c: out std_logic_vector(23 downto 0)
  );
end ri_to_c_entity_141ab06f3d;

architecture structural of ri_to_c_entity_141ab06f3d is
  signal concat_y_net_x0: std_logic_vector(23 downto 0);
  signal convert1_dout_net_x0: std_logic_vector(11 downto 0);
  signal convert2_dout_net_x0: std_logic_vector(11 downto 0);
  signal force_im_output_port_net: std_logic_vector(11 downto 0);
  signal force_re_output_port_net: std_logic_vector(11 downto 0);

begin
  convert2_dout_net_x0 <= im;
  convert1_dout_net_x0 <= re;
  c <= concat_y_net_x0;

  concat: entity work.concat_6188124172
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => force_re_output_port_net,
      in1 => force_im_output_port_net,
      y => concat_y_net_x0
    );

  force_im: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert2_dout_net_x0,
      output_port => force_im_output_port_net
    );

  force_re: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert1_dout_net_x0,
      output_port => force_re_output_port_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_last_tap/pfb_add_tree"

entity pfb_add_tree_entity_f73f6d7454 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(191 downto 0); 
    sync: in std_logic; 
    dout: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic
  );
end pfb_add_tree_entity_f73f6d7454;

architecture structural of pfb_add_tree_entity_f73f6d7454 is
  signal addr3_s_net_x0: std_logic_vector(25 downto 0);
  signal addr3_s_net_x1: std_logic_vector(25 downto 0);
  signal ce_1_sg_x261: std_logic;
  signal clk_1_sg_x261: std_logic;
  signal concat_y_net_x1: std_logic_vector(191 downto 0);
  signal concat_y_net_x2: std_logic_vector(23 downto 0);
  signal convert1_dout_net_x0: std_logic_vector(11 downto 0);
  signal convert2_dout_net_x0: std_logic_vector(11 downto 0);
  signal delay1_q_net_x0: std_logic;
  signal delay_q_net_x1: std_logic;
  signal reint0_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint0_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint1_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint1_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint2_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint2_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint3_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint3_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal scale1_op_net: std_logic_vector(25 downto 0);
  signal scale2_op_net: std_logic_vector(25 downto 0);
  signal slice0_1_y_net: std_logic_vector(23 downto 0);
  signal slice0_2_y_net: std_logic_vector(23 downto 0);
  signal slice1_1_y_net: std_logic_vector(23 downto 0);
  signal slice1_2_y_net: std_logic_vector(23 downto 0);
  signal slice2_1_y_net: std_logic_vector(23 downto 0);
  signal slice2_2_y_net: std_logic_vector(23 downto 0);
  signal slice3_1_y_net: std_logic_vector(23 downto 0);
  signal slice3_2_y_net: std_logic_vector(23 downto 0);
  signal sync_delay_q_net_x0: std_logic;

begin
  ce_1_sg_x261 <= ce_1;
  clk_1_sg_x261 <= clk_1;
  concat_y_net_x1 <= din;
  delay_q_net_x1 <= sync;
  dout <= concat_y_net_x2;
  sync_out <= delay1_q_net_x0;

  adder_tree1_3272365a05: entity work.adder_tree1_entity_3272365a05
    port map (
      ce_1 => ce_1_sg_x261,
      clk_1 => clk_1_sg_x261,
      din1 => reint0_1_output_port_net_x0,
      din2 => reint1_1_output_port_net_x0,
      din3 => reint2_1_output_port_net_x0,
      din4 => reint3_1_output_port_net_x0,
      sync => delay_q_net_x1,
      dout => addr3_s_net_x0,
      sync_out => sync_delay_q_net_x0
    );

  adder_tree2_4bc9f9d933: entity work.adder_tree2_entity_4bc9f9d933
    port map (
      ce_1 => ce_1_sg_x261,
      clk_1 => clk_1_sg_x261,
      din1 => reint0_2_output_port_net_x0,
      din2 => reint1_2_output_port_net_x0,
      din3 => reint2_2_output_port_net_x0,
      din4 => reint3_2_output_port_net_x0,
      dout => addr3_s_net_x1
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 25,
      din_width => 26,
      dout_arith => 2,
      dout_bin_pt => 11,
      dout_width => 12,
      latency => 1,
      overflow => xlSaturate,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x261,
      clk => clk_1_sg_x261,
      clr => '0',
      din => scale1_op_net,
      dout => convert1_dout_net_x0
    );

  convert2: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 25,
      din_width => 26,
      dout_arith => 2,
      dout_bin_pt => 11,
      dout_width => 12,
      latency => 1,
      overflow => xlSaturate,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x261,
      clk => clk_1_sg_x261,
      clr => '0',
      din => scale2_op_net,
      dout => convert2_dout_net_x0
    );

  delay1: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x261,
      clk => clk_1_sg_x261,
      d(0) => sync_delay_q_net_x0,
      en => '1',
      q(0) => delay1_q_net_x0
    );

  reint0_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice0_1_y_net,
      output_port => reint0_1_output_port_net_x0
    );

  reint0_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice0_2_y_net,
      output_port => reint0_2_output_port_net_x0
    );

  reint1_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_1_y_net,
      output_port => reint1_1_output_port_net_x0
    );

  reint1_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_2_y_net,
      output_port => reint1_2_output_port_net_x0
    );

  reint2_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice2_1_y_net,
      output_port => reint2_1_output_port_net_x0
    );

  reint2_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice2_2_y_net,
      output_port => reint2_2_output_port_net_x0
    );

  reint3_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice3_1_y_net,
      output_port => reint3_1_output_port_net_x0
    );

  reint3_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice3_2_y_net,
      output_port => reint3_2_output_port_net_x0
    );

  ri_to_c_141ab06f3d: entity work.ri_to_c_entity_141ab06f3d
    port map (
      im => convert2_dout_net_x0,
      re => convert1_dout_net_x0,
      c => concat_y_net_x2
    );

  scale1: entity work.scale_f01f7ce486
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => addr3_s_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_f01f7ce486
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => addr3_s_net_x1,
      op => scale2_op_net
    );

  slice0_1: entity work.xlslice
    generic map (
      new_lsb => 168,
      new_msb => 191,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice0_1_y_net
    );

  slice0_2: entity work.xlslice
    generic map (
      new_lsb => 144,
      new_msb => 167,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice0_2_y_net
    );

  slice1_1: entity work.xlslice
    generic map (
      new_lsb => 120,
      new_msb => 143,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice1_1_y_net
    );

  slice1_2: entity work.xlslice
    generic map (
      new_lsb => 96,
      new_msb => 119,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice1_2_y_net
    );

  slice2_1: entity work.xlslice
    generic map (
      new_lsb => 72,
      new_msb => 95,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice2_1_y_net
    );

  slice2_2: entity work.xlslice
    generic map (
      new_lsb => 48,
      new_msb => 71,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice2_2_y_net
    );

  slice3_1: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 47,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice3_1_y_net
    );

  slice3_2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice3_2_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_last_tap"

entity pol1_in1_last_tap_entity_46c95cbeec is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    coeff: in std_logic_vector(11 downto 0); 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    taps: in std_logic_vector(143 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic
  );
end pol1_in1_last_tap_entity_46c95cbeec;

architecture structural of pol1_in1_last_tap_entity_46c95cbeec is
  signal ce_1_sg_x262: std_logic;
  signal clk_1_sg_x262: std_logic;
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal concat_y_net_x1: std_logic_vector(191 downto 0);
  signal concat_y_net_x3: std_logic_vector(143 downto 0);
  signal concat_y_net_x4: std_logic_vector(23 downto 0);
  signal delay1_q_net_x1: std_logic;
  signal delay_q_net_x1: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x0: std_logic;
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x1: std_logic_vector(23 downto 0);
  signal slice1_y_net_x0: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x262 <= ce_1;
  clk_1_sg_x262 <= clk_1;
  slice1_y_net_x0 <= coeff;
  single_port_ram_data_out_net_x1 <= din;
  mux_y_net_x0 <= sync;
  concat_y_net_x3 <= taps;
  dout <= concat_y_net_x4;
  sync_out <= delay1_q_net_x1;

  c_to_ri_41c12fc4da: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => single_port_ram_data_out_net_x1,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  concat: entity work.concat_e3400f48bc
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => concat_y_net_x3,
      y => concat_y_net_x1
    );

  delay: entity work.xldelay
    generic map (
      latency => 2,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x262,
      clk => clk_1_sg_x262,
      d(0) => mux_y_net_x0,
      en => '1',
      q(0) => delay_q_net_x1
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x262,
      clk => clk_1_sg_x262,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x262,
      clk => clk_1_sg_x262,
      clr => '0',
      p => mult1_p_net_x0
    );

  pfb_add_tree_f73f6d7454: entity work.pfb_add_tree_entity_f73f6d7454
    port map (
      ce_1 => ce_1_sg_x262,
      clk_1 => clk_1_sg_x262,
      din => concat_y_net_x1,
      sync => delay_q_net_x1,
      dout => concat_y_net_x4,
      sync_out => delay1_q_net_x1
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_y_net_x0,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_a36773eb5e: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_tap2"

entity pol1_in1_tap2_entity_7c77e909f3 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    coeff: in std_logic_vector(35 downto 0); 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    taps: in std_logic_vector(47 downto 0); 
    coeff_out: out std_logic_vector(23 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic; 
    taps_out: out std_logic_vector(95 downto 0)
  );
end pol1_in1_tap2_entity_7c77e909f3;

architecture structural of pol1_in1_tap2_entity_7c77e909f3 is
  signal ce_1_sg_x265: std_logic;
  signal clk_1_sg_x265: std_logic;
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal concat_y_net_x2: std_logic_vector(47 downto 0);
  signal concat_y_net_x3: std_logic_vector(95 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x3: std_logic;
  signal mux_y_net_x4: std_logic;
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x4: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x5: std_logic_vector(23 downto 0);
  signal slice1_y_net_x1: std_logic_vector(35 downto 0);
  signal slice1_y_net_x2: std_logic_vector(23 downto 0);
  signal slice_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x265 <= ce_1;
  clk_1_sg_x265 <= clk_1;
  slice1_y_net_x1 <= coeff;
  single_port_ram_data_out_net_x4 <= din;
  mux_y_net_x3 <= sync;
  concat_y_net_x2 <= taps;
  coeff_out <= slice1_y_net_x2;
  dout <= single_port_ram_data_out_net_x5;
  sync_out <= mux_y_net_x4;
  taps_out <= concat_y_net_x3;

  c_to_ri_58ec69cb81: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => single_port_ram_data_out_net_x4,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  concat: entity work.concat_d2bebd35da
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => concat_y_net_x2,
      y => concat_y_net_x3
    );

  delay_bram_f43bf5d5d7: entity work.delay_bram_entity_859df8fd39
    port map (
      ce_1 => ce_1_sg_x265,
      clk_1 => clk_1_sg_x265,
      in1 => single_port_ram_data_out_net_x4,
      out1 => single_port_ram_data_out_net_x5
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x265,
      clk => clk_1_sg_x265,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x265,
      clk => clk_1_sg_x265,
      clr => '0',
      p => mult1_p_net_x0
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_y_net,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_60cf3a271a: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 36,
      y_width => 12
    )
    port map (
      x => slice1_y_net_x1,
      y => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 35,
      x_width => 36,
      y_width => 24
    )
    port map (
      x => slice1_y_net_x1,
      y => slice1_y_net_x2
    );

  sync_delay_ca2a712015: entity work.sync_delay_entity_9be8e6727f
    port map (
      ce_1 => ce_1_sg_x265,
      clk_1 => clk_1_sg_x265,
      in_x0 => mux_y_net_x3,
      out_x0 => mux_y_net_x4
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in1_tap3"

entity pol1_in1_tap3_entity_f42e83e65f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    coeff: in std_logic_vector(23 downto 0); 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    taps: in std_logic_vector(95 downto 0); 
    coeff_out: out std_logic_vector(11 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic; 
    taps_out: out std_logic_vector(143 downto 0)
  );
end pol1_in1_tap3_entity_f42e83e65f;

architecture structural of pol1_in1_tap3_entity_f42e83e65f is
  signal ce_1_sg_x268: std_logic;
  signal clk_1_sg_x268: std_logic;
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal concat_y_net_x5: std_logic_vector(95 downto 0);
  signal concat_y_net_x6: std_logic_vector(143 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal mux_y_net_x2: std_logic;
  signal mux_y_net_x6: std_logic;
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x3: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x8: std_logic_vector(23 downto 0);
  signal slice1_y_net_x3: std_logic_vector(23 downto 0);
  signal slice1_y_net_x4: std_logic_vector(11 downto 0);
  signal slice_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x268 <= ce_1;
  clk_1_sg_x268 <= clk_1;
  slice1_y_net_x3 <= coeff;
  single_port_ram_data_out_net_x8 <= din;
  mux_y_net_x6 <= sync;
  concat_y_net_x5 <= taps;
  coeff_out <= slice1_y_net_x4;
  dout <= single_port_ram_data_out_net_x3;
  sync_out <= mux_y_net_x2;
  taps_out <= concat_y_net_x6;

  c_to_ri_e5995c06e2: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => single_port_ram_data_out_net_x8,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  concat: entity work.concat_c8cd4b9ca8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => concat_y_net_x5,
      y => concat_y_net_x6
    );

  delay_bram_067b4fc3a6: entity work.delay_bram_entity_859df8fd39
    port map (
      ce_1 => ce_1_sg_x268,
      clk_1 => clk_1_sg_x268,
      in1 => single_port_ram_data_out_net_x8,
      out1 => single_port_ram_data_out_net_x3
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x268,
      clk => clk_1_sg_x268,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x268,
      clk => clk_1_sg_x268,
      clr => '0',
      p => mult1_p_net_x0
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_y_net,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_ddf065b87b: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => slice1_y_net_x3,
      y => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => slice1_y_net_x3,
      y => slice1_y_net_x4
    );

  sync_delay_5d3a40f787: entity work.sync_delay_entity_9be8e6727f
    port map (
      ce_1 => ce_1_sg_x268,
      clk_1 => clk_1_sg_x268,
      in_x0 => mux_y_net_x6,
      out_x0 => mux_y_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in2_first_tap/pfb_coeff_gen"

entity pfb_coeff_gen_entity_e54e9f543f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    coeff: out std_logic_vector(47 downto 0); 
    dout: out std_logic_vector(23 downto 0)
  );
end pfb_coeff_gen_entity_e54e9f543f;

architecture structural of pfb_coeff_gen_entity_e54e9f543f is
  signal ce_1_sg_x270: std_logic;
  signal clk_1_sg_x270: std_logic;
  signal concat_y_net: std_logic_vector(47 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay1_q_net_x3: std_logic;
  signal delay1_q_net_x4: std_logic_vector(23 downto 0);
  signal delay8_q_net_x0: std_logic_vector(23 downto 0);
  signal register_q_net_x0: std_logic_vector(47 downto 0);
  signal reinterpret1_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret2_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret3_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret4_output_port_net: std_logic_vector(11 downto 0);
  signal rom1_data_net: std_logic_vector(11 downto 0);
  signal rom2_data_net: std_logic_vector(11 downto 0);
  signal rom3_data_net: std_logic_vector(11 downto 0);
  signal rom4_data_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x270 <= ce_1;
  clk_1_sg_x270 <= clk_1;
  delay8_q_net_x0 <= din;
  delay1_q_net_x3 <= sync;
  coeff <= register_q_net_x0;
  dout <= delay1_q_net_x4;

  concat: entity work.concat_08ed6107eb
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => reinterpret1_output_port_net,
      in1 => reinterpret2_output_port_net,
      in2 => reinterpret3_output_port_net,
      in3 => reinterpret4_output_port_net,
      y => concat_y_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      clr => '0',
      en => "1",
      rst(0) => delay1_q_net_x3,
      op => counter_op_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 4,
      reg_retiming => 0,
      width => 24
    )
    port map (
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      d => delay8_q_net_x0,
      en => '1',
      q => delay1_q_net_x4
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 48,
      init_value => b"000000000000000000000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      d => concat_y_net,
      en => "1",
      rst => "0",
      q => register_q_net_x0
    );

  reinterpret1: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom1_data_net,
      output_port => reinterpret1_output_port_net
    );

  reinterpret2: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom2_data_net,
      output_port => reinterpret2_output_port_net
    );

  reinterpret3: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom3_data_net,
      output_port => reinterpret3_output_port_net
    );

  reinterpret4: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => rom4_data_net,
      output_port => reinterpret4_output_port_net
    );

  rom1: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_abda72d904723423",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      en => "1",
      rst => "0",
      data => rom1_data_net
    );

  rom2: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_5195d5d3f5dec7f3",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      en => "1",
      rst => "0",
      data => rom2_data_net
    );

  rom3: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_2272a8ec1c0cc938",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      en => "1",
      rst => "0",
      data => rom3_data_net
    );

  rom4: entity work.xlsprom
    generic map (
      c_address_width => 8,
      c_width => 12,
      core_name0 => "bmg_33_3dc44663493e5141",
      latency => 2
    )
    port map (
      addr => counter_op_net,
      ce => ce_1_sg_x270,
      clk => clk_1_sg_x270,
      en => "1",
      rst => "0",
      data => rom4_data_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in2_first_tap"

entity pol1_in2_first_tap_entity_77cc29e530 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    coeff_out: out std_logic_vector(35 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    taps_out: out std_logic_vector(47 downto 0)
  );
end pol1_in2_first_tap_entity_77cc29e530;

architecture structural of pol1_in2_first_tap_entity_77cc29e530 is
  signal ce_1_sg_x271: std_logic;
  signal clk_1_sg_x271: std_logic;
  signal concat_y_net_x1: std_logic_vector(47 downto 0);
  signal delay1_q_net_x4: std_logic_vector(23 downto 0);
  signal delay1_q_net_x5: std_logic;
  signal delay8_q_net_x1: std_logic_vector(23 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal register_q_net_x0: std_logic_vector(47 downto 0);
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x1: std_logic_vector(23 downto 0);
  signal slice1_y_net_x0: std_logic_vector(35 downto 0);
  signal slice_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x271 <= ce_1;
  clk_1_sg_x271 <= clk_1;
  delay8_q_net_x1 <= din;
  delay1_q_net_x5 <= sync;
  coeff_out <= slice1_y_net_x0;
  dout <= single_port_ram_data_out_net_x1;
  taps_out <= concat_y_net_x1;

  c_to_ri_1383f21ffe: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => delay1_q_net_x4,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  delay_bram_3a4423408d: entity work.delay_bram_entity_859df8fd39
    port map (
      ce_1 => ce_1_sg_x271,
      clk_1 => clk_1_sg_x271,
      in1 => delay1_q_net_x4,
      out1 => single_port_ram_data_out_net_x1
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x271,
      clk => clk_1_sg_x271,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x271,
      clk => clk_1_sg_x271,
      clr => '0',
      p => mult1_p_net_x0
    );

  pfb_coeff_gen_e54e9f543f: entity work.pfb_coeff_gen_entity_e54e9f543f
    port map (
      ce_1 => ce_1_sg_x271,
      clk_1 => clk_1_sg_x271,
      din => delay8_q_net_x1,
      sync => delay1_q_net_x5,
      coeff => register_q_net_x0,
      dout => delay1_q_net_x4
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_y_net,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_28592b4a86: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x1
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 48,
      y_width => 12
    )
    port map (
      x => register_q_net_x0,
      y => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 47,
      x_width => 48,
      y_width => 36
    )
    port map (
      x => register_q_net_x0,
      y => slice1_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in2_last_tap/pfb_add_tree"

entity pfb_add_tree_entity_3957282db4 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    din: in std_logic_vector(191 downto 0); 
    dout: out std_logic_vector(23 downto 0)
  );
end pfb_add_tree_entity_3957282db4;

architecture structural of pfb_add_tree_entity_3957282db4 is
  signal addr3_s_net_x0: std_logic_vector(25 downto 0);
  signal addr3_s_net_x1: std_logic_vector(25 downto 0);
  signal ce_1_sg_x274: std_logic;
  signal clk_1_sg_x274: std_logic;
  signal concat_y_net_x1: std_logic_vector(191 downto 0);
  signal concat_y_net_x2: std_logic_vector(23 downto 0);
  signal convert1_dout_net_x0: std_logic_vector(11 downto 0);
  signal convert2_dout_net_x0: std_logic_vector(11 downto 0);
  signal reint0_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint0_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint1_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint1_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint2_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint2_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint3_1_output_port_net_x0: std_logic_vector(23 downto 0);
  signal reint3_2_output_port_net_x0: std_logic_vector(23 downto 0);
  signal scale1_op_net: std_logic_vector(25 downto 0);
  signal scale2_op_net: std_logic_vector(25 downto 0);
  signal slice0_1_y_net: std_logic_vector(23 downto 0);
  signal slice0_2_y_net: std_logic_vector(23 downto 0);
  signal slice1_1_y_net: std_logic_vector(23 downto 0);
  signal slice1_2_y_net: std_logic_vector(23 downto 0);
  signal slice2_1_y_net: std_logic_vector(23 downto 0);
  signal slice2_2_y_net: std_logic_vector(23 downto 0);
  signal slice3_1_y_net: std_logic_vector(23 downto 0);
  signal slice3_2_y_net: std_logic_vector(23 downto 0);

begin
  ce_1_sg_x274 <= ce_1;
  clk_1_sg_x274 <= clk_1;
  concat_y_net_x1 <= din;
  dout <= concat_y_net_x2;

  adder_tree1_39ac89dc19: entity work.adder_tree2_entity_4bc9f9d933
    port map (
      ce_1 => ce_1_sg_x274,
      clk_1 => clk_1_sg_x274,
      din1 => reint0_1_output_port_net_x0,
      din2 => reint1_1_output_port_net_x0,
      din3 => reint2_1_output_port_net_x0,
      din4 => reint3_1_output_port_net_x0,
      dout => addr3_s_net_x0
    );

  adder_tree2_338a20bc58: entity work.adder_tree2_entity_4bc9f9d933
    port map (
      ce_1 => ce_1_sg_x274,
      clk_1 => clk_1_sg_x274,
      din1 => reint0_2_output_port_net_x0,
      din2 => reint1_2_output_port_net_x0,
      din3 => reint2_2_output_port_net_x0,
      din4 => reint3_2_output_port_net_x0,
      dout => addr3_s_net_x1
    );

  convert1: entity work.xlconvert_pipeline
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 25,
      din_width => 26,
      dout_arith => 2,
      dout_bin_pt => 11,
      dout_width => 12,
      latency => 1,
      overflow => xlSaturate,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x274,
      clk => clk_1_sg_x274,
      clr => '0',
      din => scale1_op_net,
      dout => convert1_dout_net_x0
    );

  convert2: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 25,
      din_width => 26,
      dout_arith => 2,
      dout_bin_pt => 11,
      dout_width => 12,
      latency => 1,
      overflow => xlSaturate,
      quantization => xlTruncate
    )
    port map (
      ce => ce_1_sg_x274,
      clk => clk_1_sg_x274,
      clr => '0',
      din => scale2_op_net,
      dout => convert2_dout_net_x0
    );

  reint0_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice0_1_y_net,
      output_port => reint0_1_output_port_net_x0
    );

  reint0_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice0_2_y_net,
      output_port => reint0_2_output_port_net_x0
    );

  reint1_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_1_y_net,
      output_port => reint1_1_output_port_net_x0
    );

  reint1_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_2_y_net,
      output_port => reint1_2_output_port_net_x0
    );

  reint2_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice2_1_y_net,
      output_port => reint2_1_output_port_net_x0
    );

  reint2_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice2_2_y_net,
      output_port => reint2_2_output_port_net_x0
    );

  reint3_1: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice3_1_y_net,
      output_port => reint3_1_output_port_net_x0
    );

  reint3_2: entity work.reinterpret_4bf1ad328a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice3_2_y_net,
      output_port => reint3_2_output_port_net_x0
    );

  ri_to_c_18298a111f: entity work.ri_to_c_entity_141ab06f3d
    port map (
      im => convert2_dout_net_x0,
      re => convert1_dout_net_x0,
      c => concat_y_net_x2
    );

  scale1: entity work.scale_f01f7ce486
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => addr3_s_net_x0,
      op => scale1_op_net
    );

  scale2: entity work.scale_f01f7ce486
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      ip => addr3_s_net_x1,
      op => scale2_op_net
    );

  slice0_1: entity work.xlslice
    generic map (
      new_lsb => 168,
      new_msb => 191,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice0_1_y_net
    );

  slice0_2: entity work.xlslice
    generic map (
      new_lsb => 144,
      new_msb => 167,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice0_2_y_net
    );

  slice1_1: entity work.xlslice
    generic map (
      new_lsb => 120,
      new_msb => 143,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice1_1_y_net
    );

  slice1_2: entity work.xlslice
    generic map (
      new_lsb => 96,
      new_msb => 119,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice1_2_y_net
    );

  slice2_1: entity work.xlslice
    generic map (
      new_lsb => 72,
      new_msb => 95,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice2_1_y_net
    );

  slice2_2: entity work.xlslice
    generic map (
      new_lsb => 48,
      new_msb => 71,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice2_2_y_net
    );

  slice3_1: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 47,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice3_1_y_net
    );

  slice3_2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 23,
      x_width => 192,
      y_width => 24
    )
    port map (
      x => concat_y_net_x1,
      y => slice3_2_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in2_last_tap"

entity pol1_in2_last_tap_entity_470d188f99 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    coeff: in std_logic_vector(11 downto 0); 
    din: in std_logic_vector(23 downto 0); 
    taps: in std_logic_vector(143 downto 0); 
    dout: out std_logic_vector(23 downto 0)
  );
end pol1_in2_last_tap_entity_470d188f99;

architecture structural of pol1_in2_last_tap_entity_470d188f99 is
  signal ce_1_sg_x275: std_logic;
  signal clk_1_sg_x275: std_logic;
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal concat_y_net_x1: std_logic_vector(191 downto 0);
  signal concat_y_net_x3: std_logic_vector(143 downto 0);
  signal concat_y_net_x4: std_logic_vector(23 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x1: std_logic_vector(23 downto 0);
  signal slice1_y_net_x0: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x275 <= ce_1;
  clk_1_sg_x275 <= clk_1;
  slice1_y_net_x0 <= coeff;
  single_port_ram_data_out_net_x1 <= din;
  concat_y_net_x3 <= taps;
  dout <= concat_y_net_x4;

  c_to_ri_c1d43258c1: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => single_port_ram_data_out_net_x1,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  concat: entity work.concat_e3400f48bc
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => concat_y_net_x3,
      y => concat_y_net_x1
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x275,
      clk => clk_1_sg_x275,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x275,
      clk => clk_1_sg_x275,
      clr => '0',
      p => mult1_p_net_x0
    );

  pfb_add_tree_3957282db4: entity work.pfb_add_tree_entity_3957282db4
    port map (
      ce_1 => ce_1_sg_x275,
      clk_1 => clk_1_sg_x275,
      din => concat_y_net_x1,
      dout => concat_y_net_x4
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_y_net_x0,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_6435d0f585: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in2_tap2"

entity pol1_in2_tap2_entity_b7828474cf is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    coeff: in std_logic_vector(35 downto 0); 
    din: in std_logic_vector(23 downto 0); 
    taps: in std_logic_vector(47 downto 0); 
    coeff_out: out std_logic_vector(23 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    taps_out: out std_logic_vector(95 downto 0)
  );
end pol1_in2_tap2_entity_b7828474cf;

architecture structural of pol1_in2_tap2_entity_b7828474cf is
  signal ce_1_sg_x277: std_logic;
  signal clk_1_sg_x277: std_logic;
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal concat_y_net_x2: std_logic_vector(47 downto 0);
  signal concat_y_net_x3: std_logic_vector(95 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x4: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x5: std_logic_vector(23 downto 0);
  signal slice1_y_net_x1: std_logic_vector(35 downto 0);
  signal slice1_y_net_x2: std_logic_vector(23 downto 0);
  signal slice_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x277 <= ce_1;
  clk_1_sg_x277 <= clk_1;
  slice1_y_net_x1 <= coeff;
  single_port_ram_data_out_net_x4 <= din;
  concat_y_net_x2 <= taps;
  coeff_out <= slice1_y_net_x2;
  dout <= single_port_ram_data_out_net_x5;
  taps_out <= concat_y_net_x3;

  c_to_ri_ed0af16ded: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => single_port_ram_data_out_net_x4,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  concat: entity work.concat_d2bebd35da
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => concat_y_net_x2,
      y => concat_y_net_x3
    );

  delay_bram_be4c6f6d4a: entity work.delay_bram_entity_859df8fd39
    port map (
      ce_1 => ce_1_sg_x277,
      clk_1 => clk_1_sg_x277,
      in1 => single_port_ram_data_out_net_x4,
      out1 => single_port_ram_data_out_net_x5
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x277,
      clk => clk_1_sg_x277,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x277,
      clk => clk_1_sg_x277,
      clr => '0',
      p => mult1_p_net_x0
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_y_net,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_7693cd436d: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 36,
      y_width => 12
    )
    port map (
      x => slice1_y_net_x1,
      y => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 35,
      x_width => 36,
      y_width => 24
    )
    port map (
      x => slice1_y_net_x1,
      y => slice1_y_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir/pol1_in2_tap3"

entity pol1_in2_tap3_entity_393b51545b is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    coeff: in std_logic_vector(23 downto 0); 
    din: in std_logic_vector(23 downto 0); 
    taps: in std_logic_vector(95 downto 0); 
    coeff_out: out std_logic_vector(11 downto 0); 
    dout: out std_logic_vector(23 downto 0); 
    taps_out: out std_logic_vector(143 downto 0)
  );
end pol1_in2_tap3_entity_393b51545b;

architecture structural of pol1_in2_tap3_entity_393b51545b is
  signal ce_1_sg_x279: std_logic;
  signal clk_1_sg_x279: std_logic;
  signal concat_y_net_x0: std_logic_vector(47 downto 0);
  signal concat_y_net_x5: std_logic_vector(95 downto 0);
  signal concat_y_net_x6: std_logic_vector(143 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(11 downto 0);
  signal mult1_p_net_x0: std_logic_vector(23 downto 0);
  signal mult_p_net_x0: std_logic_vector(23 downto 0);
  signal reinterpret_output_port_net: std_logic_vector(11 downto 0);
  signal single_port_ram_data_out_net_x3: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x8: std_logic_vector(23 downto 0);
  signal slice1_y_net_x3: std_logic_vector(23 downto 0);
  signal slice1_y_net_x4: std_logic_vector(11 downto 0);
  signal slice_y_net: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x279 <= ce_1;
  clk_1_sg_x279 <= clk_1;
  slice1_y_net_x3 <= coeff;
  single_port_ram_data_out_net_x8 <= din;
  concat_y_net_x5 <= taps;
  coeff_out <= slice1_y_net_x4;
  dout <= single_port_ram_data_out_net_x3;
  taps_out <= concat_y_net_x6;

  c_to_ri_e8860cdf99: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => single_port_ram_data_out_net_x8,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  concat: entity work.concat_c8cd4b9ca8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => concat_y_net_x5,
      y => concat_y_net_x6
    );

  delay_bram_84778dc82e: entity work.delay_bram_entity_859df8fd39
    port map (
      ce_1 => ce_1_sg_x279,
      clk_1 => clk_1_sg_x279,
      in1 => single_port_ram_data_out_net_x8,
      out1 => single_port_ram_data_out_net_x3
    );

  mult: entity work.mult_24652a115f
    port map (
      a => force_im_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x279,
      clk => clk_1_sg_x279,
      clr => '0',
      p => mult_p_net_x0
    );

  mult1: entity work.mult_24652a115f
    port map (
      a => force_re_output_port_net_x0,
      b => reinterpret_output_port_net,
      ce => ce_1_sg_x279,
      clk => clk_1_sg_x279,
      clr => '0',
      p => mult1_p_net_x0
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_y_net,
      output_port => reinterpret_output_port_net
    );

  ri_to_c_f724991c5b: entity work.ri_to_c_entity_b8de34e185
    port map (
      im => mult_p_net_x0,
      re => mult1_p_net_x0,
      c => concat_y_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 11,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => slice1_y_net_x3,
      y => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 23,
      x_width => 24,
      y_width => 12
    )
    port map (
      x => slice1_y_net_x3,
      y => slice1_y_net_x4
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pfb_fir"

entity pfb_fir_entity_5700d3bdc2 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pol1_in1: in std_logic_vector(23 downto 0); 
    pol1_in2: in std_logic_vector(23 downto 0); 
    sync: in std_logic; 
    pol1_out1: out std_logic_vector(23 downto 0); 
    pol1_out2: out std_logic_vector(23 downto 0); 
    sync_out: out std_logic
  );
end pfb_fir_entity_5700d3bdc2;

architecture structural of pfb_fir_entity_5700d3bdc2 is
  signal ce_1_sg_x280: std_logic;
  signal clk_1_sg_x280: std_logic;
  signal concat_y_net_x10: std_logic_vector(143 downto 0);
  signal concat_y_net_x11: std_logic_vector(23 downto 0);
  signal concat_y_net_x12: std_logic_vector(23 downto 0);
  signal concat_y_net_x2: std_logic_vector(47 downto 0);
  signal concat_y_net_x5: std_logic_vector(95 downto 0);
  signal concat_y_net_x6: std_logic_vector(143 downto 0);
  signal concat_y_net_x7: std_logic_vector(47 downto 0);
  signal concat_y_net_x9: std_logic_vector(95 downto 0);
  signal delay1_q_net_x2: std_logic;
  signal delay1_q_net_x6: std_logic;
  signal delay5_q_net_x2: std_logic_vector(23 downto 0);
  signal delay8_q_net_x2: std_logic_vector(23 downto 0);
  signal mux_y_net_x2: std_logic;
  signal mux_y_net_x3: std_logic;
  signal mux_y_net_x6: std_logic;
  signal single_port_ram_data_out_net_x3: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x4: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x5: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x6: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x8: std_logic_vector(23 downto 0);
  signal single_port_ram_data_out_net_x9: std_logic_vector(23 downto 0);
  signal slice1_y_net_x1: std_logic_vector(35 downto 0);
  signal slice1_y_net_x3: std_logic_vector(23 downto 0);
  signal slice1_y_net_x4: std_logic_vector(11 downto 0);
  signal slice1_y_net_x5: std_logic_vector(35 downto 0);
  signal slice1_y_net_x6: std_logic_vector(23 downto 0);
  signal slice1_y_net_x7: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x280 <= ce_1;
  clk_1_sg_x280 <= clk_1;
  delay5_q_net_x2 <= pol1_in1;
  delay8_q_net_x2 <= pol1_in2;
  delay1_q_net_x6 <= sync;
  pol1_out1 <= concat_y_net_x11;
  pol1_out2 <= concat_y_net_x12;
  sync_out <= delay1_q_net_x2;

  pol1_in1_first_tap_0976804e8e: entity work.pol1_in1_first_tap_entity_0976804e8e
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      din => delay5_q_net_x2,
      sync => delay1_q_net_x6,
      coeff_out => slice1_y_net_x1,
      dout => single_port_ram_data_out_net_x4,
      sync_out => mux_y_net_x3,
      taps_out => concat_y_net_x2
    );

  pol1_in1_last_tap_46c95cbeec: entity work.pol1_in1_last_tap_entity_46c95cbeec
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      coeff => slice1_y_net_x4,
      din => single_port_ram_data_out_net_x3,
      sync => mux_y_net_x2,
      taps => concat_y_net_x6,
      dout => concat_y_net_x11,
      sync_out => delay1_q_net_x2
    );

  pol1_in1_tap2_7c77e909f3: entity work.pol1_in1_tap2_entity_7c77e909f3
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      coeff => slice1_y_net_x1,
      din => single_port_ram_data_out_net_x4,
      sync => mux_y_net_x3,
      taps => concat_y_net_x2,
      coeff_out => slice1_y_net_x3,
      dout => single_port_ram_data_out_net_x8,
      sync_out => mux_y_net_x6,
      taps_out => concat_y_net_x5
    );

  pol1_in1_tap3_f42e83e65f: entity work.pol1_in1_tap3_entity_f42e83e65f
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      coeff => slice1_y_net_x3,
      din => single_port_ram_data_out_net_x8,
      sync => mux_y_net_x6,
      taps => concat_y_net_x5,
      coeff_out => slice1_y_net_x4,
      dout => single_port_ram_data_out_net_x3,
      sync_out => mux_y_net_x2,
      taps_out => concat_y_net_x6
    );

  pol1_in2_first_tap_77cc29e530: entity work.pol1_in2_first_tap_entity_77cc29e530
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      din => delay8_q_net_x2,
      sync => delay1_q_net_x6,
      coeff_out => slice1_y_net_x5,
      dout => single_port_ram_data_out_net_x5,
      taps_out => concat_y_net_x7
    );

  pol1_in2_last_tap_470d188f99: entity work.pol1_in2_last_tap_entity_470d188f99
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      coeff => slice1_y_net_x7,
      din => single_port_ram_data_out_net_x6,
      taps => concat_y_net_x10,
      dout => concat_y_net_x12
    );

  pol1_in2_tap2_b7828474cf: entity work.pol1_in2_tap2_entity_b7828474cf
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      coeff => slice1_y_net_x5,
      din => single_port_ram_data_out_net_x5,
      taps => concat_y_net_x7,
      coeff_out => slice1_y_net_x6,
      dout => single_port_ram_data_out_net_x9,
      taps_out => concat_y_net_x9
    );

  pol1_in2_tap3_393b51545b: entity work.pol1_in2_tap3_entity_393b51545b
    port map (
      ce_1 => ce_1_sg_x280,
      clk_1 => clk_1_sg_x280,
      coeff => slice1_y_net_x6,
      din => single_port_ram_data_out_net_x9,
      taps => concat_y_net_x9,
      coeff_out => slice1_y_net_x7,
      dout => single_port_ram_data_out_net_x6,
      taps_out => concat_y_net_x10
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pipeline1"

entity pipeline1_entity_ca64142bd2 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(23 downto 0); 
    q: out std_logic_vector(23 downto 0)
  );
end pipeline1_entity_ca64142bd2;

architecture structural of pipeline1_entity_ca64142bd2 is
  signal ce_1_sg_x307: std_logic;
  signal clk_1_sg_x307: std_logic;
  signal concat_y_net_x12: std_logic_vector(23 downto 0);
  signal register0_q_net: std_logic_vector(23 downto 0);
  signal register1_q_net_x1: std_logic_vector(23 downto 0);

begin
  ce_1_sg_x307 <= ce_1;
  clk_1_sg_x307 <= clk_1;
  concat_y_net_x12 <= d;
  q <= register1_q_net_x1;

  register0: entity work.xlregister
    generic map (
      d_width => 24,
      init_value => b"000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x307,
      clk => clk_1_sg_x307,
      d => concat_y_net_x12,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 24,
      init_value => b"000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x307,
      clk => clk_1_sg_x307,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/pipeline3"

entity pipeline3_entity_e232fb1c42 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic; 
    q: out std_logic
  );
end pipeline3_entity_e232fb1c42;

architecture structural of pipeline3_entity_e232fb1c42 is
  signal ce_1_sg_x309: std_logic;
  signal clk_1_sg_x309: std_logic;
  signal delay1_q_net_x3: std_logic;
  signal register0_q_net: std_logic;
  signal register1_q_net_x0: std_logic;

begin
  ce_1_sg_x309 <= ce_1;
  clk_1_sg_x309 <= clk_1;
  delay1_q_net_x3 <= d;
  q <= register1_q_net_x0;

  register0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x309,
      clk => clk_1_sg_x309,
      d(0) => delay1_q_net_x3,
      en => "1",
      rst => "0",
      q(0) => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x309,
      clk => clk_1_sg_x309,
      d(0) => register0_q_net,
      en => "1",
      rst => "0",
      q(0) => register1_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB/ri_to_c12"

entity ri_to_c12_entity_872d2867a4 is
  port (
    im: in std_logic_vector(17 downto 0); 
    re: in std_logic_vector(17 downto 0); 
    c: out std_logic_vector(35 downto 0)
  );
end ri_to_c12_entity_872d2867a4;

architecture structural of ri_to_c12_entity_872d2867a4 is
  signal concat_y_net_x0: std_logic_vector(35 downto 0);
  signal force_im_output_port_net: std_logic_vector(17 downto 0);
  signal force_re_output_port_net: std_logic_vector(17 downto 0);
  signal reinterpret13_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret9_output_port_net_x0: std_logic_vector(17 downto 0);

begin
  reinterpret9_output_port_net_x0 <= im;
  reinterpret13_output_port_net_x0 <= re;
  c <= concat_y_net_x0;

  concat: entity work.concat_b198bd62b0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => force_re_output_port_net,
      in1 => force_im_output_port_net,
      y => concat_y_net_x0
    );

  force_im: entity work.reinterpret_580feec131
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => reinterpret9_output_port_net_x0,
      output_port => force_im_output_port_net
    );

  force_re: entity work.reinterpret_580feec131
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => reinterpret13_output_port_net_x0,
      output_port => force_re_output_port_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/PFB"

entity pfb_entity_d83d8fc9f6 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_i0: in std_logic_vector(11 downto 0); 
    data_i1: in std_logic_vector(11 downto 0); 
    data_q0: in std_logic_vector(11 downto 0); 
    data_q1: in std_logic_vector(11 downto 0); 
    sync_in: in std_logic; 
    fft_out: out std_logic_vector(143 downto 0); 
    fft_rdy: out std_logic
  );
end pfb_entity_d83d8fc9f6;

architecture structural of pfb_entity_d83d8fc9f6 is
  signal bram0_data_out_net_x2: std_logic_vector(35 downto 0);
  signal bram0_data_out_net_x3: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x2: std_logic_vector(35 downto 0);
  signal bram1_data_out_net_x3: std_logic_vector(35 downto 0);
  signal ce_1_sg_x313: std_logic;
  signal clk_1_sg_x313: std_logic;
  signal concat_y_net: std_logic_vector(143 downto 0);
  signal concat_y_net_x0: std_logic_vector(35 downto 0);
  signal concat_y_net_x12: std_logic_vector(23 downto 0);
  signal concat_y_net_x13: std_logic_vector(23 downto 0);
  signal concat_y_net_x14: std_logic_vector(23 downto 0);
  signal concat_y_net_x15: std_logic_vector(23 downto 0);
  signal concat_y_net_x16: std_logic_vector(35 downto 0);
  signal concat_y_net_x17: std_logic_vector(35 downto 0);
  signal concat_y_net_x18: std_logic_vector(35 downto 0);
  signal concat_y_net_x19: std_logic_vector(23 downto 0);
  signal concat_y_net_x20: std_logic_vector(23 downto 0);
  signal concat_y_net_x21: std_logic_vector(35 downto 0);
  signal constant1_op_net_x10: std_logic_vector(31 downto 0);
  signal constant2_op_net_x10: std_logic_vector(31 downto 0);
  signal convert10_dout_net: std_logic_vector(17 downto 0);
  signal convert11_dout_net: std_logic_vector(17 downto 0);
  signal convert16_dout_net: std_logic_vector(17 downto 0);
  signal convert1_dout_net: std_logic_vector(17 downto 0);
  signal convert2_dout_net: std_logic_vector(17 downto 0);
  signal convert3_dout_net: std_logic_vector(17 downto 0);
  signal convert8_dout_net: std_logic_vector(17 downto 0);
  signal convert9_dout_net: std_logic_vector(17 downto 0);
  signal delay10_q_net_x3: std_logic;
  signal delay11_q_net_x2: std_logic_vector(23 downto 0);
  signal delay16_q_net_x4: std_logic_vector(35 downto 0);
  signal delay17_q_net_x3: std_logic_vector(35 downto 0);
  signal delay18_q_net_x3: std_logic_vector(35 downto 0);
  signal delay19_q_net_x4: std_logic_vector(35 downto 0);
  signal delay1_q_net_x12: std_logic;
  signal delay1_q_net_x3: std_logic;
  signal delay1_q_net_x4: std_logic;
  signal delay20_q_net_x0: std_logic_vector(143 downto 0);
  signal delay2_q_net_x2: std_logic_vector(23 downto 0);
  signal delay5_q_net_x2: std_logic_vector(23 downto 0);
  signal delay6_q_net_x0: std_logic;
  signal delay8_q_net_x2: std_logic_vector(23 downto 0);
  signal delay9_q_net_x3: std_logic;
  signal force_im_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(11 downto 0);
  signal force_im_output_port_net_x2: std_logic_vector(11 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(11 downto 0);
  signal force_im_output_port_net_x4: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x2: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(11 downto 0);
  signal force_re_output_port_net_x4: std_logic_vector(11 downto 0);
  signal logical3_y_net_x0: std_logic;
  signal logical_y_net_x0: std_logic;
  signal negate1_op_net_x0: std_logic_vector(17 downto 0);
  signal negate2_op_net_x0: std_logic_vector(17 downto 0);
  signal post_sync_delay_q_net_x3: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x1: std_logic_vector(23 downto 0);
  signal register1_q_net_x10: std_logic_vector(11 downto 0);
  signal register1_q_net_x11: std_logic_vector(11 downto 0);
  signal register1_q_net_x12: std_logic_vector(11 downto 0);
  signal register1_q_net_x13: std_logic_vector(11 downto 0);
  signal register1_q_net_x2: std_logic_vector(23 downto 0);
  signal register1_q_net_x3: std_logic;
  signal register1_q_net_x4: std_logic_vector(23 downto 0);
  signal register1_q_net_x5: std_logic_vector(23 downto 0);
  signal reinterpret10_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret11_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret13_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret1_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret2_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret3_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret5_output_port_net_x0: std_logic_vector(17 downto 0);
  signal reinterpret9_output_port_net_x0: std_logic_vector(17 downto 0);

begin
  ce_1_sg_x313 <= ce_1;
  clk_1_sg_x313 <= clk_1;
  register1_q_net_x10 <= data_i0;
  register1_q_net_x11 <= data_i1;
  register1_q_net_x12 <= data_q0;
  register1_q_net_x13 <= data_q1;
  logical_y_net_x0 <= sync_in;
  fft_out <= delay20_q_net_x0;
  fft_rdy <= delay6_q_net_x0;

  c_to_ri1_91f65b6f7a: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => bram1_data_out_net_x3,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri3_9f372b9ce8: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => register1_q_net_x1,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  c_to_ri4_2a3865dba9: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => register1_q_net_x2,
      im => force_im_output_port_net_x2,
      re => force_re_output_port_net_x2
    );

  c_to_ri7_cb5db1cbed: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => register1_q_net_x4,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  c_to_ri8_3a000e5efc: entity work.c_to_ri3_entity_9f372b9ce8
    port map (
      c => register1_q_net_x5,
      im => force_im_output_port_net_x4,
      re => force_re_output_port_net_x4
    );

  concat: entity work.concat_bbc53d9757
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x0,
      in1 => bram1_data_out_net_x2,
      in2 => bram0_data_out_net_x3,
      in3 => bram0_data_out_net_x2,
      y => concat_y_net
    );

  constant1: entity work.constant_9d48cff672
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net_x10
    );

  constant2: entity work.constant_9d48cff672
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net_x10
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x1,
      dout => convert1_dout_net
    );

  convert10: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x4,
      dout => convert10_dout_net
    );

  convert11: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x4,
      dout => convert11_dout_net
    );

  convert16: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x3,
      dout => convert16_dout_net
    );

  convert2: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x2,
      dout => convert2_dout_net
    );

  convert3: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x2,
      dout => convert3_dout_net
    );

  convert8: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_im_output_port_net_x3,
      dout => convert8_dout_net
    );

  convert9: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 11,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 17,
      dout_width => 18,
      latency => 0,
      overflow => xlWrap,
      quantization => xlRound
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => force_re_output_port_net_x1,
      dout => convert9_dout_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d(0) => logical_y_net_x0,
      en => '1',
      q(0) => delay1_q_net_x12
    );

  delay10: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d(0) => register1_q_net_x0,
      en => '1',
      q(0) => delay10_q_net_x3
    );

  delay11: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 24
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net_x19,
      en => '1',
      q => delay11_q_net_x2
    );

  delay16: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net_x21,
      en => '1',
      q => delay16_q_net_x4
    );

  delay17: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net_x18,
      en => '1',
      q => delay17_q_net_x3
    );

  delay18: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net_x16,
      en => '1',
      q => delay18_q_net_x3
    );

  delay19: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net_x17,
      en => '1',
      q => delay19_q_net_x4
    );

  delay2: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 24
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net_x20,
      en => '1',
      q => delay2_q_net_x2
    );

  delay20: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => concat_y_net,
      en => '1',
      q => delay20_q_net_x0
    );

  delay5: entity work.xldelay
    generic map (
      latency => 128,
      reg_retiming => 0,
      width => 24
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => delay11_q_net_x2,
      en => '1',
      q => delay5_q_net_x2
    );

  delay6: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d(0) => logical3_y_net_x0,
      en => '1',
      q(0) => delay6_q_net_x0
    );

  delay8: entity work.xldelay
    generic map (
      latency => 128,
      reg_retiming => 0,
      width => 24
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d => delay2_q_net_x2,
      en => '1',
      q => delay8_q_net_x2
    );

  delay9: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      d(0) => register1_q_net_x3,
      en => '1',
      q(0) => delay9_q_net_x3
    );

  fft1_e5227511b0: entity work.fft1_entity_e5227511b0
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      in0 => delay18_q_net_x3,
      in1 => delay19_q_net_x4,
      shift => constant2_op_net_x10,
      sync => delay10_q_net_x3,
      out0 => bram0_data_out_net_x3,
      out1 => bram1_data_out_net_x3
    );

  fft_39b4a5d56a: entity work.fft_entity_39b4a5d56a
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      in0 => delay17_q_net_x3,
      in1 => delay16_q_net_x4,
      shift => constant1_op_net_x10,
      sync => delay9_q_net_x3,
      out0 => bram0_data_out_net_x2,
      out1 => bram1_data_out_net_x2,
      sync_out => post_sync_delay_q_net_x3
    );

  gen_fft_block_ready_65e3c5b8d9: entity work.gen_fft_block_ready_entity_65e3c5b8d9
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      sync_in => post_sync_delay_q_net_x3,
      data_ready => logical3_y_net_x0
    );

  negate1: entity work.negate_19850bb816
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      clr => '0',
      ip => force_re_output_port_net_x0,
      op => negate1_op_net_x0
    );

  negate2: entity work.negate_19850bb816
    port map (
      ce => ce_1_sg_x313,
      clk => clk_1_sg_x313,
      clr => '0',
      ip => force_im_output_port_net_x0,
      op => negate2_op_net_x0
    );

  pfb_fir1_d4241bde70: entity work.pfb_fir_entity_5700d3bdc2
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      pol1_in1 => delay11_q_net_x2,
      pol1_in2 => delay2_q_net_x2,
      sync => delay1_q_net_x12,
      pol1_out1 => concat_y_net_x14,
      pol1_out2 => concat_y_net_x15,
      sync_out => delay1_q_net_x4
    );

  pfb_fir_5700d3bdc2: entity work.pfb_fir_entity_5700d3bdc2
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      pol1_in1 => delay5_q_net_x2,
      pol1_in2 => delay8_q_net_x2,
      sync => delay1_q_net_x12,
      pol1_out1 => concat_y_net_x12,
      pol1_out2 => concat_y_net_x13,
      sync_out => delay1_q_net_x3
    );

  pipeline1_ca64142bd2: entity work.pipeline1_entity_ca64142bd2
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      d => concat_y_net_x12,
      q => register1_q_net_x1
    );

  pipeline2_fe7fa423a8: entity work.pipeline1_entity_ca64142bd2
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      d => concat_y_net_x13,
      q => register1_q_net_x2
    );

  pipeline3_e232fb1c42: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      d => delay1_q_net_x4,
      q => register1_q_net_x0
    );

  pipeline4_9c3c2173a9: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      d => delay1_q_net_x3,
      q => register1_q_net_x3
    );

  pipeline5_8d243b0834: entity work.pipeline1_entity_ca64142bd2
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      d => concat_y_net_x14,
      q => register1_q_net_x4
    );

  pipeline6_6ee3875a41: entity work.pipeline1_entity_ca64142bd2
    port map (
      ce_1 => ce_1_sg_x313,
      clk_1 => clk_1_sg_x313,
      d => concat_y_net_x15,
      q => register1_q_net_x5
    );

  reinterpret1: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert1_dout_net,
      output_port => reinterpret1_output_port_net_x0
    );

  reinterpret10: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert10_dout_net,
      output_port => reinterpret10_output_port_net_x0
    );

  reinterpret11: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert11_dout_net,
      output_port => reinterpret11_output_port_net_x0
    );

  reinterpret13: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert16_dout_net,
      output_port => reinterpret13_output_port_net_x0
    );

  reinterpret2: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert2_dout_net,
      output_port => reinterpret2_output_port_net_x0
    );

  reinterpret3: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert3_dout_net,
      output_port => reinterpret3_output_port_net_x0
    );

  reinterpret5: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert9_dout_net,
      output_port => reinterpret5_output_port_net_x0
    );

  reinterpret9: entity work.reinterpret_120751dc4b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert8_dout_net,
      output_port => reinterpret9_output_port_net_x0
    );

  ri_to_c12_872d2867a4: entity work.ri_to_c12_entity_872d2867a4
    port map (
      im => reinterpret9_output_port_net_x0,
      re => reinterpret13_output_port_net_x0,
      c => concat_y_net_x16
    );

  ri_to_c13_aa365e8368: entity work.ri_to_c12_entity_872d2867a4
    port map (
      im => reinterpret10_output_port_net_x0,
      re => reinterpret11_output_port_net_x0,
      c => concat_y_net_x17
    );

  ri_to_c1_806f8784ac: entity work.ri_to_c01_entity_cc24d6b27a
    port map (
      im => negate2_op_net_x0,
      re => negate1_op_net_x0,
      c => concat_y_net_x0
    );

  ri_to_c2_34c5342b45: entity work.ri_to_c12_entity_872d2867a4
    port map (
      im => reinterpret1_output_port_net_x0,
      re => reinterpret5_output_port_net_x0,
      c => concat_y_net_x18
    );

  ri_to_c4_ffe4174668: entity work.ri_to_c_entity_141ab06f3d
    port map (
      im => register1_q_net_x12,
      re => register1_q_net_x10,
      c => concat_y_net_x19
    );

  ri_to_c5_5ffc6ddf65: entity work.ri_to_c_entity_141ab06f3d
    port map (
      im => register1_q_net_x13,
      re => register1_q_net_x11,
      c => concat_y_net_x20
    );

  ri_to_c8_cf617138b1: entity work.ri_to_c12_entity_872d2867a4
    port map (
      im => reinterpret2_output_port_net_x0,
      re => reinterpret3_output_port_net_x0,
      c => concat_y_net_x21
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/accumulator/c_to_ri1"

entity c_to_ri1_entity_3e56016386 is
  port (
    c: in std_logic_vector(37 downto 0); 
    im: out std_logic_vector(18 downto 0); 
    re: out std_logic_vector(18 downto 0)
  );
end c_to_ri1_entity_3e56016386;

architecture structural of c_to_ri1_entity_3e56016386 is
  signal force_im_output_port_net_x0: std_logic_vector(18 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(18 downto 0);
  signal slice4_y_net_x0: std_logic_vector(37 downto 0);
  signal slice_im_y_net: std_logic_vector(18 downto 0);
  signal slice_re_y_net: std_logic_vector(18 downto 0);

begin
  slice4_y_net_x0 <= c;
  im <= force_im_output_port_net_x0;
  re <= force_re_output_port_net_x0;

  force_im: entity work.reinterpret_63700884f5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_im_y_net,
      output_port => force_im_output_port_net_x0
    );

  force_re: entity work.reinterpret_63700884f5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_re_y_net,
      output_port => force_re_output_port_net_x0
    );

  slice_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 18,
      x_width => 38,
      y_width => 19
    )
    port map (
      x => slice4_y_net_x0,
      y => slice_im_y_net
    );

  slice_re: entity work.xlslice
    generic map (
      new_lsb => 19,
      new_msb => 37,
      x_width => 38,
      y_width => 19
    )
    port map (
      x => slice4_y_net_x0,
      y => slice_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/accumulator/pulse_ext/posedge"

entity posedge_entity_59344d4cf3 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end posedge_entity_59344d4cf3;

architecture structural of posedge_entity_59344d4cf3 is
  signal ce_1_sg_x314: std_logic;
  signal clk_1_sg_x314: std_logic;
  signal delay_q_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical_y_net_x0: std_logic;
  signal relational1_op_net_x0: std_logic;

begin
  ce_1_sg_x314 <= ce_1;
  clk_1_sg_x314 <= clk_1;
  relational1_op_net_x0 <= in_x0;
  out_x0 <= logical_y_net_x0;

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x314,
      clk => clk_1_sg_x314,
      d(0) => relational1_op_net_x0,
      en => '1',
      q(0) => delay_q_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x314,
      clk => clk_1_sg_x314,
      clr => '0',
      ip(0) => delay_q_net,
      op(0) => inverter_op_net
    );

  logical: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => inverter_op_net,
      d1(0) => relational1_op_net_x0,
      y(0) => logical_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/accumulator/pulse_ext"

entity pulse_ext_entity_2c3f79dc8f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end pulse_ext_entity_2c3f79dc8f;

architecture structural of pulse_ext_entity_2c3f79dc8f is
  signal ce_1_sg_x315: std_logic;
  signal clk_1_sg_x315: std_logic;
  signal constant5_op_net: std_logic_vector(8 downto 0);
  signal counter3_op_net: std_logic_vector(8 downto 0);
  signal logical_y_net_x0: std_logic;
  signal relational1_op_net_x1: std_logic;
  signal relational5_op_net_x0: std_logic;

begin
  ce_1_sg_x315 <= ce_1;
  clk_1_sg_x315 <= clk_1;
  relational1_op_net_x1 <= in_x0;
  out_x0 <= relational5_op_net_x0;

  constant5: entity work.constant_4a391b9a0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_7dbd4dbcd9455acc",
      op_arith => xlUnsigned,
      op_width => 9
    )
    port map (
      ce => ce_1_sg_x315,
      clk => clk_1_sg_x315,
      clr => '0',
      en(0) => relational5_op_net_x0,
      rst(0) => logical_y_net_x0,
      op => counter3_op_net
    );

  posedge_59344d4cf3: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x315,
      clk_1 => clk_1_sg_x315,
      in_x0 => relational1_op_net_x1,
      out_x0 => logical_y_net_x0
    );

  relational5: entity work.relational_78eac2928d
    port map (
      a => counter3_op_net,
      b => constant5_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational5_op_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/accumulator"

entity accumulator_entity_0ff8042a80 is
  port (
    accum_en: in std_logic; 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(75 downto 0); 
    data_out: out std_logic_vector(31 downto 0); 
    drdy: out std_logic
  );
end accumulator_entity_0ff8042a80;

architecture structural of accumulator_entity_0ff8042a80 is
  signal addsub1_s_net: std_logic_vector(29 downto 0);
  signal addsub2_s_net: std_logic_vector(29 downto 0);
  signal addsub3_s_net: std_logic_vector(19 downto 0);
  signal addsub4_s_net: std_logic_vector(19 downto 0);
  signal ce_1_sg_x316: std_logic;
  signal clk_1_sg_x316: std_logic;
  signal constant1_op_net: std_logic_vector(29 downto 0);
  signal constant2_op_net: std_logic_vector(29 downto 0);
  signal constant9_op_net: std_logic_vector(17 downto 0);
  signal convert1_dout_net: std_logic_vector(31 downto 0);
  signal convert3_dout_net: std_logic_vector(31 downto 0);
  signal delay1_q_net: std_logic_vector(46 downto 0);
  signal delay2_q_net: std_logic;
  signal delay30_q_net_x0: std_logic_vector(75 downto 0);
  signal delay3_q_net: std_logic;
  signal delay4_q_net: std_logic;
  signal delay5_q_net: std_logic_vector(46 downto 0);
  signal delay8_q_net: std_logic_vector(31 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(18 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(18 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(18 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(18 downto 0);
  signal inverter1_op_net: std_logic;
  signal inverter_op_net: std_logic;
  signal lut_counter1_op_net: std_logic_vector(17 downto 0);
  signal mux1_y_net: std_logic_vector(46 downto 0);
  signal mux2_y_net_x0: std_logic_vector(31 downto 0);
  signal mux3_y_net_x0: std_logic;
  signal mux_y_net: std_logic_vector(46 downto 0);
  signal reinterpret1_output_port_net: std_logic_vector(18 downto 0);
  signal reinterpret2_output_port_net: std_logic_vector(18 downto 0);
  signal reinterpret4_output_port_net: std_logic_vector(29 downto 0);
  signal reinterpret5_output_port_net: std_logic_vector(18 downto 0);
  signal reinterpret6_output_port_net: std_logic_vector(18 downto 0);
  signal reinterpret7_output_port_net: std_logic_vector(18 downto 0);
  signal reinterpret8_output_port_net: std_logic_vector(18 downto 0);
  signal relational1_op_net_x1: std_logic;
  signal relational5_op_net_x0: std_logic;
  signal relational5_op_net_x1: std_logic;
  signal slice1_y_net: std_logic_vector(18 downto 0);
  signal slice2_y_net: std_logic_vector(18 downto 0);
  signal slice4_y_net_x0: std_logic_vector(37 downto 0);
  signal slice6_y_net_x0: std_logic_vector(37 downto 0);

begin
  relational5_op_net_x1 <= accum_en;
  ce_1_sg_x316 <= ce_1;
  clk_1_sg_x316 <= clk_1;
  delay30_q_net_x0 <= data_in;
  data_out <= mux2_y_net_x0;
  drdy <= mux3_y_net_x0;

  addsub1: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 47,
      b_arith => xlSigned,
      b_bin_pt => 0,
      b_width => 20,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 48,
      core_name0 => "addsb_11_0_07376586731f7a0d",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 48,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 0,
      s_width => 30
    )
    port map (
      a => delay1_q_net,
      b => addsub4_s_net,
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      en => "1",
      s => addsub1_s_net
    );

  addsub2: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 47,
      b_arith => xlSigned,
      b_bin_pt => 0,
      b_width => 20,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 48,
      core_name0 => "addsb_11_0_07376586731f7a0d",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 48,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 0,
      s_width => 30
    )
    port map (
      a => delay5_q_net,
      b => addsub3_s_net,
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      en => "1",
      s => addsub2_s_net
    );

  addsub3: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 0,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 0,
      b_width => 19,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 20,
      core_name0 => "addsb_11_0_97a94476d39abba1",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 20,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 0,
      s_width => 20
    )
    port map (
      a => reinterpret5_output_port_net,
      b => reinterpret8_output_port_net,
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      en => "1",
      s => addsub3_s_net
    );

  addsub4: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 0,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 0,
      b_width => 19,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 20,
      core_name0 => "addsb_11_0_97a94476d39abba1",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 20,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 0,
      s_width => 20
    )
    port map (
      a => reinterpret2_output_port_net,
      b => reinterpret7_output_port_net,
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      en => "1",
      s => addsub4_s_net
    );

  c_to_ri1_3e56016386: entity work.c_to_ri1_entity_3e56016386
    port map (
      c => slice4_y_net_x0,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri2_0a2870d4e4: entity work.c_to_ri1_entity_3e56016386
    port map (
      c => slice6_y_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  constant1: entity work.constant_edea2790a5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_edea2790a5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant9: entity work.constant_dd7b6fe6cd
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant9_op_net
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 0,
      din_width => 19,
      dout_arith => 2,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterpret6_output_port_net,
      dout => convert1_dout_net
    );

  convert3: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 0,
      din_width => 19,
      dout_arith => 2,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => reinterpret1_output_port_net,
      dout => convert3_dout_net
    );

  delay1: entity work.delay_83ff242e20
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d => mux1_y_net,
      q => delay1_q_net
    );

  delay2: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d(0) => relational5_op_net_x0,
      q(0) => delay2_q_net
    );

  delay3: entity work.delay_23d71a76f2
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d(0) => relational5_op_net_x1,
      q(0) => delay3_q_net
    );

  delay4: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d(0) => delay2_q_net,
      q(0) => delay4_q_net
    );

  delay5: entity work.delay_83ff242e20
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d => mux_y_net,
      q => delay5_q_net
    );

  delay8: entity work.delay_fb02391359
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d => convert3_dout_net,
      q => delay8_q_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      ip(0) => delay3_q_net,
      op(0) => inverter_op_net
    );

  inverter1: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      ip(0) => delay2_q_net,
      op(0) => inverter1_op_net
    );

  lut_counter1: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_5515d9f6c1c522c2",
      op_arith => xlUnsigned,
      op_width => 18
    )
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      en(0) => delay3_q_net,
      rst(0) => inverter_op_net,
      op => lut_counter1_op_net
    );

  mux: entity work.mux_b54edc8403
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d0 => constant1_op_net,
      d1 => addsub2_s_net,
      sel(0) => delay3_q_net,
      y => mux_y_net
    );

  mux1: entity work.mux_b54edc8403
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d0 => constant2_op_net,
      d1 => addsub1_s_net,
      sel(0) => delay3_q_net,
      y => mux1_y_net
    );

  mux2: entity work.mux_86a34309e7
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d0 => convert1_dout_net,
      d1 => delay8_q_net,
      sel(0) => inverter1_op_net,
      y => mux2_y_net_x0
    );

  mux3: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      d0(0) => delay4_q_net,
      d1(0) => delay2_q_net,
      sel(0) => delay2_q_net,
      y(0) => mux3_y_net_x0
    );

  pulse_ext_2c3f79dc8f: entity work.pulse_ext_entity_2c3f79dc8f
    port map (
      ce_1 => ce_1_sg_x316,
      clk_1 => clk_1_sg_x316,
      in_x0 => relational1_op_net_x1,
      out_x0 => relational5_op_net_x0
    );

  reinterpret1: entity work.reinterpret_63700884f5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice1_y_net,
      output_port => reinterpret1_output_port_net
    );

  reinterpret2: entity work.reinterpret_29020b53d3
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => force_re_output_port_net_x0,
      output_port => reinterpret2_output_port_net
    );

  reinterpret4: entity work.reinterpret_46dd2ac081
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => addsub2_s_net,
      output_port => reinterpret4_output_port_net
    );

  reinterpret5: entity work.reinterpret_29020b53d3
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => force_im_output_port_net_x0,
      output_port => reinterpret5_output_port_net
    );

  reinterpret6: entity work.reinterpret_63700884f5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice2_y_net,
      output_port => reinterpret6_output_port_net
    );

  reinterpret7: entity work.reinterpret_29020b53d3
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => force_re_output_port_net_x1,
      output_port => reinterpret7_output_port_net
    );

  reinterpret8: entity work.reinterpret_29020b53d3
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => force_im_output_port_net_x1,
      output_port => reinterpret8_output_port_net
    );

  relational1: entity work.relational_4e76b03051
    port map (
      a => lut_counter1_op_net,
      b => constant9_op_net,
      ce => ce_1_sg_x316,
      clk => clk_1_sg_x316,
      clr => '0',
      op(0) => relational1_op_net_x1
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 11,
      new_msb => 29,
      x_width => 30,
      y_width => 19
    )
    port map (
      x => reinterpret4_output_port_net,
      y => slice1_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 11,
      new_msb => 29,
      x_width => 30,
      y_width => 19
    )
    port map (
      x => addsub1_s_net,
      y => slice2_y_net
    );

  slice4: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 37,
      x_width => 76,
      y_width => 38
    )
    port map (
      x => delay30_q_net_x0,
      y => slice4_y_net_x0
    );

  slice6: entity work.xlslice
    generic map (
      new_lsb => 38,
      new_msb => 75,
      x_width => 76,
      y_width => 38
    )
    port map (
      x => delay30_q_net_x0,
      y => slice6_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/adc_mkid/conv"

entity conv_entity_f8dee2a05f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(11 downto 0); 
    out1: out std_logic_vector(11 downto 0)
  );
end conv_entity_f8dee2a05f;

architecture structural of conv_entity_f8dee2a05f is
  signal ce_1_sg_x317: std_logic;
  signal clk_1_sg_x317: std_logic;
  signal concat_y_net: std_logic_vector(11 downto 0);
  signal inverter_op_net: std_logic;
  signal register1_q_net_x0: std_logic_vector(11 downto 0);
  signal reinterpret_output_port_net_x0: std_logic_vector(11 downto 0);
  signal slice1_y_net: std_logic_vector(10 downto 0);
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x317 <= ce_1;
  clk_1_sg_x317 <= clk_1;
  register1_q_net_x0 <= in1;
  out1 <= reinterpret_output_port_net_x0;

  concat: entity work.concat_9769d05421
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0(0) => inverter_op_net,
      in1 => slice1_y_net,
      y => concat_y_net
    );

  inverter: entity work.inverter_e2b989a05e
    port map (
      ce => ce_1_sg_x317,
      clk => clk_1_sg_x317,
      clr => '0',
      ip(0) => slice_y_net,
      op(0) => inverter_op_net
    );

  reinterpret: entity work.reinterpret_8f5500aea5
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => concat_y_net,
      output_port => reinterpret_output_port_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 11,
      new_msb => 11,
      x_width => 12,
      y_width => 1
    )
    port map (
      x => register1_q_net_x0,
      y(0) => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 10,
      x_width => 12,
      y_width => 11
    )
    port map (
      x => register1_q_net_x0,
      y => slice1_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/adc_mkid/pipeline"

entity pipeline_entity_88eeb446ec is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(11 downto 0); 
    q: out std_logic_vector(11 downto 0)
  );
end pipeline_entity_88eeb446ec;

architecture structural of pipeline_entity_88eeb446ec is
  signal ce_1_sg_x321: std_logic;
  signal chan_512_clean_adc_mkid_user_data_i0_net_x0: std_logic_vector(11 downto 0);
  signal clk_1_sg_x321: std_logic;
  signal register0_q_net: std_logic_vector(11 downto 0);
  signal register1_q_net_x1: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x321 <= ce_1;
  clk_1_sg_x321 <= clk_1;
  chan_512_clean_adc_mkid_user_data_i0_net_x0 <= d;
  q <= register1_q_net_x1;

  register0: entity work.xlregister
    generic map (
      d_width => 12,
      init_value => b"000000000000"
    )
    port map (
      ce => ce_1_sg_x321,
      clk => clk_1_sg_x321,
      d => chan_512_clean_adc_mkid_user_data_i0_net_x0,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 12,
      init_value => b"000000000000"
    )
    port map (
      ce => ce_1_sg_x321,
      clk => clk_1_sg_x321,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/adc_mkid/pipeline1"

entity pipeline1_entity_5f28abbbf4 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(11 downto 0); 
    q: out std_logic_vector(11 downto 0)
  );
end pipeline1_entity_5f28abbbf4;

architecture structural of pipeline1_entity_5f28abbbf4 is
  signal ce_1_sg_x322: std_logic;
  signal clk_1_sg_x322: std_logic;
  signal register0_q_net: std_logic_vector(11 downto 0);
  signal register1_q_net_x11: std_logic_vector(11 downto 0);
  signal reinterpret_output_port_net_x1: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x322 <= ce_1;
  clk_1_sg_x322 <= clk_1;
  reinterpret_output_port_net_x1 <= d;
  q <= register1_q_net_x11;

  register0: entity work.xlregister
    generic map (
      d_width => 12,
      init_value => b"000000000000"
    )
    port map (
      ce => ce_1_sg_x322,
      clk => clk_1_sg_x322,
      d => reinterpret_output_port_net_x1,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 12,
      init_value => b"000000000000"
    )
    port map (
      ce => ce_1_sg_x322,
      clk => clk_1_sg_x322,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x11
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/adc_mkid"

entity adc_mkid_entity_98b47612c6 is
  port (
    ce_1: in std_logic; 
    chan_512_clean_adc_mkid_user_data_i0: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_data_i1: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_data_q0: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_data_q1: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_sync: in std_logic; 
    clk_1: in std_logic; 
    data_i0: out std_logic_vector(11 downto 0); 
    data_i1: out std_logic_vector(11 downto 0); 
    data_q0: out std_logic_vector(11 downto 0); 
    data_q1: out std_logic_vector(11 downto 0); 
    sync: out std_logic
  );
end adc_mkid_entity_98b47612c6;

architecture structural of adc_mkid_entity_98b47612c6 is
  signal ce_1_sg_x331: std_logic;
  signal chan_512_clean_adc_mkid_user_data_i0_net_x1: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_data_i1_net_x1: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_data_q0_net_x1: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_data_q1_net_x1: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_sync_net_x1: std_logic;
  signal clk_1_sg_x331: std_logic;
  signal register1_q_net_x1: std_logic_vector(11 downto 0);
  signal register1_q_net_x15: std_logic_vector(11 downto 0);
  signal register1_q_net_x16: std_logic_vector(11 downto 0);
  signal register1_q_net_x17: std_logic_vector(11 downto 0);
  signal register1_q_net_x18: std_logic_vector(11 downto 0);
  signal register1_q_net_x19: std_logic;
  signal register1_q_net_x2: std_logic_vector(11 downto 0);
  signal register1_q_net_x3: std_logic_vector(11 downto 0);
  signal register1_q_net_x4: std_logic_vector(11 downto 0);
  signal register1_q_net_x5: std_logic;
  signal reinterpret_output_port_net_x1: std_logic_vector(11 downto 0);
  signal reinterpret_output_port_net_x2: std_logic_vector(11 downto 0);
  signal reinterpret_output_port_net_x3: std_logic_vector(11 downto 0);
  signal reinterpret_output_port_net_x4: std_logic_vector(11 downto 0);

begin
  ce_1_sg_x331 <= ce_1;
  chan_512_clean_adc_mkid_user_data_i0_net_x1 <= chan_512_clean_adc_mkid_user_data_i0;
  chan_512_clean_adc_mkid_user_data_i1_net_x1 <= chan_512_clean_adc_mkid_user_data_i1;
  chan_512_clean_adc_mkid_user_data_q0_net_x1 <= chan_512_clean_adc_mkid_user_data_q0;
  chan_512_clean_adc_mkid_user_data_q1_net_x1 <= chan_512_clean_adc_mkid_user_data_q1;
  chan_512_clean_adc_mkid_user_sync_net_x1 <= chan_512_clean_adc_mkid_user_sync;
  clk_1_sg_x331 <= clk_1;
  data_i0 <= register1_q_net_x15;
  data_i1 <= register1_q_net_x16;
  data_q0 <= register1_q_net_x17;
  data_q1 <= register1_q_net_x18;
  sync <= register1_q_net_x19;

  conv1_29c4b30021: entity work.conv_entity_f8dee2a05f
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      in1 => register1_q_net_x4,
      out1 => reinterpret_output_port_net_x2
    );

  conv2_ad8426d440: entity work.conv_entity_f8dee2a05f
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      in1 => register1_q_net_x3,
      out1 => reinterpret_output_port_net_x3
    );

  conv3_57e4dfd4e5: entity work.conv_entity_f8dee2a05f
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      in1 => register1_q_net_x2,
      out1 => reinterpret_output_port_net_x4
    );

  conv_f8dee2a05f: entity work.conv_entity_f8dee2a05f
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      in1 => register1_q_net_x1,
      out1 => reinterpret_output_port_net_x1
    );

  pipeline1_5f28abbbf4: entity work.pipeline1_entity_5f28abbbf4
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => reinterpret_output_port_net_x1,
      q => register1_q_net_x15
    );

  pipeline2_0fc30b9520: entity work.pipeline1_entity_5f28abbbf4
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => reinterpret_output_port_net_x2,
      q => register1_q_net_x16
    );

  pipeline3_a5b54c37f3: entity work.pipeline1_entity_5f28abbbf4
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => reinterpret_output_port_net_x3,
      q => register1_q_net_x17
    );

  pipeline4_4a8b6e3c2d: entity work.pipeline1_entity_5f28abbbf4
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => reinterpret_output_port_net_x4,
      q => register1_q_net_x18
    );

  pipeline5_37966e997d: entity work.pipeline_entity_88eeb446ec
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => chan_512_clean_adc_mkid_user_data_q1_net_x1,
      q => register1_q_net_x2
    );

  pipeline6_60286f170d: entity work.pipeline_entity_88eeb446ec
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => chan_512_clean_adc_mkid_user_data_q0_net_x1,
      q => register1_q_net_x3
    );

  pipeline7_0d88571ecb: entity work.pipeline_entity_88eeb446ec
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => chan_512_clean_adc_mkid_user_data_i1_net_x1,
      q => register1_q_net_x4
    );

  pipeline8_21ca18b1a0: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => chan_512_clean_adc_mkid_user_sync_net_x1,
      q => register1_q_net_x5
    );

  pipeline9_2dc540b161: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => register1_q_net_x5,
      q => register1_q_net_x19
    );

  pipeline_88eeb446ec: entity work.pipeline_entity_88eeb446ec
    port map (
      ce_1 => ce_1_sg_x331,
      clk_1 => clk_1_sg_x331,
      d => chan_512_clean_adc_mkid_user_data_i0_net_x1,
      q => register1_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/avgIQ/addr"

entity addr_entity_0b3e5d3e19 is
  port (
    reg_out: in std_logic_vector(9 downto 0); 
    convert_x0: out std_logic_vector(31 downto 0)
  );
end addr_entity_0b3e5d3e19;

architecture structural of addr_entity_0b3e5d3e19 is
  signal convert_dout_net_x0: std_logic_vector(31 downto 0);
  signal register1_q_net_x0: std_logic_vector(9 downto 0);

begin
  register1_q_net_x0 <= reg_out;
  convert_x0 <= convert_dout_net_x0;

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 10,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x0,
      dout => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/avgIQ/bram"

entity bram_entity_ba4d41d040 is
  port (
    addr: in std_logic_vector(9 downto 0); 
    data_in: in std_logic_vector(31 downto 0); 
    we: in std_logic; 
    convert_addr_x0: out std_logic_vector(9 downto 0); 
    convert_din_x0: out std_logic_vector(31 downto 0); 
    convert_we_x0: out std_logic
  );
end bram_entity_ba4d41d040;

architecture structural of bram_entity_ba4d41d040 is
  signal convert_addr_dout_net_x0: std_logic_vector(9 downto 0);
  signal convert_din_dout_net_x0: std_logic_vector(31 downto 0);
  signal convert_we_dout_net_x0: std_logic;
  signal delay2_q_net_x0: std_logic_vector(9 downto 0);
  signal delay3_q_net_x0: std_logic_vector(31 downto 0);
  signal delay4_q_net_x0: std_logic;

begin
  delay2_q_net_x0 <= addr;
  delay3_q_net_x0 <= data_in;
  delay4_q_net_x0 <= we;
  convert_addr_x0 <= convert_addr_dout_net_x0;
  convert_din_x0 <= convert_din_dout_net_x0;
  convert_we_x0 <= convert_we_dout_net_x0;

  convert_addr: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 10,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 10,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => delay2_q_net_x0,
      dout => convert_addr_dout_net_x0
    );

  convert_din: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 32,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => delay3_q_net_x0,
      dout => convert_din_dout_net_x0
    );

  convert_we: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => delay4_q_net_x0,
      dout(0) => convert_we_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/avgIQ/freeze_cntr"

entity freeze_cntr_entity_0ddc4df5a3 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    en: in std_logic; 
    rst: in std_logic; 
    addr: out std_logic_vector(9 downto 0); 
    we: out std_logic
  );
end freeze_cntr_entity_0ddc4df5a3;

architecture structural of freeze_cntr_entity_0ddc4df5a3 is
  signal ce_1_sg_x332: std_logic;
  signal clk_1_sg_x332: std_logic;
  signal counter3_op_net: std_logic_vector(10 downto 0);
  signal enable1_y_net: std_logic;
  signal enable_y_net_x0: std_logic_vector(9 downto 0);
  signal inverter1_op_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical1_y_net_x0: std_logic;
  signal logical5_y_net: std_logic;
  signal mux1_y_net_x0: std_logic;
  signal register_q_net_x0: std_logic;

begin
  ce_1_sg_x332 <= ce_1;
  clk_1_sg_x332 <= clk_1;
  mux1_y_net_x0 <= en;
  register_q_net_x0 <= rst;
  addr <= enable_y_net_x0;
  we <= logical1_y_net_x0;

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_da764ffec3b80b68",
      op_arith => xlUnsigned,
      op_width => 11
    )
    port map (
      ce => ce_1_sg_x332,
      clk => clk_1_sg_x332,
      clr => '0',
      en(0) => logical5_y_net,
      rst(0) => register_q_net_x0,
      op => counter3_op_net
    );

  enable: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 9,
      x_width => 11,
      y_width => 10
    )
    port map (
      x => counter3_op_net,
      y => enable_y_net_x0
    );

  enable1: entity work.xlslice
    generic map (
      new_lsb => 10,
      new_msb => 10,
      x_width => 11,
      y_width => 1
    )
    port map (
      x => counter3_op_net,
      y(0) => enable1_y_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x332,
      clk => clk_1_sg_x332,
      clr => '0',
      ip(0) => register_q_net_x0,
      op(0) => inverter_op_net
    );

  inverter1: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x332,
      clk => clk_1_sg_x332,
      clr => '0',
      ip(0) => enable1_y_net,
      op(0) => inverter1_op_net
    );

  logical1: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => inverter_op_net,
      d1(0) => logical5_y_net,
      y(0) => logical1_y_net_x0
    );

  logical5: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => mux1_y_net_x0,
      d1(0) => inverter1_op_net,
      y(0) => logical5_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/avgIQ"

entity avgiq_entity_df5372bbc2 is
  port (
    ce_1: in std_logic; 
    chan_512_clean_avgiq_ctrl_user_data_out: in std_logic_vector(31 downto 0); 
    clk_1: in std_logic; 
    din: in std_logic_vector(31 downto 0); 
    trig: in std_logic; 
    we: in std_logic; 
    addr: out std_logic_vector(31 downto 0); 
    bram: out std_logic_vector(9 downto 0); 
    bram_x0: out std_logic_vector(31 downto 0); 
    bram_x1: out std_logic
  );
end avgiq_entity_df5372bbc2;

architecture structural of avgiq_entity_df5372bbc2 is
  signal ce_1_sg_x334: std_logic;
  signal chan_512_clean_avgiq_ctrl_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal clk_1_sg_x334: std_logic;
  signal constant1_op_net: std_logic;
  signal constant2_op_net: std_logic;
  signal constant_op_net: std_logic;
  signal convert_addr_dout_net_x1: std_logic_vector(9 downto 0);
  signal convert_din_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_we_dout_net_x1: std_logic;
  signal delay1_q_net: std_logic_vector(31 downto 0);
  signal delay25_q_net_x0: std_logic;
  signal delay2_q_net_x0: std_logic_vector(9 downto 0);
  signal delay3_q_net_x0: std_logic_vector(31 downto 0);
  signal delay4_q_net_x0: std_logic;
  signal delay5_q_net: std_logic_vector(9 downto 0);
  signal delay6_q_net: std_logic;
  signal delay7_q_net: std_logic;
  signal enable_y_net: std_logic;
  signal enable_y_net_x0: std_logic_vector(9 downto 0);
  signal inverter_op_net: std_logic;
  signal logical1_y_net: std_logic;
  signal logical1_y_net_x0: std_logic;
  signal logical_y_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic;
  signal mux2_y_net: std_logic;
  signal mux2_y_net_x1: std_logic_vector(31 downto 0);
  signal mux3_y_net_x1: std_logic;
  signal register1_q_net_x0: std_logic_vector(9 downto 0);
  signal register_q_net_x0: std_logic;
  signal reinterpret_output_port_net: std_logic_vector(31 downto 0);
  signal slice2_y_net_x0: std_logic;
  signal trig1_y_net: std_logic;
  signal valid_y_net: std_logic;

begin
  ce_1_sg_x334 <= ce_1;
  chan_512_clean_avgiq_ctrl_user_data_out_net_x0 <= chan_512_clean_avgiq_ctrl_user_data_out;
  clk_1_sg_x334 <= clk_1;
  mux2_y_net_x1 <= din;
  slice2_y_net_x0 <= trig;
  mux3_y_net_x1 <= we;
  addr <= convert_dout_net_x1;
  bram <= convert_addr_dout_net_x1;
  bram_x0 <= convert_din_dout_net_x1;
  bram_x1 <= convert_we_dout_net_x1;

  addr_0b3e5d3e19: entity work.addr_entity_0b3e5d3e19
    port map (
      reg_out => register1_q_net_x0,
      convert_x0 => convert_dout_net_x1
    );

  bram_ba4d41d040: entity work.bram_entity_ba4d41d040
    port map (
      addr => delay2_q_net_x0,
      data_in => delay3_q_net_x0,
      we => delay4_q_net_x0,
      convert_addr_x0 => convert_addr_dout_net_x1,
      convert_din_x0 => convert_din_dout_net_x1,
      convert_we_x0 => convert_we_dout_net_x1
    );

  constant1: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant1_op_net
    );

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  constant_x0: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant_op_net
    );

  delay1: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d => mux2_y_net_x1,
      q => delay1_q_net
    );

  delay2: entity work.delay_cf4f99539f
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d => enable_y_net_x0,
      q => delay2_q_net_x0
    );

  delay25: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d(0) => enable_y_net,
      q(0) => delay25_q_net_x0
    );

  delay3: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d => reinterpret_output_port_net,
      q => delay3_q_net_x0
    );

  delay4: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d(0) => logical1_y_net_x0,
      q(0) => delay4_q_net_x0
    );

  delay5: entity work.delay_cf4f99539f
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d => enable_y_net_x0,
      q => delay5_q_net
    );

  delay6: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d(0) => logical_y_net_x0,
      q(0) => delay6_q_net
    );

  delay7: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d(0) => logical1_y_net_x0,
      q(0) => delay7_q_net
    );

  enable: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_avgiq_ctrl_user_data_out_net_x0,
      y(0) => enable_y_net
    );

  freeze_cntr_0ddc4df5a3: entity work.freeze_cntr_entity_0ddc4df5a3
    port map (
      ce_1 => ce_1_sg_x334,
      clk_1 => clk_1_sg_x334,
      en => mux1_y_net_x0,
      rst => register_q_net_x0,
      addr => enable_y_net_x0,
      we => logical1_y_net_x0
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      ip(0) => logical_y_net_x0,
      op(0) => inverter_op_net
    );

  logical1: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => mux2_y_net,
      d1(0) => inverter_op_net,
      y(0) => logical1_y_net
    );

  mux1: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d0(0) => mux3_y_net_x1,
      d1(0) => constant2_op_net,
      sel(0) => valid_y_net,
      y(0) => mux1_y_net_x0
    );

  mux2: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      clr => '0',
      d0(0) => slice2_y_net_x0,
      d1(0) => constant1_op_net,
      sel(0) => trig1_y_net,
      y(0) => mux2_y_net
    );

  posedge_ded70c1efe: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x334,
      clk_1 => clk_1_sg_x334,
      in_x0 => delay25_q_net_x0,
      out_x0 => logical_y_net_x0
    );

  register1: entity work.xlregister
    generic map (
      d_width => 10,
      init_value => b"0000000000"
    )
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      d => delay5_q_net,
      en(0) => delay7_q_net,
      rst(0) => delay6_q_net,
      q => register1_q_net_x0
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x334,
      clk => clk_1_sg_x334,
      d(0) => constant_op_net,
      en(0) => logical_y_net_x0,
      rst(0) => logical1_y_net,
      q(0) => register_q_net_x0
    );

  reinterpret: entity work.reinterpret_3f7e3674f6
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => delay1_q_net,
      output_port => reinterpret_output_port_net
    );

  trig1: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 1,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_avgiq_ctrl_user_data_out_net_x0,
      y(0) => trig1_y_net
    );

  valid: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 2,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_avgiq_ctrl_user_data_out_net_x0,
      y(0) => valid_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/capture/conv1"

entity conv1_entity_0673d685de is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in1: in std_logic_vector(11 downto 0); 
    out1: out std_logic_vector(11 downto 0)
  );
end conv1_entity_0673d685de;

architecture structural of conv1_entity_0673d685de is
  signal ce_1_sg_x335: std_logic;
  signal clk_1_sg_x335: std_logic;
  signal concat_y_net_x0: std_logic_vector(11 downto 0);
  signal convert1_dout_net_x0: std_logic_vector(11 downto 0);
  signal inverter_op_net: std_logic;
  signal reinterpret1_output_port_net: std_logic_vector(11 downto 0);
  signal slice1_y_net: std_logic_vector(10 downto 0);
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x335 <= ce_1;
  clk_1_sg_x335 <= clk_1;
  convert1_dout_net_x0 <= in1;
  out1 <= concat_y_net_x0;

  concat: entity work.concat_9769d05421
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0(0) => inverter_op_net,
      in1 => slice1_y_net,
      y => concat_y_net_x0
    );

  inverter: entity work.inverter_e2b989a05e
    port map (
      ce => ce_1_sg_x335,
      clk => clk_1_sg_x335,
      clr => '0',
      ip(0) => slice_y_net,
      op(0) => inverter_op_net
    );

  reinterpret1: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert1_dout_net_x0,
      output_port => reinterpret1_output_port_net
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 11,
      new_msb => 11,
      x_width => 12,
      y_width => 1
    )
    port map (
      x => reinterpret1_output_port_net,
      y(0) => slice_y_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 10,
      x_width => 12,
      y_width => 11
    )
    port map (
      x => reinterpret1_output_port_net,
      y => slice1_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/capture/deadtime"

entity deadtime_entity_2132d4ce1c is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end deadtime_entity_2132d4ce1c;

architecture structural of deadtime_entity_2132d4ce1c is
  signal ce_1_sg_x338: std_logic;
  signal clk_1_sg_x338: std_logic;
  signal delay100_q_net: std_logic;
  signal delay10_q_net: std_logic;
  signal delay11_q_net: std_logic;
  signal delay12_q_net: std_logic;
  signal delay13_q_net: std_logic;
  signal delay14_q_net: std_logic;
  signal delay15_q_net: std_logic;
  signal delay16_q_net: std_logic;
  signal delay17_q_net: std_logic;
  signal delay18_q_net: std_logic;
  signal delay19_q_net: std_logic;
  signal delay1_q_net: std_logic;
  signal delay20_q_net: std_logic;
  signal delay21_q_net: std_logic;
  signal delay22_q_net: std_logic;
  signal delay23_q_net: std_logic;
  signal delay24_q_net: std_logic;
  signal delay25_q_net: std_logic;
  signal delay26_q_net: std_logic;
  signal delay27_q_net: std_logic;
  signal delay28_q_net: std_logic;
  signal delay29_q_net: std_logic;
  signal delay2_q_net: std_logic;
  signal delay30_q_net: std_logic;
  signal delay31_q_net: std_logic;
  signal delay32_q_net: std_logic;
  signal delay33_q_net: std_logic;
  signal delay34_q_net: std_logic;
  signal delay35_q_net: std_logic;
  signal delay36_q_net: std_logic;
  signal delay37_q_net: std_logic;
  signal delay38_q_net: std_logic;
  signal delay39_q_net: std_logic;
  signal delay3_q_net: std_logic;
  signal delay40_q_net: std_logic;
  signal delay41_q_net: std_logic;
  signal delay42_q_net: std_logic;
  signal delay43_q_net: std_logic;
  signal delay44_q_net: std_logic;
  signal delay45_q_net: std_logic;
  signal delay46_q_net: std_logic;
  signal delay47_q_net: std_logic;
  signal delay48_q_net: std_logic;
  signal delay49_q_net: std_logic;
  signal delay4_q_net: std_logic;
  signal delay50_q_net: std_logic;
  signal delay51_q_net: std_logic;
  signal delay52_q_net: std_logic;
  signal delay53_q_net: std_logic;
  signal delay54_q_net: std_logic;
  signal delay55_q_net: std_logic;
  signal delay56_q_net: std_logic;
  signal delay57_q_net: std_logic;
  signal delay58_q_net: std_logic;
  signal delay59_q_net: std_logic;
  signal delay5_q_net: std_logic;
  signal delay60_q_net: std_logic;
  signal delay61_q_net: std_logic;
  signal delay62_q_net: std_logic;
  signal delay63_q_net: std_logic;
  signal delay64_q_net: std_logic;
  signal delay65_q_net: std_logic;
  signal delay66_q_net: std_logic;
  signal delay67_q_net: std_logic;
  signal delay68_q_net: std_logic;
  signal delay69_q_net: std_logic;
  signal delay6_q_net: std_logic;
  signal delay70_q_net: std_logic;
  signal delay71_q_net: std_logic;
  signal delay72_q_net: std_logic;
  signal delay73_q_net: std_logic;
  signal delay74_q_net: std_logic;
  signal delay75_q_net: std_logic;
  signal delay76_q_net: std_logic;
  signal delay77_q_net: std_logic;
  signal delay78_q_net: std_logic;
  signal delay79_q_net: std_logic;
  signal delay7_q_net: std_logic;
  signal delay80_q_net: std_logic;
  signal delay81_q_net: std_logic;
  signal delay82_q_net: std_logic;
  signal delay83_q_net: std_logic;
  signal delay84_q_net: std_logic;
  signal delay85_q_net: std_logic;
  signal delay86_q_net: std_logic;
  signal delay87_q_net: std_logic;
  signal delay88_q_net: std_logic;
  signal delay89_q_net: std_logic;
  signal delay8_q_net: std_logic;
  signal delay90_q_net: std_logic;
  signal delay91_q_net: std_logic;
  signal delay92_q_net: std_logic;
  signal delay93_q_net: std_logic;
  signal delay94_q_net: std_logic;
  signal delay95_q_net: std_logic;
  signal delay96_q_net: std_logic;
  signal delay97_q_net: std_logic;
  signal delay98_q_net: std_logic;
  signal delay99_q_net: std_logic;
  signal delay9_q_net: std_logic;
  signal logical7_y_net_x1: std_logic;
  signal logical7_y_net_x2: std_logic;

begin
  ce_1_sg_x338 <= ce_1;
  clk_1_sg_x338 <= clk_1;
  logical7_y_net_x1 <= in_x0;
  out_x0 <= logical7_y_net_x2;

  delay1: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay17_q_net,
      q(0) => delay1_q_net
    );

  delay10: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay11_q_net,
      q(0) => delay10_q_net
    );

  delay100: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay97_q_net,
      q(0) => delay100_q_net
    );

  delay11: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay8_q_net,
      q(0) => delay11_q_net
    );

  delay12: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay13_q_net,
      q(0) => delay12_q_net
    );

  delay13: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay10_q_net,
      q(0) => delay13_q_net
    );

  delay14: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay15_q_net,
      q(0) => delay14_q_net
    );

  delay15: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay12_q_net,
      q(0) => delay15_q_net
    );

  delay16: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay24_q_net,
      q(0) => delay16_q_net
    );

  delay17: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => logical7_y_net_x1,
      q(0) => delay17_q_net
    );

  delay18: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay19_q_net,
      q(0) => delay18_q_net
    );

  delay19: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay31_q_net,
      q(0) => delay19_q_net
    );

  delay2: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay3_q_net,
      q(0) => delay2_q_net
    );

  delay20: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay21_q_net,
      q(0) => delay20_q_net
    );

  delay21: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay18_q_net,
      q(0) => delay21_q_net
    );

  delay22: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay23_q_net,
      q(0) => delay22_q_net
    );

  delay23: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay20_q_net,
      q(0) => delay23_q_net
    );

  delay24: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay14_q_net,
      q(0) => delay24_q_net
    );

  delay25: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay26_q_net,
      q(0) => delay25_q_net
    );

  delay26: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay16_q_net,
      q(0) => delay26_q_net
    );

  delay27: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay28_q_net,
      q(0) => delay27_q_net
    );

  delay28: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay25_q_net,
      q(0) => delay28_q_net
    );

  delay29: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay30_q_net,
      q(0) => delay29_q_net
    );

  delay3: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay1_q_net,
      q(0) => delay3_q_net
    );

  delay30: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay27_q_net,
      q(0) => delay30_q_net
    );

  delay31: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay32_q_net,
      q(0) => delay31_q_net
    );

  delay32: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay29_q_net,
      q(0) => delay32_q_net
    );

  delay33: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay34_q_net,
      q(0) => delay33_q_net
    );

  delay34: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay39_q_net,
      q(0) => delay34_q_net
    );

  delay35: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay36_q_net,
      q(0) => delay35_q_net
    );

  delay36: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay33_q_net,
      q(0) => delay36_q_net
    );

  delay37: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay38_q_net,
      q(0) => delay37_q_net
    );

  delay38: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay35_q_net,
      q(0) => delay38_q_net
    );

  delay39: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay40_q_net,
      q(0) => delay39_q_net
    );

  delay4: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay5_q_net,
      q(0) => delay4_q_net
    );

  delay40: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay22_q_net,
      q(0) => delay40_q_net
    );

  delay41: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay42_q_net,
      q(0) => delay41_q_net
    );

  delay42: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay47_q_net,
      q(0) => delay42_q_net
    );

  delay43: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay44_q_net,
      q(0) => delay43_q_net
    );

  delay44: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay41_q_net,
      q(0) => delay44_q_net
    );

  delay45: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay46_q_net,
      q(0) => delay45_q_net
    );

  delay46: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay43_q_net,
      q(0) => delay46_q_net
    );

  delay47: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay48_q_net,
      q(0) => delay47_q_net
    );

  delay48: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay37_q_net,
      q(0) => delay48_q_net
    );

  delay49: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay50_q_net,
      q(0) => delay49_q_net
    );

  delay5: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay2_q_net,
      q(0) => delay5_q_net
    );

  delay50: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay45_q_net,
      q(0) => delay50_q_net
    );

  delay51: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay59_q_net,
      q(0) => delay51_q_net
    );

  delay52: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay53_q_net,
      q(0) => delay52_q_net
    );

  delay53: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay99_q_net,
      q(0) => delay53_q_net
    );

  delay54: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay55_q_net,
      q(0) => delay54_q_net
    );

  delay55: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay52_q_net,
      q(0) => delay55_q_net
    );

  delay56: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay57_q_net,
      q(0) => delay56_q_net
    );

  delay57: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay54_q_net,
      q(0) => delay57_q_net
    );

  delay58: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay67_q_net,
      q(0) => delay58_q_net
    );

  delay59: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay49_q_net,
      q(0) => delay59_q_net
    );

  delay6: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay7_q_net,
      q(0) => delay6_q_net
    );

  delay60: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay61_q_net,
      q(0) => delay60_q_net
    );

  delay61: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay75_q_net,
      q(0) => delay61_q_net
    );

  delay62: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay73_q_net,
      q(0) => delay62_q_net
    );

  delay63: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay64_q_net,
      q(0) => delay63_q_net
    );

  delay64: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay60_q_net,
      q(0) => delay64_q_net
    );

  delay65: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay66_q_net,
      q(0) => delay65_q_net
    );

  delay66: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay63_q_net,
      q(0) => delay66_q_net
    );

  delay67: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay56_q_net,
      q(0) => delay67_q_net
    );

  delay68: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay69_q_net,
      q(0) => delay68_q_net
    );

  delay69: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay58_q_net,
      q(0) => delay69_q_net
    );

  delay7: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay4_q_net,
      q(0) => delay7_q_net
    );

  delay70: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay71_q_net,
      q(0) => delay70_q_net
    );

  delay71: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay68_q_net,
      q(0) => delay71_q_net
    );

  delay72: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay74_q_net,
      q(0) => delay72_q_net
    );

  delay73: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay51_q_net,
      q(0) => delay73_q_net
    );

  delay74: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay70_q_net,
      q(0) => delay74_q_net
    );

  delay75: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay76_q_net,
      q(0) => delay75_q_net
    );

  delay76: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay72_q_net,
      q(0) => delay76_q_net
    );

  delay77: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay78_q_net,
      q(0) => delay77_q_net
    );

  delay78: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay83_q_net,
      q(0) => delay78_q_net
    );

  delay79: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay80_q_net,
      q(0) => delay79_q_net
    );

  delay8: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay9_q_net,
      q(0) => delay8_q_net
    );

  delay80: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay77_q_net,
      q(0) => delay80_q_net
    );

  delay81: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay82_q_net,
      q(0) => delay81_q_net
    );

  delay82: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay79_q_net,
      q(0) => delay82_q_net
    );

  delay83: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay85_q_net,
      q(0) => delay83_q_net
    );

  delay84: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay95_q_net,
      q(0) => delay84_q_net
    );

  delay85: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay65_q_net,
      q(0) => delay85_q_net
    );

  delay86: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay87_q_net,
      q(0) => delay86_q_net
    );

  delay87: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay92_q_net,
      q(0) => delay87_q_net
    );

  delay88: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay89_q_net,
      q(0) => delay88_q_net
    );

  delay89: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay86_q_net,
      q(0) => delay89_q_net
    );

  delay9: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay6_q_net,
      q(0) => delay9_q_net
    );

  delay90: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay91_q_net,
      q(0) => delay90_q_net
    );

  delay91: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay88_q_net,
      q(0) => delay91_q_net
    );

  delay92: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay93_q_net,
      q(0) => delay92_q_net
    );

  delay93: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay81_q_net,
      q(0) => delay93_q_net
    );

  delay94: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay96_q_net,
      q(0) => delay94_q_net
    );

  delay95: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay62_q_net,
      q(0) => delay95_q_net
    );

  delay96: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay90_q_net,
      q(0) => delay96_q_net
    );

  delay97: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay98_q_net,
      q(0) => delay97_q_net
    );

  delay98: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay84_q_net,
      q(0) => delay98_q_net
    );

  delay99: entity work.delay_7c89945f61
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d(0) => delay100_q_net,
      q(0) => delay99_q_net
    );

  logical7: entity work.logical_4d76082fb2
    port map (
      ce => ce_1_sg_x338,
      clk => clk_1_sg_x338,
      clr => '0',
      d0(0) => delay17_q_net,
      d1(0) => delay1_q_net,
      d10(0) => delay11_q_net,
      d11(0) => delay10_q_net,
      d12(0) => delay13_q_net,
      d13(0) => delay12_q_net,
      d14(0) => delay15_q_net,
      d15(0) => delay14_q_net,
      d16(0) => delay24_q_net,
      d17(0) => delay16_q_net,
      d18(0) => delay26_q_net,
      d19(0) => delay25_q_net,
      d2(0) => delay3_q_net,
      d20(0) => delay28_q_net,
      d21(0) => delay27_q_net,
      d22(0) => delay30_q_net,
      d23(0) => delay29_q_net,
      d24(0) => delay32_q_net,
      d25(0) => delay31_q_net,
      d26(0) => delay19_q_net,
      d27(0) => delay18_q_net,
      d28(0) => delay21_q_net,
      d29(0) => delay20_q_net,
      d3(0) => delay2_q_net,
      d30(0) => delay23_q_net,
      d31(0) => delay22_q_net,
      d32(0) => delay40_q_net,
      d33(0) => delay39_q_net,
      d34(0) => delay34_q_net,
      d35(0) => delay33_q_net,
      d36(0) => delay36_q_net,
      d37(0) => delay35_q_net,
      d38(0) => delay38_q_net,
      d39(0) => delay37_q_net,
      d4(0) => delay5_q_net,
      d40(0) => delay48_q_net,
      d41(0) => delay47_q_net,
      d42(0) => delay42_q_net,
      d43(0) => delay41_q_net,
      d44(0) => delay44_q_net,
      d45(0) => delay43_q_net,
      d46(0) => delay46_q_net,
      d47(0) => delay45_q_net,
      d48(0) => delay50_q_net,
      d49(0) => delay49_q_net,
      d5(0) => delay4_q_net,
      d50(0) => delay59_q_net,
      d51(0) => delay51_q_net,
      d52(0) => delay73_q_net,
      d53(0) => delay62_q_net,
      d54(0) => delay95_q_net,
      d55(0) => delay84_q_net,
      d56(0) => delay98_q_net,
      d57(0) => delay97_q_net,
      d58(0) => delay100_q_net,
      d59(0) => delay99_q_net,
      d6(0) => delay7_q_net,
      d60(0) => delay53_q_net,
      d61(0) => delay52_q_net,
      d62(0) => delay55_q_net,
      d63(0) => delay54_q_net,
      d64(0) => delay57_q_net,
      d65(0) => delay56_q_net,
      d66(0) => delay67_q_net,
      d67(0) => delay58_q_net,
      d68(0) => delay69_q_net,
      d69(0) => delay68_q_net,
      d7(0) => delay6_q_net,
      d70(0) => delay71_q_net,
      d71(0) => delay70_q_net,
      d72(0) => delay74_q_net,
      d73(0) => delay72_q_net,
      d74(0) => delay76_q_net,
      d75(0) => delay75_q_net,
      d76(0) => delay61_q_net,
      d77(0) => delay60_q_net,
      d78(0) => delay64_q_net,
      d79(0) => delay63_q_net,
      d8(0) => delay9_q_net,
      d80(0) => delay66_q_net,
      d81(0) => delay65_q_net,
      d82(0) => delay85_q_net,
      d83(0) => delay83_q_net,
      d84(0) => delay78_q_net,
      d85(0) => delay77_q_net,
      d86(0) => delay80_q_net,
      d87(0) => delay79_q_net,
      d88(0) => delay82_q_net,
      d89(0) => delay81_q_net,
      d9(0) => delay8_q_net,
      d90(0) => delay93_q_net,
      d91(0) => delay92_q_net,
      d92(0) => delay87_q_net,
      d93(0) => delay86_q_net,
      d94(0) => delay89_q_net,
      d95(0) => delay88_q_net,
      d96(0) => delay91_q_net,
      d97(0) => delay90_q_net,
      d98(0) => delay96_q_net,
      d99(0) => delay94_q_net,
      y(0) => logical7_y_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/capture"

entity capture_entity_5ab9a605d4 is
  port (
    ce_1: in std_logic; 
    ch_in: in std_logic_vector(7 downto 0); 
    chan_512_clean_capture_load_thresh_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_capture_threshold_user_data_out: in std_logic_vector(31 downto 0); 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(15 downto 0); 
    sync_in: in std_logic; 
    data_out: out std_logic_vector(63 downto 0); 
    sync_out: out std_logic; 
    we_out: out std_logic
  );
end capture_entity_5ab9a605d4;

architecture structural of capture_entity_5ab9a605d4 is
  signal addsub3_s_net: std_logic_vector(15 downto 0);
  signal ce_1_sg_x339: std_logic;
  signal chan_512_clean_capture_load_thresh_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_capture_threshold_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal clk_1_sg_x339: std_logic;
  signal concat1_y_net_x0: std_logic_vector(63 downto 0);
  signal concat_y_net_x0: std_logic_vector(11 downto 0);
  signal concat_y_net_x1: std_logic_vector(11 downto 0);
  signal concat_y_net_x2: std_logic_vector(11 downto 0);
  signal constant1_op_net: std_logic_vector(11 downto 0);
  signal constant2_op_net: std_logic_vector(11 downto 0);
  signal constant4_op_net: std_logic_vector(11 downto 0);
  signal convert1_dout_net_x0: std_logic_vector(11 downto 0);
  signal convert2_dout_net_x0: std_logic_vector(15 downto 0);
  signal convert3_dout_net_x0: std_logic_vector(11 downto 0);
  signal convert5_dout_net_x0: std_logic_vector(11 downto 0);
  signal delay10_q_net: std_logic_vector(15 downto 0);
  signal delay11_q_net: std_logic_vector(15 downto 0);
  signal delay12_q_net: std_logic_vector(7 downto 0);
  signal delay13_q_net: std_logic_vector(15 downto 0);
  signal delay14_q_net: std_logic_vector(15 downto 0);
  signal delay15_q_net: std_logic_vector(15 downto 0);
  signal delay16_q_net: std_logic_vector(15 downto 0);
  signal delay17_q_net: std_logic_vector(15 downto 0);
  signal delay18_q_net: std_logic_vector(15 downto 0);
  signal delay19_q_net: std_logic_vector(27 downto 0);
  signal delay1_q_net: std_logic;
  signal delay20_q_net: std_logic_vector(15 downto 0);
  signal delay21_q_net: std_logic_vector(15 downto 0);
  signal delay22_q_net: std_logic_vector(15 downto 0);
  signal delay23_q_net: std_logic_vector(15 downto 0);
  signal delay24_q_net: std_logic;
  signal delay24_q_net_x1: std_logic_vector(7 downto 0);
  signal delay25_q_net: std_logic_vector(7 downto 0);
  signal delay26_q_net: std_logic_vector(15 downto 0);
  signal delay27_q_net: std_logic_vector(15 downto 0);
  signal delay28_q_net: std_logic_vector(15 downto 0);
  signal delay29_q_net: std_logic_vector(27 downto 0);
  signal delay2_q_net: std_logic_vector(31 downto 0);
  signal delay30_q_net: std_logic;
  signal delay31_q_net: std_logic;
  signal delay32_q_net: std_logic_vector(15 downto 0);
  signal delay33_q_net: std_logic_vector(7 downto 0);
  signal delay34_q_net: std_logic;
  signal delay35_q_net: std_logic_vector(7 downto 0);
  signal delay36_q_net: std_logic_vector(15 downto 0);
  signal delay37_q_net: std_logic_vector(15 downto 0);
  signal delay38_q_net: std_logic;
  signal delay39_q_net: std_logic;
  signal delay3_q_net: std_logic_vector(31 downto 0);
  signal delay40_q_net: std_logic;
  signal delay41_q_net: std_logic;
  signal delay42_q_net: std_logic_vector(27 downto 0);
  signal delay43_q_net: std_logic_vector(15 downto 0);
  signal delay44_q_net: std_logic_vector(15 downto 0);
  signal delay45_q_net: std_logic_vector(27 downto 0);
  signal delay46_q_net_x0: std_logic;
  signal delay47_q_net: std_logic_vector(15 downto 0);
  signal delay48_q_net: std_logic_vector(15 downto 0);
  signal delay49_q_net: std_logic_vector(15 downto 0);
  signal delay4_q_net: std_logic_vector(15 downto 0);
  signal delay5_q_net: std_logic_vector(15 downto 0);
  signal delay6_q_net: std_logic_vector(15 downto 0);
  signal delay7_q_net: std_logic_vector(7 downto 0);
  signal delay8_q_net: std_logic_vector(7 downto 0);
  signal delay9_q_net: std_logic_vector(7 downto 0);
  signal logical1_y_net_x0: std_logic;
  signal logical7_y_net_x1: std_logic;
  signal logical7_y_net_x2: std_logic;
  signal logical_y_net_x0: std_logic;
  signal lut_counter1_op_net: std_logic_vector(27 downto 0);
  signal mux1_y_net: std_logic_vector(7 downto 0);
  signal reinterpret1_output_port_net: std_logic_vector(15 downto 0);
  signal relational1_op_net: std_logic;
  signal relational2_op_net: std_logic;
  signal relational3_op_net: std_logic;
  signal relational4_op_net: std_logic;
  signal single_port_ram_data_out_net: std_logic_vector(15 downto 0);
  signal slice13_y_net: std_logic;
  signal slice14_y_net: std_logic_vector(7 downto 0);
  signal slice1_y_net: std_logic_vector(19 downto 0);
  signal slice5_y_net: std_logic_vector(15 downto 0);

begin
  ce_1_sg_x339 <= ce_1;
  delay24_q_net_x1 <= ch_in;
  chan_512_clean_capture_load_thresh_user_data_out_net_x0 <= chan_512_clean_capture_load_thresh_user_data_out;
  chan_512_clean_capture_threshold_user_data_out_net_x0 <= chan_512_clean_capture_threshold_user_data_out;
  clk_1_sg_x339 <= clk_1;
  convert2_dout_net_x0 <= data_in;
  logical_y_net_x0 <= sync_in;
  data_out <= concat1_y_net_x0;
  sync_out <= delay46_q_net_x0;
  we_out <= logical1_y_net_x0;

  addsub3: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 13,
      a_width => 16,
      b_arith => xlSigned,
      b_bin_pt => 13,
      b_width => 16,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 17,
      core_name0 => "addsb_11_0_e4163618072387e1",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 17,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 13,
      s_width => 16
    )
    port map (
      a => delay4_q_net,
      b => delay14_q_net,
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      en => "1",
      s => addsub3_s_net
    );

  concat1: entity work.concat_bff132f7f1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => delay33_q_net,
      in1 => concat_y_net_x1,
      in2 => concat_y_net_x0,
      in3 => concat_y_net_x2,
      in4 => slice1_y_net,
      y => concat1_y_net_x0
    );

  constant1: entity work.constant_fd28b32bf8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_fd28b32bf8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant4: entity work.constant_fd28b32bf8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant4_op_net
    );

  conv1_0673d685de: entity work.conv1_entity_0673d685de
    port map (
      ce_1 => ce_1_sg_x339,
      clk_1 => clk_1_sg_x339,
      in1 => convert1_dout_net_x0,
      out1 => concat_y_net_x0
    );

  conv2_14b969e359: entity work.conv1_entity_0673d685de
    port map (
      ce_1 => ce_1_sg_x339,
      clk_1 => clk_1_sg_x339,
      in1 => convert3_dout_net_x0,
      out1 => concat_y_net_x1
    );

  conv3_f0b15c0cbf: entity work.conv1_entity_0673d685de
    port map (
      ce_1 => ce_1_sg_x339,
      clk_1 => clk_1_sg_x339,
      in1 => convert5_dout_net_x0,
      out1 => concat_y_net_x2
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 13,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 9,
      dout_width => 12,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => delay37_q_net,
      dout => convert1_dout_net_x0
    );

  convert3: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 13,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 9,
      dout_width => 12,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => delay36_q_net,
      dout => convert3_dout_net_x0
    );

  convert5: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 13,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 9,
      dout_width => 12,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => delay44_q_net,
      dout => convert5_dout_net_x0
    );

  deadtime_2132d4ce1c: entity work.deadtime_entity_2132d4ce1c
    port map (
      ce_1 => ce_1_sg_x339,
      clk_1 => clk_1_sg_x339,
      in_x0 => logical7_y_net_x1,
      out_x0 => logical7_y_net_x2
    );

  delay1: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => slice13_y_net,
      q(0) => delay1_q_net
    );

  delay10: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => convert2_dout_net_x0,
      q => delay10_q_net
    );

  delay11: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay5_q_net,
      q => delay11_q_net
    );

  delay12: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay35_q_net,
      q => delay12_q_net
    );

  delay13: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay47_q_net,
      q => delay13_q_net
    );

  delay14: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay4_q_net,
      q => delay14_q_net
    );

  delay15: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay43_q_net,
      q => delay15_q_net
    );

  delay16: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => reinterpret1_output_port_net,
      q => delay16_q_net
    );

  delay17: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay32_q_net,
      q => delay17_q_net
    );

  delay18: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay20_q_net,
      q => delay18_q_net
    );

  delay19: entity work.delay_e87587164e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay42_q_net,
      q => delay19_q_net
    );

  delay2: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => chan_512_clean_capture_load_thresh_user_data_out_net_x0,
      q => delay2_q_net
    );

  delay20: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay48_q_net,
      q => delay20_q_net
    );

  delay21: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay23_q_net,
      q => delay21_q_net
    );

  delay22: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => addsub3_s_net,
      q => delay22_q_net
    );

  delay23: entity work.delay_6b0a1b970e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay4_q_net,
      q => delay23_q_net
    );

  delay24: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => logical7_y_net_x1,
      q(0) => delay24_q_net
    );

  delay25: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay12_q_net,
      q => delay25_q_net
    );

  delay26: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay15_q_net,
      q => delay26_q_net
    );

  delay27: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay17_q_net,
      q => delay27_q_net
    );

  delay28: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay18_q_net,
      q => delay28_q_net
    );

  delay29: entity work.delay_e87587164e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay19_q_net,
      q => delay29_q_net
    );

  delay3: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => chan_512_clean_capture_threshold_user_data_out_net_x0,
      q => delay3_q_net
    );

  delay30: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => delay31_q_net,
      q(0) => delay30_q_net
    );

  delay31: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => delay41_q_net,
      q(0) => delay31_q_net
    );

  delay32: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay49_q_net,
      q => delay32_q_net
    );

  delay33: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay25_q_net,
      q => delay33_q_net
    );

  delay34: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => relational1_op_net,
      q(0) => delay34_q_net
    );

  delay35: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay7_q_net,
      q => delay35_q_net
    );

  delay36: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay26_q_net,
      q => delay36_q_net
    );

  delay37: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay27_q_net,
      q => delay37_q_net
    );

  delay38: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => delay40_q_net,
      q(0) => delay38_q_net
    );

  delay39: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => logical_y_net_x0,
      q(0) => delay39_q_net
    );

  delay4: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => convert2_dout_net_x0,
      q => delay4_q_net
    );

  delay40: entity work.delay_23d71a76f2
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => delay39_q_net,
      q(0) => delay40_q_net
    );

  delay41: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => delay38_q_net,
      q(0) => delay41_q_net
    );

  delay42: entity work.delay_e87587164e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => lut_counter1_op_net,
      q => delay42_q_net
    );

  delay43: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay32_q_net,
      q => delay43_q_net
    );

  delay44: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay28_q_net,
      q => delay44_q_net
    );

  delay45: entity work.delay_e87587164e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay29_q_net,
      q => delay45_q_net
    );

  delay46: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d(0) => delay30_q_net,
      q(0) => delay46_q_net_x0
    );

  delay47: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay22_q_net,
      q => delay47_q_net
    );

  delay48: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay21_q_net,
      q => delay48_q_net
    );

  delay49: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay11_q_net,
      q => delay49_q_net
    );

  delay5: entity work.delay_6b0a1b970e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay14_q_net,
      q => delay5_q_net
    );

  delay6: entity work.delay_6b0a1b970e
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay10_q_net,
      q => delay6_q_net
    );

  delay7: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay8_q_net,
      q => delay7_q_net
    );

  delay8: entity work.delay_9565135955
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay9_q_net,
      q => delay8_q_net
    );

  delay9: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d => delay24_q_net_x1,
      q => delay9_q_net
    );

  logical1: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d0(0) => delay24_q_net,
      d1(0) => logical7_y_net_x2,
      y(0) => logical1_y_net_x0
    );

  logical7: entity work.logical_ef735095f8
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d0(0) => relational4_op_net,
      d1(0) => relational3_op_net,
      d2(0) => relational2_op_net,
      d3(0) => delay34_q_net,
      y(0) => logical7_y_net_x1
    );

  lut_counter1: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_7f0d56fd1dcf9c88",
      op_arith => xlUnsigned,
      op_width => 28
    )
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      en => "1",
      rst(0) => delay40_q_net,
      op => lut_counter1_op_net
    );

  mux1: entity work.mux_cc14a035dc
    port map (
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      d0 => delay24_q_net_x1,
      d1 => slice14_y_net,
      sel(0) => slice13_y_net,
      y => mux1_y_net
    );

  reinterpret1: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice5_y_net,
      output_port => reinterpret1_output_port_net
    );

  relational1: entity work.relational_b51dd42e71
    port map (
      a => delay6_q_net,
      b => single_port_ram_data_out_net,
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      op(0) => relational1_op_net
    );

  relational2: entity work.relational_95e7a52777
    port map (
      a => delay13_q_net,
      b => constant1_op_net,
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      op(0) => relational2_op_net
    );

  relational3: entity work.relational_4fce89e1d4
    port map (
      a => delay47_q_net,
      b => constant4_op_net,
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      op(0) => relational3_op_net
    );

  relational4: entity work.relational_4fce89e1d4
    port map (
      a => delay22_q_net,
      b => constant2_op_net,
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      clr => '0',
      op(0) => relational4_op_net
    );

  single_port_ram: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 16,
      core_name0 => "bmg_33_7b9ccf0344272f29",
      latency => 2
    )
    port map (
      addr => mux1_y_net,
      ce => ce_1_sg_x339,
      clk => clk_1_sg_x339,
      data_in => delay16_q_net,
      en => "1",
      rst => "0",
      we(0) => delay1_q_net,
      data_out => single_port_ram_data_out_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 27,
      x_width => 28,
      y_width => 20
    )
    port map (
      x => delay45_q_net,
      y => slice1_y_net
    );

  slice13: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => delay2_q_net,
      y(0) => slice13_y_net
    );

  slice14: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 8,
      x_width => 32,
      y_width => 8
    )
    port map (
      x => delay2_q_net,
      y => slice14_y_net
    );

  slice5: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 15,
      x_width => 32,
      y_width => 16
    )
    port map (
      x => delay3_q_net,
      y => slice5_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/conv_phase/c_to_ri5"

entity c_to_ri5_entity_9fb1807ed6 is
  port (
    c: in std_logic_vector(31 downto 0); 
    im: out std_logic_vector(15 downto 0); 
    re: out std_logic_vector(15 downto 0)
  );
end c_to_ri5_entity_9fb1807ed6;

architecture structural of c_to_ri5_entity_9fb1807ed6 is
  signal force_im_output_port_net_x0: std_logic_vector(15 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(15 downto 0);
  signal single_port_ram1_data_out_net_x0: std_logic_vector(31 downto 0);
  signal slice_im_y_net: std_logic_vector(15 downto 0);
  signal slice_re_y_net: std_logic_vector(15 downto 0);

begin
  single_port_ram1_data_out_net_x0 <= c;
  im <= force_im_output_port_net_x0;
  re <= force_re_output_port_net_x0;

  force_im: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_im_y_net,
      output_port => force_im_output_port_net_x0
    );

  force_re: entity work.reinterpret_151459306d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => slice_re_y_net,
      output_port => force_re_output_port_net_x0
    );

  slice_im: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 15,
      x_width => 32,
      y_width => 16
    )
    port map (
      x => single_port_ram1_data_out_net_x0,
      y => slice_im_y_net
    );

  slice_re: entity work.xlslice
    generic map (
      new_lsb => 16,
      new_msb => 31,
      x_width => 32,
      y_width => 16
    )
    port map (
      x => single_port_ram1_data_out_net_x0,
      y => slice_re_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/conv_phase/lpf_fir_i"

entity lpf_fir_i_entity_a1dd071de4 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data0: in std_logic_vector(18 downto 0); 
    data1: in std_logic_vector(18 downto 0); 
    data_out: out std_logic_vector(18 downto 0)
  );
end lpf_fir_i_entity_a1dd071de4;

architecture structural of lpf_fir_i_entity_a1dd071de4 is
  signal addsub10_s_net: std_logic_vector(35 downto 0);
  signal addsub11_s_net: std_logic_vector(36 downto 0);
  signal addsub12_s_net_x0: std_logic_vector(18 downto 0);
  signal addsub13_s_net: std_logic_vector(37 downto 0);
  signal addsub15_s_net: std_logic_vector(36 downto 0);
  signal addsub16_s_net: std_logic_vector(36 downto 0);
  signal addsub18_s_net: std_logic_vector(37 downto 0);
  signal addsub20_s_net: std_logic_vector(38 downto 0);
  signal addsub25_s_net: std_logic_vector(35 downto 0);
  signal addsub2_s_net: std_logic_vector(35 downto 0);
  signal addsub3_s_net: std_logic_vector(35 downto 0);
  signal addsub4_s_net: std_logic_vector(35 downto 0);
  signal addsub5_s_net: std_logic_vector(35 downto 0);
  signal addsub6_s_net: std_logic_vector(36 downto 0);
  signal addsub7_s_net: std_logic_vector(35 downto 0);
  signal addsub8_s_net: std_logic_vector(35 downto 0);
  signal addsub9_s_net: std_logic_vector(35 downto 0);
  signal ce_1_sg_x340: std_logic;
  signal clk_1_sg_x340: std_logic;
  signal constant10_op_net: std_logic_vector(15 downto 0);
  signal constant11_op_net: std_logic_vector(15 downto 0);
  signal constant12_op_net: std_logic_vector(15 downto 0);
  signal constant13_op_net: std_logic_vector(15 downto 0);
  signal constant14_op_net: std_logic_vector(15 downto 0);
  signal constant15_op_net: std_logic_vector(15 downto 0);
  signal constant16_op_net: std_logic_vector(15 downto 0);
  signal constant18_op_net: std_logic_vector(15 downto 0);
  signal constant1_op_net: std_logic_vector(15 downto 0);
  signal constant21_op_net: std_logic_vector(15 downto 0);
  signal constant2_op_net: std_logic_vector(15 downto 0);
  signal constant3_op_net: std_logic_vector(15 downto 0);
  signal constant4_op_net: std_logic_vector(15 downto 0);
  signal constant5_op_net: std_logic_vector(15 downto 0);
  signal constant6_op_net: std_logic_vector(15 downto 0);
  signal constant7_op_net: std_logic_vector(15 downto 0);
  signal constant8_op_net: std_logic_vector(15 downto 0);
  signal constant9_op_net: std_logic_vector(15 downto 0);
  signal delay10_q_net: std_logic_vector(18 downto 0);
  signal delay11_q_net: std_logic_vector(18 downto 0);
  signal delay12_q_net: std_logic_vector(18 downto 0);
  signal delay13_q_net: std_logic_vector(18 downto 0);
  signal delay14_q_net: std_logic_vector(18 downto 0);
  signal delay15_q_net: std_logic_vector(18 downto 0);
  signal delay16_q_net: std_logic_vector(37 downto 0);
  signal delay17_q_net: std_logic_vector(18 downto 0);
  signal delay18_q_net: std_logic_vector(18 downto 0);
  signal delay19_q_net: std_logic_vector(18 downto 0);
  signal delay1_q_net: std_logic_vector(18 downto 0);
  signal delay2_q_net: std_logic_vector(18 downto 0);
  signal delay3_q_net: std_logic_vector(18 downto 0);
  signal delay4_q_net: std_logic_vector(18 downto 0);
  signal delay5_q_net: std_logic_vector(18 downto 0);
  signal delay6_q_net: std_logic_vector(18 downto 0);
  signal delay7_q_net: std_logic_vector(18 downto 0);
  signal delay8_q_net: std_logic_vector(18 downto 0);
  signal delay9_q_net: std_logic_vector(35 downto 0);
  signal force_re_output_port_net_x2: std_logic_vector(18 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(18 downto 0);
  signal mult10_p_net: std_logic_vector(34 downto 0);
  signal mult11_p_net: std_logic_vector(34 downto 0);
  signal mult12_p_net: std_logic_vector(34 downto 0);
  signal mult13_p_net: std_logic_vector(34 downto 0);
  signal mult14_p_net: std_logic_vector(34 downto 0);
  signal mult15_p_net: std_logic_vector(34 downto 0);
  signal mult16_p_net: std_logic_vector(34 downto 0);
  signal mult17_p_net: std_logic_vector(34 downto 0);
  signal mult1_p_net: std_logic_vector(34 downto 0);
  signal mult2_p_net: std_logic_vector(34 downto 0);
  signal mult3_p_net: std_logic_vector(34 downto 0);
  signal mult4_p_net: std_logic_vector(34 downto 0);
  signal mult5_p_net: std_logic_vector(34 downto 0);
  signal mult6_p_net: std_logic_vector(34 downto 0);
  signal mult7_p_net: std_logic_vector(34 downto 0);
  signal mult8_p_net: std_logic_vector(34 downto 0);
  signal mult9_p_net: std_logic_vector(34 downto 0);
  signal mult_p_net: std_logic_vector(34 downto 0);

begin
  ce_1_sg_x340 <= ce_1;
  clk_1_sg_x340 <= clk_1;
  force_re_output_port_net_x3 <= data0;
  force_re_output_port_net_x2 <= data1;
  data_out <= addsub12_s_net_x0;

  addsub10: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult8_p_net,
      b => mult9_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub10_s_net
    );

  addsub11: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 36,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 36,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 37,
      core_name0 => "addsb_11_0_8202536b6c80d41d",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 37,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 37
    )
    port map (
      a => addsub8_s_net,
      b => addsub9_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub11_s_net
    );

  addsub12: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 38,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 39,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 40,
      core_name0 => "addsb_11_0_d1f449097ed0a158",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 40,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 17,
      s_width => 19
    )
    port map (
      a => delay16_q_net,
      b => addsub20_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub12_s_net_x0
    );

  addsub13: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 37,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 37,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 38,
      core_name0 => "addsb_11_0_cb3661bea5598abb",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 38,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 38
    )
    port map (
      a => addsub6_s_net,
      b => addsub11_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub13_s_net
    );

  addsub15: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 36,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 36,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 37,
      core_name0 => "addsb_11_0_8202536b6c80d41d",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 37,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 37
    )
    port map (
      a => addsub3_s_net,
      b => addsub4_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub15_s_net
    );

  addsub16: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 36,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 36,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 37,
      core_name0 => "addsb_11_0_8202536b6c80d41d",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 37,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 37
    )
    port map (
      a => addsub10_s_net,
      b => addsub2_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub16_s_net
    );

  addsub18: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 37,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 37,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 38,
      core_name0 => "addsb_11_0_cb3661bea5598abb",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 38,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 38
    )
    port map (
      a => addsub16_s_net,
      b => addsub15_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub18_s_net
    );

  addsub2: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult10_p_net,
      b => mult11_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub2_s_net
    );

  addsub20: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 38,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 36,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 39,
      core_name0 => "addsb_11_0_b20b7f8d49b0a0e3",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 39,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 39
    )
    port map (
      a => addsub18_s_net,
      b => delay9_q_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub20_s_net
    );

  addsub25: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult_p_net,
      b => mult1_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub25_s_net
    );

  addsub3: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult12_p_net,
      b => mult13_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub3_s_net
    );

  addsub4: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult14_p_net,
      b => mult15_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub4_s_net
    );

  addsub5: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult2_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub5_s_net
    );

  addsub6: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 36,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 36,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 37,
      core_name0 => "addsb_11_0_8202536b6c80d41d",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 37,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 37
    )
    port map (
      a => addsub25_s_net,
      b => addsub5_s_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub6_s_net
    );

  addsub7: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult16_p_net,
      b => mult17_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub7_s_net
    );

  addsub8: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult4_p_net,
      b => mult5_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub8_s_net
    );

  addsub9: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 35,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 35,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 36,
      core_name0 => "addsb_11_0_a94e57b72e53038c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 36,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 32,
      s_width => 36
    )
    port map (
      a => mult6_p_net,
      b => mult7_p_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      en => "1",
      s => addsub9_s_net
    );

  constant1: entity work.constant_849bf26a85
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant10: entity work.constant_b21de8e88c
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant10_op_net
    );

  constant11: entity work.constant_38693a92fc
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant11_op_net
    );

  constant12: entity work.constant_fecdaebdac
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant12_op_net
    );

  constant13: entity work.constant_849bf26a85
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant13_op_net
    );

  constant14: entity work.constant_868823282d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant14_op_net
    );

  constant15: entity work.constant_4f7110b9df
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant15_op_net
    );

  constant16: entity work.constant_6d7e90dc38
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant16_op_net
    );

  constant18: entity work.constant_6d7e90dc38
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant18_op_net
    );

  constant2: entity work.constant_fecdaebdac
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant21: entity work.constant_49503e1b2c
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant21_op_net
    );

  constant3: entity work.constant_868823282d
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant3_op_net
    );

  constant4: entity work.constant_49503e1b2c
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant4_op_net
    );

  constant5: entity work.constant_b21de8e88c
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  constant6: entity work.constant_4f7110b9df
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant6_op_net
    );

  constant7: entity work.constant_441c64cbf0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant7_op_net
    );

  constant8: entity work.constant_441c64cbf0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant8_op_net
    );

  constant9: entity work.constant_38693a92fc
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant9_op_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay13_q_net,
      en => '1',
      q => delay1_q_net
    );

  delay10: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay7_q_net,
      en => '1',
      q => delay10_q_net
    );

  delay11: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay8_q_net,
      en => '1',
      q => delay11_q_net
    );

  delay12: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay10_q_net,
      en => '1',
      q => delay12_q_net
    );

  delay13: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay11_q_net,
      en => '1',
      q => delay13_q_net
    );

  delay14: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => force_re_output_port_net_x2,
      en => '1',
      q => delay14_q_net
    );

  delay15: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay3_q_net,
      en => '1',
      q => delay15_q_net
    );

  delay16: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 38
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => addsub13_s_net,
      en => '1',
      q => delay16_q_net
    );

  delay17: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay4_q_net,
      en => '1',
      q => delay17_q_net
    );

  delay18: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay17_q_net,
      en => '1',
      q => delay18_q_net
    );

  delay19: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay15_q_net,
      en => '1',
      q => delay19_q_net
    );

  delay2: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay12_q_net,
      en => '1',
      q => delay2_q_net
    );

  delay3: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay1_q_net,
      en => '1',
      q => delay3_q_net
    );

  delay4: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay2_q_net,
      en => '1',
      q => delay4_q_net
    );

  delay5: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => force_re_output_port_net_x3,
      en => '1',
      q => delay5_q_net
    );

  delay6: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay14_q_net,
      en => '1',
      q => delay6_q_net
    );

  delay7: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay5_q_net,
      en => '1',
      q => delay7_q_net
    );

  delay8: entity work.xldelay
    generic map (
      latency => 256,
      reg_retiming => 0,
      width => 19
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => delay6_q_net,
      en => '1',
      q => delay8_q_net
    );

  delay9: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 36
    )
    port map (
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      d => addsub7_s_net,
      en => '1',
      q => delay9_q_net
    );

  mult: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => force_re_output_port_net_x3,
      b => constant21_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult_p_net
    );

  mult1: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay14_q_net,
      b => constant18_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult1_p_net
    );

  mult10: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay2_q_net,
      b => constant8_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult10_p_net
    );

  mult11: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay1_q_net,
      b => constant10_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult11_p_net
    );

  mult12: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay4_q_net,
      b => constant12_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult12_p_net
    );

  mult13: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay3_q_net,
      b => constant13_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult13_p_net
    );

  mult14: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay17_q_net,
      b => constant14_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult14_p_net
    );

  mult15: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay15_q_net,
      b => constant15_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult15_p_net
    );

  mult16: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay18_q_net,
      b => constant16_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult16_p_net
    );

  mult17: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay19_q_net,
      b => constant4_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult17_p_net
    );

  mult2: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay5_q_net,
      b => constant6_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult2_p_net
    );

  mult3: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay6_q_net,
      b => constant3_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult3_p_net
    );

  mult4: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay7_q_net,
      b => constant1_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult4_p_net
    );

  mult5: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay8_q_net,
      b => constant2_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult5_p_net
    );

  mult6: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay10_q_net,
      b => constant5_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult6_p_net
    );

  mult7: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay11_q_net,
      b => constant7_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult7_p_net
    );

  mult8: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay12_q_net,
      b => constant9_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult8_p_net
    );

  mult9: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 19,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 19,
      c_output_width => 35,
      c_type => 0,
      core_name0 => "mlt_11_2_e17173d75dc3e081",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 35,
      quantization => 1
    )
    port map (
      a => delay13_q_net,
      b => constant11_op_net,
      ce => ce_1_sg_x340,
      clk => clk_1_sg_x340,
      clr => '0',
      core_ce => ce_1_sg_x340,
      core_clk => clk_1_sg_x340,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult9_p_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/conv_phase"

entity conv_phase_entity_6fdedda9a4 is
  port (
    ce_1: in std_logic; 
    ch_in: in std_logic_vector(7 downto 0); 
    chan_512_clean_conv_phase_centers_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_conv_phase_load_centers_user_data_out: in std_logic_vector(31 downto 0); 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(75 downto 0); 
    ch_out: out std_logic_vector(7 downto 0); 
    phase_out: out std_logic_vector(11 downto 0)
  );
end conv_phase_entity_6fdedda9a4;

architecture structural of conv_phase_entity_6fdedda9a4 is
  signal addsub12_s_net_x0: std_logic_vector(18 downto 0);
  signal addsub12_s_net_x1: std_logic_vector(18 downto 0);
  signal addsub1_s_net: std_logic_vector(19 downto 0);
  signal addsub4_s_net: std_logic_vector(19 downto 0);
  signal ce_1_sg_x342: std_logic;
  signal chan_512_clean_conv_phase_centers_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal chan_512_clean_conv_phase_load_centers_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal clk_1_sg_x342: std_logic;
  signal cordic_4_0_phase_out_net_x0: std_logic_vector(11 downto 0);
  signal delay21_q_net: std_logic_vector(75 downto 0);
  signal delay2_q_net_x0: std_logic_vector(7 downto 0);
  signal delay3_q_net: std_logic;
  signal delay42_q_net_x0: std_logic_vector(75 downto 0);
  signal delay43_q_net_x0: std_logic_vector(7 downto 0);
  signal delay4_q_net: std_logic_vector(31 downto 0);
  signal delay5_q_net: std_logic_vector(15 downto 0);
  signal delay6_q_net: std_logic_vector(15 downto 0);
  signal force_im_output_port_net_x0: std_logic_vector(15 downto 0);
  signal force_im_output_port_net_x2: std_logic_vector(18 downto 0);
  signal force_im_output_port_net_x3: std_logic_vector(18 downto 0);
  signal force_re_output_port_net_x0: std_logic_vector(15 downto 0);
  signal force_re_output_port_net_x2: std_logic_vector(18 downto 0);
  signal force_re_output_port_net_x3: std_logic_vector(18 downto 0);
  signal mux2_y_net: std_logic_vector(7 downto 0);
  signal reinterpret2_output_port_net: std_logic_vector(19 downto 0);
  signal reinterpret3_output_port_net: std_logic_vector(19 downto 0);
  signal single_port_ram1_data_out_net_x0: std_logic_vector(31 downto 0);
  signal slice1_y_net_x0: std_logic_vector(37 downto 0);
  signal slice2_y_net_x0: std_logic_vector(37 downto 0);
  signal slice7_y_net: std_logic;
  signal slice8_y_net: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x342 <= ce_1;
  delay43_q_net_x0 <= ch_in;
  chan_512_clean_conv_phase_centers_user_data_out_net_x0 <= chan_512_clean_conv_phase_centers_user_data_out;
  chan_512_clean_conv_phase_load_centers_user_data_out_net_x0 <= chan_512_clean_conv_phase_load_centers_user_data_out;
  clk_1_sg_x342 <= clk_1;
  delay42_q_net_x0 <= data_in;
  ch_out <= delay2_q_net_x0;
  phase_out <= cordic_4_0_phase_out_net_x0;

  addsub1: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 14,
      b_width => 16,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 20,
      core_name0 => "addsb_11_0_f0f00f6bf49b954c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 20,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 17,
      s_width => 20
    )
    port map (
      a => addsub12_s_net_x1,
      b => delay6_q_net,
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      en => "1",
      s => addsub1_s_net
    );

  addsub4: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 19,
      b_arith => xlSigned,
      b_bin_pt => 14,
      b_width => 16,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 20,
      core_name0 => "addsb_11_0_f0f00f6bf49b954c",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 20,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 17,
      s_width => 20
    )
    port map (
      a => addsub12_s_net_x0,
      b => delay5_q_net,
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      en => "1",
      s => addsub4_s_net
    );

  c_to_ri1_5c92f685e7: entity work.c_to_ri1_entity_3e56016386
    port map (
      c => slice2_y_net_x0,
      im => force_im_output_port_net_x2,
      re => force_re_output_port_net_x2
    );

  c_to_ri5_9fb1807ed6: entity work.c_to_ri5_entity_9fb1807ed6
    port map (
      c => single_port_ram1_data_out_net_x0,
      im => force_im_output_port_net_x0,
      re => force_re_output_port_net_x0
    );

  c_to_ri6_c44cb3e092: entity work.c_to_ri1_entity_3e56016386
    port map (
      c => slice1_y_net_x0,
      im => force_im_output_port_net_x3,
      re => force_re_output_port_net_x3
    );

  cordic_4_0: entity work.xlcordic_ba9b5d087113091379cb63f1ef983f25
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      x_in => reinterpret2_output_port_net,
      y_in => reinterpret3_output_port_net,
      phase_out => cordic_4_0_phase_out_net_x0
    );

  delay2: entity work.delay_540951ccf5
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d => delay43_q_net_x0,
      q => delay2_q_net_x0
    );

  delay21: entity work.delay_889dfafe6f
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d => delay42_q_net_x0,
      q => delay21_q_net
    );

  delay3: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d(0) => slice7_y_net,
      q(0) => delay3_q_net
    );

  delay4: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d => chan_512_clean_conv_phase_centers_user_data_out_net_x0,
      q => delay4_q_net
    );

  delay5: entity work.delay_8ce7e9c57c
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d => force_re_output_port_net_x0,
      q => delay5_q_net
    );

  delay6: entity work.delay_8ce7e9c57c
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d => force_im_output_port_net_x0,
      q => delay6_q_net
    );

  lpf_fir_i_a1dd071de4: entity work.lpf_fir_i_entity_a1dd071de4
    port map (
      ce_1 => ce_1_sg_x342,
      clk_1 => clk_1_sg_x342,
      data0 => force_re_output_port_net_x3,
      data1 => force_re_output_port_net_x2,
      data_out => addsub12_s_net_x0
    );

  lpf_fir_q_c2301b4859: entity work.lpf_fir_i_entity_a1dd071de4
    port map (
      ce_1 => ce_1_sg_x342,
      clk_1 => clk_1_sg_x342,
      data0 => force_im_output_port_net_x3,
      data1 => force_im_output_port_net_x2,
      data_out => addsub12_s_net_x1
    );

  mux2: entity work.mux_cc14a035dc
    port map (
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      clr => '0',
      d0 => delay43_q_net_x0,
      d1 => slice8_y_net,
      sel(0) => slice7_y_net,
      y => mux2_y_net
    );

  reinterpret2: entity work.reinterpret_3f9089a15b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => addsub4_s_net,
      output_port => reinterpret2_output_port_net
    );

  reinterpret3: entity work.reinterpret_3f9089a15b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => addsub1_s_net,
      output_port => reinterpret3_output_port_net
    );

  single_port_ram1: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 32,
      core_name0 => "bmg_33_20f40af67413e471",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x342,
      clk => clk_1_sg_x342,
      data_in => delay4_q_net,
      en => "1",
      rst => "0",
      we(0) => delay3_q_net,
      data_out => single_port_ram1_data_out_net_x0
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 37,
      x_width => 76,
      y_width => 38
    )
    port map (
      x => delay21_q_net,
      y => slice1_y_net_x0
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 38,
      new_msb => 75,
      x_width => 76,
      y_width => 38
    )
    port map (
      x => delay21_q_net,
      y => slice2_y_net_x0
    );

  slice7: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_conv_phase_load_centers_user_data_out_net_x0,
      y(0) => slice7_y_net
    );

  slice8: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 8,
      x_width => 32,
      y_width => 8
    )
    port map (
      x => chan_512_clean_conv_phase_load_centers_user_data_out_net_x0,
      y => slice8_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/dac_mkid/pipeline5"

entity pipeline5_entity_a9368eaa10 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(15 downto 0); 
    q: out std_logic_vector(15 downto 0)
  );
end pipeline5_entity_a9368eaa10;

architecture structural of pipeline5_entity_a9368eaa10 is
  signal ce_1_sg_x345: std_logic;
  signal clk_1_sg_x345: std_logic;
  signal register0_q_net: std_logic_vector(15 downto 0);
  signal register1_q_net_x0: std_logic_vector(15 downto 0);
  signal reinterpret4_output_port_net_x1: std_logic_vector(15 downto 0);

begin
  ce_1_sg_x345 <= ce_1;
  clk_1_sg_x345 <= clk_1;
  reinterpret4_output_port_net_x1 <= d;
  q <= register1_q_net_x0;

  register0: entity work.xlregister
    generic map (
      d_width => 16,
      init_value => b"0000000000000000"
    )
    port map (
      ce => ce_1_sg_x345,
      clk => clk_1_sg_x345,
      d => reinterpret4_output_port_net_x1,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 16,
      init_value => b"0000000000000000"
    )
    port map (
      ce => ce_1_sg_x345,
      clk => clk_1_sg_x345,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/dac_mkid"

entity dac_mkid_entity_562389ae59 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_i0: in std_logic_vector(15 downto 0); 
    data_i1: in std_logic_vector(15 downto 0); 
    data_q0: in std_logic_vector(15 downto 0); 
    data_q1: in std_logic_vector(15 downto 0); 
    sync_i: in std_logic; 
    convert1_x0: out std_logic_vector(15 downto 0); 
    convert2_x0: out std_logic_vector(15 downto 0); 
    convert3_x0: out std_logic_vector(15 downto 0); 
    convert_not_reset_x0: out std_logic; 
    convert_not_sdenb_i_x0: out std_logic; 
    convert_not_sdenb_q_x0: out std_logic; 
    convert_sclk_x0: out std_logic; 
    convert_sdi_x0: out std_logic; 
    convert_sync_i_x0: out std_logic; 
    convert_sync_q_x0: out std_logic; 
    convert_x0: out std_logic_vector(15 downto 0)
  );
end dac_mkid_entity_562389ae59;

architecture structural of dac_mkid_entity_562389ae59 is
  signal ce_1_sg_x349: std_logic;
  signal clk_1_sg_x349: std_logic;
  signal constant1_op_net: std_logic;
  signal constant2_op_net: std_logic;
  signal constant4_op_net: std_logic;
  signal constant5_op_net: std_logic;
  signal convert1_dout_net_x0: std_logic_vector(15 downto 0);
  signal convert2_dout_net_x0: std_logic_vector(15 downto 0);
  signal convert3_dout_net_x0: std_logic_vector(15 downto 0);
  signal convert_dout_net_x0: std_logic_vector(15 downto 0);
  signal convert_not_reset_dout_net_x0: std_logic;
  signal convert_not_sdenb_i_dout_net_x0: std_logic;
  signal convert_not_sdenb_q_dout_net_x0: std_logic;
  signal convert_sclk_dout_net_x0: std_logic;
  signal convert_sdi_dout_net_x0: std_logic;
  signal convert_sync_i_dout_net_x0: std_logic;
  signal convert_sync_q_dout_net_x0: std_logic;
  signal inverter_op_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic_vector(15 downto 0);
  signal register1_q_net_x3: std_logic_vector(15 downto 0);
  signal register1_q_net_x4: std_logic_vector(15 downto 0);
  signal register1_q_net_x5: std_logic_vector(15 downto 0);
  signal reinterpret1_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret4_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret7_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret8_output_port_net_x2: std_logic_vector(15 downto 0);
  signal slice3_y_net_x4: std_logic;

begin
  ce_1_sg_x349 <= ce_1;
  clk_1_sg_x349 <= clk_1;
  reinterpret4_output_port_net_x2 <= data_i0;
  reinterpret1_output_port_net_x2 <= data_i1;
  reinterpret8_output_port_net_x2 <= data_q0;
  reinterpret7_output_port_net_x2 <= data_q1;
  slice3_y_net_x4 <= sync_i;
  convert1_x0 <= convert1_dout_net_x0;
  convert2_x0 <= convert2_dout_net_x0;
  convert3_x0 <= convert3_dout_net_x0;
  convert_not_reset_x0 <= convert_not_reset_dout_net_x0;
  convert_not_sdenb_i_x0 <= convert_not_sdenb_i_dout_net_x0;
  convert_not_sdenb_q_x0 <= convert_not_sdenb_q_dout_net_x0;
  convert_sclk_x0 <= convert_sclk_dout_net_x0;
  convert_sdi_x0 <= convert_sdi_dout_net_x0;
  convert_sync_i_x0 <= convert_sync_i_dout_net_x0;
  convert_sync_q_x0 <= convert_sync_q_dout_net_x0;
  convert_x0 <= convert_dout_net_x0;

  constant1: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant1_op_net
    );

  constant2: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  constant4: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant4_op_net
    );

  constant5: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant5_op_net
    );

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 15,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 15,
      dout_width => 16,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x2,
      dout => convert_dout_net_x0
    );

  convert1: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 15,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 15,
      dout_width => 16,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x3,
      dout => convert1_dout_net_x0
    );

  convert2: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 15,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 15,
      dout_width => 16,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x4,
      dout => convert2_dout_net_x0
    );

  convert3: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 15,
      din_width => 16,
      dout_arith => 2,
      dout_bin_pt => 15,
      dout_width => 16,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x5,
      dout => convert3_dout_net_x0
    );

  convert_not_reset: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => inverter_op_net,
      dout(0) => convert_not_reset_dout_net_x0
    );

  convert_not_sdenb_i: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => constant1_op_net,
      dout(0) => convert_not_sdenb_i_dout_net_x0
    );

  convert_not_sdenb_q: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => constant1_op_net,
      dout(0) => convert_not_sdenb_q_dout_net_x0
    );

  convert_sclk: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => constant2_op_net,
      dout(0) => convert_sclk_dout_net_x0
    );

  convert_sdi: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => constant4_op_net,
      dout(0) => convert_sdi_dout_net_x0
    );

  convert_sync_i: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => register1_q_net_x0,
      dout(0) => convert_sync_i_dout_net_x0
    );

  convert_sync_q: entity work.xlconvert
    generic map (
      bool_conversion => 1,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => register1_q_net_x1,
      dout(0) => convert_sync_q_dout_net_x0
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x349,
      clk => clk_1_sg_x349,
      clr => '0',
      ip(0) => constant5_op_net,
      op(0) => inverter_op_net
    );

  pipeline10_aba8df6726: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x349,
      clk_1 => clk_1_sg_x349,
      d => slice3_y_net_x4,
      q => register1_q_net_x0
    );

  pipeline11_c58cc7a500: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x349,
      clk_1 => clk_1_sg_x349,
      d => slice3_y_net_x4,
      q => register1_q_net_x1
    );

  pipeline5_a9368eaa10: entity work.pipeline5_entity_a9368eaa10
    port map (
      ce_1 => ce_1_sg_x349,
      clk_1 => clk_1_sg_x349,
      d => reinterpret4_output_port_net_x2,
      q => register1_q_net_x2
    );

  pipeline6_7c20727c3a: entity work.pipeline5_entity_a9368eaa10
    port map (
      ce_1 => ce_1_sg_x349,
      clk_1 => clk_1_sg_x349,
      d => reinterpret1_output_port_net_x2,
      q => register1_q_net_x3
    );

  pipeline7_0d86a9c0f2: entity work.pipeline5_entity_a9368eaa10
    port map (
      ce_1 => ce_1_sg_x349,
      clk_1 => clk_1_sg_x349,
      d => reinterpret8_output_port_net_x2,
      q => register1_q_net_x4
    );

  pipeline9_40509c7d12: entity work.pipeline5_entity_a9368eaa10
    port map (
      ce_1 => ce_1_sg_x349,
      clk_1 => clk_1_sg_x349,
      d => reinterpret7_output_port_net_x2,
      q => register1_q_net_x5
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/gpio_a0"

entity gpio_a0_entity_ba1ddb5c7a is
  port (
    gpio_out: in std_logic; 
    convert_x0: out std_logic
  );
end gpio_a0_entity_ba1ddb5c7a;

architecture structural of gpio_a0_entity_ba1ddb5c7a is
  signal convert_dout_net_x0: std_logic;
  signal delay34_q_net_x0: std_logic;

begin
  delay34_q_net_x0 <= gpio_out;
  convert_x0 <= convert_dout_net_x0;

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => delay34_q_net_x0,
      dout(0) => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/gpio_a2"

entity gpio_a2_entity_e332881df5 is
  port (
    gpio_out: in std_logic; 
    convert_x0: out std_logic
  );
end gpio_a2_entity_e332881df5;

architecture structural of gpio_a2_entity_e332881df5 is
  signal convert_dout_net_x0: std_logic;
  signal delay36_q_net_x0: std_logic;

begin
  delay36_q_net_x0 <= gpio_out;
  convert_x0 <= convert_dout_net_x0;

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => delay36_q_net_x0,
      dout(0) => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/mixer0/mixer0/ri_to_c1"

entity ri_to_c1_entity_0134bfdaa3 is
  port (
    im: in std_logic_vector(18 downto 0); 
    re: in std_logic_vector(18 downto 0); 
    c: out std_logic_vector(37 downto 0)
  );
end ri_to_c1_entity_0134bfdaa3;

architecture structural of ri_to_c1_entity_0134bfdaa3 is
  signal addsub1_s_net_x0: std_logic_vector(18 downto 0);
  signal addsub_s_net_x0: std_logic_vector(18 downto 0);
  signal concat_y_net_x0: std_logic_vector(37 downto 0);
  signal force_im_output_port_net: std_logic_vector(18 downto 0);
  signal force_re_output_port_net: std_logic_vector(18 downto 0);

begin
  addsub_s_net_x0 <= im;
  addsub1_s_net_x0 <= re;
  c <= concat_y_net_x0;

  concat: entity work.concat_5a12f8f9be
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => force_re_output_port_net,
      in1 => force_im_output_port_net,
      y => concat_y_net_x0
    );

  force_im: entity work.reinterpret_bc4405cd1e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => addsub_s_net_x0,
      output_port => force_im_output_port_net
    );

  force_re: entity work.reinterpret_bc4405cd1e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => addsub1_s_net_x0,
      output_port => force_re_output_port_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/mixer0/mixer0"

entity mixer0_entity_596cbaa9a5 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_i: in std_logic_vector(17 downto 0); 
    data_q: in std_logic_vector(17 downto 0); 
    dds_i: in std_logic_vector(15 downto 0); 
    dds_q: in std_logic_vector(15 downto 0); 
    mixed_out: out std_logic_vector(37 downto 0)
  );
end mixer0_entity_596cbaa9a5;

architecture structural of mixer0_entity_596cbaa9a5 is
  signal addsub1_s_net_x0: std_logic_vector(18 downto 0);
  signal addsub_s_net_x0: std_logic_vector(18 downto 0);
  signal ce_1_sg_x350: std_logic;
  signal clk_1_sg_x350: std_logic;
  signal concat_y_net_x1: std_logic_vector(37 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal mult1_p_net: std_logic_vector(33 downto 0);
  signal mult2_p_net: std_logic_vector(33 downto 0);
  signal mult3_p_net: std_logic_vector(33 downto 0);
  signal mult4_p_net: std_logic_vector(33 downto 0);
  signal reinterpret3_output_port_net_x1: std_logic_vector(15 downto 0);
  signal reinterpret5_output_port_net_x1: std_logic_vector(15 downto 0);

begin
  ce_1_sg_x350 <= ce_1;
  clk_1_sg_x350 <= clk_1;
  force_re_output_port_net_x1 <= data_i;
  force_im_output_port_net_x1 <= data_q;
  reinterpret5_output_port_net_x1 <= dds_i;
  reinterpret3_output_port_net_x1 <= dds_q;
  mixed_out <= concat_y_net_x1;

  addsub: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 34,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 34,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 35,
      core_name0 => "addsb_11_0_acea36ae702708f1",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 35,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 17,
      s_width => 19
    )
    port map (
      a => mult1_p_net,
      b => mult2_p_net,
      ce => ce_1_sg_x350,
      clk => clk_1_sg_x350,
      clr => '0',
      en => "1",
      s => addsub_s_net_x0
    );

  addsub1: entity work.xladdsub
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 32,
      a_width => 34,
      b_arith => xlSigned,
      b_bin_pt => 32,
      b_width => 34,
      c_has_c_out => 0,
      c_latency => 2,
      c_output_width => 35,
      core_name0 => "addsb_11_0_5133866ee72e4ea9",
      extra_registers => 1,
      full_s_arith => 2,
      full_s_width => 35,
      latency => 3,
      overflow => 1,
      quantization => 1,
      s_arith => xlSigned,
      s_bin_pt => 17,
      s_width => 19
    )
    port map (
      a => mult4_p_net,
      b => mult3_p_net,
      ce => ce_1_sg_x350,
      clk => clk_1_sg_x350,
      clr => '0',
      en => "1",
      s => addsub1_s_net_x0
    );

  mult1: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 18,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 18,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 18,
      c_output_width => 34,
      c_type => 0,
      core_name0 => "mlt_11_2_94be7c2fab735de7",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 34,
      quantization => 1
    )
    port map (
      a => force_im_output_port_net_x1,
      b => reinterpret5_output_port_net_x1,
      ce => ce_1_sg_x350,
      clk => clk_1_sg_x350,
      clr => '0',
      core_ce => ce_1_sg_x350,
      core_clk => clk_1_sg_x350,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult1_p_net
    );

  mult2: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 18,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 18,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 18,
      c_output_width => 34,
      c_type => 0,
      core_name0 => "mlt_11_2_94be7c2fab735de7",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 34,
      quantization => 1
    )
    port map (
      a => force_re_output_port_net_x1,
      b => reinterpret3_output_port_net_x1,
      ce => ce_1_sg_x350,
      clk => clk_1_sg_x350,
      clr => '0',
      core_ce => ce_1_sg_x350,
      core_clk => clk_1_sg_x350,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult2_p_net
    );

  mult3: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 18,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 18,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 18,
      c_output_width => 34,
      c_type => 0,
      core_name0 => "mlt_11_2_94be7c2fab735de7",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 34,
      quantization => 1
    )
    port map (
      a => force_im_output_port_net_x1,
      b => reinterpret3_output_port_net_x1,
      ce => ce_1_sg_x350,
      clk => clk_1_sg_x350,
      clr => '0',
      core_ce => ce_1_sg_x350,
      core_clk => clk_1_sg_x350,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult3_p_net
    );

  mult4: entity work.xlmult
    generic map (
      a_arith => xlSigned,
      a_bin_pt => 17,
      a_width => 18,
      b_arith => xlSigned,
      b_bin_pt => 15,
      b_width => 16,
      c_a_type => 0,
      c_a_width => 18,
      c_b_type => 0,
      c_b_width => 16,
      c_baat => 18,
      c_output_width => 34,
      c_type => 0,
      core_name0 => "mlt_11_2_94be7c2fab735de7",
      extra_registers => 0,
      multsign => 2,
      overflow => 1,
      p_arith => xlSigned,
      p_bin_pt => 32,
      p_width => 34,
      quantization => 1
    )
    port map (
      a => force_re_output_port_net_x1,
      b => reinterpret5_output_port_net_x1,
      ce => ce_1_sg_x350,
      clk => clk_1_sg_x350,
      clr => '0',
      core_ce => ce_1_sg_x350,
      core_clk => clk_1_sg_x350,
      core_clr => '1',
      en => "1",
      rst => "0",
      p => mult4_p_net
    );

  ri_to_c1_0134bfdaa3: entity work.ri_to_c1_entity_0134bfdaa3
    port map (
      im => addsub_s_net_x0,
      re => addsub1_s_net_x0,
      c => concat_y_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/mixer0"

entity mixer0_entity_ea9a3b7625 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(71 downto 0); 
    dds_i0: in std_logic_vector(15 downto 0); 
    dds_i1: in std_logic_vector(15 downto 0); 
    dds_q0: in std_logic_vector(15 downto 0); 
    dds_q1: in std_logic_vector(15 downto 0); 
    data_out: out std_logic_vector(75 downto 0)
  );
end mixer0_entity_ea9a3b7625;

architecture structural of mixer0_entity_ea9a3b7625 is
  signal ce_1_sg_x352: std_logic;
  signal clk_1_sg_x352: std_logic;
  signal concat_y_net_x0: std_logic_vector(75 downto 0);
  signal concat_y_net_x1: std_logic_vector(37 downto 0);
  signal concat_y_net_x2: std_logic_vector(37 downto 0);
  signal force_im_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_im_output_port_net_x2: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x1: std_logic_vector(17 downto 0);
  signal force_re_output_port_net_x2: std_logic_vector(17 downto 0);
  signal register1_q_net_x0: std_logic_vector(71 downto 0);
  signal reinterpret2_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret3_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret5_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret6_output_port_net_x2: std_logic_vector(15 downto 0);
  signal slice1_y_net_x0: std_logic_vector(35 downto 0);
  signal slice7_y_net_x0: std_logic_vector(35 downto 0);

begin
  ce_1_sg_x352 <= ce_1;
  clk_1_sg_x352 <= clk_1;
  register1_q_net_x0 <= data_in;
  reinterpret5_output_port_net_x2 <= dds_i0;
  reinterpret6_output_port_net_x2 <= dds_i1;
  reinterpret3_output_port_net_x2 <= dds_q0;
  reinterpret2_output_port_net_x2 <= dds_q1;
  data_out <= concat_y_net_x0;

  c_to_ri1_88400d0439: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => slice1_y_net_x0,
      im => force_im_output_port_net_x2,
      re => force_re_output_port_net_x2
    );

  c_to_ri_a97503030d: entity work.c_to_ri1_entity_91f65b6f7a
    port map (
      c => slice7_y_net_x0,
      im => force_im_output_port_net_x1,
      re => force_re_output_port_net_x1
    );

  concat: entity work.concat_4822199898
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => concat_y_net_x2,
      in1 => concat_y_net_x1,
      y => concat_y_net_x0
    );

  mixer0_596cbaa9a5: entity work.mixer0_entity_596cbaa9a5
    port map (
      ce_1 => ce_1_sg_x352,
      clk_1 => clk_1_sg_x352,
      data_i => force_re_output_port_net_x1,
      data_q => force_im_output_port_net_x1,
      dds_i => reinterpret5_output_port_net_x2,
      dds_q => reinterpret3_output_port_net_x2,
      mixed_out => concat_y_net_x1
    );

  mixer1_aa38f0220f: entity work.mixer0_entity_596cbaa9a5
    port map (
      ce_1 => ce_1_sg_x352,
      clk_1 => clk_1_sg_x352,
      data_i => force_re_output_port_net_x2,
      data_q => force_im_output_port_net_x2,
      dds_i => reinterpret6_output_port_net_x2,
      dds_q => reinterpret2_output_port_net_x2,
      mixed_out => concat_y_net_x2
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 36,
      new_msb => 71,
      x_width => 72,
      y_width => 36
    )
    port map (
      x => register1_q_net_x0,
      y => slice1_y_net_x0
    );

  slice7: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 35,
      x_width => 72,
      y_width => 36
    )
    port map (
      x => register1_q_net_x0,
      y => slice7_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/negedge"

entity negedge_entity_8065189e8c is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end negedge_entity_8065189e8c;

architecture structural of negedge_entity_8065189e8c is
  signal ce_1_sg_x353: std_logic;
  signal clk_1_sg_x353: std_logic;
  signal delay_q_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical_y_net_x0: std_logic;
  signal register_q_net_x0: std_logic;

begin
  ce_1_sg_x353 <= ce_1;
  clk_1_sg_x353 <= clk_1;
  register_q_net_x0 <= in_x0;
  out_x0 <= logical_y_net_x0;

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x353,
      clk => clk_1_sg_x353,
      d(0) => register_q_net_x0,
      en => '1',
      q(0) => delay_q_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x353,
      clk => clk_1_sg_x353,
      clr => '0',
      ip(0) => register_q_net_x0,
      op(0) => inverter_op_net
    );

  logical: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => delay_q_net,
      d1(0) => inverter_op_net,
      y(0) => logical_y_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit1"

entity shifter_unit1_entity_122cc614b2 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit1_entity_122cc614b2;

architecture structural of shifter_unit1_entity_122cc614b2 is
  signal ce_1_sg_x354: std_logic;
  signal clk_1_sg_x354: std_logic;
  signal convert_dout_net_x0: std_logic_vector(32 downto 0);
  signal filler_op_net_x0: std_logic;
  signal logical_y_net_x1: std_logic;
  signal logical_y_net_x2: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x354 <= ce_1;
  clk_1_sg_x354 <= clk_1;
  convert_dout_net_x0 <= pin;
  filler_op_net_x0 <= prev;
  logical_y_net_x1 <= reg_en;
  logical_y_net_x2 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => filler_op_net_x0,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x2,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x354,
      clk => clk_1_sg_x354,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x1,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x0,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit10"

entity shifter_unit10_entity_dc91be97c8 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit10_entity_dc91be97c8;

architecture structural of shifter_unit10_entity_dc91be97c8 is
  signal ce_1_sg_x355: std_logic;
  signal clk_1_sg_x355: std_logic;
  signal convert_dout_net_x1: std_logic_vector(32 downto 0);
  signal logical_y_net_x3: std_logic;
  signal logical_y_net_x4: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x355 <= ce_1;
  clk_1_sg_x355 <= clk_1;
  convert_dout_net_x1 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x3 <= reg_en;
  logical_y_net_x4 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x4,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x355,
      clk => clk_1_sg_x355,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x3,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 9,
      new_msb => 9,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x1,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit11"

entity shifter_unit11_entity_173dae5b61 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit11_entity_173dae5b61;

architecture structural of shifter_unit11_entity_173dae5b61 is
  signal ce_1_sg_x356: std_logic;
  signal clk_1_sg_x356: std_logic;
  signal convert_dout_net_x2: std_logic_vector(32 downto 0);
  signal logical_y_net_x5: std_logic;
  signal logical_y_net_x6: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x356 <= ce_1;
  clk_1_sg_x356 <= clk_1;
  convert_dout_net_x2 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x5 <= reg_en;
  logical_y_net_x6 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x6,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x356,
      clk => clk_1_sg_x356,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x5,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 10,
      new_msb => 10,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x2,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit12"

entity shifter_unit12_entity_33cb97e3dc is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit12_entity_33cb97e3dc;

architecture structural of shifter_unit12_entity_33cb97e3dc is
  signal ce_1_sg_x357: std_logic;
  signal clk_1_sg_x357: std_logic;
  signal convert_dout_net_x3: std_logic_vector(32 downto 0);
  signal logical_y_net_x7: std_logic;
  signal logical_y_net_x8: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x357 <= ce_1;
  clk_1_sg_x357 <= clk_1;
  convert_dout_net_x3 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x7 <= reg_en;
  logical_y_net_x8 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x8,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x357,
      clk => clk_1_sg_x357,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x7,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 11,
      new_msb => 11,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x3,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit13"

entity shifter_unit13_entity_11118d75d1 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit13_entity_11118d75d1;

architecture structural of shifter_unit13_entity_11118d75d1 is
  signal ce_1_sg_x358: std_logic;
  signal clk_1_sg_x358: std_logic;
  signal convert_dout_net_x4: std_logic_vector(32 downto 0);
  signal logical_y_net_x10: std_logic;
  signal logical_y_net_x9: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x358 <= ce_1;
  clk_1_sg_x358 <= clk_1;
  convert_dout_net_x4 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x9 <= reg_en;
  logical_y_net_x10 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x10,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x358,
      clk => clk_1_sg_x358,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x9,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 12,
      new_msb => 12,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x4,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit14"

entity shifter_unit14_entity_bd0f995032 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit14_entity_bd0f995032;

architecture structural of shifter_unit14_entity_bd0f995032 is
  signal ce_1_sg_x359: std_logic;
  signal clk_1_sg_x359: std_logic;
  signal convert_dout_net_x5: std_logic_vector(32 downto 0);
  signal logical_y_net_x11: std_logic;
  signal logical_y_net_x12: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x359 <= ce_1;
  clk_1_sg_x359 <= clk_1;
  convert_dout_net_x5 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x11 <= reg_en;
  logical_y_net_x12 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x12,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x359,
      clk => clk_1_sg_x359,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x11,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 13,
      new_msb => 13,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x5,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit15"

entity shifter_unit15_entity_32e5d4fd21 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit15_entity_32e5d4fd21;

architecture structural of shifter_unit15_entity_32e5d4fd21 is
  signal ce_1_sg_x360: std_logic;
  signal clk_1_sg_x360: std_logic;
  signal convert_dout_net_x6: std_logic_vector(32 downto 0);
  signal logical_y_net_x13: std_logic;
  signal logical_y_net_x14: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x360 <= ce_1;
  clk_1_sg_x360 <= clk_1;
  convert_dout_net_x6 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x13 <= reg_en;
  logical_y_net_x14 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x14,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x360,
      clk => clk_1_sg_x360,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x13,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 14,
      new_msb => 14,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x6,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit16"

entity shifter_unit16_entity_ed4fbd6961 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit16_entity_ed4fbd6961;

architecture structural of shifter_unit16_entity_ed4fbd6961 is
  signal ce_1_sg_x361: std_logic;
  signal clk_1_sg_x361: std_logic;
  signal convert_dout_net_x7: std_logic_vector(32 downto 0);
  signal logical_y_net_x15: std_logic;
  signal logical_y_net_x16: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x361 <= ce_1;
  clk_1_sg_x361 <= clk_1;
  convert_dout_net_x7 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x15 <= reg_en;
  logical_y_net_x16 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x16,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x361,
      clk => clk_1_sg_x361,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x15,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 15,
      new_msb => 15,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x7,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit17"

entity shifter_unit17_entity_6bdaaecb32 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit17_entity_6bdaaecb32;

architecture structural of shifter_unit17_entity_6bdaaecb32 is
  signal ce_1_sg_x362: std_logic;
  signal clk_1_sg_x362: std_logic;
  signal convert_dout_net_x8: std_logic_vector(32 downto 0);
  signal logical_y_net_x17: std_logic;
  signal logical_y_net_x18: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x362 <= ce_1;
  clk_1_sg_x362 <= clk_1;
  convert_dout_net_x8 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x17 <= reg_en;
  logical_y_net_x18 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x18,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x362,
      clk => clk_1_sg_x362,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x17,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 16,
      new_msb => 16,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x8,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit18"

entity shifter_unit18_entity_cd906d285a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit18_entity_cd906d285a;

architecture structural of shifter_unit18_entity_cd906d285a is
  signal ce_1_sg_x363: std_logic;
  signal clk_1_sg_x363: std_logic;
  signal convert_dout_net_x9: std_logic_vector(32 downto 0);
  signal logical_y_net_x19: std_logic;
  signal logical_y_net_x20: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x363 <= ce_1;
  clk_1_sg_x363 <= clk_1;
  convert_dout_net_x9 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x19 <= reg_en;
  logical_y_net_x20 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x20,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x363,
      clk => clk_1_sg_x363,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x19,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 17,
      new_msb => 17,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x9,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit19"

entity shifter_unit19_entity_e1b93e312d is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit19_entity_e1b93e312d;

architecture structural of shifter_unit19_entity_e1b93e312d is
  signal ce_1_sg_x364: std_logic;
  signal clk_1_sg_x364: std_logic;
  signal convert_dout_net_x10: std_logic_vector(32 downto 0);
  signal logical_y_net_x21: std_logic;
  signal logical_y_net_x22: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x364 <= ce_1;
  clk_1_sg_x364 <= clk_1;
  convert_dout_net_x10 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x21 <= reg_en;
  logical_y_net_x22 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x22,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x364,
      clk => clk_1_sg_x364,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x21,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 18,
      new_msb => 18,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x10,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit2"

entity shifter_unit2_entity_fce68d597f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit2_entity_fce68d597f;

architecture structural of shifter_unit2_entity_fce68d597f is
  signal ce_1_sg_x365: std_logic;
  signal clk_1_sg_x365: std_logic;
  signal convert_dout_net_x11: std_logic_vector(32 downto 0);
  signal logical_y_net_x23: std_logic;
  signal logical_y_net_x24: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x365 <= ce_1;
  clk_1_sg_x365 <= clk_1;
  convert_dout_net_x11 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x23 <= reg_en;
  logical_y_net_x24 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x24,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x365,
      clk => clk_1_sg_x365,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x23,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 1,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x11,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit20"

entity shifter_unit20_entity_f697540b29 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit20_entity_f697540b29;

architecture structural of shifter_unit20_entity_f697540b29 is
  signal ce_1_sg_x366: std_logic;
  signal clk_1_sg_x366: std_logic;
  signal convert_dout_net_x12: std_logic_vector(32 downto 0);
  signal logical_y_net_x25: std_logic;
  signal logical_y_net_x26: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x366 <= ce_1;
  clk_1_sg_x366 <= clk_1;
  convert_dout_net_x12 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x25 <= reg_en;
  logical_y_net_x26 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x26,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x366,
      clk => clk_1_sg_x366,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x25,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 19,
      new_msb => 19,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x12,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit21"

entity shifter_unit21_entity_afc4bf2065 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit21_entity_afc4bf2065;

architecture structural of shifter_unit21_entity_afc4bf2065 is
  signal ce_1_sg_x367: std_logic;
  signal clk_1_sg_x367: std_logic;
  signal convert_dout_net_x13: std_logic_vector(32 downto 0);
  signal logical_y_net_x27: std_logic;
  signal logical_y_net_x28: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x367 <= ce_1;
  clk_1_sg_x367 <= clk_1;
  convert_dout_net_x13 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x27 <= reg_en;
  logical_y_net_x28 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x28,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x367,
      clk => clk_1_sg_x367,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x27,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 20,
      new_msb => 20,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x13,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit22"

entity shifter_unit22_entity_7ca75e620d is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit22_entity_7ca75e620d;

architecture structural of shifter_unit22_entity_7ca75e620d is
  signal ce_1_sg_x368: std_logic;
  signal clk_1_sg_x368: std_logic;
  signal convert_dout_net_x14: std_logic_vector(32 downto 0);
  signal logical_y_net_x29: std_logic;
  signal logical_y_net_x30: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x368 <= ce_1;
  clk_1_sg_x368 <= clk_1;
  convert_dout_net_x14 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x29 <= reg_en;
  logical_y_net_x30 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x30,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x368,
      clk => clk_1_sg_x368,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x29,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 21,
      new_msb => 21,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x14,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit23"

entity shifter_unit23_entity_7fc3792f26 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit23_entity_7fc3792f26;

architecture structural of shifter_unit23_entity_7fc3792f26 is
  signal ce_1_sg_x369: std_logic;
  signal clk_1_sg_x369: std_logic;
  signal convert_dout_net_x15: std_logic_vector(32 downto 0);
  signal logical_y_net_x31: std_logic;
  signal logical_y_net_x32: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x369 <= ce_1;
  clk_1_sg_x369 <= clk_1;
  convert_dout_net_x15 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x31 <= reg_en;
  logical_y_net_x32 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x32,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x369,
      clk => clk_1_sg_x369,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x31,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 22,
      new_msb => 22,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x15,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit24"

entity shifter_unit24_entity_234225d366 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit24_entity_234225d366;

architecture structural of shifter_unit24_entity_234225d366 is
  signal ce_1_sg_x370: std_logic;
  signal clk_1_sg_x370: std_logic;
  signal convert_dout_net_x16: std_logic_vector(32 downto 0);
  signal logical_y_net_x33: std_logic;
  signal logical_y_net_x34: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x370 <= ce_1;
  clk_1_sg_x370 <= clk_1;
  convert_dout_net_x16 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x33 <= reg_en;
  logical_y_net_x34 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x34,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x370,
      clk => clk_1_sg_x370,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x33,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 23,
      new_msb => 23,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x16,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit25"

entity shifter_unit25_entity_d975ccfa0a is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit25_entity_d975ccfa0a;

architecture structural of shifter_unit25_entity_d975ccfa0a is
  signal ce_1_sg_x371: std_logic;
  signal clk_1_sg_x371: std_logic;
  signal convert_dout_net_x17: std_logic_vector(32 downto 0);
  signal logical_y_net_x35: std_logic;
  signal logical_y_net_x36: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x371 <= ce_1;
  clk_1_sg_x371 <= clk_1;
  convert_dout_net_x17 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x35 <= reg_en;
  logical_y_net_x36 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x36,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x371,
      clk => clk_1_sg_x371,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x35,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 24,
      new_msb => 24,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x17,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit26"

entity shifter_unit26_entity_6c0535ec2d is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit26_entity_6c0535ec2d;

architecture structural of shifter_unit26_entity_6c0535ec2d is
  signal ce_1_sg_x372: std_logic;
  signal clk_1_sg_x372: std_logic;
  signal convert_dout_net_x18: std_logic_vector(32 downto 0);
  signal logical_y_net_x37: std_logic;
  signal logical_y_net_x38: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x372 <= ce_1;
  clk_1_sg_x372 <= clk_1;
  convert_dout_net_x18 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x37 <= reg_en;
  logical_y_net_x38 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x38,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x372,
      clk => clk_1_sg_x372,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x37,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 25,
      new_msb => 25,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x18,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit27"

entity shifter_unit27_entity_6bb76b3eb1 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit27_entity_6bb76b3eb1;

architecture structural of shifter_unit27_entity_6bb76b3eb1 is
  signal ce_1_sg_x373: std_logic;
  signal clk_1_sg_x373: std_logic;
  signal convert_dout_net_x19: std_logic_vector(32 downto 0);
  signal logical_y_net_x39: std_logic;
  signal logical_y_net_x40: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x373 <= ce_1;
  clk_1_sg_x373 <= clk_1;
  convert_dout_net_x19 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x39 <= reg_en;
  logical_y_net_x40 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x40,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x373,
      clk => clk_1_sg_x373,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x39,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 26,
      new_msb => 26,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x19,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit28"

entity shifter_unit28_entity_32a87dbfa6 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit28_entity_32a87dbfa6;

architecture structural of shifter_unit28_entity_32a87dbfa6 is
  signal ce_1_sg_x374: std_logic;
  signal clk_1_sg_x374: std_logic;
  signal convert_dout_net_x20: std_logic_vector(32 downto 0);
  signal logical_y_net_x41: std_logic;
  signal logical_y_net_x42: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x374 <= ce_1;
  clk_1_sg_x374 <= clk_1;
  convert_dout_net_x20 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x41 <= reg_en;
  logical_y_net_x42 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x42,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x374,
      clk => clk_1_sg_x374,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x41,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 27,
      new_msb => 27,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x20,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit29"

entity shifter_unit29_entity_c5fed9244e is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit29_entity_c5fed9244e;

architecture structural of shifter_unit29_entity_c5fed9244e is
  signal ce_1_sg_x375: std_logic;
  signal clk_1_sg_x375: std_logic;
  signal convert_dout_net_x21: std_logic_vector(32 downto 0);
  signal logical_y_net_x43: std_logic;
  signal logical_y_net_x44: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x375 <= ce_1;
  clk_1_sg_x375 <= clk_1;
  convert_dout_net_x21 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x43 <= reg_en;
  logical_y_net_x44 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x44,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x375,
      clk => clk_1_sg_x375,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x43,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 28,
      new_msb => 28,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x21,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit3"

entity shifter_unit3_entity_ce491c3ac8 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit3_entity_ce491c3ac8;

architecture structural of shifter_unit3_entity_ce491c3ac8 is
  signal ce_1_sg_x376: std_logic;
  signal clk_1_sg_x376: std_logic;
  signal convert_dout_net_x22: std_logic_vector(32 downto 0);
  signal logical_y_net_x45: std_logic;
  signal logical_y_net_x46: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x376 <= ce_1;
  clk_1_sg_x376 <= clk_1;
  convert_dout_net_x22 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x45 <= reg_en;
  logical_y_net_x46 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x46,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x376,
      clk => clk_1_sg_x376,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x45,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 2,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x22,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit30"

entity shifter_unit30_entity_2db323f20f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit30_entity_2db323f20f;

architecture structural of shifter_unit30_entity_2db323f20f is
  signal ce_1_sg_x377: std_logic;
  signal clk_1_sg_x377: std_logic;
  signal convert_dout_net_x23: std_logic_vector(32 downto 0);
  signal logical_y_net_x47: std_logic;
  signal logical_y_net_x48: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x377 <= ce_1;
  clk_1_sg_x377 <= clk_1;
  convert_dout_net_x23 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x47 <= reg_en;
  logical_y_net_x48 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x48,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x377,
      clk => clk_1_sg_x377,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x47,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 29,
      new_msb => 29,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x23,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit31"

entity shifter_unit31_entity_9f07761ff9 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit31_entity_9f07761ff9;

architecture structural of shifter_unit31_entity_9f07761ff9 is
  signal ce_1_sg_x378: std_logic;
  signal clk_1_sg_x378: std_logic;
  signal convert_dout_net_x24: std_logic_vector(32 downto 0);
  signal logical_y_net_x49: std_logic;
  signal logical_y_net_x50: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x378 <= ce_1;
  clk_1_sg_x378 <= clk_1;
  convert_dout_net_x24 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x49 <= reg_en;
  logical_y_net_x50 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x50,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x378,
      clk => clk_1_sg_x378,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x49,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 30,
      new_msb => 30,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x24,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit32"

entity shifter_unit32_entity_e1ead25347 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit32_entity_e1ead25347;

architecture structural of shifter_unit32_entity_e1ead25347 is
  signal ce_1_sg_x379: std_logic;
  signal clk_1_sg_x379: std_logic;
  signal convert_dout_net_x25: std_logic_vector(32 downto 0);
  signal logical_y_net_x51: std_logic;
  signal logical_y_net_x52: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x379 <= ce_1;
  clk_1_sg_x379 <= clk_1;
  convert_dout_net_x25 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x51 <= reg_en;
  logical_y_net_x52 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x52,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x379,
      clk => clk_1_sg_x379,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x51,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 31,
      new_msb => 31,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x25,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit33"

entity shifter_unit33_entity_363ddd0f3b is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit33_entity_363ddd0f3b;

architecture structural of shifter_unit33_entity_363ddd0f3b is
  signal ce_1_sg_x380: std_logic;
  signal clk_1_sg_x380: std_logic;
  signal convert_dout_net_x26: std_logic_vector(32 downto 0);
  signal logical_y_net_x53: std_logic;
  signal logical_y_net_x54: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x380 <= ce_1;
  clk_1_sg_x380 <= clk_1;
  convert_dout_net_x26 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x53 <= reg_en;
  logical_y_net_x54 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x54,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x380,
      clk => clk_1_sg_x380,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x53,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 32,
      new_msb => 32,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x26,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit4"

entity shifter_unit4_entity_710c5ba5f5 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit4_entity_710c5ba5f5;

architecture structural of shifter_unit4_entity_710c5ba5f5 is
  signal ce_1_sg_x381: std_logic;
  signal clk_1_sg_x381: std_logic;
  signal convert_dout_net_x27: std_logic_vector(32 downto 0);
  signal logical_y_net_x55: std_logic;
  signal logical_y_net_x56: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x381 <= ce_1;
  clk_1_sg_x381 <= clk_1;
  convert_dout_net_x27 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x55 <= reg_en;
  logical_y_net_x56 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x56,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x381,
      clk => clk_1_sg_x381,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x55,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 3,
      new_msb => 3,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x27,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit5"

entity shifter_unit5_entity_9aaa6b88f3 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit5_entity_9aaa6b88f3;

architecture structural of shifter_unit5_entity_9aaa6b88f3 is
  signal ce_1_sg_x382: std_logic;
  signal clk_1_sg_x382: std_logic;
  signal convert_dout_net_x28: std_logic_vector(32 downto 0);
  signal logical_y_net_x57: std_logic;
  signal logical_y_net_x58: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x382 <= ce_1;
  clk_1_sg_x382 <= clk_1;
  convert_dout_net_x28 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x57 <= reg_en;
  logical_y_net_x58 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x58,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x382,
      clk => clk_1_sg_x382,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x57,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 4,
      new_msb => 4,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x28,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit6"

entity shifter_unit6_entity_82661988a5 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit6_entity_82661988a5;

architecture structural of shifter_unit6_entity_82661988a5 is
  signal ce_1_sg_x383: std_logic;
  signal clk_1_sg_x383: std_logic;
  signal convert_dout_net_x29: std_logic_vector(32 downto 0);
  signal logical_y_net_x59: std_logic;
  signal logical_y_net_x60: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x383 <= ce_1;
  clk_1_sg_x383 <= clk_1;
  convert_dout_net_x29 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x59 <= reg_en;
  logical_y_net_x60 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x60,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x383,
      clk => clk_1_sg_x383,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x59,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 5,
      new_msb => 5,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x29,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit7"

entity shifter_unit7_entity_362b743c8b is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit7_entity_362b743c8b;

architecture structural of shifter_unit7_entity_362b743c8b is
  signal ce_1_sg_x384: std_logic;
  signal clk_1_sg_x384: std_logic;
  signal convert_dout_net_x30: std_logic_vector(32 downto 0);
  signal logical_y_net_x61: std_logic;
  signal logical_y_net_x62: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal register1_q_net_x3: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x384 <= ce_1;
  clk_1_sg_x384 <= clk_1;
  convert_dout_net_x30 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x61 <= reg_en;
  logical_y_net_x62 <= sel;
  dout <= register1_q_net_x0;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x62,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x384,
      clk => clk_1_sg_x384,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x61,
      rst => "0",
      q(0) => register1_q_net_x0
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 6,
      new_msb => 6,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x30,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit8"

entity shifter_unit8_entity_c9f48f0ae1 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit8_entity_c9f48f0ae1;

architecture structural of shifter_unit8_entity_c9f48f0ae1 is
  signal ce_1_sg_x385: std_logic;
  signal clk_1_sg_x385: std_logic;
  signal convert_dout_net_x31: std_logic_vector(32 downto 0);
  signal logical_y_net_x63: std_logic;
  signal logical_y_net_x64: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x2: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x385 <= ce_1;
  clk_1_sg_x385 <= clk_1;
  convert_dout_net_x31 <= pin;
  register1_q_net_x1 <= prev;
  logical_y_net_x63 <= reg_en;
  logical_y_net_x64 <= sel;
  dout <= register1_q_net_x2;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x1,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x64,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x385,
      clk => clk_1_sg_x385,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x63,
      rst => "0",
      q(0) => register1_q_net_x2
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 7,
      new_msb => 7,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x31,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1/shifter_unit9"

entity shifter_unit9_entity_9e5c2e19ea is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    prev: in std_logic; 
    reg_en: in std_logic; 
    sel: in std_logic; 
    dout: out std_logic
  );
end shifter_unit9_entity_9e5c2e19ea;

architecture structural of shifter_unit9_entity_9e5c2e19ea is
  signal ce_1_sg_x386: std_logic;
  signal clk_1_sg_x386: std_logic;
  signal convert_dout_net_x32: std_logic_vector(32 downto 0);
  signal logical_y_net_x65: std_logic;
  signal logical_y_net_x66: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x3: std_logic;
  signal register1_q_net_x4: std_logic;
  signal slice_y_net: std_logic;

begin
  ce_1_sg_x386 <= ce_1;
  clk_1_sg_x386 <= clk_1;
  convert_dout_net_x32 <= pin;
  register1_q_net_x3 <= prev;
  logical_y_net_x65 <= reg_en;
  logical_y_net_x66 <= sel;
  dout <= register1_q_net_x4;

  mux2: entity work.mux_112ed141f4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => register1_q_net_x3,
      d1(0) => slice_y_net,
      sel(0) => logical_y_net_x66,
      y(0) => mux2_y_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x386,
      clk => clk_1_sg_x386,
      d(0) => mux2_y_net,
      en(0) => logical_y_net_x65,
      rst => "0",
      q(0) => register1_q_net_x4
    );

  slice: entity work.xlslice
    generic map (
      new_lsb => 8,
      new_msb => 8,
      x_width => 33,
      y_width => 1
    )
    port map (
      x => convert_dout_net_x32,
      y(0) => slice_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/parallel_to_serial_converter1"

entity parallel_to_serial_converter1_entity_4252702d68 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    ld: in std_logic; 
    pin: in std_logic_vector(32 downto 0); 
    shift: in std_logic; 
    sout: out std_logic
  );
end parallel_to_serial_converter1_entity_4252702d68;

architecture structural of parallel_to_serial_converter1_entity_4252702d68 is
  signal ce_1_sg_x387: std_logic;
  signal clk_1_sg_x387: std_logic;
  signal convert_dout_net_x33: std_logic_vector(32 downto 0);
  signal filler_op_net_x0: std_logic;
  signal logical_y_net_x0: std_logic;
  signal logical_y_net_x65: std_logic;
  signal logical_y_net_x67: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x10: std_logic;
  signal register1_q_net_x11: std_logic;
  signal register1_q_net_x12: std_logic;
  signal register1_q_net_x13: std_logic;
  signal register1_q_net_x14: std_logic;
  signal register1_q_net_x15: std_logic;
  signal register1_q_net_x16: std_logic;
  signal register1_q_net_x17: std_logic;
  signal register1_q_net_x18: std_logic;
  signal register1_q_net_x19: std_logic;
  signal register1_q_net_x2: std_logic;
  signal register1_q_net_x20: std_logic;
  signal register1_q_net_x21: std_logic;
  signal register1_q_net_x22: std_logic;
  signal register1_q_net_x23: std_logic;
  signal register1_q_net_x24: std_logic;
  signal register1_q_net_x25: std_logic;
  signal register1_q_net_x26: std_logic;
  signal register1_q_net_x27: std_logic;
  signal register1_q_net_x28: std_logic;
  signal register1_q_net_x29: std_logic;
  signal register1_q_net_x3: std_logic;
  signal register1_q_net_x30: std_logic;
  signal register1_q_net_x31: std_logic;
  signal register1_q_net_x32: std_logic;
  signal register1_q_net_x33: std_logic;
  signal register1_q_net_x4: std_logic;
  signal register1_q_net_x5: std_logic;
  signal register1_q_net_x6: std_logic;
  signal register1_q_net_x7: std_logic;
  signal register1_q_net_x8: std_logic;
  signal register1_q_net_x9: std_logic;

begin
  ce_1_sg_x387 <= ce_1;
  clk_1_sg_x387 <= clk_1;
  logical_y_net_x67 <= ld;
  convert_dout_net_x33 <= pin;
  logical_y_net_x0 <= shift;
  sout <= register1_q_net_x33;

  filler: entity work.constant_963ed6358a
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => filler_op_net_x0
    );

  logical: entity work.logical_aacf6e1b0e
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => logical_y_net_x67,
      d1(0) => logical_y_net_x0,
      y(0) => logical_y_net_x65
    );

  shifter_unit10_dc91be97c8: entity work.shifter_unit10_entity_dc91be97c8
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x32,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x3
    );

  shifter_unit11_173dae5b61: entity work.shifter_unit11_entity_173dae5b61
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x3,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x2
    );

  shifter_unit12_33cb97e3dc: entity work.shifter_unit12_entity_33cb97e3dc
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x2,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x4
    );

  shifter_unit13_11118d75d1: entity work.shifter_unit13_entity_11118d75d1
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x4,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x5
    );

  shifter_unit14_bd0f995032: entity work.shifter_unit14_entity_bd0f995032
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x5,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x6
    );

  shifter_unit15_32e5d4fd21: entity work.shifter_unit15_entity_32e5d4fd21
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x6,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x7
    );

  shifter_unit16_ed4fbd6961: entity work.shifter_unit16_entity_ed4fbd6961
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x7,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x8
    );

  shifter_unit17_6bdaaecb32: entity work.shifter_unit17_entity_6bdaaecb32
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x8,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x9
    );

  shifter_unit18_cd906d285a: entity work.shifter_unit18_entity_cd906d285a
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x9,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x10
    );

  shifter_unit19_e1b93e312d: entity work.shifter_unit19_entity_e1b93e312d
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x10,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x11
    );

  shifter_unit1_122cc614b2: entity work.shifter_unit1_entity_122cc614b2
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => filler_op_net_x0,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x1
    );

  shifter_unit20_f697540b29: entity work.shifter_unit20_entity_f697540b29
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x11,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x13
    );

  shifter_unit21_afc4bf2065: entity work.shifter_unit21_entity_afc4bf2065
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x13,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x14
    );

  shifter_unit22_7ca75e620d: entity work.shifter_unit22_entity_7ca75e620d
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x14,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x15
    );

  shifter_unit23_7fc3792f26: entity work.shifter_unit23_entity_7fc3792f26
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x15,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x16
    );

  shifter_unit24_234225d366: entity work.shifter_unit24_entity_234225d366
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x16,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x17
    );

  shifter_unit25_d975ccfa0a: entity work.shifter_unit25_entity_d975ccfa0a
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x17,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x18
    );

  shifter_unit26_6c0535ec2d: entity work.shifter_unit26_entity_6c0535ec2d
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x18,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x19
    );

  shifter_unit27_6bb76b3eb1: entity work.shifter_unit27_entity_6bb76b3eb1
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x19,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x20
    );

  shifter_unit28_32a87dbfa6: entity work.shifter_unit28_entity_32a87dbfa6
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x20,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x21
    );

  shifter_unit29_c5fed9244e: entity work.shifter_unit29_entity_c5fed9244e
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x21,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x22
    );

  shifter_unit2_fce68d597f: entity work.shifter_unit2_entity_fce68d597f
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x1,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x12
    );

  shifter_unit30_2db323f20f: entity work.shifter_unit30_entity_2db323f20f
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x22,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x24
    );

  shifter_unit31_9f07761ff9: entity work.shifter_unit31_entity_9f07761ff9
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x24,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x25
    );

  shifter_unit32_e1ead25347: entity work.shifter_unit32_entity_e1ead25347
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x25,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x26
    );

  shifter_unit33_363ddd0f3b: entity work.shifter_unit33_entity_363ddd0f3b
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x26,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x33
    );

  shifter_unit3_ce491c3ac8: entity work.shifter_unit3_entity_ce491c3ac8
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x12,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x23
    );

  shifter_unit4_710c5ba5f5: entity work.shifter_unit4_entity_710c5ba5f5
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x23,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x27
    );

  shifter_unit5_9aaa6b88f3: entity work.shifter_unit5_entity_9aaa6b88f3
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x27,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x28
    );

  shifter_unit6_82661988a5: entity work.shifter_unit6_entity_82661988a5
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x28,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x29
    );

  shifter_unit7_362b743c8b: entity work.shifter_unit7_entity_362b743c8b
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x29,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x30
    );

  shifter_unit8_c9f48f0ae1: entity work.shifter_unit8_entity_c9f48f0ae1
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x30,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x31
    );

  shifter_unit9_9e5c2e19ea: entity work.shifter_unit9_entity_9e5c2e19ea
    port map (
      ce_1 => ce_1_sg_x387,
      clk_1 => clk_1_sg_x387,
      pin => convert_dout_net_x33,
      prev => register1_q_net_x31,
      reg_en => logical_y_net_x65,
      sel => logical_y_net_x67,
      dout => register1_q_net_x32
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pipeline1"

entity pipeline1_entity_a5dbc4aa8b is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(7 downto 0); 
    q: out std_logic_vector(7 downto 0)
  );
end pipeline1_entity_a5dbc4aa8b;

architecture structural of pipeline1_entity_a5dbc4aa8b is
  signal ce_1_sg_x388: std_logic;
  signal clk_1_sg_x388: std_logic;
  signal delay1_q_net_x1: std_logic_vector(7 downto 0);
  signal register0_q_net: std_logic_vector(7 downto 0);
  signal register1_q_net_x0: std_logic_vector(7 downto 0);

begin
  ce_1_sg_x388 <= ce_1;
  clk_1_sg_x388 <= clk_1;
  delay1_q_net_x1 <= d;
  q <= register1_q_net_x0;

  register0: entity work.xlregister
    generic map (
      d_width => 8,
      init_value => b"00000000"
    )
    port map (
      ce => ce_1_sg_x388,
      clk => clk_1_sg_x388,
      d => delay1_q_net_x1,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 8,
      init_value => b"00000000"
    )
    port map (
      ce => ce_1_sg_x388,
      clk => clk_1_sg_x388,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pipeline8"

entity pipeline8_entity_afacc1a86c is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(71 downto 0); 
    q: out std_logic_vector(71 downto 0)
  );
end pipeline8_entity_afacc1a86c;

architecture structural of pipeline8_entity_afacc1a86c is
  signal ce_1_sg_x389: std_logic;
  signal clk_1_sg_x389: std_logic;
  signal mux2_y_net_x1: std_logic_vector(71 downto 0);
  signal register0_q_net: std_logic_vector(71 downto 0);
  signal register1_q_net_x1: std_logic_vector(71 downto 0);

begin
  ce_1_sg_x389 <= ce_1;
  clk_1_sg_x389 <= clk_1;
  mux2_y_net_x1 <= d;
  q <= register1_q_net_x1;

  register0: entity work.xlregister
    generic map (
      d_width => 72,
      init_value => b"000000000000000000000000000000000000000000000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x389,
      clk => clk_1_sg_x389,
      d => mux2_y_net_x1,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 72,
      init_value => b"000000000000000000000000000000000000000000000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x389,
      clk => clk_1_sg_x389,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulse_ext"

entity pulse_ext_entity_92968fb411 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end pulse_ext_entity_92968fb411;

architecture structural of pulse_ext_entity_92968fb411 is
  signal ce_1_sg_x397: std_logic;
  signal clk_1_sg_x397: std_logic;
  signal constant5_op_net: std_logic_vector(18 downto 0);
  signal counter3_op_net: std_logic_vector(18 downto 0);
  signal logical4_y_net_x1: std_logic;
  signal logical_y_net_x0: std_logic;
  signal relational5_op_net_x2: std_logic;

begin
  ce_1_sg_x397 <= ce_1;
  clk_1_sg_x397 <= clk_1;
  logical4_y_net_x1 <= in_x0;
  out_x0 <= relational5_op_net_x2;

  constant5: entity work.constant_b713aad2a7
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_c14dbcf12e29b2d7",
      op_arith => xlUnsigned,
      op_width => 19
    )
    port map (
      ce => ce_1_sg_x397,
      clk => clk_1_sg_x397,
      clr => '0',
      en(0) => relational5_op_net_x2,
      rst(0) => logical_y_net_x0,
      op => counter3_op_net
    );

  posedge_a2abd7274b: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x397,
      clk_1 => clk_1_sg_x397,
      in_x0 => logical4_y_net_x1,
      out_x0 => logical_y_net_x0
    );

  relational5: entity work.relational_502d6cf7c0
    port map (
      a => counter3_op_net,
      b => constant5_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational5_op_net_x2
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulse_ext1"

entity pulse_ext1_entity_df42a931a1 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end pulse_ext1_entity_df42a931a1;

architecture structural of pulse_ext1_entity_df42a931a1 is
  signal ce_1_sg_x399: std_logic;
  signal clk_1_sg_x399: std_logic;
  signal constant5_op_net: std_logic_vector(13 downto 0);
  signal counter3_op_net: std_logic_vector(13 downto 0);
  signal logical_y_net_x2: std_logic;
  signal logical_y_net_x3: std_logic;
  signal relational5_op_net_x1: std_logic;

begin
  ce_1_sg_x399 <= ce_1;
  clk_1_sg_x399 <= clk_1;
  logical_y_net_x3 <= in_x0;
  out_x0 <= relational5_op_net_x1;

  constant5: entity work.constant_e8ff05e502
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_82b9fd0243bf8494",
      op_arith => xlUnsigned,
      op_width => 14
    )
    port map (
      ce => ce_1_sg_x399,
      clk => clk_1_sg_x399,
      clr => '0',
      en(0) => relational5_op_net_x1,
      rst(0) => logical_y_net_x2,
      op => counter3_op_net
    );

  posedge_2a62d341b4: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x399,
      clk_1 => clk_1_sg_x399,
      in_x0 => logical_y_net_x3,
      out_x0 => logical_y_net_x2
    );

  relational5: entity work.relational_7f67627fe4
    port map (
      a => counter3_op_net,
      b => constant5_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational5_op_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulse_ext2"

entity pulse_ext2_entity_59542487b9 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end pulse_ext2_entity_59542487b9;

architecture structural of pulse_ext2_entity_59542487b9 is
  signal ce_1_sg_x401: std_logic;
  signal clk_1_sg_x401: std_logic;
  signal constant5_op_net: std_logic_vector(13 downto 0);
  signal counter3_op_net: std_logic_vector(13 downto 0);
  signal logical_y_net_x0: std_logic;
  signal logical_y_net_x70: std_logic;
  signal relational5_op_net_x0: std_logic;

begin
  ce_1_sg_x401 <= ce_1;
  clk_1_sg_x401 <= clk_1;
  logical_y_net_x70 <= in_x0;
  out_x0 <= relational5_op_net_x0;

  constant5: entity work.constant_126acba524
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_82b9fd0243bf8494",
      op_arith => xlUnsigned,
      op_width => 14
    )
    port map (
      ce => ce_1_sg_x401,
      clk => clk_1_sg_x401,
      clr => '0',
      en(0) => relational5_op_net_x0,
      rst(0) => logical_y_net_x0,
      op => counter3_op_net
    );

  posedge_1f64e71797: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x401,
      clk_1 => clk_1_sg_x401,
      in_x0 => logical_y_net_x70,
      out_x0 => logical_y_net_x0
    );

  relational5: entity work.relational_7f67627fe4
    port map (
      a => counter3_op_net,
      b => constant5_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational5_op_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulse_ext3"

entity pulse_ext3_entity_d662f5bd82 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end pulse_ext3_entity_d662f5bd82;

architecture structural of pulse_ext3_entity_d662f5bd82 is
  signal ce_1_sg_x403: std_logic;
  signal clk_1_sg_x403: std_logic;
  signal constant5_op_net: std_logic_vector(12 downto 0);
  signal counter3_op_net: std_logic_vector(12 downto 0);
  signal logical_y_net_x0: std_logic;
  signal logical_y_net_x72: std_logic;
  signal relational5_op_net_x0: std_logic;

begin
  ce_1_sg_x403 <= ce_1;
  clk_1_sg_x403 <= clk_1;
  logical_y_net_x72 <= in_x0;
  out_x0 <= relational5_op_net_x0;

  constant5: entity work.constant_e0b2ebc754
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_eea7476f289fee22",
      op_arith => xlUnsigned,
      op_width => 13
    )
    port map (
      ce => ce_1_sg_x403,
      clk => clk_1_sg_x403,
      clr => '0',
      en(0) => relational5_op_net_x0,
      rst(0) => logical_y_net_x0,
      op => counter3_op_net
    );

  posedge_cbaa1cbc21: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x403,
      clk_1 => clk_1_sg_x403,
      in_x0 => logical_y_net_x72,
      out_x0 => logical_y_net_x0
    );

  relational5: entity work.relational_2550da35d2
    port map (
      a => counter3_op_net,
      b => constant5_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational5_op_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulse_ext4"

entity pulse_ext4_entity_5dcf7b9a40 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end pulse_ext4_entity_5dcf7b9a40;

architecture structural of pulse_ext4_entity_5dcf7b9a40 is
  signal ce_1_sg_x405: std_logic;
  signal clk_1_sg_x405: std_logic;
  signal constant5_op_net: std_logic_vector(12 downto 0);
  signal counter3_op_net: std_logic_vector(12 downto 0);
  signal logical_y_net_x0: std_logic;
  signal logical_y_net_x74: std_logic;
  signal relational5_op_net_x0: std_logic;

begin
  ce_1_sg_x405 <= ce_1;
  clk_1_sg_x405 <= clk_1;
  logical_y_net_x74 <= in_x0;
  out_x0 <= relational5_op_net_x0;

  constant5: entity work.constant_40894c83ce
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant5_op_net
    );

  counter3: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_eea7476f289fee22",
      op_arith => xlUnsigned,
      op_width => 13
    )
    port map (
      ce => ce_1_sg_x405,
      clk => clk_1_sg_x405,
      clr => '0',
      en(0) => relational5_op_net_x0,
      rst(0) => logical_y_net_x0,
      op => counter3_op_net
    );

  posedge_ed68c3e8a3: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x405,
      clk_1 => clk_1_sg_x405,
      in_x0 => logical_y_net_x74,
      out_x0 => logical_y_net_x0
    );

  relational5: entity work.relational_2550da35d2
    port map (
      a => counter3_op_net,
      b => constant5_op_net,
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => relational5_op_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulses/bram0"

entity bram0_entity_4b6cf72a79 is
  port (
    addr: in std_logic_vector(13 downto 0); 
    data_in: in std_logic_vector(31 downto 0); 
    we: in std_logic; 
    convert_addr_x0: out std_logic_vector(13 downto 0); 
    convert_din_x0: out std_logic_vector(31 downto 0); 
    convert_we_x0: out std_logic
  );
end bram0_entity_4b6cf72a79;

architecture structural of bram0_entity_4b6cf72a79 is
  signal convert_addr_dout_net_x0: std_logic_vector(13 downto 0);
  signal convert_din_dout_net_x0: std_logic_vector(31 downto 0);
  signal convert_we_dout_net_x0: std_logic;
  signal register1_q_net_x2: std_logic_vector(31 downto 0);
  signal register1_q_net_x3: std_logic_vector(13 downto 0);
  signal register1_q_net_x4: std_logic;

begin
  register1_q_net_x3 <= addr;
  register1_q_net_x2 <= data_in;
  register1_q_net_x4 <= we;
  convert_addr_x0 <= convert_addr_dout_net_x0;
  convert_din_x0 <= convert_din_dout_net_x0;
  convert_we_x0 <= convert_we_dout_net_x0;

  convert_addr: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 14,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 14,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x3,
      dout => convert_addr_dout_net_x0
    );

  convert_din: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 32,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => register1_q_net_x2,
      dout => convert_din_dout_net_x0
    );

  convert_we: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 1,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 1,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din(0) => register1_q_net_x4,
      dout(0) => convert_we_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulses/pipeline1"

entity pipeline1_entity_d8051c6068 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(31 downto 0); 
    q: out std_logic_vector(31 downto 0)
  );
end pipeline1_entity_d8051c6068;

architecture structural of pipeline1_entity_d8051c6068 is
  signal ce_1_sg_x408: std_logic;
  signal clk_1_sg_x408: std_logic;
  signal delay39_q_net_x0: std_logic_vector(31 downto 0);
  signal register0_q_net: std_logic_vector(31 downto 0);
  signal register1_q_net_x3: std_logic_vector(31 downto 0);

begin
  ce_1_sg_x408 <= ce_1;
  clk_1_sg_x408 <= clk_1;
  delay39_q_net_x0 <= d;
  q <= register1_q_net_x3;

  register0: entity work.xlregister
    generic map (
      d_width => 32,
      init_value => b"00000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x408,
      clk => clk_1_sg_x408,
      d => delay39_q_net_x0,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 32,
      init_value => b"00000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x408,
      clk => clk_1_sg_x408,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x3
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulses/pipeline2"

entity pipeline2_entity_e5f717eecf is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(13 downto 0); 
    q: out std_logic_vector(13 downto 0)
  );
end pipeline2_entity_e5f717eecf;

architecture structural of pipeline2_entity_e5f717eecf is
  signal ce_1_sg_x409: std_logic;
  signal clk_1_sg_x409: std_logic;
  signal lut_counter2_op_net_x0: std_logic_vector(13 downto 0);
  signal register0_q_net: std_logic_vector(13 downto 0);
  signal register1_q_net_x4: std_logic_vector(13 downto 0);

begin
  ce_1_sg_x409 <= ce_1;
  clk_1_sg_x409 <= clk_1;
  lut_counter2_op_net_x0 <= d;
  q <= register1_q_net_x4;

  register0: entity work.xlregister
    generic map (
      d_width => 14,
      init_value => b"00000000000000"
    )
    port map (
      ce => ce_1_sg_x409,
      clk => clk_1_sg_x409,
      d => lut_counter2_op_net_x0,
      en => "1",
      rst => "0",
      q => register0_q_net
    );

  register1: entity work.xlregister
    generic map (
      d_width => 14,
      init_value => b"00000000000000"
    )
    port map (
      ce => ce_1_sg_x409,
      clk => clk_1_sg_x409,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x4
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/pulses"

entity pulses_entity_b41946d268 is
  port (
    acq_started: in std_logic; 
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_in: in std_logic_vector(63 downto 0); 
    reset_addr: in std_logic; 
    sync_in: in std_logic; 
    we: in std_logic; 
    addr: out std_logic_vector(31 downto 0); 
    bram0: out std_logic_vector(13 downto 0); 
    bram0_x0: out std_logic_vector(31 downto 0); 
    bram0_x1: out std_logic; 
    bram1: out std_logic_vector(13 downto 0); 
    bram1_x0: out std_logic_vector(31 downto 0); 
    bram1_x1: out std_logic
  );
end pulses_entity_b41946d268;

architecture structural of pulses_entity_b41946d268 is
  signal ce_1_sg_x415: std_logic;
  signal clk_1_sg_x415: std_logic;
  signal constant2_op_net: std_logic;
  signal constant_op_net: std_logic_vector(63 downto 0);
  signal convert_addr_dout_net_x2: std_logic_vector(13 downto 0);
  signal convert_addr_dout_net_x3: std_logic_vector(13 downto 0);
  signal convert_din_dout_net_x2: std_logic_vector(31 downto 0);
  signal convert_din_dout_net_x3: std_logic_vector(31 downto 0);
  signal convert_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_we_dout_net_x2: std_logic;
  signal convert_we_dout_net_x3: std_logic;
  signal delay1_q_net: std_logic;
  signal delay2_q_net: std_logic;
  signal delay30_q_net_x0: std_logic;
  signal delay38_q_net_x0: std_logic;
  signal delay39_q_net_x0: std_logic_vector(31 downto 0);
  signal delay39_q_net_x1: std_logic_vector(63 downto 0);
  signal delay3_q_net: std_logic_vector(63 downto 0);
  signal delay41_q_net_x0: std_logic;
  signal delay45_q_net_x0: std_logic_vector(31 downto 0);
  signal delay45_q_net_x1: std_logic;
  signal delay4_q_net: std_logic;
  signal logical3_y_net: std_logic;
  signal logical6_y_net_x0: std_logic;
  signal logical_y_net_x1: std_logic;
  signal lut_counter2_op_net_x2: std_logic_vector(13 downto 0);
  signal mux1_y_net: std_logic;
  signal mux2_y_net: std_logic_vector(63 downto 0);
  signal register1_q_net_x1: std_logic_vector(13 downto 0);
  signal register1_q_net_x3: std_logic_vector(31 downto 0);
  signal register1_q_net_x4: std_logic_vector(13 downto 0);
  signal register1_q_net_x5: std_logic;
  signal register1_q_net_x6: std_logic_vector(13 downto 0);
  signal register1_q_net_x7: std_logic_vector(31 downto 0);
  signal register1_q_net_x8: std_logic;
  signal slice1_y_net: std_logic_vector(31 downto 0);
  signal slice2_y_net: std_logic_vector(31 downto 0);

begin
  delay45_q_net_x1 <= acq_started;
  ce_1_sg_x415 <= ce_1;
  clk_1_sg_x415 <= clk_1;
  delay39_q_net_x1 <= data_in;
  logical_y_net_x1 <= reset_addr;
  delay38_q_net_x0 <= sync_in;
  logical6_y_net_x0 <= we;
  addr <= convert_dout_net_x1;
  bram0 <= convert_addr_dout_net_x2;
  bram0_x0 <= convert_din_dout_net_x2;
  bram0_x1 <= convert_we_dout_net_x2;
  bram1 <= convert_addr_dout_net_x3;
  bram1_x0 <= convert_din_dout_net_x3;
  bram1_x1 <= convert_we_dout_net_x3;

  addr_95560a6d6f: entity work.rd_valid_entity_a0091712c4
    port map (
      reg_out => register1_q_net_x1,
      convert_x0 => convert_dout_net_x1
    );

  bram0_4b6cf72a79: entity work.bram0_entity_4b6cf72a79
    port map (
      addr => register1_q_net_x4,
      data_in => register1_q_net_x3,
      we => register1_q_net_x5,
      convert_addr_x0 => convert_addr_dout_net_x2,
      convert_din_x0 => convert_din_dout_net_x2,
      convert_we_x0 => convert_we_dout_net_x2
    );

  bram1_596bff5dc6: entity work.bram0_entity_4b6cf72a79
    port map (
      addr => register1_q_net_x6,
      data_in => register1_q_net_x7,
      we => register1_q_net_x8,
      convert_addr_x0 => convert_addr_dout_net_x3,
      convert_din_x0 => convert_din_dout_net_x3,
      convert_we_x0 => convert_we_dout_net_x3
    );

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  constant_x0: entity work.constant_17eda58ae4
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  delay1: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d(0) => delay4_q_net,
      q(0) => delay1_q_net
    );

  delay2: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d(0) => logical6_y_net_x0,
      q(0) => delay2_q_net
    );

  delay3: entity work.delay_e2d047c154
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d => delay39_q_net_x1,
      q => delay3_q_net
    );

  delay30: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d(0) => mux1_y_net,
      q(0) => delay30_q_net_x0
    );

  delay39: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d => slice2_y_net,
      q => delay39_q_net_x0
    );

  delay4: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d(0) => logical_y_net_x1,
      q(0) => delay4_q_net
    );

  delay41: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d(0) => mux1_y_net,
      q(0) => delay41_q_net_x0
    );

  delay45: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d => slice1_y_net,
      q => delay45_q_net_x0
    );

  logical3: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d0(0) => delay45_q_net_x1,
      d1(0) => delay38_q_net_x0,
      y(0) => logical3_y_net
    );

  lut_counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_82b9fd0243bf8494",
      op_arith => xlUnsigned,
      op_width => 14
    )
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      en(0) => mux1_y_net,
      rst(0) => delay1_q_net,
      op => lut_counter2_op_net_x2
    );

  mux1: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d0(0) => delay2_q_net,
      d1(0) => constant2_op_net,
      sel(0) => logical3_y_net,
      y(0) => mux1_y_net
    );

  mux2: entity work.mux_fd01d62b53
    port map (
      ce => ce_1_sg_x415,
      clk => clk_1_sg_x415,
      clr => '0',
      d0 => delay3_q_net,
      d1 => constant_op_net,
      sel(0) => logical3_y_net,
      y => mux2_y_net
    );

  pipeline1_d8051c6068: entity work.pipeline1_entity_d8051c6068
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => delay39_q_net_x0,
      q => register1_q_net_x3
    );

  pipeline2_e5f717eecf: entity work.pipeline2_entity_e5f717eecf
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => lut_counter2_op_net_x2,
      q => register1_q_net_x4
    );

  pipeline3_18d500fc97: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => delay30_q_net_x0,
      q => register1_q_net_x5
    );

  pipeline4_c8536cee10: entity work.pipeline2_entity_e5f717eecf
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => lut_counter2_op_net_x2,
      q => register1_q_net_x6
    );

  pipeline5_1a3f5e9fab: entity work.pipeline1_entity_d8051c6068
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => delay45_q_net_x0,
      q => register1_q_net_x7
    );

  pipeline6_9c027026ca: entity work.pipeline3_entity_e232fb1c42
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => delay41_q_net_x0,
      q => register1_q_net_x8
    );

  pipeline7_67f505b877: entity work.pipeline2_entity_e5f717eecf
    port map (
      ce_1 => ce_1_sg_x415,
      clk_1 => clk_1_sg_x415,
      d => lut_counter2_op_net_x2,
      q => register1_q_net_x1
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 32,
      new_msb => 63,
      x_width => 64,
      y_width => 32
    )
    port map (
      x => mux2_y_net,
      y => slice1_y_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 31,
      x_width => 64,
      y_width => 32
    )
    port map (
      x => mux2_y_net,
      y => slice2_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/seconds"

entity seconds_entity_8c9708d995 is
  port (
    reg_out: in std_logic_vector(31 downto 0); 
    convert_x0: out std_logic_vector(31 downto 0)
  );
end seconds_entity_8c9708d995;

architecture structural of seconds_entity_8c9708d995 is
  signal convert_dout_net_x0: std_logic_vector(31 downto 0);
  signal lut_counter2_op_net_x0: std_logic_vector(31 downto 0);

begin
  lut_counter2_op_net_x0 <= reg_out;
  convert_x0 <= convert_dout_net_x0;

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 32,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 32,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => lut_counter2_op_net_x0,
      dout => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean/snapPhase"

entity snapphase_entity_2e30223fdd is
  port (
    ce_1: in std_logic; 
    chan_512_clean_snapphase_ctrl_user_data_out: in std_logic_vector(31 downto 0); 
    clk_1: in std_logic; 
    din: in std_logic_vector(31 downto 0); 
    trig: in std_logic; 
    we: in std_logic; 
    addr: out std_logic_vector(31 downto 0); 
    bram: out std_logic_vector(9 downto 0); 
    bram_x0: out std_logic_vector(31 downto 0); 
    bram_x1: out std_logic
  );
end snapphase_entity_2e30223fdd;

architecture structural of snapphase_entity_2e30223fdd is
  signal ce_1_sg_x418: std_logic;
  signal chan_512_clean_snapphase_ctrl_user_data_out_net_x0: std_logic_vector(31 downto 0);
  signal clk_1_sg_x418: std_logic;
  signal concat2_y_net_x0: std_logic_vector(31 downto 0);
  signal constant1_op_net: std_logic;
  signal constant2_op_net: std_logic;
  signal constant_op_net: std_logic;
  signal convert_addr_dout_net_x1: std_logic_vector(9 downto 0);
  signal convert_din_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_we_dout_net_x1: std_logic;
  signal delay1_q_net: std_logic_vector(31 downto 0);
  signal delay25_q_net_x0: std_logic;
  signal delay25_q_net_x1: std_logic;
  signal delay2_q_net_x0: std_logic_vector(9 downto 0);
  signal delay3_q_net_x0: std_logic_vector(31 downto 0);
  signal delay4_q_net_x0: std_logic;
  signal delay5_q_net: std_logic_vector(9 downto 0);
  signal delay6_q_net: std_logic;
  signal delay7_q_net: std_logic;
  signal enable_y_net: std_logic;
  signal enable_y_net_x0: std_logic_vector(9 downto 0);
  signal inverter_op_net: std_logic;
  signal logical1_y_net_x0: std_logic;
  signal logical1_y_net_x1: std_logic;
  signal logical1_y_net_x2: std_logic;
  signal logical_y_net_x0: std_logic;
  signal mux1_y_net_x0: std_logic;
  signal mux2_y_net: std_logic;
  signal register1_q_net_x0: std_logic_vector(9 downto 0);
  signal register_q_net_x0: std_logic;
  signal reinterpret_output_port_net: std_logic_vector(31 downto 0);
  signal trig1_y_net: std_logic;
  signal valid_y_net: std_logic;

begin
  ce_1_sg_x418 <= ce_1;
  chan_512_clean_snapphase_ctrl_user_data_out_net_x0 <= chan_512_clean_snapphase_ctrl_user_data_out;
  clk_1_sg_x418 <= clk_1;
  concat2_y_net_x0 <= din;
  delay25_q_net_x1 <= trig;
  logical1_y_net_x2 <= we;
  addr <= convert_dout_net_x1;
  bram <= convert_addr_dout_net_x1;
  bram_x0 <= convert_din_dout_net_x1;
  bram_x1 <= convert_we_dout_net_x1;

  addr_92d9e5a2f4: entity work.addr_entity_0b3e5d3e19
    port map (
      reg_out => register1_q_net_x0,
      convert_x0 => convert_dout_net_x1
    );

  bram_cf5565cb1f: entity work.bram_entity_ba4d41d040
    port map (
      addr => delay2_q_net_x0,
      data_in => delay3_q_net_x0,
      we => delay4_q_net_x0,
      convert_addr_x0 => convert_addr_dout_net_x1,
      convert_din_x0 => convert_din_dout_net_x1,
      convert_we_x0 => convert_we_dout_net_x1
    );

  constant1: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant1_op_net
    );

  constant2: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant2_op_net
    );

  constant_x0: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant_op_net
    );

  delay1: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d => concat2_y_net_x0,
      q => delay1_q_net
    );

  delay2: entity work.delay_cf4f99539f
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d => enable_y_net_x0,
      q => delay2_q_net_x0
    );

  delay25: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d(0) => enable_y_net,
      q(0) => delay25_q_net_x0
    );

  delay3: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d => reinterpret_output_port_net,
      q => delay3_q_net_x0
    );

  delay4: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d(0) => logical1_y_net_x1,
      q(0) => delay4_q_net_x0
    );

  delay5: entity work.delay_cf4f99539f
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d => enable_y_net_x0,
      q => delay5_q_net
    );

  delay6: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d(0) => logical_y_net_x0,
      q(0) => delay6_q_net
    );

  delay7: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d(0) => logical1_y_net_x1,
      q(0) => delay7_q_net
    );

  enable: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_snapphase_ctrl_user_data_out_net_x0,
      y(0) => enable_y_net
    );

  freeze_cntr_3332e1ebb6: entity work.freeze_cntr_entity_0ddc4df5a3
    port map (
      ce_1 => ce_1_sg_x418,
      clk_1 => clk_1_sg_x418,
      en => mux1_y_net_x0,
      rst => register_q_net_x0,
      addr => enable_y_net_x0,
      we => logical1_y_net_x1
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      ip(0) => logical_y_net_x0,
      op(0) => inverter_op_net
    );

  logical1: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => mux2_y_net,
      d1(0) => inverter_op_net,
      y(0) => logical1_y_net_x0
    );

  mux1: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d0(0) => logical1_y_net_x2,
      d1(0) => constant2_op_net,
      sel(0) => valid_y_net,
      y(0) => mux1_y_net_x0
    );

  mux2: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      clr => '0',
      d0(0) => delay25_q_net_x1,
      d1(0) => constant1_op_net,
      sel(0) => trig1_y_net,
      y(0) => mux2_y_net
    );

  posedge_802f763cb0: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x418,
      clk_1 => clk_1_sg_x418,
      in_x0 => delay25_q_net_x0,
      out_x0 => logical_y_net_x0
    );

  register1: entity work.xlregister
    generic map (
      d_width => 10,
      init_value => b"0000000000"
    )
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      d => delay5_q_net,
      en(0) => delay7_q_net,
      rst(0) => delay6_q_net,
      q => register1_q_net_x0
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x418,
      clk => clk_1_sg_x418,
      d(0) => constant_op_net,
      en(0) => logical_y_net_x0,
      rst(0) => logical1_y_net_x0,
      q(0) => register_q_net_x0
    );

  reinterpret: entity work.reinterpret_c5d4d59b73
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => delay1_q_net,
      output_port => reinterpret_output_port_net
    );

  trig1: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 1,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_snapphase_ctrl_user_data_out_net_x0,
      y(0) => trig1_y_net
    );

  valid: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 2,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_snapphase_ctrl_user_data_out_net_x0,
      y(0) => valid_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "chan_512_clean"

entity chan_512_clean is
  port (
    ce_1: in std_logic; 
    chan_512_clean_adc_mkid_user_data_i0: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_data_i1: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_data_q0: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_data_q1: in std_logic_vector(11 downto 0); 
    chan_512_clean_adc_mkid_user_sync: in std_logic; 
    chan_512_clean_avgiq_bram_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_avgiq_ctrl_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_bins_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_capture_load_thresh_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_capture_threshold_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_ch_we_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_conv_phase_centers_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_conv_phase_load_centers_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_dram_lut_dram_mem_cmd_ack: in std_logic; 
    chan_512_clean_dram_lut_dram_mem_rd_dout: in std_logic_vector(143 downto 0); 
    chan_512_clean_dram_lut_dram_mem_rd_tag: in std_logic_vector(31 downto 0); 
    chan_512_clean_dram_lut_dram_mem_rd_valid: in std_logic; 
    chan_512_clean_dram_lut_dram_phy_ready: in std_logic; 
    chan_512_clean_fir_b0b1_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b10b11_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b12b13_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b14b15_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b16b17_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b18b19_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b20b21_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b22b23_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b24b25_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b2b3_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b4b5_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b6b7_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_b8b9_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_fir_load_coeff_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_if_switch_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_lo_sle_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_load_bins_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_pulses_bram0_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_pulses_bram1_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_regs_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_ser_di_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_snapphase_bram_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_snapphase_ctrl_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_start_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_startaccumulator_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_startbuffer_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_startdac_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_startsnap_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_stb_en_user_data_out: in std_logic_vector(31 downto 0); 
    chan_512_clean_swat_le_user_data_out: in std_logic_vector(31 downto 0); 
    clk_1: in std_logic; 
    chan_512_clean_avgiq_addr_user_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_avgiq_bram_addr: out std_logic_vector(9 downto 0); 
    chan_512_clean_avgiq_bram_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_avgiq_bram_we: out std_logic; 
    chan_512_clean_dac_mkid_dac_data_i0: out std_logic_vector(15 downto 0); 
    chan_512_clean_dac_mkid_dac_data_i1: out std_logic_vector(15 downto 0); 
    chan_512_clean_dac_mkid_dac_data_q0: out std_logic_vector(15 downto 0); 
    chan_512_clean_dac_mkid_dac_data_q1: out std_logic_vector(15 downto 0); 
    chan_512_clean_dac_mkid_dac_sync_i: out std_logic; 
    chan_512_clean_dac_mkid_dac_sync_q: out std_logic; 
    chan_512_clean_dac_mkid_not_reset: out std_logic; 
    chan_512_clean_dac_mkid_not_sdenb_i: out std_logic; 
    chan_512_clean_dac_mkid_not_sdenb_q: out std_logic; 
    chan_512_clean_dac_mkid_sclk: out std_logic; 
    chan_512_clean_dac_mkid_sdi: out std_logic; 
    chan_512_clean_dram_lut_dram_mem_cmd_address: out std_logic_vector(31 downto 0); 
    chan_512_clean_dram_lut_dram_mem_cmd_rnw: out std_logic; 
    chan_512_clean_dram_lut_dram_mem_cmd_tag: out std_logic_vector(31 downto 0); 
    chan_512_clean_dram_lut_dram_mem_cmd_valid: out std_logic; 
    chan_512_clean_dram_lut_dram_mem_rd_ack: out std_logic; 
    chan_512_clean_dram_lut_dram_mem_rst: out std_logic; 
    chan_512_clean_dram_lut_dram_mem_wr_be: out std_logic_vector(17 downto 0); 
    chan_512_clean_dram_lut_dram_mem_wr_din: out std_logic_vector(143 downto 0); 
    chan_512_clean_dram_lut_rd_valid_user_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_gpio_a0_gateway: out std_logic; 
    chan_512_clean_gpio_a1_gateway: out std_logic; 
    chan_512_clean_gpio_a2_gateway: out std_logic; 
    chan_512_clean_gpio_a3_gateway: out std_logic; 
    chan_512_clean_gpio_a5_gateway: out std_logic; 
    chan_512_clean_pulses_addr_user_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_pulses_bram0_addr: out std_logic_vector(13 downto 0); 
    chan_512_clean_pulses_bram0_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_pulses_bram0_we: out std_logic; 
    chan_512_clean_pulses_bram1_addr: out std_logic_vector(13 downto 0); 
    chan_512_clean_pulses_bram1_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_pulses_bram1_we: out std_logic; 
    chan_512_clean_seconds_user_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_snapphase_addr_user_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_snapphase_bram_addr: out std_logic_vector(9 downto 0); 
    chan_512_clean_snapphase_bram_data_in: out std_logic_vector(31 downto 0); 
    chan_512_clean_snapphase_bram_we: out std_logic
  );
end chan_512_clean;

architecture structural of chan_512_clean is
  attribute core_generation_info: string;
  attribute core_generation_info of structural : architecture is "chan_512_clean,sysgen_core_11_4,{modelsim_hdl_co_simulation_interface_block=1,total_blocks=8531,xilinx_adder_subtracter_block=122,xilinx_arithmetic_relational_operator_block=90,xilinx_assert_block=8,xilinx_bit_slice_extractor_block=840,xilinx_black_box_block=1,xilinx_bus_concatenator_block=182,xilinx_bus_multiplexer_block=231,xilinx_constant_block_block=409,xilinx_cordic_4_0_block=1,xilinx_counter_block=139,xilinx_delay_block=596,xilinx_disregard_subsystem_for_generation_block=7,xilinx_dsp48e_block=36,xilinx_fifo_block_block=3,xilinx_gateway_in_block=60,xilinx_gateway_out_block=45,xilinx_input_scaler_block=80,xilinx_inverter_block=304,xilinx_logical_block_block=339,xilinx_multiplier_block=158,xilinx_negate_block_block=4,xilinx_register_block=108,xilinx_simulation_multiplexer_block=4,xilinx_single_port_random_access_memory_block=65,xilinx_single_port_read_only_memory_block=62,xilinx_system_generator_block=1,xilinx_type_converter_block=403,xilinx_type_reinterpreter_block=766,}";

  signal addsub40_s_net_x0: std_logic_vector(11 downto 0);
  signal ce_1_sg_x419: std_logic;
  signal chan_512_clean_adc_mkid_user_data_i0_net: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_data_i1_net: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_data_q0_net: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_data_q1_net: std_logic_vector(11 downto 0);
  signal chan_512_clean_adc_mkid_user_sync_net: std_logic;
  signal chan_512_clean_avgiq_addr_user_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_avgiq_bram_addr_net: std_logic_vector(9 downto 0);
  signal chan_512_clean_avgiq_bram_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_avgiq_bram_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_avgiq_bram_we_net: std_logic;
  signal chan_512_clean_avgiq_ctrl_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_bins_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_capture_load_thresh_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_capture_threshold_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_ch_we_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_conv_phase_centers_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_conv_phase_load_centers_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_dac_mkid_dac_data_i0_net: std_logic_vector(15 downto 0);
  signal chan_512_clean_dac_mkid_dac_data_i1_net: std_logic_vector(15 downto 0);
  signal chan_512_clean_dac_mkid_dac_data_q0_net: std_logic_vector(15 downto 0);
  signal chan_512_clean_dac_mkid_dac_data_q1_net: std_logic_vector(15 downto 0);
  signal chan_512_clean_dac_mkid_dac_sync_i_net: std_logic;
  signal chan_512_clean_dac_mkid_dac_sync_q_net: std_logic;
  signal chan_512_clean_dac_mkid_not_reset_net: std_logic;
  signal chan_512_clean_dac_mkid_not_sdenb_i_net: std_logic;
  signal chan_512_clean_dac_mkid_not_sdenb_q_net: std_logic;
  signal chan_512_clean_dac_mkid_sclk_net: std_logic;
  signal chan_512_clean_dac_mkid_sdi_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_cmd_ack_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_cmd_address_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_cmd_rnw_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_cmd_tag_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_cmd_valid_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_rd_ack_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_rd_dout_net: std_logic_vector(143 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_rd_tag_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_rd_valid_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_rst_net: std_logic;
  signal chan_512_clean_dram_lut_dram_mem_wr_be_net: std_logic_vector(17 downto 0);
  signal chan_512_clean_dram_lut_dram_mem_wr_din_net: std_logic_vector(143 downto 0);
  signal chan_512_clean_dram_lut_dram_phy_ready_net: std_logic;
  signal chan_512_clean_dram_lut_rd_valid_user_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b0b1_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b10b11_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b12b13_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b14b15_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b16b17_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b18b19_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b20b21_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b22b23_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b24b25_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b2b3_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b4b5_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b6b7_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_b8b9_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_fir_load_coeff_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_gpio_a0_gateway_net: std_logic;
  signal chan_512_clean_gpio_a1_gateway_net: std_logic;
  signal chan_512_clean_gpio_a2_gateway_net: std_logic;
  signal chan_512_clean_gpio_a3_gateway_net: std_logic;
  signal chan_512_clean_gpio_a5_gateway_net: std_logic;
  signal chan_512_clean_if_switch_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_lo_sle_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_load_bins_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_pulses_addr_user_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_pulses_bram0_addr_net: std_logic_vector(13 downto 0);
  signal chan_512_clean_pulses_bram0_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_pulses_bram0_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_pulses_bram0_we_net: std_logic;
  signal chan_512_clean_pulses_bram1_addr_net: std_logic_vector(13 downto 0);
  signal chan_512_clean_pulses_bram1_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_pulses_bram1_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_pulses_bram1_we_net: std_logic;
  signal chan_512_clean_regs_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_seconds_user_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_ser_di_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_snapphase_addr_user_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_snapphase_bram_addr_net: std_logic_vector(9 downto 0);
  signal chan_512_clean_snapphase_bram_data_in_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_snapphase_bram_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_snapphase_bram_we_net: std_logic;
  signal chan_512_clean_snapphase_ctrl_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_start_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_startaccumulator_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_startbuffer_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_startdac_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_startsnap_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_stb_en_user_data_out_net: std_logic_vector(31 downto 0);
  signal chan_512_clean_swat_le_user_data_out_net: std_logic_vector(31 downto 0);
  signal clk_1_sg_x419: std_logic;
  signal concat1_y_net_x0: std_logic_vector(63 downto 0);
  signal concat2_y_net_x0: std_logic_vector(31 downto 0);
  signal concat_y_net_x0: std_logic_vector(75 downto 0);
  signal constant10_op_net: std_logic;
  signal constant9_op_net: std_logic_vector(7 downto 0);
  signal convert2_dout_net_x0: std_logic_vector(15 downto 0);
  signal convert4_dout_net: std_logic_vector(15 downto 0);
  signal convert_dout_net_x33: std_logic_vector(32 downto 0);
  signal cordic_4_0_phase_out_net_x0: std_logic_vector(11 downto 0);
  signal counter1_op_net: std_logic_vector(7 downto 0);
  signal counter_op_net: std_logic_vector(7 downto 0);
  signal delay10_q_net_x1: std_logic_vector(11 downto 0);
  signal delay11_q_net: std_logic_vector(143 downto 0);
  signal delay12_q_net_x1: std_logic;
  signal delay14_q_net_x1: std_logic_vector(7 downto 0);
  signal delay15_q_net_x1: std_logic_vector(143 downto 0);
  signal delay16_q_net_x0: std_logic_vector(8 downto 0);
  signal delay17_q_net: std_logic_vector(75 downto 0);
  signal delay18_q_net: std_logic;
  signal delay19_q_net: std_logic;
  signal delay1_q_net: std_logic_vector(7 downto 0);
  signal delay1_q_net_x1: std_logic_vector(7 downto 0);
  signal delay20_q_net: std_logic;
  signal delay20_q_net_x0: std_logic_vector(143 downto 0);
  signal delay21_q_net: std_logic;
  signal delay22_q_net: std_logic;
  signal delay23_q_net: std_logic;
  signal delay24_q_net: std_logic_vector(15 downto 0);
  signal delay24_q_net_x1: std_logic_vector(7 downto 0);
  signal delay25_q_net_x1: std_logic;
  signal delay26_q_net: std_logic_vector(75 downto 0);
  signal delay27_q_net: std_logic_vector(15 downto 0);
  signal delay28_q_net: std_logic_vector(15 downto 0);
  signal delay29_q_net: std_logic_vector(15 downto 0);
  signal delay2_q_net: std_logic;
  signal delay2_q_net_x0: std_logic_vector(7 downto 0);
  signal delay30_q_net_x0: std_logic_vector(75 downto 0);
  signal delay32_q_net: std_logic;
  signal delay33_q_net: std_logic;
  signal delay34_q_net_x0: std_logic;
  signal delay35_q_net_x0: std_logic;
  signal delay36_q_net_x0: std_logic;
  signal delay37_q_net_x0: std_logic;
  signal delay38_q_net_x0: std_logic;
  signal delay39_q_net_x1: std_logic_vector(63 downto 0);
  signal delay40_q_net: std_logic;
  signal delay41_q_net: std_logic_vector(15 downto 0);
  signal delay42_q_net_x0: std_logic_vector(75 downto 0);
  signal delay43_q_net_x0: std_logic_vector(7 downto 0);
  signal delay45_q_net_x1: std_logic;
  signal delay46_q_net_x0: std_logic;
  signal delay48_q_net: std_logic_vector(15 downto 0);
  signal delay49_q_net: std_logic;
  signal delay4_q_net: std_logic_vector(7 downto 0);
  signal delay50_q_net_x0: std_logic;
  signal delay5_q_net: std_logic;
  signal delay6_q_net_x0: std_logic;
  signal delay7_q_net: std_logic_vector(7 downto 0);
  signal delay8_q_net: std_logic_vector(143 downto 0);
  signal delay9_q_net_x1: std_logic_vector(7 downto 0);
  signal inverter1_op_net: std_logic;
  signal inverter2_op_net: std_logic;
  signal inverter3_op_net: std_logic;
  signal inverter4_op_net: std_logic;
  signal inverter5_op_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical1_y_net_x0: std_logic;
  signal logical1_y_net_x2: std_logic;
  signal logical2_y_net: std_logic;
  signal logical3_y_net: std_logic;
  signal logical4_y_net_x1: std_logic;
  signal logical5_y_net: std_logic;
  signal logical6_y_net_x0: std_logic;
  signal logical_y_net: std_logic;
  signal logical_y_net_x1: std_logic;
  signal logical_y_net_x2: std_logic;
  signal logical_y_net_x3: std_logic;
  signal logical_y_net_x4: std_logic;
  signal logical_y_net_x5: std_logic;
  signal logical_y_net_x6: std_logic;
  signal logical_y_net_x74: std_logic;
  signal lut_counter1_op_net: std_logic;
  signal lut_counter2_op_net_x0: std_logic_vector(31 downto 0);
  signal lut_counter_op_net: std_logic_vector(7 downto 0);
  signal mux1_y_net: std_logic;
  signal mux2_y_net: std_logic_vector(7 downto 0);
  signal mux2_y_net_x1: std_logic_vector(71 downto 0);
  signal mux2_y_net_x2: std_logic_vector(31 downto 0);
  signal mux3_y_net: std_logic;
  signal mux3_y_net_x1: std_logic;
  signal mux4_y_net: std_logic;
  signal mux5_y_net: std_logic;
  signal mux6_y_net: std_logic;
  signal mux7_y_net: std_logic;
  signal register1_q_net_x0: std_logic_vector(7 downto 0);
  signal register1_q_net_x1: std_logic_vector(71 downto 0);
  signal register1_q_net_x15: std_logic_vector(11 downto 0);
  signal register1_q_net_x16: std_logic_vector(11 downto 0);
  signal register1_q_net_x17: std_logic_vector(11 downto 0);
  signal register1_q_net_x18: std_logic_vector(11 downto 0);
  signal register1_q_net_x20: std_logic;
  signal register1_q_net_x33: std_logic;
  signal register_q_net_x0: std_logic;
  signal reinterpret1_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret2_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret3_output_port_net: std_logic_vector(15 downto 0);
  signal reinterpret3_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret4_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret5_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret6_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret7_output_port_net_x2: std_logic_vector(15 downto 0);
  signal reinterpret8_output_port_net_x2: std_logic_vector(15 downto 0);
  signal relational1_op_net: std_logic;
  signal relational5_op_net_x0: std_logic;
  signal relational5_op_net_x1: std_logic;
  signal relational5_op_net_x2: std_logic;
  signal relational5_op_net_x3: std_logic;
  signal relational5_op_net_x4: std_logic;
  signal relational5_op_net_x5: std_logic;
  signal relational_op_net: std_logic;
  signal single_port_ram2_data_out_net: std_logic_vector(8 downto 0);
  signal slice10_y_net: std_logic;
  signal slice11_y_net: std_logic;
  signal slice12_y_net: std_logic_vector(8 downto 0);
  signal slice13_y_net: std_logic;
  signal slice14_y_net: std_logic;
  signal slice15_y_net: std_logic;
  signal slice16_y_net: std_logic;
  signal slice17_y_net: std_logic;
  signal slice18_y_net: std_logic;
  signal slice19_y_net_x0: std_logic;
  signal slice1_y_net: std_logic_vector(7 downto 0);
  signal slice20_y_net: std_logic;
  signal slice21_y_net: std_logic;
  signal slice22_y_net: std_logic;
  signal slice23_y_net: std_logic;
  signal slice24_y_net: std_logic_vector(7 downto 0);
  signal slice25_y_net: std_logic;
  signal slice26_y_net_x0: std_logic;
  signal slice2_y_net_x1: std_logic;
  signal slice3_y_net_x5: std_logic;
  signal slice5_y_net: std_logic;

begin
  ce_1_sg_x419 <= ce_1;
  chan_512_clean_adc_mkid_user_data_i0_net <= chan_512_clean_adc_mkid_user_data_i0;
  chan_512_clean_adc_mkid_user_data_i1_net <= chan_512_clean_adc_mkid_user_data_i1;
  chan_512_clean_adc_mkid_user_data_q0_net <= chan_512_clean_adc_mkid_user_data_q0;
  chan_512_clean_adc_mkid_user_data_q1_net <= chan_512_clean_adc_mkid_user_data_q1;
  chan_512_clean_adc_mkid_user_sync_net <= chan_512_clean_adc_mkid_user_sync;
  chan_512_clean_avgiq_bram_data_out_net <= chan_512_clean_avgiq_bram_data_out;
  chan_512_clean_avgiq_ctrl_user_data_out_net <= chan_512_clean_avgiq_ctrl_user_data_out;
  chan_512_clean_bins_user_data_out_net <= chan_512_clean_bins_user_data_out;
  chan_512_clean_capture_load_thresh_user_data_out_net <= chan_512_clean_capture_load_thresh_user_data_out;
  chan_512_clean_capture_threshold_user_data_out_net <= chan_512_clean_capture_threshold_user_data_out;
  chan_512_clean_ch_we_user_data_out_net <= chan_512_clean_ch_we_user_data_out;
  chan_512_clean_conv_phase_centers_user_data_out_net <= chan_512_clean_conv_phase_centers_user_data_out;
  chan_512_clean_conv_phase_load_centers_user_data_out_net <= chan_512_clean_conv_phase_load_centers_user_data_out;
  chan_512_clean_dram_lut_dram_mem_cmd_ack_net <= chan_512_clean_dram_lut_dram_mem_cmd_ack;
  chan_512_clean_dram_lut_dram_mem_rd_dout_net <= chan_512_clean_dram_lut_dram_mem_rd_dout;
  chan_512_clean_dram_lut_dram_mem_rd_tag_net <= chan_512_clean_dram_lut_dram_mem_rd_tag;
  chan_512_clean_dram_lut_dram_mem_rd_valid_net <= chan_512_clean_dram_lut_dram_mem_rd_valid;
  chan_512_clean_dram_lut_dram_phy_ready_net <= chan_512_clean_dram_lut_dram_phy_ready;
  chan_512_clean_fir_b0b1_user_data_out_net <= chan_512_clean_fir_b0b1_user_data_out;
  chan_512_clean_fir_b10b11_user_data_out_net <= chan_512_clean_fir_b10b11_user_data_out;
  chan_512_clean_fir_b12b13_user_data_out_net <= chan_512_clean_fir_b12b13_user_data_out;
  chan_512_clean_fir_b14b15_user_data_out_net <= chan_512_clean_fir_b14b15_user_data_out;
  chan_512_clean_fir_b16b17_user_data_out_net <= chan_512_clean_fir_b16b17_user_data_out;
  chan_512_clean_fir_b18b19_user_data_out_net <= chan_512_clean_fir_b18b19_user_data_out;
  chan_512_clean_fir_b20b21_user_data_out_net <= chan_512_clean_fir_b20b21_user_data_out;
  chan_512_clean_fir_b22b23_user_data_out_net <= chan_512_clean_fir_b22b23_user_data_out;
  chan_512_clean_fir_b24b25_user_data_out_net <= chan_512_clean_fir_b24b25_user_data_out;
  chan_512_clean_fir_b2b3_user_data_out_net <= chan_512_clean_fir_b2b3_user_data_out;
  chan_512_clean_fir_b4b5_user_data_out_net <= chan_512_clean_fir_b4b5_user_data_out;
  chan_512_clean_fir_b6b7_user_data_out_net <= chan_512_clean_fir_b6b7_user_data_out;
  chan_512_clean_fir_b8b9_user_data_out_net <= chan_512_clean_fir_b8b9_user_data_out;
  chan_512_clean_fir_load_coeff_user_data_out_net <= chan_512_clean_fir_load_coeff_user_data_out;
  chan_512_clean_if_switch_user_data_out_net <= chan_512_clean_if_switch_user_data_out;
  chan_512_clean_lo_sle_user_data_out_net <= chan_512_clean_lo_sle_user_data_out;
  chan_512_clean_load_bins_user_data_out_net <= chan_512_clean_load_bins_user_data_out;
  chan_512_clean_pulses_bram0_data_out_net <= chan_512_clean_pulses_bram0_data_out;
  chan_512_clean_pulses_bram1_data_out_net <= chan_512_clean_pulses_bram1_data_out;
  chan_512_clean_regs_user_data_out_net <= chan_512_clean_regs_user_data_out;
  chan_512_clean_ser_di_user_data_out_net <= chan_512_clean_ser_di_user_data_out;
  chan_512_clean_snapphase_bram_data_out_net <= chan_512_clean_snapphase_bram_data_out;
  chan_512_clean_snapphase_ctrl_user_data_out_net <= chan_512_clean_snapphase_ctrl_user_data_out;
  chan_512_clean_start_user_data_out_net <= chan_512_clean_start_user_data_out;
  chan_512_clean_startaccumulator_user_data_out_net <= chan_512_clean_startaccumulator_user_data_out;
  chan_512_clean_startbuffer_user_data_out_net <= chan_512_clean_startbuffer_user_data_out;
  chan_512_clean_startdac_user_data_out_net <= chan_512_clean_startdac_user_data_out;
  chan_512_clean_startsnap_user_data_out_net <= chan_512_clean_startsnap_user_data_out;
  chan_512_clean_stb_en_user_data_out_net <= chan_512_clean_stb_en_user_data_out;
  chan_512_clean_swat_le_user_data_out_net <= chan_512_clean_swat_le_user_data_out;
  clk_1_sg_x419 <= clk_1;
  chan_512_clean_avgiq_addr_user_data_in <= chan_512_clean_avgiq_addr_user_data_in_net;
  chan_512_clean_avgiq_bram_addr <= chan_512_clean_avgiq_bram_addr_net;
  chan_512_clean_avgiq_bram_data_in <= chan_512_clean_avgiq_bram_data_in_net;
  chan_512_clean_avgiq_bram_we <= chan_512_clean_avgiq_bram_we_net;
  chan_512_clean_dac_mkid_dac_data_i0 <= chan_512_clean_dac_mkid_dac_data_i0_net;
  chan_512_clean_dac_mkid_dac_data_i1 <= chan_512_clean_dac_mkid_dac_data_i1_net;
  chan_512_clean_dac_mkid_dac_data_q0 <= chan_512_clean_dac_mkid_dac_data_q0_net;
  chan_512_clean_dac_mkid_dac_data_q1 <= chan_512_clean_dac_mkid_dac_data_q1_net;
  chan_512_clean_dac_mkid_dac_sync_i <= chan_512_clean_dac_mkid_dac_sync_i_net;
  chan_512_clean_dac_mkid_dac_sync_q <= chan_512_clean_dac_mkid_dac_sync_q_net;
  chan_512_clean_dac_mkid_not_reset <= chan_512_clean_dac_mkid_not_reset_net;
  chan_512_clean_dac_mkid_not_sdenb_i <= chan_512_clean_dac_mkid_not_sdenb_i_net;
  chan_512_clean_dac_mkid_not_sdenb_q <= chan_512_clean_dac_mkid_not_sdenb_q_net;
  chan_512_clean_dac_mkid_sclk <= chan_512_clean_dac_mkid_sclk_net;
  chan_512_clean_dac_mkid_sdi <= chan_512_clean_dac_mkid_sdi_net;
  chan_512_clean_dram_lut_dram_mem_cmd_address <= chan_512_clean_dram_lut_dram_mem_cmd_address_net;
  chan_512_clean_dram_lut_dram_mem_cmd_rnw <= chan_512_clean_dram_lut_dram_mem_cmd_rnw_net;
  chan_512_clean_dram_lut_dram_mem_cmd_tag <= chan_512_clean_dram_lut_dram_mem_cmd_tag_net;
  chan_512_clean_dram_lut_dram_mem_cmd_valid <= chan_512_clean_dram_lut_dram_mem_cmd_valid_net;
  chan_512_clean_dram_lut_dram_mem_rd_ack <= chan_512_clean_dram_lut_dram_mem_rd_ack_net;
  chan_512_clean_dram_lut_dram_mem_rst <= chan_512_clean_dram_lut_dram_mem_rst_net;
  chan_512_clean_dram_lut_dram_mem_wr_be <= chan_512_clean_dram_lut_dram_mem_wr_be_net;
  chan_512_clean_dram_lut_dram_mem_wr_din <= chan_512_clean_dram_lut_dram_mem_wr_din_net;
  chan_512_clean_dram_lut_rd_valid_user_data_in <= chan_512_clean_dram_lut_rd_valid_user_data_in_net;
  chan_512_clean_gpio_a0_gateway <= chan_512_clean_gpio_a0_gateway_net;
  chan_512_clean_gpio_a1_gateway <= chan_512_clean_gpio_a1_gateway_net;
  chan_512_clean_gpio_a2_gateway <= chan_512_clean_gpio_a2_gateway_net;
  chan_512_clean_gpio_a3_gateway <= chan_512_clean_gpio_a3_gateway_net;
  chan_512_clean_gpio_a5_gateway <= chan_512_clean_gpio_a5_gateway_net;
  chan_512_clean_pulses_addr_user_data_in <= chan_512_clean_pulses_addr_user_data_in_net;
  chan_512_clean_pulses_bram0_addr <= chan_512_clean_pulses_bram0_addr_net;
  chan_512_clean_pulses_bram0_data_in <= chan_512_clean_pulses_bram0_data_in_net;
  chan_512_clean_pulses_bram0_we <= chan_512_clean_pulses_bram0_we_net;
  chan_512_clean_pulses_bram1_addr <= chan_512_clean_pulses_bram1_addr_net;
  chan_512_clean_pulses_bram1_data_in <= chan_512_clean_pulses_bram1_data_in_net;
  chan_512_clean_pulses_bram1_we <= chan_512_clean_pulses_bram1_we_net;
  chan_512_clean_seconds_user_data_in <= chan_512_clean_seconds_user_data_in_net;
  chan_512_clean_snapphase_addr_user_data_in <= chan_512_clean_snapphase_addr_user_data_in_net;
  chan_512_clean_snapphase_bram_addr <= chan_512_clean_snapphase_bram_addr_net;
  chan_512_clean_snapphase_bram_data_in <= chan_512_clean_snapphase_bram_data_in_net;
  chan_512_clean_snapphase_bram_we <= chan_512_clean_snapphase_bram_we_net;

  accumulator_0ff8042a80: entity work.accumulator_entity_0ff8042a80
    port map (
      accum_en => relational5_op_net_x2,
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      data_in => delay30_q_net_x0,
      data_out => mux2_y_net_x2,
      drdy => mux3_y_net_x1
    );

  adc_mkid_98b47612c6: entity work.adc_mkid_entity_98b47612c6
    port map (
      ce_1 => ce_1_sg_x419,
      chan_512_clean_adc_mkid_user_data_i0 => chan_512_clean_adc_mkid_user_data_i0_net,
      chan_512_clean_adc_mkid_user_data_i1 => chan_512_clean_adc_mkid_user_data_i1_net,
      chan_512_clean_adc_mkid_user_data_q0 => chan_512_clean_adc_mkid_user_data_q0_net,
      chan_512_clean_adc_mkid_user_data_q1 => chan_512_clean_adc_mkid_user_data_q1_net,
      chan_512_clean_adc_mkid_user_sync => chan_512_clean_adc_mkid_user_sync_net,
      clk_1 => clk_1_sg_x419,
      data_i0 => register1_q_net_x15,
      data_i1 => register1_q_net_x16,
      data_q0 => register1_q_net_x17,
      data_q1 => register1_q_net_x18,
      sync => register1_q_net_x20
    );

  avgiq_df5372bbc2: entity work.avgiq_entity_df5372bbc2
    port map (
      ce_1 => ce_1_sg_x419,
      chan_512_clean_avgiq_ctrl_user_data_out => chan_512_clean_avgiq_ctrl_user_data_out_net,
      clk_1 => clk_1_sg_x419,
      din => mux2_y_net_x2,
      trig => slice2_y_net_x1,
      we => mux3_y_net_x1,
      addr => chan_512_clean_avgiq_addr_user_data_in_net,
      bram => chan_512_clean_avgiq_bram_addr_net,
      bram_x0 => chan_512_clean_avgiq_bram_data_in_net,
      bram_x1 => chan_512_clean_avgiq_bram_we_net
    );

  bufferedswitch_5a7620c24d: entity work.bufferedswitch_entity_5a7620c24d
    port map (
      ce_1 => ce_1_sg_x419,
      ch_in => delay14_q_net_x1,
      clk_1 => clk_1_sg_x419,
      data_rdy => delay12_q_net_x1,
      fft_bin => delay16_q_net_x0,
      fft_data => delay15_q_net_x1,
      ch_out => delay1_q_net_x1,
      data_out => mux2_y_net_x1
    );

  capture_5ab9a605d4: entity work.capture_entity_5ab9a605d4
    port map (
      ce_1 => ce_1_sg_x419,
      ch_in => delay24_q_net_x1,
      chan_512_clean_capture_load_thresh_user_data_out => chan_512_clean_capture_load_thresh_user_data_out_net,
      chan_512_clean_capture_threshold_user_data_out => chan_512_clean_capture_threshold_user_data_out_net,
      clk_1 => clk_1_sg_x419,
      data_in => convert2_dout_net_x0,
      sync_in => logical_y_net_x6,
      data_out => concat1_y_net_x0,
      sync_out => delay46_q_net_x0,
      we_out => logical1_y_net_x0
    );

  concat2: entity work.concat_a369e00c6b
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => delay48_q_net,
      in1 => delay41_q_net,
      y => concat2_y_net_x0
    );

  constant10: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant10_op_net
    );

  constant9: entity work.constant_91ef1678ca
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant9_op_net
    );

  conv_phase_6fdedda9a4: entity work.conv_phase_entity_6fdedda9a4
    port map (
      ce_1 => ce_1_sg_x419,
      ch_in => delay43_q_net_x0,
      chan_512_clean_conv_phase_centers_user_data_out => chan_512_clean_conv_phase_centers_user_data_out_net,
      chan_512_clean_conv_phase_load_centers_user_data_out => chan_512_clean_conv_phase_load_centers_user_data_out_net,
      clk_1 => clk_1_sg_x419,
      data_in => delay42_q_net_x0,
      ch_out => delay2_q_net_x0,
      phase_out => cordic_4_0_phase_out_net_x0
    );

  convert: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 1,
      din_bin_pt => 0,
      din_width => 32,
      dout_arith => 1,
      dout_bin_pt => 0,
      dout_width => 33,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => chan_512_clean_ser_di_user_data_out_net,
      dout => convert_dout_net_x33
    );

  convert2: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 9,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 13,
      dout_width => 16,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => addsub40_s_net_x0,
      dout => convert2_dout_net_x0
    );

  convert4: entity work.xlconvert
    generic map (
      bool_conversion => 0,
      din_arith => 2,
      din_bin_pt => 9,
      din_width => 12,
      dout_arith => 2,
      dout_bin_pt => 13,
      dout_width => 16,
      latency => 0,
      overflow => xlWrap,
      quantization => xlTruncate
    )
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      din => addsub40_s_net_x0,
      dout => convert4_dout_net
    );

  counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      en(0) => relational5_op_net_x1,
      rst(0) => inverter4_op_net,
      op => counter_op_net
    );

  counter1: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      en(0) => relational5_op_net_x1,
      rst(0) => inverter3_op_net,
      op => counter1_op_net
    );

  dac_mkid_562389ae59: entity work.dac_mkid_entity_562389ae59
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      data_i0 => reinterpret4_output_port_net_x2,
      data_i1 => reinterpret1_output_port_net_x2,
      data_q0 => reinterpret8_output_port_net_x2,
      data_q1 => reinterpret7_output_port_net_x2,
      sync_i => slice3_y_net_x5,
      convert1_x0 => chan_512_clean_dac_mkid_dac_data_i1_net,
      convert2_x0 => chan_512_clean_dac_mkid_dac_data_q0_net,
      convert3_x0 => chan_512_clean_dac_mkid_dac_data_q1_net,
      convert_not_reset_x0 => chan_512_clean_dac_mkid_not_reset_net,
      convert_not_sdenb_i_x0 => chan_512_clean_dac_mkid_not_sdenb_i_net,
      convert_not_sdenb_q_x0 => chan_512_clean_dac_mkid_not_sdenb_q_net,
      convert_sclk_x0 => chan_512_clean_dac_mkid_sclk_net,
      convert_sdi_x0 => chan_512_clean_dac_mkid_sdi_net,
      convert_sync_i_x0 => chan_512_clean_dac_mkid_dac_sync_i_net,
      convert_sync_q_x0 => chan_512_clean_dac_mkid_dac_sync_q_net,
      convert_x0 => chan_512_clean_dac_mkid_dac_data_i0_net
    );

  delay1: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => delay7_q_net,
      en => '1',
      q => delay1_q_net
    );

  delay10: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => cordic_4_0_phase_out_net_x0,
      q => delay10_q_net_x1
    );

  delay11: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => delay20_q_net_x0,
      en => '1',
      q => delay11_q_net
    );

  delay12: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => delay2_q_net,
      en => '1',
      q(0) => delay12_q_net_x1
    );

  delay14: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => delay1_q_net,
      en => '1',
      q => delay14_q_net_x1
    );

  delay15: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => delay8_q_net,
      en => '1',
      q => delay15_q_net_x1
    );

  delay16: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 9
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => single_port_ram2_data_out_net,
      en => '1',
      q => delay16_q_net_x0
    );

  delay17: entity work.delay_f9b4d79e87
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay26_q_net,
      q => delay17_q_net
    );

  delay18: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => slice23_y_net,
      en => '1',
      q(0) => delay18_q_net
    );

  delay19: entity work.xldelay
    generic map (
      latency => 64,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => logical3_y_net,
      en => '1',
      q(0) => delay19_q_net
    );

  delay2: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => delay5_q_net,
      en => '1',
      q(0) => delay2_q_net
    );

  delay20: entity work.xldelay
    generic map (
      latency => 64,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => slice19_y_net_x0,
      en => '1',
      q(0) => delay20_q_net
    );

  delay21: entity work.xldelay
    generic map (
      latency => 64,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => inverter_op_net,
      en => '1',
      q(0) => delay21_q_net
    );

  delay22: entity work.xldelay
    generic map (
      latency => 64,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => inverter2_op_net,
      en => '1',
      q(0) => delay22_q_net
    );

  delay23: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => delay32_q_net,
      q(0) => delay23_q_net
    );

  delay24: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay29_q_net,
      q => delay24_q_net
    );

  delay25: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => delay23_q_net,
      q(0) => delay25_q_net_x1
    );

  delay26: entity work.delay_f9b4d79e87
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay42_q_net_x0,
      q => delay26_q_net
    );

  delay27: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => reinterpret3_output_port_net,
      q => delay27_q_net
    );

  delay28: entity work.delay_d1a3118d26
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay24_q_net,
      q => delay28_q_net
    );

  delay29: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay27_q_net,
      q => delay29_q_net
    );

  delay30: entity work.delay_f9b4d79e87
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay17_q_net,
      q => delay30_q_net_x0
    );

  delay32: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => slice13_y_net,
      q(0) => delay32_q_net
    );

  delay33: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => relational_op_net,
      q(0) => delay33_q_net
    );

  delay34: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => mux1_y_net,
      en => '1',
      q(0) => delay34_q_net_x0
    );

  delay35: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => mux6_y_net,
      en => '1',
      q(0) => delay35_q_net_x0
    );

  delay36: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => mux3_y_net,
      en => '1',
      q(0) => delay36_q_net_x0
    );

  delay37: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => mux5_y_net,
      en => '1',
      q(0) => delay37_q_net_x0
    );

  delay38: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => delay46_q_net_x0,
      q(0) => delay38_q_net_x0
    );

  delay39: entity work.delay_e2d047c154
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => concat1_y_net_x0,
      q => delay39_q_net_x1
    );

  delay4: entity work.xldelay
    generic map (
      latency => 8,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => register1_q_net_x0,
      en => '1',
      q => delay4_q_net
    );

  delay40: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => logical5_y_net,
      q(0) => delay40_q_net
    );

  delay41: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay28_q_net,
      q => delay41_q_net
    );

  delay42: entity work.delay_f9b4d79e87
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => concat_y_net_x0,
      q => delay42_q_net_x0
    );

  delay43: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay4_q_net,
      q => delay43_q_net_x0
    );

  delay45: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => register_q_net_x0,
      q(0) => delay45_q_net_x1
    );

  delay48: entity work.delay_4246ea65a9
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay24_q_net,
      q => delay48_q_net
    );

  delay49: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d(0) => delay33_q_net,
      q(0) => delay49_q_net
    );

  delay5: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => delay6_q_net_x0,
      en => '1',
      q(0) => delay5_q_net
    );

  delay50: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => mux4_y_net,
      en => '1',
      q(0) => delay50_q_net_x0
    );

  delay7: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => lut_counter_op_net,
      en => '1',
      q => delay7_q_net
    );

  delay8: entity work.xldelay
    generic map (
      latency => 3,
      reg_retiming => 0,
      width => 144
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d => delay11_q_net,
      en => '1',
      q => delay8_q_net
    );

  delay9: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d => delay2_q_net_x0,
      q => delay9_q_net_x1
    );

  dram_lut_639411377c: entity work.dram_lut_entity_639411377c
    port map (
      ce_1 => ce_1_sg_x419,
      chan_512_clean_dram_lut_dram_mem_rd_dout => chan_512_clean_dram_lut_dram_mem_rd_dout_net,
      chan_512_clean_dram_lut_dram_mem_rd_valid => chan_512_clean_dram_lut_dram_mem_rd_valid_net,
      clk_1 => clk_1_sg_x419,
      startdac => slice3_y_net_x5,
      data_i0 => reinterpret4_output_port_net_x2,
      data_i1 => reinterpret1_output_port_net_x2,
      data_q0 => reinterpret8_output_port_net_x2,
      data_q1 => reinterpret7_output_port_net_x2,
      dds_i0 => reinterpret5_output_port_net_x2,
      dds_i1 => reinterpret6_output_port_net_x2,
      dds_q0 => reinterpret3_output_port_net_x2,
      dds_q1 => reinterpret2_output_port_net_x2,
      dram => chan_512_clean_dram_lut_dram_mem_cmd_address_net,
      dram_x0 => chan_512_clean_dram_lut_dram_mem_cmd_tag_net,
      dram_x1 => chan_512_clean_dram_lut_dram_mem_cmd_valid_net,
      dram_x2 => chan_512_clean_dram_lut_dram_mem_rd_ack_net,
      dram_x3 => chan_512_clean_dram_lut_dram_mem_rst_net,
      dram_x4 => chan_512_clean_dram_lut_dram_mem_cmd_rnw_net,
      dram_x5 => chan_512_clean_dram_lut_dram_mem_wr_be_net,
      dram_x6 => chan_512_clean_dram_lut_dram_mem_wr_din_net,
      rd_valid => chan_512_clean_dram_lut_rd_valid_user_data_in_net
    );

  fir_1abae60b67: entity work.fir_entity_1abae60b67
    port map (
      ce_1 => ce_1_sg_x419,
      ch_in => delay9_q_net_x1,
      chan_512_clean_fir_b0b1_user_data_out => chan_512_clean_fir_b0b1_user_data_out_net,
      chan_512_clean_fir_b10b11_user_data_out => chan_512_clean_fir_b10b11_user_data_out_net,
      chan_512_clean_fir_b12b13_user_data_out => chan_512_clean_fir_b12b13_user_data_out_net,
      chan_512_clean_fir_b14b15_user_data_out => chan_512_clean_fir_b14b15_user_data_out_net,
      chan_512_clean_fir_b16b17_user_data_out => chan_512_clean_fir_b16b17_user_data_out_net,
      chan_512_clean_fir_b18b19_user_data_out => chan_512_clean_fir_b18b19_user_data_out_net,
      chan_512_clean_fir_b20b21_user_data_out => chan_512_clean_fir_b20b21_user_data_out_net,
      chan_512_clean_fir_b22b23_user_data_out => chan_512_clean_fir_b22b23_user_data_out_net,
      chan_512_clean_fir_b24b25_user_data_out => chan_512_clean_fir_b24b25_user_data_out_net,
      chan_512_clean_fir_b2b3_user_data_out => chan_512_clean_fir_b2b3_user_data_out_net,
      chan_512_clean_fir_b4b5_user_data_out => chan_512_clean_fir_b4b5_user_data_out_net,
      chan_512_clean_fir_b6b7_user_data_out => chan_512_clean_fir_b6b7_user_data_out_net,
      chan_512_clean_fir_b8b9_user_data_out => chan_512_clean_fir_b8b9_user_data_out_net,
      chan_512_clean_fir_load_coeff_user_data_out => chan_512_clean_fir_load_coeff_user_data_out_net,
      clk_1 => clk_1_sg_x419,
      data_in => delay10_q_net_x1,
      ch_out => delay24_q_net_x1,
      data_out => addsub40_s_net_x0
    );

  gpio_a0_ba1ddb5c7a: entity work.gpio_a0_entity_ba1ddb5c7a
    port map (
      gpio_out => delay34_q_net_x0,
      convert_x0 => chan_512_clean_gpio_a0_gateway_net
    );

  gpio_a1_684f53b930: entity work.gpio_a0_entity_ba1ddb5c7a
    port map (
      gpio_out => delay35_q_net_x0,
      convert_x0 => chan_512_clean_gpio_a1_gateway_net
    );

  gpio_a2_e332881df5: entity work.gpio_a2_entity_e332881df5
    port map (
      gpio_out => delay36_q_net_x0,
      convert_x0 => chan_512_clean_gpio_a2_gateway_net
    );

  gpio_a3_ca271be6eb: entity work.gpio_a0_entity_ba1ddb5c7a
    port map (
      gpio_out => delay37_q_net_x0,
      convert_x0 => chan_512_clean_gpio_a3_gateway_net
    );

  gpio_a5_c713409844: entity work.gpio_a0_entity_ba1ddb5c7a
    port map (
      gpio_out => delay50_q_net_x0,
      convert_x0 => chan_512_clean_gpio_a5_gateway_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      ip(0) => logical_y_net,
      op(0) => inverter_op_net
    );

  inverter1: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      ip(0) => relational5_op_net_x4,
      op(0) => inverter1_op_net
    );

  inverter2: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      ip(0) => logical2_y_net,
      op(0) => inverter2_op_net
    );

  inverter3: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      ip(0) => relational5_op_net_x1,
      op(0) => inverter3_op_net
    );

  inverter4: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      ip(0) => relational5_op_net_x1,
      op(0) => inverter4_op_net
    );

  inverter5: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      ip(0) => slice5_y_net,
      op(0) => inverter5_op_net
    );

  logical: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => relational5_op_net_x0,
      d1(0) => slice21_y_net,
      y(0) => logical_y_net
    );

  logical1: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => delay49_q_net,
      d1(0) => slice17_y_net,
      y(0) => logical1_y_net_x2
    );

  logical2: entity work.logical_80f90b97d0
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => relational5_op_net_x3,
      d1(0) => slice14_y_net,
      y(0) => logical2_y_net
    );

  logical3: entity work.logical_954ee29728
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      d0(0) => slice15_y_net,
      d1(0) => slice10_y_net,
      d2(0) => inverter1_op_net,
      y(0) => logical3_y_net
    );

  logical4: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => relational1_op_net,
      d1(0) => relational5_op_net_x5,
      y(0) => logical4_y_net_x1
    );

  logical5: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => delay46_q_net_x0,
      d1(0) => slice5_y_net,
      y(0) => logical5_y_net
    );

  logical6: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => logical1_y_net_x0,
      d1(0) => register_q_net_x0,
      y(0) => logical6_y_net_x0
    );

  lut_counter: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      en => "1",
      rst(0) => delay6_q_net_x0,
      op => lut_counter_op_net
    );

  lut_counter1: entity work.counter_2943023fcf
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      en(0) => delay33_q_net,
      op(0) => lut_counter1_op_net
    );

  lut_counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_f52338cfe462aa75",
      op_arith => xlUnsigned,
      op_width => 32
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      en(0) => delay46_q_net_x0,
      rst(0) => inverter5_op_net,
      op => lut_counter2_op_net_x0
    );

  mixer0_ea9a3b7625: entity work.mixer0_entity_ea9a3b7625
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      data_in => register1_q_net_x1,
      dds_i0 => reinterpret5_output_port_net_x2,
      dds_i1 => reinterpret6_output_port_net_x2,
      dds_q0 => reinterpret3_output_port_net_x2,
      dds_q1 => reinterpret2_output_port_net_x2,
      data_out => concat_y_net_x0
    );

  mux1: entity work.mux_2aa09bfea3
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => delay19_q_net,
      d1(0) => slice20_y_net,
      sel(0) => slice18_y_net,
      y(0) => mux1_y_net
    );

  mux2: entity work.mux_cc14a035dc
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0 => lut_counter_op_net,
      d1 => slice24_y_net,
      sel(0) => slice23_y_net,
      y => mux2_y_net
    );

  mux3: entity work.mux_8629a22ab4
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => register1_q_net_x33,
      d1(0) => slice25_y_net,
      sel(0) => slice18_y_net,
      y(0) => mux3_y_net
    );

  mux4: entity work.mux_2aa09bfea3
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => delay22_q_net,
      d1(0) => slice16_y_net,
      sel(0) => slice18_y_net,
      y(0) => mux4_y_net
    );

  mux5: entity work.mux_2aa09bfea3
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => delay21_q_net,
      d1(0) => slice11_y_net,
      sel(0) => slice18_y_net,
      y(0) => mux5_y_net
    );

  mux6: entity work.mux_2aa09bfea3
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => delay20_q_net,
      d1(0) => slice22_y_net,
      sel(0) => slice18_y_net,
      y(0) => mux6_y_net
    );

  mux7: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      d0(0) => constant10_op_net,
      d1(0) => logical5_y_net,
      sel(0) => slice5_y_net,
      y(0) => mux7_y_net
    );

  negedge_8065189e8c: entity work.negedge_entity_8065189e8c
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => register_q_net_x0,
      out_x0 => logical_y_net_x1
    );

  parallel_to_serial_converter1_4252702d68: entity work.parallel_to_serial_converter1_entity_4252702d68
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      ld => logical_y_net_x74,
      pin => convert_dout_net_x33,
      shift => logical_y_net_x5,
      sout => register1_q_net_x33
    );

  pfb_d83d8fc9f6: entity work.pfb_entity_d83d8fc9f6
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      data_i0 => register1_q_net_x15,
      data_i1 => register1_q_net_x16,
      data_q0 => register1_q_net_x17,
      data_q1 => register1_q_net_x18,
      sync_in => logical_y_net_x2,
      fft_out => delay20_q_net_x0,
      fft_rdy => delay6_q_net_x0
    );

  pipeline1_a5dbc4aa8b: entity work.pipeline1_entity_a5dbc4aa8b
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      d => delay1_q_net_x1,
      q => register1_q_net_x0
    );

  pipeline8_afacc1a86c: entity work.pipeline8_entity_afacc1a86c
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      d => mux2_y_net_x1,
      q => register1_q_net_x1
    );

  posedge1_9e0a198ebf: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => slice3_y_net_x5,
      out_x0 => logical_y_net_x2
    );

  posedge2_34836d32a0: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => slice26_y_net_x0,
      out_x0 => logical_y_net_x4
    );

  posedge3_e8979166fb: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => relational5_op_net_x1,
      out_x0 => logical_y_net_x74
    );

  posedge4_837371fc77: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => slice19_y_net_x0,
      out_x0 => logical_y_net_x5
    );

  posedge5_6907ae5f6d: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => register1_q_net_x20,
      out_x0 => logical_y_net_x6
    );

  posedge_5275b22786: entity work.posedge_entity_59344d4cf3
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => slice2_y_net_x1,
      out_x0 => logical_y_net_x3
    );

  pulse_ext1_df42a931a1: entity work.pulse_ext1_entity_df42a931a1
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => logical_y_net_x4,
      out_x0 => relational5_op_net_x1
    );

  pulse_ext2_59542487b9: entity work.pulse_ext2_entity_59542487b9
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => logical_y_net_x74,
      out_x0 => relational5_op_net_x0
    );

  pulse_ext3_d662f5bd82: entity work.pulse_ext3_entity_d662f5bd82
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => logical_y_net_x74,
      out_x0 => relational5_op_net_x3
    );

  pulse_ext4_5dcf7b9a40: entity work.pulse_ext4_entity_5dcf7b9a40
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => logical_y_net_x74,
      out_x0 => relational5_op_net_x4
    );

  pulse_ext5_ec3cf76a28: entity work.pulse_ext_entity_2c3f79dc8f
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => logical_y_net_x3,
      out_x0 => relational5_op_net_x5
    );

  pulse_ext_92968fb411: entity work.pulse_ext_entity_92968fb411
    port map (
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      in_x0 => logical4_y_net_x1,
      out_x0 => relational5_op_net_x2
    );

  pulses_b41946d268: entity work.pulses_entity_b41946d268
    port map (
      acq_started => delay45_q_net_x1,
      ce_1 => ce_1_sg_x419,
      clk_1 => clk_1_sg_x419,
      data_in => delay39_q_net_x1,
      reset_addr => logical_y_net_x1,
      sync_in => delay38_q_net_x0,
      we => logical6_y_net_x0,
      addr => chan_512_clean_pulses_addr_user_data_in_net,
      bram0 => chan_512_clean_pulses_bram0_addr_net,
      bram0_x0 => chan_512_clean_pulses_bram0_data_in_net,
      bram0_x1 => chan_512_clean_pulses_bram0_we_net,
      bram1 => chan_512_clean_pulses_bram1_addr_net,
      bram1_x0 => chan_512_clean_pulses_bram1_data_in_net,
      bram1_x1 => chan_512_clean_pulses_bram1_we_net
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      d(0) => delay40_q_net,
      en(0) => mux7_y_net,
      rst => "0",
      q(0) => register_q_net_x0
    );

  reinterpret3: entity work.reinterpret_7025463ea8
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => convert4_dout_net,
      output_port => reinterpret3_output_port_net
    );

  relational: entity work.relational_deb0401f42
    port map (
      a => delay24_q_net_x1,
      b => slice1_y_net,
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      op(0) => relational_op_net
    );

  relational1: entity work.relational_deb0401f42
    port map (
      a => delay43_q_net_x0,
      b => constant9_op_net,
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      clr => '0',
      op(0) => relational1_op_net
    );

  seconds_8c9708d995: entity work.seconds_entity_8c9708d995
    port map (
      reg_out => lut_counter2_op_net_x0,
      convert_x0 => chan_512_clean_seconds_user_data_in_net
    );

  single_port_ram2: entity work.xlspram
    generic map (
      c_address_width => 8,
      c_width => 9,
      core_name0 => "bmg_33_703aafc348b40980",
      latency => 2
    )
    port map (
      addr => mux2_y_net,
      ce => ce_1_sg_x419,
      clk => clk_1_sg_x419,
      data_in => slice12_y_net,
      en => "1",
      rst => "0",
      we(0) => delay18_q_net,
      data_out => single_port_ram2_data_out_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 7,
      x_width => 32,
      y_width => 8
    )
    port map (
      x => chan_512_clean_ch_we_user_data_out_net,
      y => slice1_y_net
    );

  slice10: entity work.xlslice
    generic map (
      new_lsb => 7,
      new_msb => 7,
      x_width => 8,
      y_width => 1
    )
    port map (
      x => counter1_op_net,
      y(0) => slice10_y_net
    );

  slice11: entity work.xlslice
    generic map (
      new_lsb => 3,
      new_msb => 3,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_regs_user_data_out_net,
      y(0) => slice11_y_net
    );

  slice12: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 8,
      x_width => 32,
      y_width => 9
    )
    port map (
      x => chan_512_clean_bins_user_data_out_net,
      y => slice12_y_net
    );

  slice13: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_startsnap_user_data_out_net,
      y(0) => slice13_y_net
    );

  slice14: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_swat_le_user_data_out_net,
      y(0) => slice14_y_net
    );

  slice15: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_stb_en_user_data_out_net,
      y(0) => slice15_y_net
    );

  slice16: entity work.xlslice
    generic map (
      new_lsb => 4,
      new_msb => 4,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_regs_user_data_out_net,
      y(0) => slice16_y_net
    );

  slice17: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 1,
      y_width => 1
    )
    port map (
      x(0) => lut_counter1_op_net,
      y(0) => slice17_y_net
    );

  slice18: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_if_switch_user_data_out_net,
      y(0) => slice18_y_net
    );

  slice19: entity work.xlslice
    generic map (
      new_lsb => 7,
      new_msb => 7,
      x_width => 8,
      y_width => 1
    )
    port map (
      x => counter_op_net,
      y(0) => slice19_y_net_x0
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_startaccumulator_user_data_out_net,
      y(0) => slice2_y_net_x1
    );

  slice20: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_regs_user_data_out_net,
      y(0) => slice20_y_net
    );

  slice21: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_lo_sle_user_data_out_net,
      y(0) => slice21_y_net
    );

  slice22: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 1,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_regs_user_data_out_net,
      y(0) => slice22_y_net
    );

  slice23: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_load_bins_user_data_out_net,
      y(0) => slice23_y_net
    );

  slice24: entity work.xlslice
    generic map (
      new_lsb => 1,
      new_msb => 8,
      x_width => 32,
      y_width => 8
    )
    port map (
      x => chan_512_clean_load_bins_user_data_out_net,
      y => slice24_y_net
    );

  slice25: entity work.xlslice
    generic map (
      new_lsb => 2,
      new_msb => 2,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_regs_user_data_out_net,
      y(0) => slice25_y_net
    );

  slice26: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_start_user_data_out_net,
      y(0) => slice26_y_net_x0
    );

  slice3: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_startdac_user_data_out_net,
      y(0) => slice3_y_net_x5
    );

  slice5: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => chan_512_clean_startbuffer_user_data_out_net,
      y(0) => slice5_y_net
    );

  snapphase_2e30223fdd: entity work.snapphase_entity_2e30223fdd
    port map (
      ce_1 => ce_1_sg_x419,
      chan_512_clean_snapphase_ctrl_user_data_out => chan_512_clean_snapphase_ctrl_user_data_out_net,
      clk_1 => clk_1_sg_x419,
      din => concat2_y_net_x0,
      trig => delay25_q_net_x1,
      we => logical1_y_net_x2,
      addr => chan_512_clean_snapphase_addr_user_data_in_net,
      bram => chan_512_clean_snapphase_bram_addr_net,
      bram_x0 => chan_512_clean_snapphase_bram_data_in_net,
      bram_x1 => chan_512_clean_snapphase_bram_we_net
    );

end structural;
