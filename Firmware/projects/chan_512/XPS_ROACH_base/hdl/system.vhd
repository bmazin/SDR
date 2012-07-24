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
    chan_512_gpio_a0_ext : out std_logic_vector(0 to 0);
    chan_512_gpio_a1_ext : out std_logic_vector(0 to 0);
    chan_512_gpio_a2_ext : out std_logic_vector(0 to 0);
    chan_512_gpio_a3_ext : out std_logic_vector(0 to 0);
    chan_512_gpio_a5_ext : out std_logic_vector(0 to 0)
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
      Sl_beAck : in std_logic_vector(0 to 32);
      Sl_DBus : in std_logic_vector(0 to 1055);
      Sl_DBusEn : in std_logic_vector(0 to 32);
      Sl_DBusEn32_63 : in std_logic_vector(0 to 32);
      Sl_errAck : in std_logic_vector(0 to 32);
      Sl_dwAck : in std_logic_vector(0 to 32);
      Sl_fwAck : in std_logic_vector(0 to 32);
      Sl_hwAck : in std_logic_vector(0 to 32);
      Sl_retry : in std_logic_vector(0 to 32);
      Sl_toutSup : in std_logic_vector(0 to 32);
      Sl_xferAck : in std_logic_vector(0 to 32);
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

  component chan_512_xsg_core_config_wrapper is
    port (
      clk : in std_logic;
      chan_512_DRAM_LUT_dram_Mem_Cmd_Ack : in std_logic;
      chan_512_DRAM_LUT_dram_Mem_Rd_Dout : in std_logic_vector(143 downto 0);
      chan_512_DRAM_LUT_dram_Mem_Rd_Tag : in std_logic_vector(31 downto 0);
      chan_512_DRAM_LUT_dram_Mem_Rd_Valid : in std_logic;
      chan_512_DRAM_LUT_dram_phy_ready : in std_logic;
      chan_512_DRAM_LUT_dram_Mem_Cmd_Address : out std_logic_vector(31 downto 0);
      chan_512_DRAM_LUT_dram_Mem_Cmd_RNW : out std_logic;
      chan_512_DRAM_LUT_dram_Mem_Cmd_Tag : out std_logic_vector(31 downto 0);
      chan_512_DRAM_LUT_dram_Mem_Cmd_Valid : out std_logic;
      chan_512_DRAM_LUT_dram_Mem_Rd_Ack : out std_logic;
      chan_512_DRAM_LUT_dram_Mem_Rst : out std_logic;
      chan_512_DRAM_LUT_dram_Mem_Wr_BE : out std_logic_vector(17 downto 0);
      chan_512_DRAM_LUT_dram_Mem_Wr_Din : out std_logic_vector(143 downto 0);
      chan_512_DRAM_LUT_lut_size_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_DRAM_LUT_rd_valid_user_data_in : out std_logic_vector(31 downto 0);
      chan_512_FIR_b0b1_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b10b11_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b12b13_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b14b15_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b16b17_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b18b19_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b20b21_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b22b23_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b24b25_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b2b3_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b4b5_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b6b7_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_b8b9_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_FIR_load_coeff_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_LO_SLE_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_SER_DI_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_SWAT_LE_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_adc_mkid_user_data_i0 : in std_logic_vector(11 downto 0);
      chan_512_adc_mkid_user_data_i1 : in std_logic_vector(11 downto 0);
      chan_512_adc_mkid_user_data_q0 : in std_logic_vector(11 downto 0);
      chan_512_adc_mkid_user_data_q1 : in std_logic_vector(11 downto 0);
      chan_512_adc_mkid_user_sync : in std_logic;
      chan_512_avgIQ_addr_user_data_in : out std_logic_vector(31 downto 0);
      chan_512_avgIQ_bram_data_out : in std_logic_vector(31 downto 0);
      chan_512_avgIQ_bram_addr : out std_logic_vector(9 downto 0);
      chan_512_avgIQ_bram_data_in : out std_logic_vector(31 downto 0);
      chan_512_avgIQ_bram_we : out std_logic;
      chan_512_avgIQ_ctrl_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_bins_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_capture_load_thresh_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_capture_threshold_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_ch_we_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_conv_phase_centers_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_conv_phase_load_centers_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_dac_mkid_dac_data_i0 : out std_logic_vector(15 downto 0);
      chan_512_dac_mkid_dac_data_i1 : out std_logic_vector(15 downto 0);
      chan_512_dac_mkid_dac_data_q0 : out std_logic_vector(15 downto 0);
      chan_512_dac_mkid_dac_data_q1 : out std_logic_vector(15 downto 0);
      chan_512_dac_mkid_dac_sync_i : out std_logic;
      chan_512_dac_mkid_dac_sync_q : out std_logic;
      chan_512_dac_mkid_not_reset : out std_logic;
      chan_512_dac_mkid_not_sdenb_i : out std_logic;
      chan_512_dac_mkid_not_sdenb_q : out std_logic;
      chan_512_dac_mkid_sclk : out std_logic;
      chan_512_dac_mkid_sdi : out std_logic;
      chan_512_gpio_a0_gateway : out std_logic;
      chan_512_gpio_a1_gateway : out std_logic;
      chan_512_gpio_a2_gateway : out std_logic;
      chan_512_gpio_a3_gateway : out std_logic;
      chan_512_gpio_a5_gateway : out std_logic;
      chan_512_if_switch_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_load_bins_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_pulses_addr_user_data_in : out std_logic_vector(31 downto 0);
      chan_512_pulses_bram0_data_out : in std_logic_vector(31 downto 0);
      chan_512_pulses_bram0_addr : out std_logic_vector(13 downto 0);
      chan_512_pulses_bram0_data_in : out std_logic_vector(31 downto 0);
      chan_512_pulses_bram0_we : out std_logic;
      chan_512_pulses_bram1_data_out : in std_logic_vector(31 downto 0);
      chan_512_pulses_bram1_addr : out std_logic_vector(13 downto 0);
      chan_512_pulses_bram1_data_in : out std_logic_vector(31 downto 0);
      chan_512_pulses_bram1_we : out std_logic;
      chan_512_regs_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_seconds_user_data_in : out std_logic_vector(31 downto 0);
      chan_512_snapPhase_addr_user_data_in : out std_logic_vector(31 downto 0);
      chan_512_snapPhase_bram_data_out : in std_logic_vector(31 downto 0);
      chan_512_snapPhase_bram_addr : out std_logic_vector(9 downto 0);
      chan_512_snapPhase_bram_data_in : out std_logic_vector(31 downto 0);
      chan_512_snapPhase_bram_we : out std_logic;
      chan_512_snapPhase_ctrl_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_start_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_startAccumulator_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_startBuffer_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_startDAC_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_startSnap_user_data_out : in std_logic_vector(31 downto 0);
      chan_512_stb_en_user_data_out : in std_logic_vector(31 downto 0)
    );
  end component;

  component dram_infrastructure_inst_wrapper is
    port (
      reset : in std_logic;
      clk_in : in std_logic;
      clk_in_locked : in std_logic;
      clk_out : out std_logic;
      dram_clk_0 : out std_logic;
      dram_clk_90 : out std_logic;
      dram_clk_div : out std_logic;
      dram_rst_0 : out std_logic;
      dram_rst_90 : out std_logic;
      dram_rst_div : out std_logic
    );
  end component;

  component dram_controller_inst_wrapper is
    port (
      phy_rdy : out std_logic;
      cal_fail : out std_logic;
      clk0 : in std_logic;
      clk90 : in std_logic;
      clkdiv0 : in std_logic;
      rst0 : in std_logic;
      rst90 : in std_logic;
      rstdiv0 : in std_logic;
      app_cmd_addr : in std_logic_vector(31 downto 0);
      app_cmd_rnw : in std_logic;
      app_cmd_valid : in std_logic;
      app_wr_data : in std_logic_vector(143 downto 0);
      app_wr_be : in std_logic_vector(17 downto 0);
      app_rd_data : out std_logic_vector(143 downto 0);
      app_rd_valid : out std_logic;
      app_fifo_ready : out std_logic;
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
      dram_reset_n : out std_logic
    );
  end component;

  component opb_dram_sniffer_inst_wrapper is
    port (
      ctrl_OPB_Clk : in std_logic;
      ctrl_OPB_Rst : in std_logic;
      ctrl_Sl_DBus : out std_logic_vector(0 to 31);
      ctrl_Sl_errAck : out std_logic;
      ctrl_Sl_retry : out std_logic;
      ctrl_Sl_toutSup : out std_logic;
      ctrl_Sl_xferAck : out std_logic;
      ctrl_OPB_ABus : in std_logic_vector(0 to 31);
      ctrl_OPB_BE : in std_logic_vector(0 to 3);
      ctrl_OPB_DBus : in std_logic_vector(0 to 31);
      ctrl_OPB_RNW : in std_logic;
      ctrl_OPB_select : in std_logic;
      ctrl_OPB_seqAddr : in std_logic;
      mem_OPB_Clk : in std_logic;
      mem_OPB_Rst : in std_logic;
      mem_Sl_DBus : out std_logic_vector(0 to 31);
      mem_Sl_errAck : out std_logic;
      mem_Sl_retry : out std_logic;
      mem_Sl_toutSup : out std_logic;
      mem_Sl_xferAck : out std_logic;
      mem_OPB_ABus : in std_logic_vector(0 to 31);
      mem_OPB_BE : in std_logic_vector(0 to 3);
      mem_OPB_DBus : in std_logic_vector(0 to 31);
      mem_OPB_RNW : in std_logic;
      mem_OPB_select : in std_logic;
      mem_OPB_seqAddr : in std_logic;
      dram_clk : in std_logic;
      dram_rst : in std_logic;
      phy_ready : in std_logic;
      dram_cmd_addr : out std_logic_vector(31 downto 0);
      dram_cmd_rnw : out std_logic;
      dram_cmd_valid : out std_logic;
      dram_wr_data : out std_logic_vector(143 downto 0);
      dram_wr_be : out std_logic_vector(17 downto 0);
      dram_rd_data : in std_logic_vector(143 downto 0);
      dram_rd_valid : in std_logic;
      dram_fifo_ready : in std_logic;
      app_cmd_addr : in std_logic_vector(31 downto 0);
      app_cmd_rnw : in std_logic;
      app_cmd_valid : in std_logic;
      app_cmd_ack : out std_logic;
      app_wr_data : in std_logic_vector(143 downto 0);
      app_wr_be : in std_logic_vector(17 downto 0);
      app_rd_data : out std_logic_vector(143 downto 0);
      app_rd_valid : out std_logic
    );
  end component;

  component async_dram_1_wrapper is
    port (
      dram_clk : in std_logic;
      dram_reset : out std_logic;
      dram_address : out std_logic_vector(31 downto 0);
      dram_rnw : out std_logic;
      dram_cmd_en : out std_logic;
      dram_ready : in std_logic;
      dram_data_o : out std_logic_vector(143 downto 0);
      dram_byte_enable : out std_logic_vector(17 downto 0);
      dram_data_i : in std_logic_vector(143 downto 0);
      dram_data_valid : in std_logic;
      Mem_Clk : in std_logic;
      Mem_Rst : in std_logic;
      Mem_Cmd_Address : in std_logic_vector(31 downto 0);
      Mem_Cmd_RNW : in std_logic;
      Mem_Cmd_Valid : in std_logic;
      Mem_Cmd_Tag : in std_logic_vector(31 downto 0);
      Mem_Cmd_Ack : out std_logic;
      Mem_Rd_Dout : out std_logic_vector(143 downto 0);
      Mem_Rd_Tag : out std_logic_vector(31 downto 0);
      Mem_Rd_Ack : in std_logic;
      Mem_Rd_Valid : out std_logic;
      Mem_Wr_Din : in std_logic_vector(143 downto 0);
      Mem_Wr_BE : in std_logic_vector(17 downto 0)
    );
  end component;

  component chan_512_dram_lut_lut_size_wrapper is
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

  component chan_512_dram_lut_rd_valid_wrapper is
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

  component chan_512_fir_b0b1_wrapper is
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

  component chan_512_fir_b10b11_wrapper is
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

  component chan_512_fir_b12b13_wrapper is
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

  component chan_512_fir_b14b15_wrapper is
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

  component chan_512_fir_b16b17_wrapper is
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

  component chan_512_fir_b18b19_wrapper is
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

  component chan_512_fir_b20b21_wrapper is
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

  component chan_512_fir_b22b23_wrapper is
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

  component chan_512_fir_b24b25_wrapper is
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

  component chan_512_fir_b2b3_wrapper is
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

  component chan_512_fir_b4b5_wrapper is
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

  component chan_512_fir_b6b7_wrapper is
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

  component chan_512_fir_b8b9_wrapper is
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

  component chan_512_fir_load_coeff_wrapper is
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

  component chan_512_lo_sle_wrapper is
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

  component chan_512_ser_di_wrapper is
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

  component chan_512_swat_le_wrapper is
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

  component chan_512_adc_mkid_wrapper is
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

  component chan_512_avgiq_addr_wrapper is
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

  component chan_512_avgiq_bram_ramif_wrapper is
    port (
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 3);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 31);
      bram_dout : out std_logic_vector(0 to 31);
      clk_in : in std_logic;
      addr : in std_logic_vector(9 downto 0);
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(31 downto 0);
      we : in std_logic
    );
  end component;

  component chan_512_avgiq_bram_ramblk_wrapper is
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

  component chan_512_avgiq_bram_wrapper is
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

  component chan_512_avgiq_ctrl_wrapper is
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

  component chan_512_bins_wrapper is
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

  component chan_512_capture_load_thresh_wrapper is
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

  component chan_512_capture_threshold_wrapper is
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

  component chan_512_ch_we_wrapper is
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

  component chan_512_conv_phase_centers_wrapper is
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

  component chan_512_conv_phase_load_centers_wrapper is
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

  component chan_512_dac_mkid_wrapper is
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

  component chan_512_gpio_a0_wrapper is
    port (
      gateway : in std_logic_vector(0 to 0);
      io_pad : out std_logic_vector(0 to 0);
      clk : in std_logic;
      clk90 : in std_logic
    );
  end component;

  component chan_512_gpio_a1_wrapper is
    port (
      gateway : in std_logic_vector(0 to 0);
      io_pad : out std_logic_vector(0 to 0);
      clk : in std_logic;
      clk90 : in std_logic
    );
  end component;

  component chan_512_gpio_a2_wrapper is
    port (
      gateway : in std_logic_vector(0 to 0);
      io_pad : out std_logic_vector(0 to 0);
      clk : in std_logic;
      clk90 : in std_logic
    );
  end component;

  component chan_512_gpio_a3_wrapper is
    port (
      gateway : in std_logic_vector(0 to 0);
      io_pad : out std_logic_vector(0 to 0);
      clk : in std_logic;
      clk90 : in std_logic
    );
  end component;

  component chan_512_gpio_a5_wrapper is
    port (
      gateway : in std_logic_vector(0 to 0);
      io_pad : out std_logic_vector(0 to 0);
      clk : in std_logic;
      clk90 : in std_logic
    );
  end component;

  component chan_512_if_switch_wrapper is
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

  component chan_512_load_bins_wrapper is
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

  component chan_512_pulses_addr_wrapper is
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

  component chan_512_pulses_bram0_ramif_wrapper is
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

  component chan_512_pulses_bram0_ramblk_wrapper is
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

  component chan_512_pulses_bram0_wrapper is
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

  component chan_512_pulses_bram1_ramif_wrapper is
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

  component chan_512_pulses_bram1_ramblk_wrapper is
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

  component chan_512_pulses_bram1_wrapper is
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

  component chan_512_regs_wrapper is
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

  component chan_512_seconds_wrapper is
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

  component chan_512_snapphase_addr_wrapper is
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

  component chan_512_snapphase_bram_ramif_wrapper is
    port (
      bram_rst : out std_logic;
      bram_clk : out std_logic;
      bram_en : out std_logic;
      bram_wen : out std_logic_vector(0 to 3);
      bram_addr : out std_logic_vector(0 to 31);
      bram_din : in std_logic_vector(0 to 31);
      bram_dout : out std_logic_vector(0 to 31);
      clk_in : in std_logic;
      addr : in std_logic_vector(9 downto 0);
      data_in : in std_logic_vector(31 downto 0);
      data_out : out std_logic_vector(31 downto 0);
      we : in std_logic
    );
  end component;

  component chan_512_snapphase_bram_ramblk_wrapper is
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

  component chan_512_snapphase_bram_wrapper is
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

  component chan_512_snapphase_ctrl_wrapper is
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

  component chan_512_start_wrapper is
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

  component chan_512_startaccumulator_wrapper is
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

  component chan_512_startbuffer_wrapper is
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

  component chan_512_startdac_wrapper is
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

  component chan_512_startsnap_wrapper is
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

  component chan_512_stb_en_wrapper is
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

  component opb1_wrapper is
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
      Sl_beAck : in std_logic_vector(0 to 14);
      Sl_DBus : in std_logic_vector(0 to 479);
      Sl_DBusEn : in std_logic_vector(0 to 14);
      Sl_DBusEn32_63 : in std_logic_vector(0 to 14);
      Sl_errAck : in std_logic_vector(0 to 14);
      Sl_dwAck : in std_logic_vector(0 to 14);
      Sl_fwAck : in std_logic_vector(0 to 14);
      Sl_hwAck : in std_logic_vector(0 to 14);
      Sl_retry : in std_logic_vector(0 to 14);
      Sl_toutSup : in std_logic_vector(0 to 14);
      Sl_xferAck : in std_logic_vector(0 to 14);
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

  component opb2opb_bridge_opb1_wrapper is
    port (
      MOPB_Clk : in std_logic;
      SOPB_Clk : in std_logic;
      MOPB_Rst : in std_logic;
      SOPB_Rst : in std_logic;
      SOPB_ABus : in std_logic_vector(0 to 31);
      SOPB_BE : in std_logic_vector(0 to 3);
      SOPB_DBus : in std_logic_vector(0 to 31);
      SOPB_RNW : in std_logic;
      SOPB_select : in std_logic;
      SOPB_seqAddr : in std_logic;
      Sl_DBus : out std_logic_vector(0 to 31);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      M_ABus : out std_logic_vector(0 to 31);
      M_BE : out std_logic_vector(0 to 3);
      M_busLock : out std_logic;
      M_DBus : out std_logic_vector(0 to 31);
      M_request : out std_logic;
      M_RNW : out std_logic;
      M_select : out std_logic;
      M_seqAddr : out std_logic;
      MOPB_DBus : in std_logic_vector(0 to 31);
      MOPB_errAck : in std_logic;
      MOPB_MGrant : in std_logic;
      MOPB_retry : in std_logic;
      MOPB_timeout : in std_logic;
      MOPB_xferAck : in std_logic
    );
  end component;

  -- Internal signals

  signal adc1_clk : std_logic;
  signal adc1_clk90 : std_logic;
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Ack : std_logic;
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Address : std_logic_vector(31 downto 0);
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_RNW : std_logic;
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Tag : std_logic_vector(31 downto 0);
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Valid : std_logic;
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Ack : std_logic;
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Dout : std_logic_vector(143 downto 0);
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Tag : std_logic_vector(31 downto 0);
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Valid : std_logic;
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Wr_BE : std_logic_vector(17 downto 0);
  signal chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Wr_Din : std_logic_vector(143 downto 0);
  signal chan_512_DRAM_LUT_dram_Mem_Rst : std_logic;
  signal chan_512_DRAM_LUT_dram_phy_ready : std_logic;
  signal chan_512_DRAM_LUT_lut_size_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_DRAM_LUT_rd_valid_user_data_in : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b0b1_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b2b3_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b4b5_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b6b7_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b8b9_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b10b11_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b12b13_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b14b15_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b16b17_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b18b19_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b20b21_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b22b23_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_b24b25_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_FIR_load_coeff_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_LO_SLE_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_SER_DI_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_SWAT_LE_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_adc_mkid_user_data_i0 : std_logic_vector(11 downto 0);
  signal chan_512_adc_mkid_user_data_i1 : std_logic_vector(11 downto 0);
  signal chan_512_adc_mkid_user_data_q0 : std_logic_vector(11 downto 0);
  signal chan_512_adc_mkid_user_data_q1 : std_logic_vector(11 downto 0);
  signal chan_512_adc_mkid_user_sync : std_logic;
  signal chan_512_avgIQ_addr_user_data_in : std_logic_vector(31 downto 0);
  signal chan_512_avgIQ_bram_addr : std_logic_vector(9 downto 0);
  signal chan_512_avgIQ_bram_data_in : std_logic_vector(31 downto 0);
  signal chan_512_avgIQ_bram_data_out : std_logic_vector(31 downto 0);
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_Clk : std_logic;
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_EN : std_logic;
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_Rst : std_logic;
  signal chan_512_avgIQ_bram_ramblk_porta_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_Clk : std_logic;
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_EN : std_logic;
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_Rst : std_logic;
  signal chan_512_avgIQ_bram_ramblk_portb_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_avgIQ_bram_we : std_logic;
  signal chan_512_avgIQ_ctrl_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_bins_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_capture_load_thresh_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_capture_threshold_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_ch_we_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_conv_phase_centers_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_conv_phase_load_centers_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_dac_mkid_dac_data_i0 : std_logic_vector(15 downto 0);
  signal chan_512_dac_mkid_dac_data_i1 : std_logic_vector(15 downto 0);
  signal chan_512_dac_mkid_dac_data_q0 : std_logic_vector(15 downto 0);
  signal chan_512_dac_mkid_dac_data_q1 : std_logic_vector(15 downto 0);
  signal chan_512_dac_mkid_dac_sync_i : std_logic;
  signal chan_512_dac_mkid_dac_sync_q : std_logic;
  signal chan_512_dac_mkid_not_reset : std_logic;
  signal chan_512_dac_mkid_not_sdenb_i : std_logic;
  signal chan_512_dac_mkid_not_sdenb_q : std_logic;
  signal chan_512_dac_mkid_sclk : std_logic;
  signal chan_512_dac_mkid_sdi : std_logic;
  signal chan_512_gpio_a0_gateway : std_logic_vector(0 to 0);
  signal chan_512_gpio_a1_gateway : std_logic_vector(0 to 0);
  signal chan_512_gpio_a2_gateway : std_logic_vector(0 to 0);
  signal chan_512_gpio_a3_gateway : std_logic_vector(0 to 0);
  signal chan_512_gpio_a5_gateway : std_logic_vector(0 to 0);
  signal chan_512_if_switch_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_load_bins_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_pulses_addr_user_data_in : std_logic_vector(31 downto 0);
  signal chan_512_pulses_bram0_addr : std_logic_vector(13 downto 0);
  signal chan_512_pulses_bram0_data_in : std_logic_vector(31 downto 0);
  signal chan_512_pulses_bram0_data_out : std_logic_vector(31 downto 0);
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_Clk : std_logic;
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_EN : std_logic;
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_Rst : std_logic;
  signal chan_512_pulses_bram0_ramblk_porta_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_Clk : std_logic;
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_EN : std_logic;
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_Rst : std_logic;
  signal chan_512_pulses_bram0_ramblk_portb_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_pulses_bram0_we : std_logic;
  signal chan_512_pulses_bram1_addr : std_logic_vector(13 downto 0);
  signal chan_512_pulses_bram1_data_in : std_logic_vector(31 downto 0);
  signal chan_512_pulses_bram1_data_out : std_logic_vector(31 downto 0);
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_Clk : std_logic;
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_EN : std_logic;
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_Rst : std_logic;
  signal chan_512_pulses_bram1_ramblk_porta_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_Clk : std_logic;
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_EN : std_logic;
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_Rst : std_logic;
  signal chan_512_pulses_bram1_ramblk_portb_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_pulses_bram1_we : std_logic;
  signal chan_512_regs_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_seconds_user_data_in : std_logic_vector(31 downto 0);
  signal chan_512_snapPhase_addr_user_data_in : std_logic_vector(31 downto 0);
  signal chan_512_snapPhase_bram_addr : std_logic_vector(9 downto 0);
  signal chan_512_snapPhase_bram_data_in : std_logic_vector(31 downto 0);
  signal chan_512_snapPhase_bram_data_out : std_logic_vector(31 downto 0);
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_Clk : std_logic;
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_EN : std_logic;
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_Rst : std_logic;
  signal chan_512_snapPhase_bram_ramblk_porta_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_Addr : std_logic_vector(0 to 31);
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_Clk : std_logic;
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_Din : std_logic_vector(0 to 31);
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_Dout : std_logic_vector(0 to 31);
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_EN : std_logic;
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_Rst : std_logic;
  signal chan_512_snapPhase_bram_ramblk_portb_BRAM_WEN : std_logic_vector(0 to 3);
  signal chan_512_snapPhase_bram_we : std_logic;
  signal chan_512_snapPhase_ctrl_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_startAccumulator_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_startBuffer_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_startDAC_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_startSnap_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_start_user_data_out : std_logic_vector(31 downto 0);
  signal chan_512_stb_en_user_data_out : std_logic_vector(31 downto 0);
  signal dly_clk : std_logic;
  signal dram_ctrl_app_cmd_addr : std_logic_vector(31 downto 0);
  signal dram_ctrl_app_cmd_rnw : std_logic;
  signal dram_ctrl_app_cmd_valid : std_logic;
  signal dram_ctrl_app_fifo_ready : std_logic;
  signal dram_ctrl_app_rd_data : std_logic_vector(143 downto 0);
  signal dram_ctrl_app_rd_valid : std_logic;
  signal dram_ctrl_app_wr_be : std_logic_vector(17 downto 0);
  signal dram_ctrl_app_wr_data : std_logic_vector(143 downto 0);
  signal dram_sys_dram_clk_0 : std_logic;
  signal dram_sys_dram_clk_90 : std_logic;
  signal dram_sys_dram_clk_div : std_logic;
  signal dram_sys_dram_rst_0 : std_logic;
  signal dram_sys_dram_rst_90 : std_logic;
  signal dram_sys_dram_rst_div : std_logic;
  signal dram_user_clk : std_logic;
  signal dram_user_dimm1_async_app_cmd_ack : std_logic;
  signal dram_user_dimm1_async_app_cmd_addr : std_logic_vector(31 downto 0);
  signal dram_user_dimm1_async_app_cmd_rnw : std_logic;
  signal dram_user_dimm1_async_app_cmd_valid : std_logic;
  signal dram_user_dimm1_async_app_rd_data : std_logic_vector(143 downto 0);
  signal dram_user_dimm1_async_app_rd_valid : std_logic;
  signal dram_user_dimm1_async_app_wr_be : std_logic_vector(17 downto 0);
  signal dram_user_dimm1_async_app_wr_data : std_logic_vector(143 downto 0);
  signal dram_user_reset : std_logic;
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
  signal net_gnd15 : std_logic_vector(0 to 14);
  signal net_gnd33 : std_logic_vector(0 to 32);
  signal net_vcc1 : std_logic_vector(0 to 0);
  signal net_vcc15 : std_logic_vector(0 to 14);
  signal net_vcc33 : std_logic_vector(0 to 32);
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
  signal opb0_Sl_DBus : std_logic_vector(0 to 1055);
  signal opb0_Sl_errAck : std_logic_vector(0 to 32);
  signal opb0_Sl_retry : std_logic_vector(0 to 32);
  signal opb0_Sl_toutSup : std_logic_vector(0 to 32);
  signal opb0_Sl_xferAck : std_logic_vector(0 to 32);
  signal opb1_M_ABus : std_logic_vector(0 to 31);
  signal opb1_M_BE : std_logic_vector(0 to 3);
  signal opb1_M_DBus : std_logic_vector(0 to 31);
  signal opb1_M_RNW : std_logic_vector(0 to 0);
  signal opb1_M_busLock : std_logic_vector(0 to 0);
  signal opb1_M_request : std_logic_vector(0 to 0);
  signal opb1_M_select : std_logic_vector(0 to 0);
  signal opb1_M_seqAddr : std_logic_vector(0 to 0);
  signal opb1_OPB_ABus : std_logic_vector(0 to 31);
  signal opb1_OPB_BE : std_logic_vector(0 to 3);
  signal opb1_OPB_DBus : std_logic_vector(0 to 31);
  signal opb1_OPB_MGrant : std_logic_vector(0 to 0);
  signal opb1_OPB_RNW : std_logic;
  signal opb1_OPB_Rst : std_logic;
  signal opb1_OPB_errAck : std_logic;
  signal opb1_OPB_retry : std_logic;
  signal opb1_OPB_select : std_logic;
  signal opb1_OPB_seqAddr : std_logic;
  signal opb1_OPB_timeout : std_logic;
  signal opb1_OPB_xferAck : std_logic;
  signal opb1_Sl_DBus : std_logic_vector(0 to 479);
  signal opb1_Sl_errAck : std_logic_vector(0 to 14);
  signal opb1_Sl_retry : std_logic_vector(0 to 14);
  signal opb1_Sl_toutSup : std_logic_vector(0 to 14);
  signal opb1_Sl_xferAck : std_logic_vector(0 to 14);
  signal pgassign1 : std_logic;
  signal pgassign2 : std_logic_vector(15 downto 0);
  signal pgassign3 : std_logic;
  signal sys_reset : std_logic;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of infrastructure_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of reset_block_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of opb0_wrapper : component is "user_black_box";
  attribute BOX_TYPE of epb_opb_bridge_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of epb_infrastructure_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of sys_block_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_xsg_core_config_wrapper : component is "user_black_box";
  attribute BOX_TYPE of dram_infrastructure_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of dram_controller_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of opb_dram_sniffer_inst_wrapper : component is "user_black_box";
  attribute BOX_TYPE of async_dram_1_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_dram_lut_lut_size_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_dram_lut_rd_valid_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b0b1_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b10b11_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b12b13_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b14b15_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b16b17_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b18b19_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b20b21_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b22b23_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b24b25_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b2b3_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b4b5_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b6b7_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_b8b9_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_fir_load_coeff_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_lo_sle_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_ser_di_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_swat_le_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_adc_mkid_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_avgiq_addr_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_avgiq_bram_ramif_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_avgiq_bram_ramblk_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_avgiq_bram_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_avgiq_ctrl_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_bins_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_capture_load_thresh_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_capture_threshold_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_ch_we_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_conv_phase_centers_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_conv_phase_load_centers_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_dac_mkid_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_gpio_a0_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_gpio_a1_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_gpio_a2_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_gpio_a3_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_gpio_a5_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_if_switch_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_load_bins_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_addr_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_bram0_ramif_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_bram0_ramblk_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_bram0_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_bram1_ramif_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_bram1_ramblk_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_pulses_bram1_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_regs_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_seconds_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_snapphase_addr_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_snapphase_bram_ramif_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_snapphase_bram_ramblk_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_snapphase_bram_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_snapphase_ctrl_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_start_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_startaccumulator_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_startbuffer_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_startdac_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_startsnap_wrapper : component is "user_black_box";
  attribute BOX_TYPE of chan_512_stb_en_wrapper : component is "user_black_box";
  attribute BOX_TYPE of opb1_wrapper : component is "user_black_box";
  attribute BOX_TYPE of opb2opb_bridge_opb1_wrapper : component is "user_black_box";

begin

  -- Internal assignments

  pgassign1 <= '0';
  pgassign2(15 downto 0) <= X"0000";
  pgassign3 <= '1';
  net_gnd0 <= '0';
  net_gnd1(0 to 0) <= B"0";
  net_gnd15(0 to 14) <= B"000000000000000";
  net_gnd33(0 to 32) <= B"000000000000000000000000000000000";
  net_vcc1(0 to 0) <= B"1";
  net_vcc15(0 to 14) <= B"111111111111111";
  net_vcc33(0 to 32) <= B"111111111111111111111111111111111";

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
      dly_clk => dly_clk,
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
      Sl_beAck => net_gnd33,
      Sl_DBus => opb0_Sl_DBus,
      Sl_DBusEn => net_vcc33,
      Sl_DBusEn32_63 => net_vcc33,
      Sl_errAck => opb0_Sl_errAck,
      Sl_dwAck => net_gnd33,
      Sl_fwAck => net_gnd33,
      Sl_hwAck => net_gnd33,
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

  chan_512_XSG_core_config : chan_512_xsg_core_config_wrapper
    port map (
      clk => adc1_clk,
      chan_512_DRAM_LUT_dram_Mem_Cmd_Ack => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Ack,
      chan_512_DRAM_LUT_dram_Mem_Rd_Dout => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Dout,
      chan_512_DRAM_LUT_dram_Mem_Rd_Tag => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Tag,
      chan_512_DRAM_LUT_dram_Mem_Rd_Valid => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Valid,
      chan_512_DRAM_LUT_dram_phy_ready => chan_512_DRAM_LUT_dram_phy_ready,
      chan_512_DRAM_LUT_dram_Mem_Cmd_Address => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Address,
      chan_512_DRAM_LUT_dram_Mem_Cmd_RNW => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_RNW,
      chan_512_DRAM_LUT_dram_Mem_Cmd_Tag => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Tag,
      chan_512_DRAM_LUT_dram_Mem_Cmd_Valid => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Valid,
      chan_512_DRAM_LUT_dram_Mem_Rd_Ack => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Ack,
      chan_512_DRAM_LUT_dram_Mem_Rst => chan_512_DRAM_LUT_dram_Mem_Rst,
      chan_512_DRAM_LUT_dram_Mem_Wr_BE => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Wr_BE,
      chan_512_DRAM_LUT_dram_Mem_Wr_Din => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Wr_Din,
      chan_512_DRAM_LUT_lut_size_user_data_out => chan_512_DRAM_LUT_lut_size_user_data_out,
      chan_512_DRAM_LUT_rd_valid_user_data_in => chan_512_DRAM_LUT_rd_valid_user_data_in,
      chan_512_FIR_b0b1_user_data_out => chan_512_FIR_b0b1_user_data_out,
      chan_512_FIR_b10b11_user_data_out => chan_512_FIR_b10b11_user_data_out,
      chan_512_FIR_b12b13_user_data_out => chan_512_FIR_b12b13_user_data_out,
      chan_512_FIR_b14b15_user_data_out => chan_512_FIR_b14b15_user_data_out,
      chan_512_FIR_b16b17_user_data_out => chan_512_FIR_b16b17_user_data_out,
      chan_512_FIR_b18b19_user_data_out => chan_512_FIR_b18b19_user_data_out,
      chan_512_FIR_b20b21_user_data_out => chan_512_FIR_b20b21_user_data_out,
      chan_512_FIR_b22b23_user_data_out => chan_512_FIR_b22b23_user_data_out,
      chan_512_FIR_b24b25_user_data_out => chan_512_FIR_b24b25_user_data_out,
      chan_512_FIR_b2b3_user_data_out => chan_512_FIR_b2b3_user_data_out,
      chan_512_FIR_b4b5_user_data_out => chan_512_FIR_b4b5_user_data_out,
      chan_512_FIR_b6b7_user_data_out => chan_512_FIR_b6b7_user_data_out,
      chan_512_FIR_b8b9_user_data_out => chan_512_FIR_b8b9_user_data_out,
      chan_512_FIR_load_coeff_user_data_out => chan_512_FIR_load_coeff_user_data_out,
      chan_512_LO_SLE_user_data_out => chan_512_LO_SLE_user_data_out,
      chan_512_SER_DI_user_data_out => chan_512_SER_DI_user_data_out,
      chan_512_SWAT_LE_user_data_out => chan_512_SWAT_LE_user_data_out,
      chan_512_adc_mkid_user_data_i0 => chan_512_adc_mkid_user_data_i0,
      chan_512_adc_mkid_user_data_i1 => chan_512_adc_mkid_user_data_i1,
      chan_512_adc_mkid_user_data_q0 => chan_512_adc_mkid_user_data_q0,
      chan_512_adc_mkid_user_data_q1 => chan_512_adc_mkid_user_data_q1,
      chan_512_adc_mkid_user_sync => chan_512_adc_mkid_user_sync,
      chan_512_avgIQ_addr_user_data_in => chan_512_avgIQ_addr_user_data_in,
      chan_512_avgIQ_bram_data_out => chan_512_avgIQ_bram_data_out,
      chan_512_avgIQ_bram_addr => chan_512_avgIQ_bram_addr,
      chan_512_avgIQ_bram_data_in => chan_512_avgIQ_bram_data_in,
      chan_512_avgIQ_bram_we => chan_512_avgIQ_bram_we,
      chan_512_avgIQ_ctrl_user_data_out => chan_512_avgIQ_ctrl_user_data_out,
      chan_512_bins_user_data_out => chan_512_bins_user_data_out,
      chan_512_capture_load_thresh_user_data_out => chan_512_capture_load_thresh_user_data_out,
      chan_512_capture_threshold_user_data_out => chan_512_capture_threshold_user_data_out,
      chan_512_ch_we_user_data_out => chan_512_ch_we_user_data_out,
      chan_512_conv_phase_centers_user_data_out => chan_512_conv_phase_centers_user_data_out,
      chan_512_conv_phase_load_centers_user_data_out => chan_512_conv_phase_load_centers_user_data_out,
      chan_512_dac_mkid_dac_data_i0 => chan_512_dac_mkid_dac_data_i0,
      chan_512_dac_mkid_dac_data_i1 => chan_512_dac_mkid_dac_data_i1,
      chan_512_dac_mkid_dac_data_q0 => chan_512_dac_mkid_dac_data_q0,
      chan_512_dac_mkid_dac_data_q1 => chan_512_dac_mkid_dac_data_q1,
      chan_512_dac_mkid_dac_sync_i => chan_512_dac_mkid_dac_sync_i,
      chan_512_dac_mkid_dac_sync_q => chan_512_dac_mkid_dac_sync_q,
      chan_512_dac_mkid_not_reset => chan_512_dac_mkid_not_reset,
      chan_512_dac_mkid_not_sdenb_i => chan_512_dac_mkid_not_sdenb_i,
      chan_512_dac_mkid_not_sdenb_q => chan_512_dac_mkid_not_sdenb_q,
      chan_512_dac_mkid_sclk => chan_512_dac_mkid_sclk,
      chan_512_dac_mkid_sdi => chan_512_dac_mkid_sdi,
      chan_512_gpio_a0_gateway => chan_512_gpio_a0_gateway(0),
      chan_512_gpio_a1_gateway => chan_512_gpio_a1_gateway(0),
      chan_512_gpio_a2_gateway => chan_512_gpio_a2_gateway(0),
      chan_512_gpio_a3_gateway => chan_512_gpio_a3_gateway(0),
      chan_512_gpio_a5_gateway => chan_512_gpio_a5_gateway(0),
      chan_512_if_switch_user_data_out => chan_512_if_switch_user_data_out,
      chan_512_load_bins_user_data_out => chan_512_load_bins_user_data_out,
      chan_512_pulses_addr_user_data_in => chan_512_pulses_addr_user_data_in,
      chan_512_pulses_bram0_data_out => chan_512_pulses_bram0_data_out,
      chan_512_pulses_bram0_addr => chan_512_pulses_bram0_addr,
      chan_512_pulses_bram0_data_in => chan_512_pulses_bram0_data_in,
      chan_512_pulses_bram0_we => chan_512_pulses_bram0_we,
      chan_512_pulses_bram1_data_out => chan_512_pulses_bram1_data_out,
      chan_512_pulses_bram1_addr => chan_512_pulses_bram1_addr,
      chan_512_pulses_bram1_data_in => chan_512_pulses_bram1_data_in,
      chan_512_pulses_bram1_we => chan_512_pulses_bram1_we,
      chan_512_regs_user_data_out => chan_512_regs_user_data_out,
      chan_512_seconds_user_data_in => chan_512_seconds_user_data_in,
      chan_512_snapPhase_addr_user_data_in => chan_512_snapPhase_addr_user_data_in,
      chan_512_snapPhase_bram_data_out => chan_512_snapPhase_bram_data_out,
      chan_512_snapPhase_bram_addr => chan_512_snapPhase_bram_addr,
      chan_512_snapPhase_bram_data_in => chan_512_snapPhase_bram_data_in,
      chan_512_snapPhase_bram_we => chan_512_snapPhase_bram_we,
      chan_512_snapPhase_ctrl_user_data_out => chan_512_snapPhase_ctrl_user_data_out,
      chan_512_start_user_data_out => chan_512_start_user_data_out,
      chan_512_startAccumulator_user_data_out => chan_512_startAccumulator_user_data_out,
      chan_512_startBuffer_user_data_out => chan_512_startBuffer_user_data_out,
      chan_512_startDAC_user_data_out => chan_512_startDAC_user_data_out,
      chan_512_startSnap_user_data_out => chan_512_startSnap_user_data_out,
      chan_512_stb_en_user_data_out => chan_512_stb_en_user_data_out
    );

  dram_infrastructure_inst : dram_infrastructure_inst_wrapper
    port map (
      reset => sys_reset,
      clk_in => dly_clk,
      clk_in_locked => pgassign3,
      clk_out => dram_user_clk,
      dram_clk_0 => dram_sys_dram_clk_0,
      dram_clk_90 => dram_sys_dram_clk_90,
      dram_clk_div => dram_sys_dram_clk_div,
      dram_rst_0 => dram_sys_dram_rst_0,
      dram_rst_90 => dram_sys_dram_rst_90,
      dram_rst_div => dram_sys_dram_rst_div
    );

  dram_controller_inst : dram_controller_inst_wrapper
    port map (
      phy_rdy => chan_512_DRAM_LUT_dram_phy_ready,
      cal_fail => open,
      clk0 => dram_sys_dram_clk_0,
      clk90 => dram_sys_dram_clk_90,
      clkdiv0 => dram_sys_dram_clk_div,
      rst0 => dram_sys_dram_rst_0,
      rst90 => dram_sys_dram_rst_90,
      rstdiv0 => dram_sys_dram_rst_div,
      app_cmd_addr => dram_ctrl_app_cmd_addr,
      app_cmd_rnw => dram_ctrl_app_cmd_rnw,
      app_cmd_valid => dram_ctrl_app_cmd_valid,
      app_wr_data => dram_ctrl_app_wr_data,
      app_wr_be => dram_ctrl_app_wr_be,
      app_rd_data => dram_ctrl_app_rd_data,
      app_rd_valid => dram_ctrl_app_rd_valid,
      app_fifo_ready => dram_ctrl_app_fifo_ready,
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
      dram_reset_n => dram_reset_n
    );

  opb_dram_sniffer_inst : opb_dram_sniffer_inst_wrapper
    port map (
      ctrl_OPB_Clk => epb_clk,
      ctrl_OPB_Rst => opb0_OPB_Rst,
      ctrl_Sl_DBus => opb0_Sl_DBus(64 to 95),
      ctrl_Sl_errAck => opb0_Sl_errAck(2),
      ctrl_Sl_retry => opb0_Sl_retry(2),
      ctrl_Sl_toutSup => opb0_Sl_toutSup(2),
      ctrl_Sl_xferAck => opb0_Sl_xferAck(2),
      ctrl_OPB_ABus => opb0_OPB_ABus,
      ctrl_OPB_BE => opb0_OPB_BE,
      ctrl_OPB_DBus => opb0_OPB_DBus,
      ctrl_OPB_RNW => opb0_OPB_RNW,
      ctrl_OPB_select => opb0_OPB_select,
      ctrl_OPB_seqAddr => opb0_OPB_seqAddr,
      mem_OPB_Clk => epb_clk,
      mem_OPB_Rst => opb0_OPB_Rst,
      mem_Sl_DBus => opb0_Sl_DBus(32 to 63),
      mem_Sl_errAck => opb0_Sl_errAck(1),
      mem_Sl_retry => opb0_Sl_retry(1),
      mem_Sl_toutSup => opb0_Sl_toutSup(1),
      mem_Sl_xferAck => opb0_Sl_xferAck(1),
      mem_OPB_ABus => opb0_OPB_ABus,
      mem_OPB_BE => opb0_OPB_BE,
      mem_OPB_DBus => opb0_OPB_DBus,
      mem_OPB_RNW => opb0_OPB_RNW,
      mem_OPB_select => opb0_OPB_select,
      mem_OPB_seqAddr => opb0_OPB_seqAddr,
      dram_clk => dram_user_clk,
      dram_rst => dram_user_reset,
      phy_ready => chan_512_DRAM_LUT_dram_phy_ready,
      dram_cmd_addr => dram_ctrl_app_cmd_addr,
      dram_cmd_rnw => dram_ctrl_app_cmd_rnw,
      dram_cmd_valid => dram_ctrl_app_cmd_valid,
      dram_wr_data => dram_ctrl_app_wr_data,
      dram_wr_be => dram_ctrl_app_wr_be,
      dram_rd_data => dram_ctrl_app_rd_data,
      dram_rd_valid => dram_ctrl_app_rd_valid,
      dram_fifo_ready => dram_ctrl_app_fifo_ready,
      app_cmd_addr => dram_user_dimm1_async_app_cmd_addr,
      app_cmd_rnw => dram_user_dimm1_async_app_cmd_rnw,
      app_cmd_valid => dram_user_dimm1_async_app_cmd_valid,
      app_cmd_ack => dram_user_dimm1_async_app_cmd_ack,
      app_wr_data => dram_user_dimm1_async_app_wr_data,
      app_wr_be => dram_user_dimm1_async_app_wr_be,
      app_rd_data => dram_user_dimm1_async_app_rd_data,
      app_rd_valid => dram_user_dimm1_async_app_rd_valid
    );

  async_dram_1 : async_dram_1_wrapper
    port map (
      dram_clk => dram_user_clk,
      dram_reset => dram_user_reset,
      dram_address => dram_user_dimm1_async_app_cmd_addr,
      dram_rnw => dram_user_dimm1_async_app_cmd_rnw,
      dram_cmd_en => dram_user_dimm1_async_app_cmd_valid,
      dram_ready => dram_user_dimm1_async_app_cmd_ack,
      dram_data_o => dram_user_dimm1_async_app_wr_data,
      dram_byte_enable => dram_user_dimm1_async_app_wr_be,
      dram_data_i => dram_user_dimm1_async_app_rd_data,
      dram_data_valid => dram_user_dimm1_async_app_rd_valid,
      Mem_Clk => adc1_clk,
      Mem_Rst => chan_512_DRAM_LUT_dram_Mem_Rst,
      Mem_Cmd_Address => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Address,
      Mem_Cmd_RNW => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_RNW,
      Mem_Cmd_Valid => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Valid,
      Mem_Cmd_Tag => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Tag,
      Mem_Cmd_Ack => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Cmd_Ack,
      Mem_Rd_Dout => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Dout,
      Mem_Rd_Tag => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Tag,
      Mem_Rd_Ack => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Ack,
      Mem_Rd_Valid => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Rd_Valid,
      Mem_Wr_Din => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Wr_Din,
      Mem_Wr_BE => chan_512_DRAM_LUT_dram_MEM_CMD_Mem_Wr_BE
    );

  chan_512_DRAM_LUT_lut_size : chan_512_dram_lut_lut_size_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(96 to 127),
      Sl_errAck => opb0_Sl_errAck(3),
      Sl_retry => opb0_Sl_retry(3),
      Sl_toutSup => opb0_Sl_toutSup(3),
      Sl_xferAck => opb0_Sl_xferAck(3),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_DRAM_LUT_lut_size_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_DRAM_LUT_rd_valid : chan_512_dram_lut_rd_valid_wrapper
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
      user_data_in => chan_512_DRAM_LUT_rd_valid_user_data_in,
      user_clk => adc1_clk
    );

  chan_512_FIR_b0b1 : chan_512_fir_b0b1_wrapper
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
      user_data_out => chan_512_FIR_b0b1_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b10b11 : chan_512_fir_b10b11_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(192 to 223),
      Sl_errAck => opb0_Sl_errAck(6),
      Sl_retry => opb0_Sl_retry(6),
      Sl_toutSup => opb0_Sl_toutSup(6),
      Sl_xferAck => opb0_Sl_xferAck(6),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b10b11_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b12b13 : chan_512_fir_b12b13_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(224 to 255),
      Sl_errAck => opb0_Sl_errAck(7),
      Sl_retry => opb0_Sl_retry(7),
      Sl_toutSup => opb0_Sl_toutSup(7),
      Sl_xferAck => opb0_Sl_xferAck(7),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b12b13_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b14b15 : chan_512_fir_b14b15_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(256 to 287),
      Sl_errAck => opb0_Sl_errAck(8),
      Sl_retry => opb0_Sl_retry(8),
      Sl_toutSup => opb0_Sl_toutSup(8),
      Sl_xferAck => opb0_Sl_xferAck(8),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b14b15_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b16b17 : chan_512_fir_b16b17_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(288 to 319),
      Sl_errAck => opb0_Sl_errAck(9),
      Sl_retry => opb0_Sl_retry(9),
      Sl_toutSup => opb0_Sl_toutSup(9),
      Sl_xferAck => opb0_Sl_xferAck(9),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b16b17_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b18b19 : chan_512_fir_b18b19_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(320 to 351),
      Sl_errAck => opb0_Sl_errAck(10),
      Sl_retry => opb0_Sl_retry(10),
      Sl_toutSup => opb0_Sl_toutSup(10),
      Sl_xferAck => opb0_Sl_xferAck(10),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b18b19_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b20b21 : chan_512_fir_b20b21_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(352 to 383),
      Sl_errAck => opb0_Sl_errAck(11),
      Sl_retry => opb0_Sl_retry(11),
      Sl_toutSup => opb0_Sl_toutSup(11),
      Sl_xferAck => opb0_Sl_xferAck(11),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b20b21_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b22b23 : chan_512_fir_b22b23_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(384 to 415),
      Sl_errAck => opb0_Sl_errAck(12),
      Sl_retry => opb0_Sl_retry(12),
      Sl_toutSup => opb0_Sl_toutSup(12),
      Sl_xferAck => opb0_Sl_xferAck(12),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b22b23_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b24b25 : chan_512_fir_b24b25_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(416 to 447),
      Sl_errAck => opb0_Sl_errAck(13),
      Sl_retry => opb0_Sl_retry(13),
      Sl_toutSup => opb0_Sl_toutSup(13),
      Sl_xferAck => opb0_Sl_xferAck(13),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b24b25_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b2b3 : chan_512_fir_b2b3_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(448 to 479),
      Sl_errAck => opb0_Sl_errAck(14),
      Sl_retry => opb0_Sl_retry(14),
      Sl_toutSup => opb0_Sl_toutSup(14),
      Sl_xferAck => opb0_Sl_xferAck(14),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b2b3_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b4b5 : chan_512_fir_b4b5_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(480 to 511),
      Sl_errAck => opb0_Sl_errAck(15),
      Sl_retry => opb0_Sl_retry(15),
      Sl_toutSup => opb0_Sl_toutSup(15),
      Sl_xferAck => opb0_Sl_xferAck(15),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b4b5_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b6b7 : chan_512_fir_b6b7_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(512 to 543),
      Sl_errAck => opb0_Sl_errAck(16),
      Sl_retry => opb0_Sl_retry(16),
      Sl_toutSup => opb0_Sl_toutSup(16),
      Sl_xferAck => opb0_Sl_xferAck(16),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b6b7_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_b8b9 : chan_512_fir_b8b9_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(544 to 575),
      Sl_errAck => opb0_Sl_errAck(17),
      Sl_retry => opb0_Sl_retry(17),
      Sl_toutSup => opb0_Sl_toutSup(17),
      Sl_xferAck => opb0_Sl_xferAck(17),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_b8b9_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_FIR_load_coeff : chan_512_fir_load_coeff_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(576 to 607),
      Sl_errAck => opb0_Sl_errAck(18),
      Sl_retry => opb0_Sl_retry(18),
      Sl_toutSup => opb0_Sl_toutSup(18),
      Sl_xferAck => opb0_Sl_xferAck(18),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_FIR_load_coeff_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_LO_SLE : chan_512_lo_sle_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(608 to 639),
      Sl_errAck => opb0_Sl_errAck(19),
      Sl_retry => opb0_Sl_retry(19),
      Sl_toutSup => opb0_Sl_toutSup(19),
      Sl_xferAck => opb0_Sl_xferAck(19),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_LO_SLE_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_SER_DI : chan_512_ser_di_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(640 to 671),
      Sl_errAck => opb0_Sl_errAck(20),
      Sl_retry => opb0_Sl_retry(20),
      Sl_toutSup => opb0_Sl_toutSup(20),
      Sl_xferAck => opb0_Sl_xferAck(20),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_SER_DI_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_SWAT_LE : chan_512_swat_le_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(672 to 703),
      Sl_errAck => opb0_Sl_errAck(21),
      Sl_retry => opb0_Sl_retry(21),
      Sl_toutSup => opb0_Sl_toutSup(21),
      Sl_xferAck => opb0_Sl_xferAck(21),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_SWAT_LE_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_adc_mkid : chan_512_adc_mkid_wrapper
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
      adc_clk90_out => adc1_clk90,
      adc_clk180_out => open,
      adc_clk270_out => open,
      adc_dcm_locked => open,
      user_data_i0 => chan_512_adc_mkid_user_data_i0,
      user_data_i1 => chan_512_adc_mkid_user_data_i1,
      user_data_q0 => chan_512_adc_mkid_user_data_q0,
      user_data_q1 => chan_512_adc_mkid_user_data_q1,
      user_sync => chan_512_adc_mkid_user_sync
    );

  chan_512_avgIQ_addr : chan_512_avgiq_addr_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(704 to 735),
      Sl_errAck => opb0_Sl_errAck(22),
      Sl_retry => opb0_Sl_retry(22),
      Sl_toutSup => opb0_Sl_toutSup(22),
      Sl_xferAck => opb0_Sl_xferAck(22),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_in => chan_512_avgIQ_addr_user_data_in,
      user_clk => adc1_clk
    );

  chan_512_avgIQ_bram_ramif : chan_512_avgiq_bram_ramif_wrapper
    port map (
      bram_rst => chan_512_avgIQ_bram_ramblk_porta_BRAM_Rst,
      bram_clk => chan_512_avgIQ_bram_ramblk_porta_BRAM_Clk,
      bram_en => chan_512_avgIQ_bram_ramblk_porta_BRAM_EN,
      bram_wen => chan_512_avgIQ_bram_ramblk_porta_BRAM_WEN,
      bram_addr => chan_512_avgIQ_bram_ramblk_porta_BRAM_Addr,
      bram_din => chan_512_avgIQ_bram_ramblk_porta_BRAM_Din,
      bram_dout => chan_512_avgIQ_bram_ramblk_porta_BRAM_Dout,
      clk_in => adc1_clk,
      addr => chan_512_avgIQ_bram_addr,
      data_in => chan_512_avgIQ_bram_data_in,
      data_out => chan_512_avgIQ_bram_data_out,
      we => chan_512_avgIQ_bram_we
    );

  chan_512_avgiq_bram_ramblk : chan_512_avgiq_bram_ramblk_wrapper
    port map (
      BRAM_Rst_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_Rst,
      BRAM_Clk_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_Clk,
      BRAM_EN_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_EN,
      BRAM_WEN_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_WEN,
      BRAM_Addr_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_Addr,
      BRAM_Din_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_Din,
      BRAM_Dout_A => chan_512_avgIQ_bram_ramblk_porta_BRAM_Dout,
      BRAM_Rst_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_Rst,
      BRAM_Clk_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_Clk,
      BRAM_EN_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_EN,
      BRAM_WEN_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_WEN,
      BRAM_Addr_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_Addr,
      BRAM_Din_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_Din,
      BRAM_Dout_B => chan_512_avgIQ_bram_ramblk_portb_BRAM_Dout
    );

  chan_512_avgIQ_bram : chan_512_avgiq_bram_wrapper
    port map (
      opb_clk => epb_clk,
      opb_rst => opb0_OPB_Rst,
      opb_abus => opb0_OPB_ABus,
      opb_dbus => opb0_OPB_DBus,
      sln_dbus => opb0_Sl_DBus(736 to 767),
      opb_select => opb0_OPB_select,
      opb_rnw => opb0_OPB_RNW,
      opb_seqaddr => opb0_OPB_seqAddr,
      opb_be => opb0_OPB_BE,
      sln_xferack => opb0_Sl_xferAck(23),
      sln_errack => opb0_Sl_errAck(23),
      sln_toutsup => opb0_Sl_toutSup(23),
      sln_retry => opb0_Sl_retry(23),
      bram_rst => chan_512_avgIQ_bram_ramblk_portb_BRAM_Rst,
      bram_clk => chan_512_avgIQ_bram_ramblk_portb_BRAM_Clk,
      bram_en => chan_512_avgIQ_bram_ramblk_portb_BRAM_EN,
      bram_wen => chan_512_avgIQ_bram_ramblk_portb_BRAM_WEN,
      bram_addr => chan_512_avgIQ_bram_ramblk_portb_BRAM_Addr,
      bram_din => chan_512_avgIQ_bram_ramblk_portb_BRAM_Din,
      bram_dout => chan_512_avgIQ_bram_ramblk_portb_BRAM_Dout
    );

  chan_512_avgIQ_ctrl : chan_512_avgiq_ctrl_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(768 to 799),
      Sl_errAck => opb0_Sl_errAck(24),
      Sl_retry => opb0_Sl_retry(24),
      Sl_toutSup => opb0_Sl_toutSup(24),
      Sl_xferAck => opb0_Sl_xferAck(24),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_avgIQ_ctrl_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_bins : chan_512_bins_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(800 to 831),
      Sl_errAck => opb0_Sl_errAck(25),
      Sl_retry => opb0_Sl_retry(25),
      Sl_toutSup => opb0_Sl_toutSup(25),
      Sl_xferAck => opb0_Sl_xferAck(25),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_bins_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_capture_load_thresh : chan_512_capture_load_thresh_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(832 to 863),
      Sl_errAck => opb0_Sl_errAck(26),
      Sl_retry => opb0_Sl_retry(26),
      Sl_toutSup => opb0_Sl_toutSup(26),
      Sl_xferAck => opb0_Sl_xferAck(26),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_capture_load_thresh_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_capture_threshold : chan_512_capture_threshold_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(864 to 895),
      Sl_errAck => opb0_Sl_errAck(27),
      Sl_retry => opb0_Sl_retry(27),
      Sl_toutSup => opb0_Sl_toutSup(27),
      Sl_xferAck => opb0_Sl_xferAck(27),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_capture_threshold_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_ch_we : chan_512_ch_we_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(896 to 927),
      Sl_errAck => opb0_Sl_errAck(28),
      Sl_retry => opb0_Sl_retry(28),
      Sl_toutSup => opb0_Sl_toutSup(28),
      Sl_xferAck => opb0_Sl_xferAck(28),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_ch_we_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_conv_phase_centers : chan_512_conv_phase_centers_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(928 to 959),
      Sl_errAck => opb0_Sl_errAck(29),
      Sl_retry => opb0_Sl_retry(29),
      Sl_toutSup => opb0_Sl_toutSup(29),
      Sl_xferAck => opb0_Sl_xferAck(29),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_conv_phase_centers_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_conv_phase_load_centers : chan_512_conv_phase_load_centers_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(960 to 991),
      Sl_errAck => opb0_Sl_errAck(30),
      Sl_retry => opb0_Sl_retry(30),
      Sl_toutSup => opb0_Sl_toutSup(30),
      Sl_xferAck => opb0_Sl_xferAck(30),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_conv_phase_load_centers_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_dac_mkid : chan_512_dac_mkid_wrapper
    port map (
      dac_clk_p => dac0_clk_p,
      dac_clk_n => dac0_clk_n,
      dac_smpl_clk_i_p => dac0_smpl_clk_i_p,
      dac_smpl_clk_i_n => dac0_smpl_clk_i_n,
      dac_smpl_clk_q_p => dac0_smpl_clk_q_p,
      dac_smpl_clk_q_n => dac0_smpl_clk_q_n,
      dac_sync_i_p => dac0_sync_i_p,
      dac_sync_i_n => dac0_sync_i_n,
      dac_sync_q_p => dac0_sync_q_p,
      dac_sync_q_n => dac0_sync_q_n,
      dac_data_i_p => dac0_data_i_p,
      dac_data_i_n => dac0_data_i_n,
      dac_data_q_p => dac0_data_q_p,
      dac_data_q_n => dac0_data_q_n,
      dac_not_sdenb_i => dac0_not_sdenb_i,
      dac_not_sdenb_q => dac0_not_sdenb_q,
      dac_sclk => dac0_sclk,
      dac_sdi => dac0_sdi,
      dac_not_reset => dac0_not_reset,
      dac_data_i0 => chan_512_dac_mkid_dac_data_i0,
      dac_data_i1 => chan_512_dac_mkid_dac_data_i1,
      dac_data_q0 => chan_512_dac_mkid_dac_data_q0,
      dac_data_q1 => chan_512_dac_mkid_dac_data_q1,
      dac_sync_i => chan_512_dac_mkid_dac_sync_i,
      dac_sync_q => chan_512_dac_mkid_dac_sync_q,
      dac_smpl_clk => adc1_clk,
      not_sdenb_i => chan_512_dac_mkid_not_sdenb_i,
      not_sdenb_q => chan_512_dac_mkid_not_sdenb_q,
      sclk => chan_512_dac_mkid_sclk,
      sdi => chan_512_dac_mkid_sdi,
      not_reset => chan_512_dac_mkid_not_reset,
      dac_clk_out => open,
      dac_clk90_out => open,
      dac_clk180_out => open,
      dac_clk270_out => open,
      dac_dcm_locked => open
    );

  chan_512_gpio_a0 : chan_512_gpio_a0_wrapper
    port map (
      gateway => chan_512_gpio_a0_gateway(0 to 0),
      io_pad => chan_512_gpio_a0_ext(0 to 0),
      clk => adc1_clk,
      clk90 => adc1_clk90
    );

  chan_512_gpio_a1 : chan_512_gpio_a1_wrapper
    port map (
      gateway => chan_512_gpio_a1_gateway(0 to 0),
      io_pad => chan_512_gpio_a1_ext(0 to 0),
      clk => adc1_clk,
      clk90 => adc1_clk90
    );

  chan_512_gpio_a2 : chan_512_gpio_a2_wrapper
    port map (
      gateway => chan_512_gpio_a2_gateway(0 to 0),
      io_pad => chan_512_gpio_a2_ext(0 to 0),
      clk => adc1_clk,
      clk90 => adc1_clk90
    );

  chan_512_gpio_a3 : chan_512_gpio_a3_wrapper
    port map (
      gateway => chan_512_gpio_a3_gateway(0 to 0),
      io_pad => chan_512_gpio_a3_ext(0 to 0),
      clk => adc1_clk,
      clk90 => adc1_clk90
    );

  chan_512_gpio_a5 : chan_512_gpio_a5_wrapper
    port map (
      gateway => chan_512_gpio_a5_gateway(0 to 0),
      io_pad => chan_512_gpio_a5_ext(0 to 0),
      clk => adc1_clk,
      clk90 => adc1_clk90
    );

  chan_512_if_switch : chan_512_if_switch_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb0_OPB_Rst,
      Sl_DBus => opb0_Sl_DBus(992 to 1023),
      Sl_errAck => opb0_Sl_errAck(31),
      Sl_retry => opb0_Sl_retry(31),
      Sl_toutSup => opb0_Sl_toutSup(31),
      Sl_xferAck => opb0_Sl_xferAck(31),
      OPB_ABus => opb0_OPB_ABus,
      OPB_BE => opb0_OPB_BE,
      OPB_DBus => opb0_OPB_DBus,
      OPB_RNW => opb0_OPB_RNW,
      OPB_select => opb0_OPB_select,
      OPB_seqAddr => opb0_OPB_seqAddr,
      user_data_out => chan_512_if_switch_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_load_bins : chan_512_load_bins_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(0 to 31),
      Sl_errAck => opb1_Sl_errAck(0),
      Sl_retry => opb1_Sl_retry(0),
      Sl_toutSup => opb1_Sl_toutSup(0),
      Sl_xferAck => opb1_Sl_xferAck(0),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_load_bins_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_pulses_addr : chan_512_pulses_addr_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(32 to 63),
      Sl_errAck => opb1_Sl_errAck(1),
      Sl_retry => opb1_Sl_retry(1),
      Sl_toutSup => opb1_Sl_toutSup(1),
      Sl_xferAck => opb1_Sl_xferAck(1),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_in => chan_512_pulses_addr_user_data_in,
      user_clk => adc1_clk
    );

  chan_512_pulses_bram0_ramif : chan_512_pulses_bram0_ramif_wrapper
    port map (
      bram_rst => chan_512_pulses_bram0_ramblk_porta_BRAM_Rst,
      bram_clk => chan_512_pulses_bram0_ramblk_porta_BRAM_Clk,
      bram_en => chan_512_pulses_bram0_ramblk_porta_BRAM_EN,
      bram_wen => chan_512_pulses_bram0_ramblk_porta_BRAM_WEN,
      bram_addr => chan_512_pulses_bram0_ramblk_porta_BRAM_Addr,
      bram_din => chan_512_pulses_bram0_ramblk_porta_BRAM_Din,
      bram_dout => chan_512_pulses_bram0_ramblk_porta_BRAM_Dout,
      clk_in => adc1_clk,
      addr => chan_512_pulses_bram0_addr,
      data_in => chan_512_pulses_bram0_data_in,
      data_out => chan_512_pulses_bram0_data_out,
      we => chan_512_pulses_bram0_we
    );

  chan_512_pulses_bram0_ramblk : chan_512_pulses_bram0_ramblk_wrapper
    port map (
      BRAM_Rst_A => chan_512_pulses_bram0_ramblk_porta_BRAM_Rst,
      BRAM_Clk_A => chan_512_pulses_bram0_ramblk_porta_BRAM_Clk,
      BRAM_EN_A => chan_512_pulses_bram0_ramblk_porta_BRAM_EN,
      BRAM_WEN_A => chan_512_pulses_bram0_ramblk_porta_BRAM_WEN,
      BRAM_Addr_A => chan_512_pulses_bram0_ramblk_porta_BRAM_Addr,
      BRAM_Din_A => chan_512_pulses_bram0_ramblk_porta_BRAM_Din,
      BRAM_Dout_A => chan_512_pulses_bram0_ramblk_porta_BRAM_Dout,
      BRAM_Rst_B => chan_512_pulses_bram0_ramblk_portb_BRAM_Rst,
      BRAM_Clk_B => chan_512_pulses_bram0_ramblk_portb_BRAM_Clk,
      BRAM_EN_B => chan_512_pulses_bram0_ramblk_portb_BRAM_EN,
      BRAM_WEN_B => chan_512_pulses_bram0_ramblk_portb_BRAM_WEN,
      BRAM_Addr_B => chan_512_pulses_bram0_ramblk_portb_BRAM_Addr,
      BRAM_Din_B => chan_512_pulses_bram0_ramblk_portb_BRAM_Din,
      BRAM_Dout_B => chan_512_pulses_bram0_ramblk_portb_BRAM_Dout
    );

  chan_512_pulses_bram0 : chan_512_pulses_bram0_wrapper
    port map (
      opb_clk => epb_clk,
      opb_rst => opb1_OPB_Rst,
      opb_abus => opb1_OPB_ABus,
      opb_dbus => opb1_OPB_DBus,
      sln_dbus => opb1_Sl_DBus(64 to 95),
      opb_select => opb1_OPB_select,
      opb_rnw => opb1_OPB_RNW,
      opb_seqaddr => opb1_OPB_seqAddr,
      opb_be => opb1_OPB_BE,
      sln_xferack => opb1_Sl_xferAck(2),
      sln_errack => opb1_Sl_errAck(2),
      sln_toutsup => opb1_Sl_toutSup(2),
      sln_retry => opb1_Sl_retry(2),
      bram_rst => chan_512_pulses_bram0_ramblk_portb_BRAM_Rst,
      bram_clk => chan_512_pulses_bram0_ramblk_portb_BRAM_Clk,
      bram_en => chan_512_pulses_bram0_ramblk_portb_BRAM_EN,
      bram_wen => chan_512_pulses_bram0_ramblk_portb_BRAM_WEN,
      bram_addr => chan_512_pulses_bram0_ramblk_portb_BRAM_Addr,
      bram_din => chan_512_pulses_bram0_ramblk_portb_BRAM_Din,
      bram_dout => chan_512_pulses_bram0_ramblk_portb_BRAM_Dout
    );

  chan_512_pulses_bram1_ramif : chan_512_pulses_bram1_ramif_wrapper
    port map (
      bram_rst => chan_512_pulses_bram1_ramblk_porta_BRAM_Rst,
      bram_clk => chan_512_pulses_bram1_ramblk_porta_BRAM_Clk,
      bram_en => chan_512_pulses_bram1_ramblk_porta_BRAM_EN,
      bram_wen => chan_512_pulses_bram1_ramblk_porta_BRAM_WEN,
      bram_addr => chan_512_pulses_bram1_ramblk_porta_BRAM_Addr,
      bram_din => chan_512_pulses_bram1_ramblk_porta_BRAM_Din,
      bram_dout => chan_512_pulses_bram1_ramblk_porta_BRAM_Dout,
      clk_in => adc1_clk,
      addr => chan_512_pulses_bram1_addr,
      data_in => chan_512_pulses_bram1_data_in,
      data_out => chan_512_pulses_bram1_data_out,
      we => chan_512_pulses_bram1_we
    );

  chan_512_pulses_bram1_ramblk : chan_512_pulses_bram1_ramblk_wrapper
    port map (
      BRAM_Rst_A => chan_512_pulses_bram1_ramblk_porta_BRAM_Rst,
      BRAM_Clk_A => chan_512_pulses_bram1_ramblk_porta_BRAM_Clk,
      BRAM_EN_A => chan_512_pulses_bram1_ramblk_porta_BRAM_EN,
      BRAM_WEN_A => chan_512_pulses_bram1_ramblk_porta_BRAM_WEN,
      BRAM_Addr_A => chan_512_pulses_bram1_ramblk_porta_BRAM_Addr,
      BRAM_Din_A => chan_512_pulses_bram1_ramblk_porta_BRAM_Din,
      BRAM_Dout_A => chan_512_pulses_bram1_ramblk_porta_BRAM_Dout,
      BRAM_Rst_B => chan_512_pulses_bram1_ramblk_portb_BRAM_Rst,
      BRAM_Clk_B => chan_512_pulses_bram1_ramblk_portb_BRAM_Clk,
      BRAM_EN_B => chan_512_pulses_bram1_ramblk_portb_BRAM_EN,
      BRAM_WEN_B => chan_512_pulses_bram1_ramblk_portb_BRAM_WEN,
      BRAM_Addr_B => chan_512_pulses_bram1_ramblk_portb_BRAM_Addr,
      BRAM_Din_B => chan_512_pulses_bram1_ramblk_portb_BRAM_Din,
      BRAM_Dout_B => chan_512_pulses_bram1_ramblk_portb_BRAM_Dout
    );

  chan_512_pulses_bram1 : chan_512_pulses_bram1_wrapper
    port map (
      opb_clk => epb_clk,
      opb_rst => opb1_OPB_Rst,
      opb_abus => opb1_OPB_ABus,
      opb_dbus => opb1_OPB_DBus,
      sln_dbus => opb1_Sl_DBus(96 to 127),
      opb_select => opb1_OPB_select,
      opb_rnw => opb1_OPB_RNW,
      opb_seqaddr => opb1_OPB_seqAddr,
      opb_be => opb1_OPB_BE,
      sln_xferack => opb1_Sl_xferAck(3),
      sln_errack => opb1_Sl_errAck(3),
      sln_toutsup => opb1_Sl_toutSup(3),
      sln_retry => opb1_Sl_retry(3),
      bram_rst => chan_512_pulses_bram1_ramblk_portb_BRAM_Rst,
      bram_clk => chan_512_pulses_bram1_ramblk_portb_BRAM_Clk,
      bram_en => chan_512_pulses_bram1_ramblk_portb_BRAM_EN,
      bram_wen => chan_512_pulses_bram1_ramblk_portb_BRAM_WEN,
      bram_addr => chan_512_pulses_bram1_ramblk_portb_BRAM_Addr,
      bram_din => chan_512_pulses_bram1_ramblk_portb_BRAM_Din,
      bram_dout => chan_512_pulses_bram1_ramblk_portb_BRAM_Dout
    );

  chan_512_regs : chan_512_regs_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(128 to 159),
      Sl_errAck => opb1_Sl_errAck(4),
      Sl_retry => opb1_Sl_retry(4),
      Sl_toutSup => opb1_Sl_toutSup(4),
      Sl_xferAck => opb1_Sl_xferAck(4),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_regs_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_seconds : chan_512_seconds_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(160 to 191),
      Sl_errAck => opb1_Sl_errAck(5),
      Sl_retry => opb1_Sl_retry(5),
      Sl_toutSup => opb1_Sl_toutSup(5),
      Sl_xferAck => opb1_Sl_xferAck(5),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_in => chan_512_seconds_user_data_in,
      user_clk => adc1_clk
    );

  chan_512_snapPhase_addr : chan_512_snapphase_addr_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(192 to 223),
      Sl_errAck => opb1_Sl_errAck(6),
      Sl_retry => opb1_Sl_retry(6),
      Sl_toutSup => opb1_Sl_toutSup(6),
      Sl_xferAck => opb1_Sl_xferAck(6),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_in => chan_512_snapPhase_addr_user_data_in,
      user_clk => adc1_clk
    );

  chan_512_snapPhase_bram_ramif : chan_512_snapphase_bram_ramif_wrapper
    port map (
      bram_rst => chan_512_snapPhase_bram_ramblk_porta_BRAM_Rst,
      bram_clk => chan_512_snapPhase_bram_ramblk_porta_BRAM_Clk,
      bram_en => chan_512_snapPhase_bram_ramblk_porta_BRAM_EN,
      bram_wen => chan_512_snapPhase_bram_ramblk_porta_BRAM_WEN,
      bram_addr => chan_512_snapPhase_bram_ramblk_porta_BRAM_Addr,
      bram_din => chan_512_snapPhase_bram_ramblk_porta_BRAM_Din,
      bram_dout => chan_512_snapPhase_bram_ramblk_porta_BRAM_Dout,
      clk_in => adc1_clk,
      addr => chan_512_snapPhase_bram_addr,
      data_in => chan_512_snapPhase_bram_data_in,
      data_out => chan_512_snapPhase_bram_data_out,
      we => chan_512_snapPhase_bram_we
    );

  chan_512_snapphase_bram_ramblk : chan_512_snapphase_bram_ramblk_wrapper
    port map (
      BRAM_Rst_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_Rst,
      BRAM_Clk_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_Clk,
      BRAM_EN_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_EN,
      BRAM_WEN_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_WEN,
      BRAM_Addr_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_Addr,
      BRAM_Din_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_Din,
      BRAM_Dout_A => chan_512_snapPhase_bram_ramblk_porta_BRAM_Dout,
      BRAM_Rst_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_Rst,
      BRAM_Clk_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_Clk,
      BRAM_EN_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_EN,
      BRAM_WEN_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_WEN,
      BRAM_Addr_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_Addr,
      BRAM_Din_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_Din,
      BRAM_Dout_B => chan_512_snapPhase_bram_ramblk_portb_BRAM_Dout
    );

  chan_512_snapPhase_bram : chan_512_snapphase_bram_wrapper
    port map (
      opb_clk => epb_clk,
      opb_rst => opb1_OPB_Rst,
      opb_abus => opb1_OPB_ABus,
      opb_dbus => opb1_OPB_DBus,
      sln_dbus => opb1_Sl_DBus(224 to 255),
      opb_select => opb1_OPB_select,
      opb_rnw => opb1_OPB_RNW,
      opb_seqaddr => opb1_OPB_seqAddr,
      opb_be => opb1_OPB_BE,
      sln_xferack => opb1_Sl_xferAck(7),
      sln_errack => opb1_Sl_errAck(7),
      sln_toutsup => opb1_Sl_toutSup(7),
      sln_retry => opb1_Sl_retry(7),
      bram_rst => chan_512_snapPhase_bram_ramblk_portb_BRAM_Rst,
      bram_clk => chan_512_snapPhase_bram_ramblk_portb_BRAM_Clk,
      bram_en => chan_512_snapPhase_bram_ramblk_portb_BRAM_EN,
      bram_wen => chan_512_snapPhase_bram_ramblk_portb_BRAM_WEN,
      bram_addr => chan_512_snapPhase_bram_ramblk_portb_BRAM_Addr,
      bram_din => chan_512_snapPhase_bram_ramblk_portb_BRAM_Din,
      bram_dout => chan_512_snapPhase_bram_ramblk_portb_BRAM_Dout
    );

  chan_512_snapPhase_ctrl : chan_512_snapphase_ctrl_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(256 to 287),
      Sl_errAck => opb1_Sl_errAck(8),
      Sl_retry => opb1_Sl_retry(8),
      Sl_toutSup => opb1_Sl_toutSup(8),
      Sl_xferAck => opb1_Sl_xferAck(8),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_snapPhase_ctrl_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_start : chan_512_start_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(288 to 319),
      Sl_errAck => opb1_Sl_errAck(9),
      Sl_retry => opb1_Sl_retry(9),
      Sl_toutSup => opb1_Sl_toutSup(9),
      Sl_xferAck => opb1_Sl_xferAck(9),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_start_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_startAccumulator : chan_512_startaccumulator_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(320 to 351),
      Sl_errAck => opb1_Sl_errAck(10),
      Sl_retry => opb1_Sl_retry(10),
      Sl_toutSup => opb1_Sl_toutSup(10),
      Sl_xferAck => opb1_Sl_xferAck(10),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_startAccumulator_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_startBuffer : chan_512_startbuffer_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(352 to 383),
      Sl_errAck => opb1_Sl_errAck(11),
      Sl_retry => opb1_Sl_retry(11),
      Sl_toutSup => opb1_Sl_toutSup(11),
      Sl_xferAck => opb1_Sl_xferAck(11),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_startBuffer_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_startDAC : chan_512_startdac_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(384 to 415),
      Sl_errAck => opb1_Sl_errAck(12),
      Sl_retry => opb1_Sl_retry(12),
      Sl_toutSup => opb1_Sl_toutSup(12),
      Sl_xferAck => opb1_Sl_xferAck(12),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_startDAC_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_startSnap : chan_512_startsnap_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(416 to 447),
      Sl_errAck => opb1_Sl_errAck(13),
      Sl_retry => opb1_Sl_retry(13),
      Sl_toutSup => opb1_Sl_toutSup(13),
      Sl_xferAck => opb1_Sl_xferAck(13),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_startSnap_user_data_out,
      user_clk => adc1_clk
    );

  chan_512_stb_en : chan_512_stb_en_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      Sl_DBus => opb1_Sl_DBus(448 to 479),
      Sl_errAck => opb1_Sl_errAck(14),
      Sl_retry => opb1_Sl_retry(14),
      Sl_toutSup => opb1_Sl_toutSup(14),
      Sl_xferAck => opb1_Sl_xferAck(14),
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_DBus => opb1_OPB_DBus,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      user_data_out => chan_512_stb_en_user_data_out,
      user_clk => adc1_clk
    );

  opb1 : opb1_wrapper
    port map (
      OPB_Clk => epb_clk,
      OPB_Rst => opb1_OPB_Rst,
      SYS_Rst => sys_reset,
      Debug_SYS_Rst => net_gnd0,
      WDT_Rst => net_gnd0,
      M_ABus => opb1_M_ABus,
      M_BE => opb1_M_BE,
      M_beXfer => net_gnd1(0 to 0),
      M_busLock => opb1_M_busLock(0 to 0),
      M_DBus => opb1_M_DBus,
      M_DBusEn => net_gnd1(0 to 0),
      M_DBusEn32_63 => net_vcc1(0 to 0),
      M_dwXfer => net_gnd1(0 to 0),
      M_fwXfer => net_gnd1(0 to 0),
      M_hwXfer => net_gnd1(0 to 0),
      M_request => opb1_M_request(0 to 0),
      M_RNW => opb1_M_RNW(0 to 0),
      M_select => opb1_M_select(0 to 0),
      M_seqAddr => opb1_M_seqAddr(0 to 0),
      Sl_beAck => net_gnd15,
      Sl_DBus => opb1_Sl_DBus,
      Sl_DBusEn => net_vcc15,
      Sl_DBusEn32_63 => net_vcc15,
      Sl_errAck => opb1_Sl_errAck,
      Sl_dwAck => net_gnd15,
      Sl_fwAck => net_gnd15,
      Sl_hwAck => net_gnd15,
      Sl_retry => opb1_Sl_retry,
      Sl_toutSup => opb1_Sl_toutSup,
      Sl_xferAck => opb1_Sl_xferAck,
      OPB_MRequest => open,
      OPB_ABus => opb1_OPB_ABus,
      OPB_BE => opb1_OPB_BE,
      OPB_beXfer => open,
      OPB_beAck => open,
      OPB_busLock => open,
      OPB_rdDBus => open,
      OPB_wrDBus => open,
      OPB_DBus => opb1_OPB_DBus,
      OPB_errAck => opb1_OPB_errAck,
      OPB_dwAck => open,
      OPB_dwXfer => open,
      OPB_fwAck => open,
      OPB_fwXfer => open,
      OPB_hwAck => open,
      OPB_hwXfer => open,
      OPB_MGrant => opb1_OPB_MGrant(0 to 0),
      OPB_pendReq => open,
      OPB_retry => opb1_OPB_retry,
      OPB_RNW => opb1_OPB_RNW,
      OPB_select => opb1_OPB_select,
      OPB_seqAddr => opb1_OPB_seqAddr,
      OPB_timeout => opb1_OPB_timeout,
      OPB_toutSup => open,
      OPB_xferAck => opb1_OPB_xferAck
    );

  opb2opb_bridge_opb1 : opb2opb_bridge_opb1_wrapper
    port map (
      MOPB_Clk => epb_clk,
      SOPB_Clk => epb_clk,
      MOPB_Rst => opb1_OPB_Rst,
      SOPB_Rst => opb0_OPB_Rst,
      SOPB_ABus => opb0_OPB_ABus,
      SOPB_BE => opb0_OPB_BE,
      SOPB_DBus => opb0_OPB_DBus,
      SOPB_RNW => opb0_OPB_RNW,
      SOPB_select => opb0_OPB_select,
      SOPB_seqAddr => opb0_OPB_seqAddr,
      Sl_DBus => opb0_Sl_DBus(1024 to 1055),
      Sl_errAck => opb0_Sl_errAck(32),
      Sl_retry => opb0_Sl_retry(32),
      Sl_toutSup => opb0_Sl_toutSup(32),
      Sl_xferAck => opb0_Sl_xferAck(32),
      M_ABus => opb1_M_ABus,
      M_BE => opb1_M_BE,
      M_busLock => opb1_M_busLock(0),
      M_DBus => opb1_M_DBus,
      M_request => opb1_M_request(0),
      M_RNW => opb1_M_RNW(0),
      M_select => opb1_M_select(0),
      M_seqAddr => opb1_M_seqAddr(0),
      MOPB_DBus => opb1_OPB_DBus,
      MOPB_errAck => opb1_OPB_errAck,
      MOPB_MGrant => opb1_OPB_MGrant(0),
      MOPB_retry => opb1_OPB_retry,
      MOPB_timeout => opb1_OPB_timeout,
      MOPB_xferAck => opb1_OPB_xferAck
    );

end architecture STRUCTURE;

