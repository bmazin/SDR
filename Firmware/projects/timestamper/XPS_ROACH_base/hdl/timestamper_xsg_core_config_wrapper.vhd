-------------------------------------------------------------------------------
-- timestamper_xsg_core_config_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity timestamper_xsg_core_config_wrapper is
  port (
    clk : in std_logic;
    timestamper_adc_mkid_user_data_i0 : in std_logic_vector(11 downto 0);
    timestamper_adc_mkid_user_data_i1 : in std_logic_vector(11 downto 0);
    timestamper_adc_mkid_user_data_q0 : in std_logic_vector(11 downto 0);
    timestamper_adc_mkid_user_data_q1 : in std_logic_vector(11 downto 0);
    timestamper_adc_mkid_user_sync : in std_logic;
    timestamper_pulses_addr_user_data_in : out std_logic_vector(31 downto 0);
    timestamper_pulses_bram0_data_out : in std_logic_vector(31 downto 0);
    timestamper_pulses_bram0_addr : out std_logic_vector(13 downto 0);
    timestamper_pulses_bram0_data_in : out std_logic_vector(31 downto 0);
    timestamper_pulses_bram0_we : out std_logic;
    timestamper_pulses_bram1_data_out : in std_logic_vector(31 downto 0);
    timestamper_pulses_bram1_addr : out std_logic_vector(13 downto 0);
    timestamper_pulses_bram1_data_in : out std_logic_vector(31 downto 0);
    timestamper_pulses_bram1_we : out std_logic;
    timestamper_seconds_user_data_in : out std_logic_vector(31 downto 0);
    timestamper_startBuffer_user_data_out : in std_logic_vector(31 downto 0)
  );

  attribute x_core_info : STRING;
  attribute x_core_info of timestamper_xsg_core_config_wrapper : entity is "timestamper_v1_00_a";

end timestamper_xsg_core_config_wrapper;

architecture STRUCTURE of timestamper_xsg_core_config_wrapper is

  component timestamper is
    port (
      clk : in std_logic;
      timestamper_adc_mkid_user_data_i0 : in std_logic_vector(11 downto 0);
      timestamper_adc_mkid_user_data_i1 : in std_logic_vector(11 downto 0);
      timestamper_adc_mkid_user_data_q0 : in std_logic_vector(11 downto 0);
      timestamper_adc_mkid_user_data_q1 : in std_logic_vector(11 downto 0);
      timestamper_adc_mkid_user_sync : in std_logic;
      timestamper_pulses_addr_user_data_in : out std_logic_vector(31 downto 0);
      timestamper_pulses_bram0_data_out : in std_logic_vector(31 downto 0);
      timestamper_pulses_bram0_addr : out std_logic_vector(13 downto 0);
      timestamper_pulses_bram0_data_in : out std_logic_vector(31 downto 0);
      timestamper_pulses_bram0_we : out std_logic;
      timestamper_pulses_bram1_data_out : in std_logic_vector(31 downto 0);
      timestamper_pulses_bram1_addr : out std_logic_vector(13 downto 0);
      timestamper_pulses_bram1_data_in : out std_logic_vector(31 downto 0);
      timestamper_pulses_bram1_we : out std_logic;
      timestamper_seconds_user_data_in : out std_logic_vector(31 downto 0);
      timestamper_startBuffer_user_data_out : in std_logic_vector(31 downto 0)
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of timestamper : component is "user_black_box";

begin

  timestamper_XSG_core_config : timestamper
    port map (
      clk => clk,
      timestamper_adc_mkid_user_data_i0 => timestamper_adc_mkid_user_data_i0,
      timestamper_adc_mkid_user_data_i1 => timestamper_adc_mkid_user_data_i1,
      timestamper_adc_mkid_user_data_q0 => timestamper_adc_mkid_user_data_q0,
      timestamper_adc_mkid_user_data_q1 => timestamper_adc_mkid_user_data_q1,
      timestamper_adc_mkid_user_sync => timestamper_adc_mkid_user_sync,
      timestamper_pulses_addr_user_data_in => timestamper_pulses_addr_user_data_in,
      timestamper_pulses_bram0_data_out => timestamper_pulses_bram0_data_out,
      timestamper_pulses_bram0_addr => timestamper_pulses_bram0_addr,
      timestamper_pulses_bram0_data_in => timestamper_pulses_bram0_data_in,
      timestamper_pulses_bram0_we => timestamper_pulses_bram0_we,
      timestamper_pulses_bram1_data_out => timestamper_pulses_bram1_data_out,
      timestamper_pulses_bram1_addr => timestamper_pulses_bram1_addr,
      timestamper_pulses_bram1_data_in => timestamper_pulses_bram1_data_in,
      timestamper_pulses_bram1_we => timestamper_pulses_bram1_we,
      timestamper_seconds_user_data_in => timestamper_seconds_user_data_in,
      timestamper_startBuffer_user_data_out => timestamper_startBuffer_user_data_out
    );

end architecture STRUCTURE;

