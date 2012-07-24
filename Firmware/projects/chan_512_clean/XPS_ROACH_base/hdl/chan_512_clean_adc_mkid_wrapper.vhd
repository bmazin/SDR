-------------------------------------------------------------------------------
-- chan_512_clean_adc_mkid_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library adc_mkid_interface_v1_00_a;
use adc_mkid_interface_v1_00_a.all;

entity chan_512_clean_adc_mkid_wrapper is
  port (
    DRDY_I_p : in std_logic;
    DRDY_I_n : in std_logic;
    DRDY_Q_p : in std_logic;
    DRDY_Q_n : in std_logic;
    DI_p : in std_logic_vector(11 downto 0);
    DI_n : in std_logic_vector(11 downto 0);
    DQ_p : in std_logic_vector(11 downto 0);
    DQ_n : in std_logic_vector(11 downto 0);
    ADC_ext_in_p : in std_logic;
    ADC_ext_in_n : in std_logic;
    fpga_clk : in std_logic;
    adc_clk_out : out std_logic;
    adc_clk90_out : out std_logic;
    adc_clk180_out : out std_logic;
    adc_clk270_out : out std_logic;
    adc_dcm_locked : out std_logic;
    user_data_i0 : out std_logic_vector(11 downto 0);
    user_data_i1 : out std_logic_vector(11 downto 0);
    user_data_q0 : out std_logic_vector(11 downto 0);
    user_data_q1 : out std_logic_vector(11 downto 0);
    user_sync : out std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of chan_512_clean_adc_mkid_wrapper : entity is "adc_mkid_interface_v1_00_a";

end chan_512_clean_adc_mkid_wrapper;

architecture STRUCTURE of chan_512_clean_adc_mkid_wrapper is

  component adc_mkid_interface is
    generic (
      OUTPUT_CLK : INTEGER
    );
    port (
      DRDY_I_p : in std_logic;
      DRDY_I_n : in std_logic;
      DRDY_Q_p : in std_logic;
      DRDY_Q_n : in std_logic;
      DI_p : in std_logic_vector(11 downto 0);
      DI_n : in std_logic_vector(11 downto 0);
      DQ_p : in std_logic_vector(11 downto 0);
      DQ_n : in std_logic_vector(11 downto 0);
      ADC_ext_in_p : in std_logic;
      ADC_ext_in_n : in std_logic;
      fpga_clk : in std_logic;
      adc_clk_out : out std_logic;
      adc_clk90_out : out std_logic;
      adc_clk180_out : out std_logic;
      adc_clk270_out : out std_logic;
      adc_dcm_locked : out std_logic;
      user_data_i0 : out std_logic_vector(11 downto 0);
      user_data_i1 : out std_logic_vector(11 downto 0);
      user_data_q0 : out std_logic_vector(11 downto 0);
      user_data_q1 : out std_logic_vector(11 downto 0);
      user_sync : out std_logic
    );
  end component;

begin

  chan_512_clean_adc_mkid : adc_mkid_interface
    generic map (
      OUTPUT_CLK => 1
    )
    port map (
      DRDY_I_p => DRDY_I_p,
      DRDY_I_n => DRDY_I_n,
      DRDY_Q_p => DRDY_Q_p,
      DRDY_Q_n => DRDY_Q_n,
      DI_p => DI_p,
      DI_n => DI_n,
      DQ_p => DQ_p,
      DQ_n => DQ_n,
      ADC_ext_in_p => ADC_ext_in_p,
      ADC_ext_in_n => ADC_ext_in_n,
      fpga_clk => fpga_clk,
      adc_clk_out => adc_clk_out,
      adc_clk90_out => adc_clk90_out,
      adc_clk180_out => adc_clk180_out,
      adc_clk270_out => adc_clk270_out,
      adc_dcm_locked => adc_dcm_locked,
      user_data_i0 => user_data_i0,
      user_data_i1 => user_data_i1,
      user_data_q0 => user_data_q0,
      user_data_q1 => user_data_q1,
      user_sync => user_sync
    );

end architecture STRUCTURE;

