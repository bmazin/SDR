-------------------------------------------------------------------------------
-- system.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity system is
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
end system;

architecture STRUCTURE of system is

  component infrastructure_inst_wrapper is
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
      sys_clk : out std_logic;
      sys_clk90 : out std_logic;
      sys_clk180 : out std_logic;
      sys_clk270 : out std_logic;
      sys_clk_lock : out std_logic;
      sys_clk2x : out std_logic;
      sys_clk2x90 : out std_logic;
      sys_clk2x180 : out std_logic;
      sys_clk2x270 : out std_logic;
      dly_clk : out std_logic;
      aux0_clk : out std_logic;
      aux0_clk90 : out std_logic;
      aux0_clk180 : out std_logic;
      aux0_clk270 : out std_logic;
      aux1_clk : out std_logic;
      aux1_clk90 : out std_logic;
      aux1_clk180 : out std_logic;
      aux1_clk270 : out std_logic;
      aux0_clk2x : out std_logic;
      aux0_clk2x90 : out std_logic;
      aux0_clk2x180 : out std_logic;
      aux0_clk2x270 : out std_logic;
      epb_clk : out std_logic;
      idelay_rst : in std_logic;
      idelay_rdy : out std_logic
    );
  end component;

  component reset_block_inst_wrapper is
    port (
      clk : in std_logic;
      async_reset_i : in std_logic;
      reset_i : in std_logic;
      reset_o : out std_logic
    );
  end component;

  component opb0_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : out std_logic;
      SYS_Rst : in std_logic;
      Debug_SYS_Rst : in std_logic;
      WDT_Rst : in std_logic;
      M_ABus : in std_logic_vector(0 to 31);
      M_BE : in std_logic_vector(0 to 3);
      M_beXfer : in std_logic_vector(0 to 0);
      M_busLock : in std_logic_vector(0 to 0);
      M_DBus : in std_logic_vector(0 to 31);
      M_DBusEn : in std_logic_vector(0 to 0);
      M_DBusEn32_63 : in std_logic_vector(0 to 0);
      M_dwXfer : in std_logic_vector(0 to 0);
      M_fwXfer : in std_logic_vector(0 to 0);
      M_hwXfer : in std_logic_vector(0 to 0);
      M_request : in std_logic_vector(0 to 0);
      M_RNW : in std_logic_vector(0 to 0);
      M_select : in std_logic_vector(0 to 0);
      M_seqAddr : in std_logic_vector(0 to 0);
      Sl_beAck : in std_logic_vector(0 to 5);
      Sl_DBus : in std_logic_vector(0 to 191);
      Sl_DBusEn : in std_logic_vector(0 to 5);
      Sl_DBusEn32_63 : in std_logic_vector(0 to 5);
      Sl_errAck : in std_logic_vector(0 to 5);
      Sl_dwAck : in std_logic_vector(0 to 5);
      Sl_fwAck : in std_logic_vector(0 to 5);
      Sl_hwAck : in std_logic_vector(0 to 5);
      Sl_retry : in std_logic_vector(0 to 5);
      Sl_toutSup : in std_logic_vector(0 to 5);
      Sl_xferAck : in std_logic_vector(0 to 5);
      OPB_MRequest : out std_logic_vector(0 to 0);
      OPB_ABus : out std_logic_vector(0 to 31);
      OPB_BE : out std_logic_vector(0 to 3);
      OPB_beXfer : out std_logic;
      OPB_beAck : out std_logic;
      OPB_busLock : out std_logic;
      OPB_rdDBus : out std_logic_vector(0 to 31);
      OPB_wrDBus : out std_logic_vector(0 to 31);
      OPB_DBus : out std_logic_vector(0 to 31);
      OPB_errAck : out std_logic;
      OPB_dwAck : out std_logic;
      OPB_dwXfer : out std_logic;
      OPB_fwAck : out std_logic;
      OPB_fwXfer : out std_logic;
      OPB_hwAck : out std_logic;
      OPB_hwXfer : out std_logic;
      OPB_MGrant : out std_logic_vector(0 to 0);
      OPB_pendReq : out std_logic_vector(0 to 0);
      OPB_retry : out std_logic;
      OPB_RNW : out std_logic;
      OPB_select : out std_logic;
      OPB_seqAddr : out std_logic;
      OPB_timeout : out std_logic;
      OPB_toutSup : out std_logic;
      OPB_xferAck : out std_logic
    );
  end component;

  component epb_opb_bridge_inst_wrapper is
    port (
      sys_reset : in std_logic;
      epb_data_oe_n : out std_logic;
      epb_cs_n : in std_logic;
      epb_oe_n : in std_logic;
      epb_r_w_n : in std_logic;
      epb_be_n : in std_logic_vector(1 downto 0);
      epb_addr : in std_logic_vector(22 downto 0);
      epb_addr_gp : in std_logic_vector(5 downto 0);
      epb_data_i : in std_logic_vector(15 downto 0);
      epb_data_o : out std_logic_vector(15 downto 0);
      epb_rdy : out std_logic;
      epb_rdy_oe : out std_logic;
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      M_request : out std_logic;
      M_busLock : out std_logic;
      M_select : out std_logic;
      M_RNW : out std_logic;
      M_BE : out std_logic_vector(0 to 3);
      M_seqAddr : out std_logic;
      M_DBus : out std_logic_vector(0 to 31);
      M_ABus : out std_logic_vector(0 to 31);
      OPB_MGrant : in std_logic;
      OPB_xferAck : in std_logic;
      OPB_errAck : in std_logic;
      OPB_retry : in std_logic;
      OPB_timeout : in std_logic;
      OPB_DBus : in std_logic_vector(0 to 31)
    );
  end component;

  component epb_infrastructure_inst_wrapper is
    port (
      epb_data_buf : inout std_logic_vector(15 downto 0);
      epb_data_oe_n_i : in std_logic;
      epb_data_out_i : in std_logic_vector(15 downto 0);
      epb_data_in_o : out std_logic_vector(15 downto 0);
      epb_oe_n_buf : in std_logic;
      epb_oe_n : out std_logic;
      epb_cs_n_buf : in std_logic;
      epb_cs_n : out std_logic;
      epb_r_w_n_buf : in std_logic;
      epb_r_w_n : out std_logic;
      epb_be_n_buf : in std_logic_vector(1 downto 0);
      epb_be_n : out std_logic_vector(1 downto 0);
      epb_addr_buf : in std_logic_vector(22 downto 0);
      epb_addr : out std_logic_vector(22 downto 0);
      epb_addr_gp_buf : in std_logic_vector(5 downto 0);
      epb_addr_gp : out std_logic_vector(5 downto 0);
      epb_rdy_buf : out std_logic;
      epb_rdy : in std_logic;
      epb_rdy_oe : in std_logic
    );
  end component;

  component sys_block_inst_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Sl_DBus : out std_logic_vector(0 to 31);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      soft_reset : out std_logic;
      irq_n : out std_logic;
      app_irq : in std_logic_vector(15 downto 0);
      fab_clk : in std_logic
    );
  end component;

  component timestamper_xsg_core_config_wrapper is
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

  component timestamper_adc_mkid_wrapper is
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

  component timestamper_pulses_addr_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Sl_DBus : out std_logic_vector(0 to 31);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      user_data_in : in std_logic_vector(31 downto 0);
      user_clk : in std_logic
    );
  end component;

  component timestamper_pulses_bram0_ramif_wrapper is
    port (
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 3);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 31);
      bram_dout : out std_logic_vector(0 to 31);
      clk_in : in std_logic;
      addr : in std_logic_vector(13 downto 0);
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(31 downto 0);
      we : in std_logic
    );
  end component;

  component timestamper_pulses_bram0_ramblk_wrapper is
    port (
      BRAM_Rst_A : in std_logic;
      BRAM_Clk_A : in std_logic;
      BRAM_EN_A : in std_logic;
      BRAM_WEN_A : in std_logic_vector(0 to 3);
      BRAM_Addr_A : in std_logic_vector(0 to 31);
      BRAM_Din_A : out std_logic_vector(0 to 31);
      BRAM_Dout_A : in std_logic_vector(0 to 31);
      BRAM_Rst_B : in std_logic;
      BRAM_Clk_B : in std_logic;
      BRAM_EN_B : in std_logic;
      BRAM_WEN_B : in std_logic_vector(0 to 3);
      BRAM_Addr_B : in std_logic_vector(0 to 31);
      BRAM_Din_B : out std_logic_vector(0 to 31);
      BRAM_Dout_B : in std_logic_vector(0 to 31)
    );
  end component;

  component timestamper_pulses_bram0_wrapper is
    port (
      opb_clk : in std_logic;
      opb_rst : in std_logic;
      opb_abus : in std_logic_vector(0 to 31);
      opb_dbus : in std_logic_vector(0 to 31);
      sln_dbus : out std_logic_vector(0 to 31);
      opb_select : in std_logic;
      opb_rnw : in std_logic;
      opb_seqaddr : in std_logic;
      opb_be : in std_logic_vector(0 to 3);
      sln_xferack : out std_logic;
      sln_errack : out std_logic;
      sln_toutsup : out std_logic;
      sln_retry : out std_logic;
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 3);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 31);
      bram_dout : out std_logic_vector(0 to 31)
    );
  end component;

  component timestamper_pulses_bram1_ramif_wrapper is
    port (
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 3);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 31);
      bram_dout : out std_logic_vector(0 to 31);
      clk_in : in std_logic;
      addr : in std_logic_vector(13 downto 0);
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(31 downto 0);
      we : in std_logic
    );
  end component;

  component timestamper_pulses_bram1_ramblk_wrapper is
    port (
      BRAM_Rst_A : in std_logic;
      BRAM_Clk_A : in std_logic;
      BRAM_EN_A : in std_logic;
      BRAM_WEN_A : in std_logic_vector(0 to 3);
      BRAM_Addr_A : in std_logic_vector(0 to 31);
      BRAM_Din_A : out std_logic_vector(0 to 31);
      BRAM_Dout_A : in std_logic_vector(0 to 31);
      BRAM_Rst_B : in std_logic;
      BRAM_Clk_B : in std_logic;
      BRAM_EN_B : in std_logic;
      BRAM_WEN_B : in std_logic_vector(0 to 3);
      BRAM_Addr_B : in std_logic_vector(0 to 31);
      BRAM_Din_B : out std_logic_vector(0 to 31);
      BRAM_Dout_B : in std_logic_vector(0 to 31)
    );
  end component;

  component timestamper_pulses_bram1_wrapper is
    port (
      opb_clk : in std_logic;
      opb_rst : in std_logic;
      opb_abus : in std_logic_vector(0 to 31);
      opb_dbus : in std_logic_vector(0 to 31);
      sln_dbus : out std_logic_vector(0 to 31);
      opb_select : in std_logic;
      opb_rnw : in std_logic;
      opb_seqaddr : in std_logic;
      opb_be : in std_logic_vector(0 to 3);
      sln_xferack : out std_logic;
      sln_errack : out std_logic;
      sln_toutsup : out std_logic;
      sln_retry : out std_logic;
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 3);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 31);
      bram_dout : out std_logic_vector(0 to 31)
    );
  end component;

  component timestamper_seconds_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Sl_DBus : out std_logic_vector(0 to 31);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      user_data_in : in std_logic_vector(31 downto 0);
      user_clk : in std_logic
    );
  end component;

  component timestamper_startbuffer_wrapper is
    port (
      OPB_Clk : in std_logic;
      OPB_Rst : in std_logic;
      Sl_DBus : out std_logic_vector(0 to 31);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      OPB_ABus : in std_logic_vector(0 to 31);
      OPB_BE : in std_logic_vector(0 to 3);
      OPB_DBus : in std_logic_vector(0 to 31);
      OPB_RNW : in std_logic;
      OPB_select : in std_logic;
      OPB_seqAddr : in std_logic;
      user_data_out : out std_logic_vector(31 downto 0);
      user_clk : in std_logic
    );
  end component;

  -- Internal signals

  signal adc1_clk : std_logic;
  signal epb_addr_gp_int : std_logic_vector(5 downto 0);
  signal epb_addr_int : std_logic_vector(22 downto 0);
  signal epb_be_n_int : std_logic_vector(1 downto 0);
  signal epb_clk : std_logic;
  signal epb_cs_n_int : std_logic;
  signal epb_data_i : std_logic_vector(15 downto 0);
  signal epb_data_o : std_logic_vector(15 downto 0);
  signal epb_data_oe_n : std_logic;
  signal epb_oe_n_int : std_logic;
  signal epb_r_w_n_int : std_logic;
  signal epb_rdy_buf : std_logic;
  signal epb_rdy_oe : std_logic;
  signal net_gnd0 : std_logic;
  signal net_gnd1 : std_logic_vector(0 to 0);
  signal net_gnd6 : std_logic_vector(0 to 5);
  signal net_vcc1 : std_logic_vector(0 to 0);
  signal net_vcc6 : std_logic_vector(0 to 5);
  signal opb0_M_ABus : std_logic_vector(0 to 31);
  signal opb0_M_BE : std_logic_vector(0 to 3);
  signal opb0_M_DBus : std_logic_vector(0 to 31);
  signal opb0_M_RNW : std_logic_vector(0 to 0);
  signal opb0_M_busLock : std_logic_vector(0 to 0);
  signal opb0_M_request : std_logic_vector(0 to 0);
  signal opb0_M_select : std_logic_vector(0 to 0);
  signal opb0_M_seqAddr : std_logic_vector(0 to 0);
  signal opb0_OPB_ABus : std_logic_vector(0 to 31);
  signal opb0_OPB_BE : std_logic_vector(0 to 3);
  signal opb0_OPB_DBus : std_logic_vector(0 to 31);
  signal opb0_OPB_MGrant : std_logic_vector(0 to 0);
  signal opb0_OPB_RNW : std_logic;
  signal opb0_OPB_Rst : std_logic;
  signal opb0_OPB_errAck : std_logic;
  signal opb0_OPB_retry : std_logic;
  signal opb0_OPB_select : std_logic;
  signal opb0_OPB_seqAddr : std_logic;
  signal opb0_OPB_timeout : std_logic;
  signal opb0_OPB_xferAck : std_logic;
  signal opb0_Sl_DBus : std_logic_vector(0 to 191);
  signal opb0_Sl_errAck : std_logic_vector(0 to 5);
  signal opb0_Sl_retry : std_logic_vector(0 to 5);
  signal opb0_Sl_toutSup : std_logic_vector(0 to 5);
  signal opb0_Sl_xferAck : std_logic_vector(0 to 5);
  signal pgassign1 : std_logic;
  signal pgassign2 : std_logic_vector(15 downto 0);
  signal sys_reset : std_logic;
  signal timestamper_adc_mkid_user_data_i0 : std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_data_i1 : std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_data_q0 : std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_data_q1 : std_logic_vector(11 downto 0);
  signal timestamper_adc_mkid_user_sync : std_logic;
  signal timestamper_pulses_addr_user_data_in : std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram0_addr : std_logic_vector(13 downto 0);
  signal timestamper_pulses_bram0_data_in : std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram0_data_out : std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_Clk : std_logic;
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_Din : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_Dout : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_EN : std_logic;
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_Rst : std_logic;
  signal timestamper_pulses_bram0_ramblk_porta_BRAM_WEN : std_logic_vector(0 to 3);
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_Addr : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_Clk : std_logic;
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_Din : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_Dout : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_EN : std_logic;
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_Rst : std_logic;
  signal timestamper_pulses_bram0_ramblk_portb_BRAM_WEN : std_logic_vector(0 to 3);
  signal timestamper_pulses_bram0_we : std_logic;
  signal timestamper_pulses_bram1_addr : std_logic_vector(13 downto 0);
  signal timestamper_pulses_bram1_data_in : std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram1_data_out : std_logic_vector(31 downto 0);
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_Clk : std_logic;
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_Din : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_Dout : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_EN : std_logic;
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_Rst : std_logic;
  signal timestamper_pulses_bram1_ramblk_porta_BRAM_WEN : std_logic_vector(0 to 3);
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_Addr : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_Clk : std_logic;
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_Din : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_Dout : std_logic_vector(0 to 31);
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_EN : std_logic;
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_Rst : std_logic;
  signal timestamper_pulses_bram1_ramblk_portb_BRAM_WEN : std_logic_vector(0 to 3);
  signal timestamper_pulses_bram1_we : std_logic;
  signal timestamper_seconds_user_data_in : std_logic_vector(31 downto 0);
  signal timestamper_startBuffer_user_data_out : std_logic_vector(31 downto 0);

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of infrastructure_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of reset_block_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of opb0_wrapper : component is "user_black_box";
  attribute BOX_TYPE of epb_opb_bridge_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of epb_infrastructure_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of sys_block_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_xsg_core_config_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_adc_mkid_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_addr_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_bram0_ramif_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_bram0_ramblk_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_bram0_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_bram1_ramif_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_bram1_ramblk_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_pulses_bram1_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_seconds_wrapper : component is "user_black_box";
  attribute BOX_TYPE of timestamper_startbuffer_wrapper : component is "user_black_box";

begin

  -- Internal assignments

  pgassign1 <= '0';
  pgassign2(15 downto 0) <= X"0000";
  net_gnd0 <= '0';
  net_gnd1(0 to 0) <= B"0";
  net_gnd6(0 to 5) <= B"000000";
  net_vcc1(0 to 0) <= B"1";
  net_vcc6(0 to 5) <= B"111111";

  infrastructure_inst : infrastructure_inst_wrapper
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
      sys_clk => open,
      sys_clk90 => open,
      sys_clk180 => open,
      sys_clk270 => open,
      sys_clk_lock => open,
      sys_clk2x => open,
      sys_clk2x90 => open,
      sys_clk2x180 => open,
      sys_clk2x270 => open,
      dly_clk => open,
      aux0_clk => open,
      aux0_clk90 => open,
      aux0_clk180 => open,
      aux0_clk270 => open,
      aux1_clk => open,
      aux1_clk90 => open,
      aux1_clk180 => open,
      aux1_clk270 => open,
      aux0_clk2x => open,
      aux0_clk2x90 => open,
      aux0_clk2x180 => open,
      aux0_clk2x270 => open,
      epb_clk => epb_clk,
      idelay_rst => sys_reset,
      idelay_rdy => open
    );

  reset_block_inst : reset_block_inst_wrapper
    port map (
      clk => epb_clk,
      async_reset_i => pgassign1,
      reset_i => pgassign1,
      reset_o => sys_reset
    );

  opb0 : opb0_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      SYS_Rst => pgassign1,
      Debug_SYS_Rst => net_gnd0,
      WDT_Rst => net_gnd0,
      M_ABus => opb0_M_ABus,
      M_BE => opb0_M_BE,
      M_beXfer => net_gnd1(0 to 0),
      M_busLock => opb0_M_busLock(0 to 0),
      M_DBus => opb0_M_DBus,
      M_DBusEn => net_gnd1(0 to 0),
      M_DBusEn32_63 => net_vcc1(0 to 0),
      M_dwXfer => net_gnd1(0 to 0),
      M_fwXfer => net_gnd1(0 to 0),
      M_hwXfer => net_gnd1(0 to 0),
      M_request => opb0_M_request(0 to 0),
      M_RNW => opb0_M_RNW(0 to 0),
      M_select => opb0_M_select(0 to 0),
      M_seqAddr => opb0_M_seqAddr(0 to 0),
      Sl_beAck => net_gnd6,
      Sl_DBus => opb0_Sl_DBus,
      Sl_DBusEn => net_vcc6,
      Sl_DBusEn32_63 => net_vcc6,
      Sl_errAck => opb0_Sl_errAck,
      Sl_dwAck => net_gnd6,
      Sl_fwAck => net_gnd6,
      Sl_hwAck => net_gnd6,
      Sl_retry => opb0_Sl_retry,
      Sl_toutSup => opb0_Sl_toutSup,
      Sl_xferAck => opb0_Sl_xferAck,
      OPB_MRequest => open,
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_beXfer => open,
      OPB_beAck => open,
      OPB_busLock => open,
      OPB_rdDBus => open,
      OPB_wrDBus => open,
      OPB_DBus => opb0_OPB_DBus,
      OPB_errAck => opb0_OPB_errAck,
      OPB_dwAck => open,
      OPB_dwXfer => open,
      OPB_fwAck => open,
      OPB_fwXfer => open,
      OPB_hwAck => open,
      OPB_hwXfer => open,
      OPB_MGrant => opb0_OPB_MGrant(0 to 0),
      OPB_pendReq => open,
      OPB_retry => opb0_OPB_retry,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      OPB_timeout => opb0_OPB_timeout,
      OPB_toutSup => open,
      OPB_xferAck => opb0_OPB_xferAck
    );

  epb_opb_bridge_inst : epb_opb_bridge_inst_wrapper
    port map (
      sys_reset => pgassign1,
      epb_data_oe_n => epb_data_oe_n,
      epb_cs_n => epb_cs_n_int,
      epb_oe_n => epb_oe_n_int,
      epb_r_w_n => epb_r_w_n_int,
      epb_be_n => epb_be_n_int,
      epb_addr => epb_addr_int,
      epb_addr_gp => epb_addr_gp_int,
      epb_data_i => epb_data_i,
      epb_data_o => epb_data_o,
      epb_rdy => epb_rdy_buf,
      epb_rdy_oe => epb_rdy_oe,
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      M_request => opb0_M_request(0),
      M_busLock => opb0_M_busLock(0),
      M_select => opb0_M_select(0),
      M_RNW => opb0_M_RNW(0),
      M_BE => opb0_M_BE,
      M_seqAddr => opb0_M_seqAddr(0),
      M_DBus => opb0_M_DBus,
      M_ABus => opb0_M_ABus,
      OPB_MGrant => opb0_OPB_MGrant(0),
      OPB_xferAck => opb0_OPB_xferAck,
      OPB_errAck => opb0_OPB_errAck,
      OPB_retry => opb0_OPB_retry,
      OPB_timeout => opb0_OPB_timeout,
      OPB_DBus => opb0_OPB_DBus
    );

  epb_infrastructure_inst : epb_infrastructure_inst_wrapper
    port map (
      epb_data_buf => epb_data,
      epb_data_oe_n_i => epb_data_oe_n,
      epb_data_out_i => epb_data_o,
      epb_data_in_o => epb_data_i,
      epb_oe_n_buf => epb_oe_n,
      epb_oe_n => epb_oe_n_int,
      epb_cs_n_buf => epb_cs_n,
      epb_cs_n => epb_cs_n_int,
      epb_r_w_n_buf => epb_r_w_n,
      epb_r_w_n => epb_r_w_n_int,
      epb_be_n_buf => epb_be_n,
      epb_be_n => epb_be_n_int,
      epb_addr_buf => epb_addr,
      epb_addr => epb_addr_int,
      epb_addr_gp_buf => epb_addr_gp,
      epb_addr_gp => epb_addr_gp_int,
      epb_rdy_buf => epb_rdy,
      epb_rdy => epb_rdy_buf,
      epb_rdy_oe => epb_rdy_oe
    );

  sys_block_inst : sys_block_inst_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(0 to 31),
      Sl_errAck => opb0_Sl_errAck(0),
      Sl_retry => opb0_Sl_retry(0),
      Sl_toutSup => opb0_Sl_toutSup(0),
      Sl_xferAck => opb0_Sl_xferAck(0),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      soft_reset => open,
      irq_n => ppc_irq_n,
      app_irq => pgassign2,
      fab_clk => adc1_clk
    );

  timestamper_XSG_core_config : timestamper_xsg_core_config_wrapper
    port map (
      clk => adc1_clk,
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

  timestamper_adc_mkid : timestamper_adc_mkid_wrapper
    port map (
      DRDY_I_p => adcmkid1_DRDY_I_p,
      DRDY_I_n => adcmkid1_DRDY_I_n,
      DRDY_Q_p => adcmkid1_DRDY_Q_p,
      DRDY_Q_n => adcmkid1_DRDY_Q_n,
      DI_p => adcmkid1_DI_p,
      DI_n => adcmkid1_DI_n,
      DQ_p => adcmkid1_DQ_p,
      DQ_n => adcmkid1_DQ_n,
      ADC_ext_in_p => adcmkid1_ADC_ext_in_p,
      ADC_ext_in_n => adcmkid1_ADC_ext_in_n,
      fpga_clk => adc1_clk,
      adc_clk_out => adc1_clk,
      adc_clk90_out => open,
      adc_clk180_out => open,
      adc_clk270_out => open,
      adc_dcm_locked => open,
      user_data_i0 => timestamper_adc_mkid_user_data_i0,
      user_data_i1 => timestamper_adc_mkid_user_data_i1,
      user_data_q0 => timestamper_adc_mkid_user_data_q0,
      user_data_q1 => timestamper_adc_mkid_user_data_q1,
      user_sync => timestamper_adc_mkid_user_sync
    );

  timestamper_pulses_addr : timestamper_pulses_addr_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(32 to 63),
      Sl_errAck => opb0_Sl_errAck(1),
      Sl_retry => opb0_Sl_retry(1),
      Sl_toutSup => opb0_Sl_toutSup(1),
      Sl_xferAck => opb0_Sl_xferAck(1),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_in => timestamper_pulses_addr_user_data_in,
      user_clk => adc1_clk
    );

  timestamper_pulses_bram0_ramif : timestamper_pulses_bram0_ramif_wrapper
    port map (
      bram_rst => timestamper_pulses_bram0_ramblk_porta_BRAM_Rst,
      bram_clk => timestamper_pulses_bram0_ramblk_porta_BRAM_Clk,
      bram_en => timestamper_pulses_bram0_ramblk_porta_BRAM_EN,
      bram_wen => timestamper_pulses_bram0_ramblk_porta_BRAM_WEN,
      bram_addr => timestamper_pulses_bram0_ramblk_porta_BRAM_Addr,
      bram_din => timestamper_pulses_bram0_ramblk_porta_BRAM_Din,
      bram_dout => timestamper_pulses_bram0_ramblk_porta_BRAM_Dout,
      clk_in => adc1_clk,
      addr => timestamper_pulses_bram0_addr,
      data_in => timestamper_pulses_bram0_data_in,
      data_out => timestamper_pulses_bram0_data_out,
      we => timestamper_pulses_bram0_we
    );

  timestamper_pulses_bram0_ramblk : timestamper_pulses_bram0_ramblk_wrapper
    port map (
      BRAM_Rst_A => timestamper_pulses_bram0_ramblk_porta_BRAM_Rst,
      BRAM_Clk_A => timestamper_pulses_bram0_ramblk_porta_BRAM_Clk,
      BRAM_EN_A => timestamper_pulses_bram0_ramblk_porta_BRAM_EN,
      BRAM_WEN_A => timestamper_pulses_bram0_ramblk_porta_BRAM_WEN,
      BRAM_Addr_A => timestamper_pulses_bram0_ramblk_porta_BRAM_Addr,
      BRAM_Din_A => timestamper_pulses_bram0_ramblk_porta_BRAM_Din,
      BRAM_Dout_A => timestamper_pulses_bram0_ramblk_porta_BRAM_Dout,
      BRAM_Rst_B => timestamper_pulses_bram0_ramblk_portb_BRAM_Rst,
      BRAM_Clk_B => timestamper_pulses_bram0_ramblk_portb_BRAM_Clk,
      BRAM_EN_B => timestamper_pulses_bram0_ramblk_portb_BRAM_EN,
      BRAM_WEN_B => timestamper_pulses_bram0_ramblk_portb_BRAM_WEN,
      BRAM_Addr_B => timestamper_pulses_bram0_ramblk_portb_BRAM_Addr,
      BRAM_Din_B => timestamper_pulses_bram0_ramblk_portb_BRAM_Din,
      BRAM_Dout_B => timestamper_pulses_bram0_ramblk_portb_BRAM_Dout
    );

  timestamper_pulses_bram0 : timestamper_pulses_bram0_wrapper
    port map (
      opb_clk => epb_clk,
      opb_rst => opb0_OPB_Rst,
      opb_abus => opb0_OPB_ABus,
      opb_dbus => opb0_OPB_DBus,
      sln_dbus => opb0_Sl_DBus(64 to 95),
      opb_select => opb0_OPB_select,
      opb_rnw => opb0_OPB_RNW,
      opb_seqaddr => opb0_OPB_seqAddr,
      opb_be => opb0_OPB_BE,
      sln_xferack => opb0_Sl_xferAck(2),
      sln_errack => opb0_Sl_errAck(2),
      sln_toutsup => opb0_Sl_toutSup(2),
      sln_retry => opb0_Sl_retry(2),
      bram_rst => timestamper_pulses_bram0_ramblk_portb_BRAM_Rst,
      bram_clk => timestamper_pulses_bram0_ramblk_portb_BRAM_Clk,
      bram_en => timestamper_pulses_bram0_ramblk_portb_BRAM_EN,
      bram_wen => timestamper_pulses_bram0_ramblk_portb_BRAM_WEN,
      bram_addr => timestamper_pulses_bram0_ramblk_portb_BRAM_Addr,
      bram_din => timestamper_pulses_bram0_ramblk_portb_BRAM_Din,
      bram_dout => timestamper_pulses_bram0_ramblk_portb_BRAM_Dout
    );

  timestamper_pulses_bram1_ramif : timestamper_pulses_bram1_ramif_wrapper
    port map (
      bram_rst => timestamper_pulses_bram1_ramblk_porta_BRAM_Rst,
      bram_clk => timestamper_pulses_bram1_ramblk_porta_BRAM_Clk,
      bram_en => timestamper_pulses_bram1_ramblk_porta_BRAM_EN,
      bram_wen => timestamper_pulses_bram1_ramblk_porta_BRAM_WEN,
      bram_addr => timestamper_pulses_bram1_ramblk_porta_BRAM_Addr,
      bram_din => timestamper_pulses_bram1_ramblk_porta_BRAM_Din,
      bram_dout => timestamper_pulses_bram1_ramblk_porta_BRAM_Dout,
      clk_in => adc1_clk,
      addr => timestamper_pulses_bram1_addr,
      data_in => timestamper_pulses_bram1_data_in,
      data_out => timestamper_pulses_bram1_data_out,
      we => timestamper_pulses_bram1_we
    );

  timestamper_pulses_bram1_ramblk : timestamper_pulses_bram1_ramblk_wrapper
    port map (
      BRAM_Rst_A => timestamper_pulses_bram1_ramblk_porta_BRAM_Rst,
      BRAM_Clk_A => timestamper_pulses_bram1_ramblk_porta_BRAM_Clk,
      BRAM_EN_A => timestamper_pulses_bram1_ramblk_porta_BRAM_EN,
      BRAM_WEN_A => timestamper_pulses_bram1_ramblk_porta_BRAM_WEN,
      BRAM_Addr_A => timestamper_pulses_bram1_ramblk_porta_BRAM_Addr,
      BRAM_Din_A => timestamper_pulses_bram1_ramblk_porta_BRAM_Din,
      BRAM_Dout_A => timestamper_pulses_bram1_ramblk_porta_BRAM_Dout,
      BRAM_Rst_B => timestamper_pulses_bram1_ramblk_portb_BRAM_Rst,
      BRAM_Clk_B => timestamper_pulses_bram1_ramblk_portb_BRAM_Clk,
      BRAM_EN_B => timestamper_pulses_bram1_ramblk_portb_BRAM_EN,
      BRAM_WEN_B => timestamper_pulses_bram1_ramblk_portb_BRAM_WEN,
      BRAM_Addr_B => timestamper_pulses_bram1_ramblk_portb_BRAM_Addr,
      BRAM_Din_B => timestamper_pulses_bram1_ramblk_portb_BRAM_Din,
      BRAM_Dout_B => timestamper_pulses_bram1_ramblk_portb_BRAM_Dout
    );

  timestamper_pulses_bram1 : timestamper_pulses_bram1_wrapper
    port map (
      opb_clk => epb_clk,
      opb_rst => opb0_OPB_Rst,
      opb_abus => opb0_OPB_ABus,
      opb_dbus => opb0_OPB_DBus,
      sln_dbus => opb0_Sl_DBus(96 to 127),
      opb_select => opb0_OPB_select,
      opb_rnw => opb0_OPB_RNW,
      opb_seqaddr => opb0_OPB_seqAddr,
      opb_be => opb0_OPB_BE,
      sln_xferack => opb0_Sl_xferAck(3),
      sln_errack => opb0_Sl_errAck(3),
      sln_toutsup => opb0_Sl_toutSup(3),
      sln_retry => opb0_Sl_retry(3),
      bram_rst => timestamper_pulses_bram1_ramblk_portb_BRAM_Rst,
      bram_clk => timestamper_pulses_bram1_ramblk_portb_BRAM_Clk,
      bram_en => timestamper_pulses_bram1_ramblk_portb_BRAM_EN,
      bram_wen => timestamper_pulses_bram1_ramblk_portb_BRAM_WEN,
      bram_addr => timestamper_pulses_bram1_ramblk_portb_BRAM_Addr,
      bram_din => timestamper_pulses_bram1_ramblk_portb_BRAM_Din,
      bram_dout => timestamper_pulses_bram1_ramblk_portb_BRAM_Dout
    );

  timestamper_seconds : timestamper_seconds_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(128 to 159),
      Sl_errAck => opb0_Sl_errAck(4),
      Sl_retry => opb0_Sl_retry(4),
      Sl_toutSup => opb0_Sl_toutSup(4),
      Sl_xferAck => opb0_Sl_xferAck(4),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_in => timestamper_seconds_user_data_in,
      user_clk => adc1_clk
    );

  timestamper_startBuffer : timestamper_startbuffer_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(160 to 191),
      Sl_errAck => opb0_Sl_errAck(5),
      Sl_retry => opb0_Sl_retry(5),
      Sl_toutSup => opb0_Sl_toutSup(5),
      Sl_xferAck => opb0_Sl_xferAck(5),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => timestamper_startBuffer_user_data_out,
      user_clk => adc1_clk
    );

end architecture STRUCTURE;

