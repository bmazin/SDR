-------------------------------------------------------------------------------
-- system_stub.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system_stub is
  port (
    sys_clk_n : in std_logic;
    sys_clk_p : in std_logic;
    dly_clk_n : in std_logic;
    dly_clk_p : in std_logic;
    aux0_clk_n : in std_logic;
    aux0_clk_p : in std_logic;
    aux1_clk_n : in std_logic;
    aux1_clk_p : in std_logic;
    epb_clk_in : in std_logic;
    epb_data : inout std_logic_vector(15 downto 0);
    epb_addr : in std_logic_vector(22 downto 0);
    epb_addr_gp : in std_logic_vector(5 downto 0);
    epb_cs_n : in std_logic;
    epb_be_n : in std_logic_vector(1 downto 0);
    epb_r_w_n : in std_logic;
    epb_oe_n : in std_logic;
    epb_rdy : out std_logic;
    ppc_irq_n : out std_logic;
    dram_ck : out std_logic_vector(2 downto 0);
    dram_ck_n : out std_logic_vector(2 downto 0);
    dram_a : out std_logic_vector(15 downto 0);
    dram_ba : out std_logic_vector(2 downto 0);
    dram_ras_n : out std_logic;
    dram_cas_n : out std_logic;
    dram_we_n : out std_logic;
    dram_cs_n : out std_logic_vector(1 downto 0);
    dram_cke : out std_logic_vector(1 downto 0);
    dram_odt : out std_logic_vector(1 downto 0);
    dram_dm : out std_logic_vector(8 downto 0);
    dram_dqs : inout std_logic_vector(8 downto 0);
    dram_dqs_n : inout std_logic_vector(8 downto 0);
    dram_dq : inout std_logic_vector(71 downto 0);
    dram_reset_n : out std_logic;
    adcmkid1_DRDY_I_p : in std_logic;
    adcmkid1_DRDY_I_n : in std_logic;
    adcmkid1_DRDY_Q_p : in std_logic;
    adcmkid1_DRDY_Q_n : in std_logic;
    adcmkid1_DI_p : in std_logic_vector(11 downto 0);
    adcmkid1_DI_n : in std_logic_vector(11 downto 0);
    adcmkid1_DQ_p : in std_logic_vector(11 downto 0);
    adcmkid1_DQ_n : in std_logic_vector(11 downto 0);
    adcmkid1_ADC_ext_in_p : in std_logic;
    adcmkid1_ADC_ext_in_n : in std_logic;
    dac0_clk_p : in std_logic;
    dac0_clk_n : in std_logic;
    dac0_smpl_clk_i_p : out std_logic;
    dac0_smpl_clk_i_n : out std_logic;
    dac0_smpl_clk_q_p : out std_logic;
    dac0_smpl_clk_q_n : out std_logic;
    dac0_data_i_p : out std_logic_vector(15 downto 0);
    dac0_data_i_n : out std_logic_vector(15 downto 0);
    dac0_data_q_p : out std_logic_vector(15 downto 0);
    dac0_data_q_n : out std_logic_vector(15 downto 0);
    dac0_sync_i_p : out std_logic;
    dac0_sync_i_n : out std_logic;
    dac0_sync_q_p : out std_logic;
    dac0_sync_q_n : out std_logic;
    dac0_not_sdenb_i : out std_logic;
    dac0_not_sdenb_q : out std_logic;
    dac0_sclk : out std_logic;
    dac0_sdi : out std_logic;
    dac0_not_reset : out std_logic;
    chan_550_clean_gpio_a0_ext : out std_logic_vector(0 to 0);
    chan_550_clean_gpio_a1_ext : out std_logic_vector(0 to 0);
    chan_550_clean_gpio_a2_ext : out std_logic_vector(0 to 0);
    chan_550_clean_gpio_a3_ext : out std_logic_vector(0 to 0);
    chan_550_clean_gpio_a5_ext : out std_logic_vector(0 to 0)
  );
end system_stub;

architecture STRUCTURE of system_stub is

  component system is
    port (
      sys_clk_n : in std_logic;
      sys_clk_p : in std_logic;
      dly_clk_n : in std_logic;
      dly_clk_p : in std_logic;
      aux0_clk_n : in std_logic;
      aux0_clk_p : in std_logic;
      aux1_clk_n : in std_logic;
      aux1_clk_p : in std_logic;
      epb_clk_in : in std_logic;
      epb_data : inout std_logic_vector(15 downto 0);
      epb_addr : in std_logic_vector(22 downto 0);
      epb_addr_gp : in std_logic_vector(5 downto 0);
      epb_cs_n : in std_logic;
      epb_be_n : in std_logic_vector(1 downto 0);
      epb_r_w_n : in std_logic;
      epb_oe_n : in std_logic;
      epb_rdy : out std_logic;
      ppc_irq_n : out std_logic;
      dram_ck : out std_logic_vector(2 downto 0);
      dram_ck_n : out std_logic_vector(2 downto 0);
      dram_a : out std_logic_vector(15 downto 0);
      dram_ba : out std_logic_vector(2 downto 0);
      dram_ras_n : out std_logic;
      dram_cas_n : out std_logic;
      dram_we_n : out std_logic;
      dram_cs_n : out std_logic_vector(1 downto 0);
      dram_cke : out std_logic_vector(1 downto 0);
      dram_odt : out std_logic_vector(1 downto 0);
      dram_dm : out std_logic_vector(8 downto 0);
      dram_dqs : inout std_logic_vector(8 downto 0);
      dram_dqs_n : inout std_logic_vector(8 downto 0);
      dram_dq : inout std_logic_vector(71 downto 0);
      dram_reset_n : out std_logic;
      adcmkid1_DRDY_I_p : in std_logic;
      adcmkid1_DRDY_I_n : in std_logic;
      adcmkid1_DRDY_Q_p : in std_logic;
      adcmkid1_DRDY_Q_n : in std_logic;
      adcmkid1_DI_p : in std_logic_vector(11 downto 0);
      adcmkid1_DI_n : in std_logic_vector(11 downto 0);
      adcmkid1_DQ_p : in std_logic_vector(11 downto 0);
      adcmkid1_DQ_n : in std_logic_vector(11 downto 0);
      adcmkid1_ADC_ext_in_p : in std_logic;
      adcmkid1_ADC_ext_in_n : in std_logic;
      dac0_clk_p : in std_logic;
      dac0_clk_n : in std_logic;
      dac0_smpl_clk_i_p : out std_logic;
      dac0_smpl_clk_i_n : out std_logic;
      dac0_smpl_clk_q_p : out std_logic;
      dac0_smpl_clk_q_n : out std_logic;
      dac0_data_i_p : out std_logic_vector(15 downto 0);
      dac0_data_i_n : out std_logic_vector(15 downto 0);
      dac0_data_q_p : out std_logic_vector(15 downto 0);
      dac0_data_q_n : out std_logic_vector(15 downto 0);
      dac0_sync_i_p : out std_logic;
      dac0_sync_i_n : out std_logic;
      dac0_sync_q_p : out std_logic;
      dac0_sync_q_n : out std_logic;
      dac0_not_sdenb_i : out std_logic;
      dac0_not_sdenb_q : out std_logic;
      dac0_sclk : out std_logic;
      dac0_sdi : out std_logic;
      dac0_not_reset : out std_logic;
      chan_550_clean_gpio_a0_ext : out std_logic_vector(0 to 0);
      chan_550_clean_gpio_a1_ext : out std_logic_vector(0 to 0);
      chan_550_clean_gpio_a2_ext : out std_logic_vector(0 to 0);
      chan_550_clean_gpio_a3_ext : out std_logic_vector(0 to 0);
      chan_550_clean_gpio_a5_ext : out std_logic_vector(0 to 0)
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of system : component is "user_black_box";

begin

  system_i : system
    port map (
      sys_clk_n => sys_clk_n,
      sys_clk_p => sys_clk_p,
      dly_clk_n => dly_clk_n,
      dly_clk_p => dly_clk_p,
      aux0_clk_n => aux0_clk_n,
      aux0_clk_p => aux0_clk_p,
      aux1_clk_n => aux1_clk_n,
      aux1_clk_p => aux1_clk_p,
      epb_clk_in => epb_clk_in,
      epb_data => epb_data,
      epb_addr => epb_addr,
      epb_addr_gp => epb_addr_gp,
      epb_cs_n => epb_cs_n,
      epb_be_n => epb_be_n,
      epb_r_w_n => epb_r_w_n,
      epb_oe_n => epb_oe_n,
      epb_rdy => epb_rdy,
      ppc_irq_n => ppc_irq_n,
      dram_ck => dram_ck,
      dram_ck_n => dram_ck_n,
      dram_a => dram_a,
      dram_ba => dram_ba,
      dram_ras_n => dram_ras_n,
      dram_cas_n => dram_cas_n,
      dram_we_n => dram_we_n,
      dram_cs_n => dram_cs_n,
      dram_cke => dram_cke,
      dram_odt => dram_odt,
      dram_dm => dram_dm,
      dram_dqs => dram_dqs,
      dram_dqs_n => dram_dqs_n,
      dram_dq => dram_dq,
      dram_reset_n => dram_reset_n,
      adcmkid1_DRDY_I_p => adcmkid1_DRDY_I_p,
      adcmkid1_DRDY_I_n => adcmkid1_DRDY_I_n,
      adcmkid1_DRDY_Q_p => adcmkid1_DRDY_Q_p,
      adcmkid1_DRDY_Q_n => adcmkid1_DRDY_Q_n,
      adcmkid1_DI_p => adcmkid1_DI_p,
      adcmkid1_DI_n => adcmkid1_DI_n,
      adcmkid1_DQ_p => adcmkid1_DQ_p,
      adcmkid1_DQ_n => adcmkid1_DQ_n,
      adcmkid1_ADC_ext_in_p => adcmkid1_ADC_ext_in_p,
      adcmkid1_ADC_ext_in_n => adcmkid1_ADC_ext_in_n,
      dac0_clk_p => dac0_clk_p,
      dac0_clk_n => dac0_clk_n,
      dac0_smpl_clk_i_p => dac0_smpl_clk_i_p,
      dac0_smpl_clk_i_n => dac0_smpl_clk_i_n,
      dac0_smpl_clk_q_p => dac0_smpl_clk_q_p,
      dac0_smpl_clk_q_n => dac0_smpl_clk_q_n,
      dac0_data_i_p => dac0_data_i_p,
      dac0_data_i_n => dac0_data_i_n,
      dac0_data_q_p => dac0_data_q_p,
      dac0_data_q_n => dac0_data_q_n,
      dac0_sync_i_p => dac0_sync_i_p,
      dac0_sync_i_n => dac0_sync_i_n,
      dac0_sync_q_p => dac0_sync_q_p,
      dac0_sync_q_n => dac0_sync_q_n,
      dac0_not_sdenb_i => dac0_not_sdenb_i,
      dac0_not_sdenb_q => dac0_not_sdenb_q,
      dac0_sclk => dac0_sclk,
      dac0_sdi => dac0_sdi,
      dac0_not_reset => dac0_not_reset,
      chan_550_clean_gpio_a0_ext => chan_550_clean_gpio_a0_ext(0 to 0),
      chan_550_clean_gpio_a1_ext => chan_550_clean_gpio_a1_ext(0 to 0),
      chan_550_clean_gpio_a2_ext => chan_550_clean_gpio_a2_ext(0 to 0),
      chan_550_clean_gpio_a3_ext => chan_550_clean_gpio_a3_ext(0 to 0),
      chan_550_clean_gpio_a5_ext => chan_550_clean_gpio_a5_ext(0 to 0)
    );

end architecture STRUCTURE;

