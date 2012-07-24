-------------------------------------------------------------------------------
-- chan_512_clean_dac_mkid_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library dac_mkid_interface_v1_01_a;
use dac_mkid_interface_v1_01_a.all;

entity chan_512_clean_dac_mkid_wrapper is
  port (
    dac_clk_p : in std_logic;
    dac_clk_n : in std_logic;
    dac_smpl_clk_i_p : out std_logic;
    dac_smpl_clk_i_n : out std_logic;
    dac_smpl_clk_q_p : out std_logic;
    dac_smpl_clk_q_n : out std_logic;
    dac_sync_i_p : out std_logic;
    dac_sync_i_n : out std_logic;
    dac_sync_q_p : out std_logic;
    dac_sync_q_n : out std_logic;
    dac_data_i_p : out std_logic_vector(15 downto 0);
    dac_data_i_n : out std_logic_vector(15 downto 0);
    dac_data_q_p : out std_logic_vector(15 downto 0);
    dac_data_q_n : out std_logic_vector(15 downto 0);
    dac_not_sdenb_i : out std_logic;
    dac_not_sdenb_q : out std_logic;
    dac_sclk : out std_logic;
    dac_sdi : out std_logic;
    dac_not_reset : out std_logic;
    dac_data_i0 : in std_logic_vector(15 downto 0);
    dac_data_i1 : in std_logic_vector(15 downto 0);
    dac_data_q0 : in std_logic_vector(15 downto 0);
    dac_data_q1 : in std_logic_vector(15 downto 0);
    dac_sync_i : in std_logic;
    dac_sync_q : in std_logic;
    dac_smpl_clk : in std_logic;
    not_sdenb_i : in std_logic;
    not_sdenb_q : in std_logic;
    sclk : in std_logic;
    sdi : in std_logic;
    not_reset : in std_logic;
    dac_clk_out : out std_logic;
    dac_clk90_out : out std_logic;
    dac_clk180_out : out std_logic;
    dac_clk270_out : out std_logic;
    dac_dcm_locked : out std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of chan_512_clean_dac_mkid_wrapper : entity is "dac_mkid_interface_v1_01_a";

end chan_512_clean_dac_mkid_wrapper;

architecture STRUCTURE of chan_512_clean_dac_mkid_wrapper is

  component dac_mkid_interface is
    generic (
      CTRL_CLK_PHASE : INTEGER;
      OUTPUT_CLK : INTEGER
    );
    port (
      dac_clk_p : in std_logic;
      dac_clk_n : in std_logic;
      dac_smpl_clk_i_p : out std_logic;
      dac_smpl_clk_i_n : out std_logic;
      dac_smpl_clk_q_p : out std_logic;
      dac_smpl_clk_q_n : out std_logic;
      dac_sync_i_p : out std_logic;
      dac_sync_i_n : out std_logic;
      dac_sync_q_p : out std_logic;
      dac_sync_q_n : out std_logic;
      dac_data_i_p : out std_logic_vector(15 downto 0);
      dac_data_i_n : out std_logic_vector(15 downto 0);
      dac_data_q_p : out std_logic_vector(15 downto 0);
      dac_data_q_n : out std_logic_vector(15 downto 0);
      dac_not_sdenb_i : out std_logic;
      dac_not_sdenb_q : out std_logic;
      dac_sclk : out std_logic;
      dac_sdi : out std_logic;
      dac_not_reset : out std_logic;
      dac_data_i0 : in std_logic_vector(15 downto 0);
      dac_data_i1 : in std_logic_vector(15 downto 0);
      dac_data_q0 : in std_logic_vector(15 downto 0);
      dac_data_q1 : in std_logic_vector(15 downto 0);
      dac_sync_i : in std_logic;
      dac_sync_q : in std_logic;
      dac_smpl_clk : in std_logic;
      not_sdenb_i : in std_logic;
      not_sdenb_q : in std_logic;
      sclk : in std_logic;
      sdi : in std_logic;
      not_reset : in std_logic;
      dac_clk_out : out std_logic;
      dac_clk90_out : out std_logic;
      dac_clk180_out : out std_logic;
      dac_clk270_out : out std_logic;
      dac_dcm_locked : out std_logic
    );
  end component;

begin

  chan_512_clean_dac_mkid : dac_mkid_interface
    generic map (
      CTRL_CLK_PHASE => 0,
      OUTPUT_CLK => 0
    )
    port map (
      dac_clk_p => dac_clk_p,
      dac_clk_n => dac_clk_n,
      dac_smpl_clk_i_p => dac_smpl_clk_i_p,
      dac_smpl_clk_i_n => dac_smpl_clk_i_n,
      dac_smpl_clk_q_p => dac_smpl_clk_q_p,
      dac_smpl_clk_q_n => dac_smpl_clk_q_n,
      dac_sync_i_p => dac_sync_i_p,
      dac_sync_i_n => dac_sync_i_n,
      dac_sync_q_p => dac_sync_q_p,
      dac_sync_q_n => dac_sync_q_n,
      dac_data_i_p => dac_data_i_p,
      dac_data_i_n => dac_data_i_n,
      dac_data_q_p => dac_data_q_p,
      dac_data_q_n => dac_data_q_n,
      dac_not_sdenb_i => dac_not_sdenb_i,
      dac_not_sdenb_q => dac_not_sdenb_q,
      dac_sclk => dac_sclk,
      dac_sdi => dac_sdi,
      dac_not_reset => dac_not_reset,
      dac_data_i0 => dac_data_i0,
      dac_data_i1 => dac_data_i1,
      dac_data_q0 => dac_data_q0,
      dac_data_q1 => dac_data_q1,
      dac_sync_i => dac_sync_i,
      dac_sync_q => dac_sync_q,
      dac_smpl_clk => dac_smpl_clk,
      not_sdenb_i => not_sdenb_i,
      not_sdenb_q => not_sdenb_q,
      sclk => sclk,
      sdi => sdi,
      not_reset => not_reset,
      dac_clk_out => dac_clk_out,
      dac_clk90_out => dac_clk90_out,
      dac_clk180_out => dac_clk180_out,
      dac_clk270_out => dac_clk270_out,
      dac_dcm_locked => dac_dcm_locked
    );

end architecture STRUCTURE;

