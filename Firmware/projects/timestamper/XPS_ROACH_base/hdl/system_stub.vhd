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
    adcmkid1_DRDY_I_p : in std_logic;
    adcmkid1_DRDY_I_n : in std_logic;
    adcmkid1_DRDY_Q_p : in std_logic;
    adcmkid1_DRDY_Q_n : in std_logic;
    adcmkid1_DI_p : in std_logic_vector(11 downto 0);
    adcmkid1_DI_n : in std_logic_vector(11 downto 0);
    adcmkid1_DQ_p : in std_logic_vector(11 downto 0);
    adcmkid1_DQ_n : in std_logic_vector(11 downto 0);
    adcmkid1_ADC_ext_in_p : in std_logic;
    adcmkid1_ADC_ext_in_n : in std_logic
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
      adcmkid1_DRDY_I_p : in std_logic;
      adcmkid1_DRDY_I_n : in std_logic;
      adcmkid1_DRDY_Q_p : in std_logic;
      adcmkid1_DRDY_Q_n : in std_logic;
      adcmkid1_DI_p : in std_logic_vector(11 downto 0);
      adcmkid1_DI_n : in std_logic_vector(11 downto 0);
      adcmkid1_DQ_p : in std_logic_vector(11 downto 0);
      adcmkid1_DQ_n : in std_logic_vector(11 downto 0);
      adcmkid1_ADC_ext_in_p : in std_logic;
      adcmkid1_ADC_ext_in_n : in std_logic
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
      adcmkid1_DRDY_I_p => adcmkid1_DRDY_I_p,
      adcmkid1_DRDY_I_n => adcmkid1_DRDY_I_n,
      adcmkid1_DRDY_Q_p => adcmkid1_DRDY_Q_p,
      adcmkid1_DRDY_Q_n => adcmkid1_DRDY_Q_n,
      adcmkid1_DI_p => adcmkid1_DI_p,
      adcmkid1_DI_n => adcmkid1_DI_n,
      adcmkid1_DQ_p => adcmkid1_DQ_p,
      adcmkid1_DQ_n => adcmkid1_DQ_n,
      adcmkid1_ADC_ext_in_p => adcmkid1_ADC_ext_in_p,
      adcmkid1_ADC_ext_in_n => adcmkid1_ADC_ext_in_n
    );

end architecture STRUCTURE;

