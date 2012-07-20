library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/adc_mkid/pipeline8"

entity pipeline8_entity_792aeffb65 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic; 
    q: out std_logic
  );
end pipeline8_entity_792aeffb65;

architecture structural of pipeline8_entity_792aeffb65 is
  signal ce_1_sg_x0: std_logic;
  signal clk_1_sg_x0: std_logic;
  signal register0_q_net: std_logic;
  signal register1_q_net_x0: std_logic;
  signal timestamper_adc_mkid_user_sync_net_x0: std_logic;

begin
  ce_1_sg_x0 <= ce_1;
  clk_1_sg_x0 <= clk_1;
  timestamper_adc_mkid_user_sync_net_x0 <= d;
  q <= register1_q_net_x0;

  register0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x0,
      clk => clk_1_sg_x0,
      d(0) => timestamper_adc_mkid_user_sync_net_x0,
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
      ce => ce_1_sg_x0,
      clk => clk_1_sg_x0,
      d(0) => register0_q_net,
      en => "1",
      rst => "0",
      q(0) => register1_q_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/adc_mkid"

entity adc_mkid_entity_802cdbfdbd is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    timestamper_adc_mkid_user_sync: in std_logic; 
    sync: out std_logic
  );
end adc_mkid_entity_802cdbfdbd;

architecture structural of adc_mkid_entity_802cdbfdbd is
  signal ce_1_sg_x2: std_logic;
  signal clk_1_sg_x2: std_logic;
  signal register1_q_net_x1: std_logic;
  signal register1_q_net_x3: std_logic;
  signal timestamper_adc_mkid_user_sync_net_x1: std_logic;

begin
  ce_1_sg_x2 <= ce_1;
  clk_1_sg_x2 <= clk_1;
  timestamper_adc_mkid_user_sync_net_x1 <= timestamper_adc_mkid_user_sync;
  sync <= register1_q_net_x3;

  pipeline8_792aeffb65: entity work.pipeline8_entity_792aeffb65
    port map (
      ce_1 => ce_1_sg_x2,
      clk_1 => clk_1_sg_x2,
      d => timestamper_adc_mkid_user_sync_net_x1,
      q => register1_q_net_x1
    );

  pipeline9_840e319f52: entity work.pipeline8_entity_792aeffb65
    port map (
      ce_1 => ce_1_sg_x2,
      clk_1 => clk_1_sg_x2,
      d => register1_q_net_x1,
      q => register1_q_net_x3
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/capture"

entity capture_entity_f86145b86f is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    sync_in: in std_logic; 
    we: in std_logic; 
    data_out: out std_logic_vector(63 downto 0); 
    sync_out: out std_logic; 
    we_out: out std_logic
  );
end capture_entity_f86145b86f;

architecture structural of capture_entity_f86145b86f is
  signal ce_1_sg_x3: std_logic;
  signal clk_1_sg_x3: std_logic;
  signal concat1_y_net_x0: std_logic_vector(63 downto 0);
  signal constant1_op_net: std_logic_vector(11 downto 0);
  signal constant2_op_net: std_logic_vector(11 downto 0);
  signal constant3_op_net: std_logic_vector(11 downto 0);
  signal delay12_q_net: std_logic_vector(7 downto 0);
  signal delay13_q_net: std_logic_vector(11 downto 0);
  signal delay15_q_net: std_logic_vector(11 downto 0);
  signal delay18_q_net: std_logic_vector(11 downto 0);
  signal delay19_q_net: std_logic_vector(19 downto 0);
  signal delay1_q_net: std_logic;
  signal delay21_q_net: std_logic_vector(7 downto 0);
  signal delay23_q_net: std_logic_vector(11 downto 0);
  signal delay24_q_net: std_logic_vector(11 downto 0);
  signal delay25_q_net: std_logic_vector(19 downto 0);
  signal delay26_q_net: std_logic_vector(7 downto 0);
  signal delay27_q_net: std_logic_vector(11 downto 0);
  signal delay28_q_net: std_logic_vector(11 downto 0);
  signal delay29_q_net: std_logic_vector(19 downto 0);
  signal delay2_q_net: std_logic;
  signal delay31_q_net: std_logic;
  signal delay36_q_net: std_logic;
  signal delay37_q_net_x0: std_logic;
  signal delay3_q_net: std_logic;
  signal delay41_q_net: std_logic;
  signal delay42_q_net: std_logic_vector(19 downto 0);
  signal delay44_q_net: std_logic_vector(11 downto 0);
  signal delay45_q_net: std_logic_vector(11 downto 0);
  signal delay4_q_net_x0: std_logic;
  signal logical_y_net_x0: std_logic;
  signal lut_counter1_op_net: std_logic_vector(19 downto 0);
  signal lut_counter2_op_net: std_logic_vector(7 downto 0);
  signal reinterpret1_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret2_output_port_net: std_logic_vector(11 downto 0);
  signal reinterpret3_output_port_net: std_logic_vector(11 downto 0);
  signal relational_op_net_x0: std_logic;
  signal slice1_y_net: std_logic_vector(19 downto 0);

begin
  ce_1_sg_x3 <= ce_1;
  clk_1_sg_x3 <= clk_1;
  logical_y_net_x0 <= sync_in;
  relational_op_net_x0 <= we;
  data_out <= concat1_y_net_x0;
  sync_out <= delay37_q_net_x0;
  we_out <= delay4_q_net_x0;

  concat1: entity work.concat_bff132f7f1
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      in0 => delay26_q_net,
      in1 => reinterpret1_output_port_net,
      in2 => reinterpret2_output_port_net,
      in3 => reinterpret3_output_port_net,
      in4 => slice1_y_net,
      y => concat1_y_net_x0
    );

  constant1: entity work.constant_e4fc66a735
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant1_op_net
    );

  constant2: entity work.constant_c6372293dc
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant2_op_net
    );

  constant3: entity work.constant_7c91b1b314
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant3_op_net
    );

  delay1: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => relational_op_net_x0,
      q(0) => delay1_q_net
    );

  delay12: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => lut_counter2_op_net,
      q => delay12_q_net
    );

  delay13: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => constant1_op_net,
      q => delay13_q_net
    );

  delay15: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => constant2_op_net,
      q => delay15_q_net
    );

  delay18: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => constant3_op_net,
      q => delay18_q_net
    );

  delay19: entity work.delay_a5c036284d
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay42_q_net,
      q => delay19_q_net
    );

  delay2: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => delay1_q_net,
      q(0) => delay2_q_net
    );

  delay21: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay12_q_net,
      q => delay21_q_net
    );

  delay23: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay15_q_net,
      q => delay23_q_net
    );

  delay24: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay18_q_net,
      q => delay24_q_net
    );

  delay25: entity work.delay_a5c036284d
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay19_q_net,
      q => delay25_q_net
    );

  delay26: entity work.delay_ebec135d8a
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay21_q_net,
      q => delay26_q_net
    );

  delay27: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay23_q_net,
      q => delay27_q_net
    );

  delay28: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay24_q_net,
      q => delay28_q_net
    );

  delay29: entity work.delay_a5c036284d
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay25_q_net,
      q => delay29_q_net
    );

  delay3: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => delay2_q_net,
      q(0) => delay3_q_net
    );

  delay31: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => delay41_q_net,
      q(0) => delay31_q_net
    );

  delay36: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => delay31_q_net,
      q(0) => delay36_q_net
    );

  delay37: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => delay36_q_net,
      q(0) => delay37_q_net_x0
    );

  delay4: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => delay3_q_net,
      q(0) => delay4_q_net_x0
    );

  delay41: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d(0) => logical_y_net_x0,
      q(0) => delay41_q_net
    );

  delay42: entity work.delay_a5c036284d
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => lut_counter1_op_net,
      q => delay42_q_net
    );

  delay44: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay13_q_net,
      q => delay44_q_net
    );

  delay45: entity work.delay_87cc993d41
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      d => delay44_q_net,
      q => delay45_q_net
    );

  lut_counter1: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 2500,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_b40c42d5e24bb86a",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 20
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      en(0) => relational_op_net_x0,
      rst => "0",
      op => lut_counter1_op_net
    );

  lut_counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_18bbeb067aa07bfe",
      op_arith => xlUnsigned,
      op_width => 8
    )
    port map (
      ce => ce_1_sg_x3,
      clk => clk_1_sg_x3,
      clr => '0',
      en(0) => relational_op_net_x0,
      rst => "0",
      op => lut_counter2_op_net
    );

  reinterpret1: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => delay45_q_net,
      output_port => reinterpret1_output_port_net
    );

  reinterpret2: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => delay27_q_net,
      output_port => reinterpret2_output_port_net
    );

  reinterpret3: entity work.reinterpret_a106f99236
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      input_port => delay28_q_net,
      output_port => reinterpret3_output_port_net
    );

  slice1: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 19,
      x_width => 20,
      y_width => 20
    )
    port map (
      x => delay29_q_net,
      y => slice1_y_net
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/negedge"

entity negedge_entity_c3395d4ee4 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end negedge_entity_c3395d4ee4;

architecture structural of negedge_entity_c3395d4ee4 is
  signal ce_1_sg_x4: std_logic;
  signal clk_1_sg_x4: std_logic;
  signal delay_q_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical_y_net_x0: std_logic;
  signal register_q_net_x0: std_logic;

begin
  ce_1_sg_x4 <= ce_1;
  clk_1_sg_x4 <= clk_1;
  register_q_net_x0 <= in_x0;
  out_x0 <= logical_y_net_x0;

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
      d(0) => register_q_net_x0,
      en => '1',
      q(0) => delay_q_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x4,
      clk => clk_1_sg_x4,
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

-- Generated from Simulink block "timestamper/posedge"

entity posedge_entity_afeb600db0 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    in_x0: in std_logic; 
    out_x0: out std_logic
  );
end posedge_entity_afeb600db0;

architecture structural of posedge_entity_afeb600db0 is
  signal ce_1_sg_x5: std_logic;
  signal clk_1_sg_x5: std_logic;
  signal delay_q_net: std_logic;
  signal inverter_op_net: std_logic;
  signal logical_y_net_x1: std_logic;
  signal register1_q_net_x4: std_logic;

begin
  ce_1_sg_x5 <= ce_1;
  clk_1_sg_x5 <= clk_1;
  register1_q_net_x4 <= in_x0;
  out_x0 <= logical_y_net_x1;

  delay: entity work.xldelay
    generic map (
      latency => 1,
      reg_retiming => 0,
      width => 1
    )
    port map (
      ce => ce_1_sg_x5,
      clk => clk_1_sg_x5,
      d(0) => register1_q_net_x4,
      en => '1',
      q(0) => delay_q_net
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x5,
      clk => clk_1_sg_x5,
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
      d1(0) => register1_q_net_x4,
      y(0) => logical_y_net_x1
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/pulses/addr"

entity addr_entity_86c2b6771b is
  port (
    reg_out: in std_logic_vector(13 downto 0); 
    convert_x0: out std_logic_vector(31 downto 0)
  );
end addr_entity_86c2b6771b;

architecture structural of addr_entity_86c2b6771b is
  signal convert_dout_net_x0: std_logic_vector(31 downto 0);
  signal register1_q_net_x0: std_logic_vector(13 downto 0);

begin
  register1_q_net_x0 <= reg_out;
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
      din => register1_q_net_x0,
      dout => convert_dout_net_x0
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/pulses/bram0"

entity bram0_entity_1b1454236a is
  port (
    addr: in std_logic_vector(13 downto 0); 
    data_in: in std_logic_vector(31 downto 0); 
    we: in std_logic; 
    convert_addr_x0: out std_logic_vector(13 downto 0); 
    convert_din_x0: out std_logic_vector(31 downto 0); 
    convert_we_x0: out std_logic
  );
end bram0_entity_1b1454236a;

architecture structural of bram0_entity_1b1454236a is
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

-- Generated from Simulink block "timestamper/pulses/pipeline1"

entity pipeline1_entity_672f137dfe is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(31 downto 0); 
    q: out std_logic_vector(31 downto 0)
  );
end pipeline1_entity_672f137dfe;

architecture structural of pipeline1_entity_672f137dfe is
  signal ce_1_sg_x6: std_logic;
  signal clk_1_sg_x6: std_logic;
  signal delay39_q_net_x0: std_logic_vector(31 downto 0);
  signal register0_q_net: std_logic_vector(31 downto 0);
  signal register1_q_net_x3: std_logic_vector(31 downto 0);

begin
  ce_1_sg_x6 <= ce_1;
  clk_1_sg_x6 <= clk_1;
  delay39_q_net_x0 <= d;
  q <= register1_q_net_x3;

  register0: entity work.xlregister
    generic map (
      d_width => 32,
      init_value => b"00000000000000000000000000000000"
    )
    port map (
      ce => ce_1_sg_x6,
      clk => clk_1_sg_x6,
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
      ce => ce_1_sg_x6,
      clk => clk_1_sg_x6,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x3
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/pulses/pipeline2"

entity pipeline2_entity_4c90476db6 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    d: in std_logic_vector(13 downto 0); 
    q: out std_logic_vector(13 downto 0)
  );
end pipeline2_entity_4c90476db6;

architecture structural of pipeline2_entity_4c90476db6 is
  signal ce_1_sg_x7: std_logic;
  signal clk_1_sg_x7: std_logic;
  signal lut_counter2_op_net_x0: std_logic_vector(13 downto 0);
  signal register0_q_net: std_logic_vector(13 downto 0);
  signal register1_q_net_x4: std_logic_vector(13 downto 0);

begin
  ce_1_sg_x7 <= ce_1;
  clk_1_sg_x7 <= clk_1;
  lut_counter2_op_net_x0 <= d;
  q <= register1_q_net_x4;

  register0: entity work.xlregister
    generic map (
      d_width => 14,
      init_value => b"00000000000000"
    )
    port map (
      ce => ce_1_sg_x7,
      clk => clk_1_sg_x7,
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
      ce => ce_1_sg_x7,
      clk => clk_1_sg_x7,
      d => register0_q_net,
      en => "1",
      rst => "0",
      q => register1_q_net_x4
    );

end structural;
library IEEE;
use IEEE.std_logic_1164.all;
use work.conv_pkg.all;

-- Generated from Simulink block "timestamper/pulses"

entity pulses_entity_7390d2234e is
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
end pulses_entity_7390d2234e;

architecture structural of pulses_entity_7390d2234e is
  signal ce_1_sg_x13: std_logic;
  signal clk_1_sg_x13: std_logic;
  signal constant2_op_net: std_logic;
  signal constant_op_net: std_logic_vector(63 downto 0);
  signal convert_addr_dout_net_x2: std_logic_vector(13 downto 0);
  signal convert_addr_dout_net_x3: std_logic_vector(13 downto 0);
  signal convert_din_dout_net_x2: std_logic_vector(31 downto 0);
  signal convert_din_dout_net_x3: std_logic_vector(31 downto 0);
  signal convert_dout_net_x1: std_logic_vector(31 downto 0);
  signal convert_we_dout_net_x2: std_logic;
  signal convert_we_dout_net_x3: std_logic;
  signal delay10_q_net_x0: std_logic;
  signal delay12_q_net_x0: std_logic;
  signal delay1_q_net: std_logic;
  signal delay2_q_net: std_logic;
  signal delay30_q_net_x0: std_logic;
  signal delay39_q_net_x0: std_logic_vector(31 downto 0);
  signal delay3_q_net: std_logic_vector(63 downto 0);
  signal delay41_q_net_x0: std_logic;
  signal delay45_q_net_x0: std_logic_vector(31 downto 0);
  signal delay4_q_net: std_logic;
  signal delay9_q_net_x0: std_logic_vector(63 downto 0);
  signal logical3_y_net_x0: std_logic;
  signal logical3_y_net_x1: std_logic;
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
  delay12_q_net_x0 <= acq_started;
  ce_1_sg_x13 <= ce_1;
  clk_1_sg_x13 <= clk_1;
  delay9_q_net_x0 <= data_in;
  logical_y_net_x1 <= reset_addr;
  delay10_q_net_x0 <= sync_in;
  logical3_y_net_x1 <= we;
  addr <= convert_dout_net_x1;
  bram0 <= convert_addr_dout_net_x2;
  bram0_x0 <= convert_din_dout_net_x2;
  bram0_x1 <= convert_we_dout_net_x2;
  bram1 <= convert_addr_dout_net_x3;
  bram1_x0 <= convert_din_dout_net_x3;
  bram1_x1 <= convert_we_dout_net_x3;

  addr_86c2b6771b: entity work.addr_entity_86c2b6771b
    port map (
      reg_out => register1_q_net_x1,
      convert_x0 => convert_dout_net_x1
    );

  bram0_1b1454236a: entity work.bram0_entity_1b1454236a
    port map (
      addr => register1_q_net_x4,
      data_in => register1_q_net_x3,
      we => register1_q_net_x5,
      convert_addr_x0 => convert_addr_dout_net_x2,
      convert_din_x0 => convert_din_dout_net_x2,
      convert_we_x0 => convert_we_dout_net_x2
    );

  bram1_ac6296b5bc: entity work.bram0_entity_1b1454236a
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
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d(0) => delay4_q_net,
      q(0) => delay1_q_net
    );

  delay2: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d(0) => logical3_y_net_x1,
      q(0) => delay2_q_net
    );

  delay3: entity work.delay_e2d047c154
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d => delay9_q_net_x0,
      q => delay3_q_net
    );

  delay30: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d(0) => mux1_y_net,
      q(0) => delay30_q_net_x0
    );

  delay39: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d => slice2_y_net,
      q => delay39_q_net_x0
    );

  delay4: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d(0) => logical_y_net_x1,
      q(0) => delay4_q_net
    );

  delay41: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d(0) => mux1_y_net,
      q(0) => delay41_q_net_x0
    );

  delay45: entity work.delay_672d2b8d1e
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d => slice1_y_net,
      q => delay45_q_net_x0
    );

  logical3: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d0(0) => delay12_q_net_x0,
      d1(0) => delay10_q_net_x0,
      y(0) => logical3_y_net_x0
    );

  lut_counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_82b9fd0243bf8494",
      op_arith => xlUnsigned,
      op_width => 14
    )
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      en(0) => mux1_y_net,
      rst(0) => delay1_q_net,
      op => lut_counter2_op_net_x2
    );

  mux1: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d0(0) => delay2_q_net,
      d1(0) => constant2_op_net,
      sel(0) => logical3_y_net_x0,
      y(0) => mux1_y_net
    );

  mux2: entity work.mux_fd01d62b53
    port map (
      ce => ce_1_sg_x13,
      clk => clk_1_sg_x13,
      clr => '0',
      d0 => delay3_q_net,
      d1 => constant_op_net,
      sel(0) => logical3_y_net_x0,
      y => mux2_y_net
    );

  pipeline1_672f137dfe: entity work.pipeline1_entity_672f137dfe
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
      d => delay39_q_net_x0,
      q => register1_q_net_x3
    );

  pipeline2_4c90476db6: entity work.pipeline2_entity_4c90476db6
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
      d => lut_counter2_op_net_x2,
      q => register1_q_net_x4
    );

  pipeline3_2ddf80c3cb: entity work.pipeline8_entity_792aeffb65
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
      d => delay30_q_net_x0,
      q => register1_q_net_x5
    );

  pipeline4_e48bbb5f71: entity work.pipeline2_entity_4c90476db6
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
      d => lut_counter2_op_net_x2,
      q => register1_q_net_x6
    );

  pipeline5_39cb915cac: entity work.pipeline1_entity_672f137dfe
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
      d => delay45_q_net_x0,
      q => register1_q_net_x7
    );

  pipeline6_3d4cece172: entity work.pipeline8_entity_792aeffb65
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
      d => delay41_q_net_x0,
      q => register1_q_net_x8
    );

  pipeline7_4cbf7995ff: entity work.pipeline2_entity_4c90476db6
    port map (
      ce_1 => ce_1_sg_x13,
      clk_1 => clk_1_sg_x13,
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

-- Generated from Simulink block "timestamper/seconds"

entity seconds_entity_5ab98a6a0e is
  port (
    reg_out: in std_logic_vector(31 downto 0); 
    convert_x0: out std_logic_vector(31 downto 0)
  );
end seconds_entity_5ab98a6a0e;

architecture structural of seconds_entity_5ab98a6a0e is
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

-- Generated from Simulink block "timestamper"

entity timestamper is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    timestamper_adc_mkid_user_data_i0: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_data_i1: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_data_q0: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_data_q1: in std_logic_vector(11 downto 0); 
    timestamper_adc_mkid_user_sync: in std_logic; 
    timestamper_pulses_bram0_data_out: in std_logic_vector(31 downto 0); 
    timestamper_pulses_bram1_data_out: in std_logic_vector(31 downto 0); 
    timestamper_startbuffer_user_data_out: in std_logic_vector(31 downto 0); 
    timestamper_pulses_addr_user_data_in: out std_logic_vector(31 downto 0); 
    timestamper_pulses_bram0_addr: out std_logic_vector(13 downto 0); 
    timestamper_pulses_bram0_data_in: out std_logic_vector(31 downto 0); 
    timestamper_pulses_bram0_we: out std_logic; 
    timestamper_pulses_bram1_addr: out std_logic_vector(13 downto 0); 
    timestamper_pulses_bram1_data_in: out std_logic_vector(31 downto 0); 
    timestamper_pulses_bram1_we: out std_logic; 
    timestamper_seconds_user_data_in: out std_logic_vector(31 downto 0)
  );
end timestamper;

architecture structural of timestamper is
  attribute core_generation_info: string;
  attribute core_generation_info of structural : architecture is "timestamper,sysgen_core_11_4,{total_blocks=287,xilinx_arithmetic_relational_operator_block=1,xilinx_bit_slice_extractor_block=13,xilinx_bus_concatenator_block=5,xilinx_bus_multiplexer_block=3,xilinx_constant_block_block=7,xilinx_counter_block=5,xilinx_delay_block=38,xilinx_disregard_subsystem_for_generation_block=2,xilinx_gateway_in_block=14,xilinx_gateway_out_block=10,xilinx_inverter_block=7,xilinx_logical_block_block=5,xilinx_register_block=35,xilinx_single_port_random_access_memory_block=2,xilinx_system_generator_block=1,xilinx_type_converter_block=8,xilinx_type_reinterpreter_block=7,}";

  signal ce_1_sg_x14: std_logic;
  signal clk_1_sg_x14: std_logic;
  signal concat1_y_net_x0: std_logic_vector(63 downto 0);
  signal constant3_op_net: std_logic;
  signal constant_op_net: std_logic_vector(31 downto 0);
  signal delay10_q_net_x0: std_logic;
  signal delay12_q_net_x0: std_logic;
  signal delay1_q_net: std_logic;
  signal delay37_q_net_x0: std_logic;
  signal delay4_q_net_x0: std_logic;
  signal delay9_q_net_x0: std_logic_vector(63 downto 0);
  signal inverter_op_net: std_logic;
  signal logical1_y_net: std_logic;
  signal logical3_y_net_x1: std_logic;
  signal logical_y_net_x1: std_logic;
  signal logical_y_net_x2: std_logic;
  signal lut_counter1_op_net: std_logic_vector(31 downto 0);
  signal lut_counter2_op_net_x0: std_logic_vector(31 downto 0);
  signal mux1_y_net: std_logic;
  signal register1_q_net_x4: std_logic;
  signal register_q_net_x0: std_logic;
  signal relational_op_net_x0: std_logic;
  signal slice2_y_net: std_logic;
  signal timestamper_adc_mkid_user_data_i0_net: std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_data_i1_net: std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_data_q0_net: std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_data_q1_net: std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_sync_net: std_logic;
  signal timestamper_pulses_addr_user_data_in_net: std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram0_addr_net: std_logic_vector(13 downto 0);
  signal timestamper_pulses_bram0_data_in_net: std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram0_data_out_net: std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram0_we_net: std_logic;
  signal timestamper_pulses_bram1_addr_net: std_logic_vector(13 downto 0);
  signal timestamper_pulses_bram1_data_in_net: std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram1_data_out_net: std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram1_we_net: std_logic;
  signal timestamper_seconds_user_data_in_net: std_logic_vector(31 downto 0);
  signal timestamper_startbuffer_user_data_out_net: std_logic_vector(31 downto 0);

begin
  ce_1_sg_x14 <= ce_1;
  clk_1_sg_x14 <= clk_1;
  timestamper_adc_mkid_user_data_i0_net <= timestamper_adc_mkid_user_data_i0;
  timestamper_adc_mkid_user_data_i1_net <= timestamper_adc_mkid_user_data_i1;
  timestamper_adc_mkid_user_data_q0_net <= timestamper_adc_mkid_user_data_q0;
  timestamper_adc_mkid_user_data_q1_net <= timestamper_adc_mkid_user_data_q1;
  timestamper_adc_mkid_user_sync_net <= timestamper_adc_mkid_user_sync;
  timestamper_pulses_bram0_data_out_net <= timestamper_pulses_bram0_data_out;
  timestamper_pulses_bram1_data_out_net <= timestamper_pulses_bram1_data_out;
  timestamper_startbuffer_user_data_out_net <= timestamper_startbuffer_user_data_out;
  timestamper_pulses_addr_user_data_in <= timestamper_pulses_addr_user_data_in_net;
  timestamper_pulses_bram0_addr <= timestamper_pulses_bram0_addr_net;
  timestamper_pulses_bram0_data_in <= timestamper_pulses_bram0_data_in_net;
  timestamper_pulses_bram0_we <= timestamper_pulses_bram0_we_net;
  timestamper_pulses_bram1_addr <= timestamper_pulses_bram1_addr_net;
  timestamper_pulses_bram1_data_in <= timestamper_pulses_bram1_data_in_net;
  timestamper_pulses_bram1_we <= timestamper_pulses_bram1_we_net;
  timestamper_seconds_user_data_in <= timestamper_seconds_user_data_in_net;

  adc_mkid_802cdbfdbd: entity work.adc_mkid_entity_802cdbfdbd
    port map (
      ce_1 => ce_1_sg_x14,
      clk_1 => clk_1_sg_x14,
      timestamper_adc_mkid_user_sync => timestamper_adc_mkid_user_sync_net,
      sync => register1_q_net_x4
    );

  capture_f86145b86f: entity work.capture_entity_f86145b86f
    port map (
      ce_1 => ce_1_sg_x14,
      clk_1 => clk_1_sg_x14,
      sync_in => logical_y_net_x2,
      we => relational_op_net_x0,
      data_out => concat1_y_net_x0,
      sync_out => delay37_q_net_x0,
      we_out => delay4_q_net_x0
    );

  constant3: entity work.constant_6293007044
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op(0) => constant3_op_net
    );

  constant_x0: entity work.constant_37567836aa
    port map (
      ce => '0',
      clk => '0',
      clr => '0',
      op => constant_op_net
    );

  delay1: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d(0) => logical1_y_net,
      q(0) => delay1_q_net
    );

  delay10: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d(0) => delay37_q_net_x0,
      q(0) => delay10_q_net_x0
    );

  delay12: entity work.delay_9f02caa990
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d(0) => register_q_net_x0,
      q(0) => delay12_q_net_x0
    );

  delay9: entity work.delay_e2d047c154
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d => concat1_y_net_x0,
      q => delay9_q_net_x0
    );

  inverter: entity work.inverter_e5b38cca3b
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      ip(0) => slice2_y_net,
      op(0) => inverter_op_net
    );

  logical1: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d0(0) => delay37_q_net_x0,
      d1(0) => slice2_y_net,
      y(0) => logical1_y_net
    );

  logical3: entity work.logical_799f62af22
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d0(0) => delay4_q_net_x0,
      d1(0) => register_q_net_x0,
      y(0) => logical3_y_net_x1
    );

  lut_counter1: entity work.xlcounter_limit
    generic map (
      cnt_15_0 => 1000,
      cnt_31_16 => 0,
      cnt_47_32 => 0,
      cnt_63_48 => 0,
      core_name0 => "cntr_11_0_f52338cfe462aa75",
      count_limited => 1,
      op_arith => xlUnsigned,
      op_width => 32
    )
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      en => "1",
      rst => "0",
      op => lut_counter1_op_net
    );

  lut_counter2: entity work.xlcounter_free
    generic map (
      core_name0 => "cntr_11_0_f52338cfe462aa75",
      op_arith => xlUnsigned,
      op_width => 32
    )
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      en(0) => delay37_q_net_x0,
      rst(0) => inverter_op_net,
      op => lut_counter2_op_net_x0
    );

  mux1: entity work.mux_1e22c21d05
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      d0(0) => constant3_op_net,
      d1(0) => logical1_y_net,
      sel(0) => slice2_y_net,
      y(0) => mux1_y_net
    );

  negedge_c3395d4ee4: entity work.negedge_entity_c3395d4ee4
    port map (
      ce_1 => ce_1_sg_x14,
      clk_1 => clk_1_sg_x14,
      in_x0 => register_q_net_x0,
      out_x0 => logical_y_net_x1
    );

  posedge_afeb600db0: entity work.posedge_entity_afeb600db0
    port map (
      ce_1 => ce_1_sg_x14,
      clk_1 => clk_1_sg_x14,
      in_x0 => register1_q_net_x4,
      out_x0 => logical_y_net_x2
    );

  pulses_7390d2234e: entity work.pulses_entity_7390d2234e
    port map (
      acq_started => delay12_q_net_x0,
      ce_1 => ce_1_sg_x14,
      clk_1 => clk_1_sg_x14,
      data_in => delay9_q_net_x0,
      reset_addr => logical_y_net_x1,
      sync_in => delay10_q_net_x0,
      we => logical3_y_net_x1,
      addr => timestamper_pulses_addr_user_data_in_net,
      bram0 => timestamper_pulses_bram0_addr_net,
      bram0_x0 => timestamper_pulses_bram0_data_in_net,
      bram0_x1 => timestamper_pulses_bram0_we_net,
      bram1 => timestamper_pulses_bram1_addr_net,
      bram1_x0 => timestamper_pulses_bram1_data_in_net,
      bram1_x1 => timestamper_pulses_bram1_we_net
    );

  register_x0: entity work.xlregister
    generic map (
      d_width => 1,
      init_value => b"0"
    )
    port map (
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      d(0) => delay1_q_net,
      en(0) => mux1_y_net,
      rst => "0",
      q(0) => register_q_net_x0
    );

  relational: entity work.relational_770e12e4ab
    port map (
      a => constant_op_net,
      b => lut_counter1_op_net,
      ce => ce_1_sg_x14,
      clk => clk_1_sg_x14,
      clr => '0',
      op(0) => relational_op_net_x0
    );

  seconds_5ab98a6a0e: entity work.seconds_entity_5ab98a6a0e
    port map (
      reg_out => lut_counter2_op_net_x0,
      convert_x0 => timestamper_seconds_user_data_in_net
    );

  slice2: entity work.xlslice
    generic map (
      new_lsb => 0,
      new_msb => 0,
      x_width => 32,
      y_width => 1
    )
    port map (
      x => timestamper_startbuffer_user_data_out_net,
      y(0) => slice2_y_net
    );

end structural;
