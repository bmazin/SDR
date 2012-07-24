-------------------------------------------------------------------------------
-- chan_550_simple_xsg_core_config_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity chan_550_simple_xsg_core_config_wrapper is
  port (
    clk : in std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Ack : in std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Rd_Dout : in std_logic_vector(143 downto 0);
    chan_550_simple_DRAM_LUT_dram_Mem_Rd_Tag : in std_logic_vector(31 downto 0);
    chan_550_simple_DRAM_LUT_dram_Mem_Rd_Valid : in std_logic;
    chan_550_simple_DRAM_LUT_dram_phy_ready : in std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Address : out std_logic_vector(31 downto 0);
    chan_550_simple_DRAM_LUT_dram_Mem_Cmd_RNW : out std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Tag : out std_logic_vector(31 downto 0);
    chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Valid : out std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Rd_Ack : out std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Rst : out std_logic;
    chan_550_simple_DRAM_LUT_dram_Mem_Wr_BE : out std_logic_vector(17 downto 0);
    chan_550_simple_DRAM_LUT_dram_Mem_Wr_Din : out std_logic_vector(143 downto 0);
    chan_550_simple_DRAM_LUT_rd_valid_user_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b0b1_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b10b11_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b12b13_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b14b15_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b16b17_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b18b19_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b20b21_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b22b23_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b24b25_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b2b3_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b4b5_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b6b7_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_b8b9_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_FIR_load_coeff_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_LO_SLE_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_SER_DI_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_SWAT_LE_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_adc_mkid_user_data_i0 : in std_logic_vector(11 downto 0);
    chan_550_simple_adc_mkid_user_data_i1 : in std_logic_vector(11 downto 0);
    chan_550_simple_adc_mkid_user_data_q0 : in std_logic_vector(11 downto 0);
    chan_550_simple_adc_mkid_user_data_q1 : in std_logic_vector(11 downto 0);
    chan_550_simple_adc_mkid_user_sync : in std_logic;
    chan_550_simple_avgIQ_addr_user_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_avgIQ_bram_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_avgIQ_bram_addr : out std_logic_vector(9 downto 0);
    chan_550_simple_avgIQ_bram_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_avgIQ_bram_we : out std_logic;
    chan_550_simple_avgIQ_ctrl_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_bins_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_capture_load_thresh_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_capture_threshold_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_ch_we_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_conv_phase_centers_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_conv_phase_load_centers_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_dac_mkid_dac_data_i0 : out std_logic_vector(15 downto 0);
    chan_550_simple_dac_mkid_dac_data_i1 : out std_logic_vector(15 downto 0);
    chan_550_simple_dac_mkid_dac_data_q0 : out std_logic_vector(15 downto 0);
    chan_550_simple_dac_mkid_dac_data_q1 : out std_logic_vector(15 downto 0);
    chan_550_simple_dac_mkid_dac_sync_i : out std_logic;
    chan_550_simple_dac_mkid_dac_sync_q : out std_logic;
    chan_550_simple_dac_mkid_not_reset : out std_logic;
    chan_550_simple_dac_mkid_not_sdenb_i : out std_logic;
    chan_550_simple_dac_mkid_not_sdenb_q : out std_logic;
    chan_550_simple_dac_mkid_sclk : out std_logic;
    chan_550_simple_dac_mkid_sdi : out std_logic;
    chan_550_simple_gpio_a0_gateway : out std_logic;
    chan_550_simple_gpio_a1_gateway : out std_logic;
    chan_550_simple_gpio_a2_gateway : out std_logic;
    chan_550_simple_gpio_a3_gateway : out std_logic;
    chan_550_simple_gpio_a5_gateway : out std_logic;
    chan_550_simple_if_switch_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_load_bins_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_pulses_addr_user_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_pulses_bram0_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_pulses_bram0_addr : out std_logic_vector(13 downto 0);
    chan_550_simple_pulses_bram0_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_pulses_bram0_we : out std_logic;
    chan_550_simple_pulses_bram1_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_pulses_bram1_addr : out std_logic_vector(13 downto 0);
    chan_550_simple_pulses_bram1_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_pulses_bram1_we : out std_logic;
    chan_550_simple_regs_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_seconds_user_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_snapPhase_addr_user_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_snapPhase_bram_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_snapPhase_bram_addr : out std_logic_vector(9 downto 0);
    chan_550_simple_snapPhase_bram_data_in : out std_logic_vector(31 downto 0);
    chan_550_simple_snapPhase_bram_we : out std_logic;
    chan_550_simple_snapPhase_ctrl_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_start_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_startAccumulator_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_startBuffer_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_startDAC_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_startSnap_user_data_out : in std_logic_vector(31 downto 0);
    chan_550_simple_stb_en_user_data_out : in std_logic_vector(31 downto 0)
  );

  attribute x_core_info : STRING;
  attribute x_core_info of chan_550_simple_xsg_core_config_wrapper : entity is "chan_550_simple_v1_00_a";

end chan_550_simple_xsg_core_config_wrapper;

architecture STRUCTURE of chan_550_simple_xsg_core_config_wrapper is

  component chan_550_simple is
    port (
      clk : in std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Ack : in std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Dout : in std_logic_vector(143 downto 0);
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Tag : in std_logic_vector(31 downto 0);
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Valid : in std_logic;
      chan_550_simple_DRAM_LUT_dram_phy_ready : in std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Address : out std_logic_vector(31 downto 0);
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_RNW : out std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Tag : out std_logic_vector(31 downto 0);
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Valid : out std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Ack : out std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Rst : out std_logic;
      chan_550_simple_DRAM_LUT_dram_Mem_Wr_BE : out std_logic_vector(17 downto 0);
      chan_550_simple_DRAM_LUT_dram_Mem_Wr_Din : out std_logic_vector(143 downto 0);
      chan_550_simple_DRAM_LUT_rd_valid_user_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b0b1_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b10b11_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b12b13_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b14b15_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b16b17_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b18b19_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b20b21_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b22b23_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b24b25_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b2b3_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b4b5_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b6b7_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_b8b9_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_FIR_load_coeff_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_LO_SLE_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_SER_DI_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_SWAT_LE_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_adc_mkid_user_data_i0 : in std_logic_vector(11 downto 0);
      chan_550_simple_adc_mkid_user_data_i1 : in std_logic_vector(11 downto 0);
      chan_550_simple_adc_mkid_user_data_q0 : in std_logic_vector(11 downto 0);
      chan_550_simple_adc_mkid_user_data_q1 : in std_logic_vector(11 downto 0);
      chan_550_simple_adc_mkid_user_sync : in std_logic;
      chan_550_simple_avgIQ_addr_user_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_avgIQ_bram_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_avgIQ_bram_addr : out std_logic_vector(9 downto 0);
      chan_550_simple_avgIQ_bram_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_avgIQ_bram_we : out std_logic;
      chan_550_simple_avgIQ_ctrl_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_bins_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_capture_load_thresh_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_capture_threshold_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_ch_we_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_conv_phase_centers_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_conv_phase_load_centers_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_dac_mkid_dac_data_i0 : out std_logic_vector(15 downto 0);
      chan_550_simple_dac_mkid_dac_data_i1 : out std_logic_vector(15 downto 0);
      chan_550_simple_dac_mkid_dac_data_q0 : out std_logic_vector(15 downto 0);
      chan_550_simple_dac_mkid_dac_data_q1 : out std_logic_vector(15 downto 0);
      chan_550_simple_dac_mkid_dac_sync_i : out std_logic;
      chan_550_simple_dac_mkid_dac_sync_q : out std_logic;
      chan_550_simple_dac_mkid_not_reset : out std_logic;
      chan_550_simple_dac_mkid_not_sdenb_i : out std_logic;
      chan_550_simple_dac_mkid_not_sdenb_q : out std_logic;
      chan_550_simple_dac_mkid_sclk : out std_logic;
      chan_550_simple_dac_mkid_sdi : out std_logic;
      chan_550_simple_gpio_a0_gateway : out std_logic;
      chan_550_simple_gpio_a1_gateway : out std_logic;
      chan_550_simple_gpio_a2_gateway : out std_logic;
      chan_550_simple_gpio_a3_gateway : out std_logic;
      chan_550_simple_gpio_a5_gateway : out std_logic;
      chan_550_simple_if_switch_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_load_bins_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_pulses_addr_user_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_pulses_bram0_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_pulses_bram0_addr : out std_logic_vector(13 downto 0);
      chan_550_simple_pulses_bram0_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_pulses_bram0_we : out std_logic;
      chan_550_simple_pulses_bram1_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_pulses_bram1_addr : out std_logic_vector(13 downto 0);
      chan_550_simple_pulses_bram1_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_pulses_bram1_we : out std_logic;
      chan_550_simple_regs_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_seconds_user_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_snapPhase_addr_user_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_snapPhase_bram_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_snapPhase_bram_addr : out std_logic_vector(9 downto 0);
      chan_550_simple_snapPhase_bram_data_in : out std_logic_vector(31 downto 0);
      chan_550_simple_snapPhase_bram_we : out std_logic;
      chan_550_simple_snapPhase_ctrl_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_start_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_startAccumulator_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_startBuffer_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_startDAC_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_startSnap_user_data_out : in std_logic_vector(31 downto 0);
      chan_550_simple_stb_en_user_data_out : in std_logic_vector(31 downto 0)
    );
  end component;

  attribute BOX_TYPE : STRING;
  attribute BOX_TYPE of chan_550_simple : component is "user_black_box";

begin

  chan_550_simple_XSG_core_config : chan_550_simple
    port map (
      clk => clk,
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Ack => chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Ack,
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Dout => chan_550_simple_DRAM_LUT_dram_Mem_Rd_Dout,
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Tag => chan_550_simple_DRAM_LUT_dram_Mem_Rd_Tag,
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Valid => chan_550_simple_DRAM_LUT_dram_Mem_Rd_Valid,
      chan_550_simple_DRAM_LUT_dram_phy_ready => chan_550_simple_DRAM_LUT_dram_phy_ready,
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Address => chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Address,
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_RNW => chan_550_simple_DRAM_LUT_dram_Mem_Cmd_RNW,
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Tag => chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Tag,
      chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Valid => chan_550_simple_DRAM_LUT_dram_Mem_Cmd_Valid,
      chan_550_simple_DRAM_LUT_dram_Mem_Rd_Ack => chan_550_simple_DRAM_LUT_dram_Mem_Rd_Ack,
      chan_550_simple_DRAM_LUT_dram_Mem_Rst => chan_550_simple_DRAM_LUT_dram_Mem_Rst,
      chan_550_simple_DRAM_LUT_dram_Mem_Wr_BE => chan_550_simple_DRAM_LUT_dram_Mem_Wr_BE,
      chan_550_simple_DRAM_LUT_dram_Mem_Wr_Din => chan_550_simple_DRAM_LUT_dram_Mem_Wr_Din,
      chan_550_simple_DRAM_LUT_rd_valid_user_data_in => chan_550_simple_DRAM_LUT_rd_valid_user_data_in,
      chan_550_simple_FIR_b0b1_user_data_out => chan_550_simple_FIR_b0b1_user_data_out,
      chan_550_simple_FIR_b10b11_user_data_out => chan_550_simple_FIR_b10b11_user_data_out,
      chan_550_simple_FIR_b12b13_user_data_out => chan_550_simple_FIR_b12b13_user_data_out,
      chan_550_simple_FIR_b14b15_user_data_out => chan_550_simple_FIR_b14b15_user_data_out,
      chan_550_simple_FIR_b16b17_user_data_out => chan_550_simple_FIR_b16b17_user_data_out,
      chan_550_simple_FIR_b18b19_user_data_out => chan_550_simple_FIR_b18b19_user_data_out,
      chan_550_simple_FIR_b20b21_user_data_out => chan_550_simple_FIR_b20b21_user_data_out,
      chan_550_simple_FIR_b22b23_user_data_out => chan_550_simple_FIR_b22b23_user_data_out,
      chan_550_simple_FIR_b24b25_user_data_out => chan_550_simple_FIR_b24b25_user_data_out,
      chan_550_simple_FIR_b2b3_user_data_out => chan_550_simple_FIR_b2b3_user_data_out,
      chan_550_simple_FIR_b4b5_user_data_out => chan_550_simple_FIR_b4b5_user_data_out,
      chan_550_simple_FIR_b6b7_user_data_out => chan_550_simple_FIR_b6b7_user_data_out,
      chan_550_simple_FIR_b8b9_user_data_out => chan_550_simple_FIR_b8b9_user_data_out,
      chan_550_simple_FIR_load_coeff_user_data_out => chan_550_simple_FIR_load_coeff_user_data_out,
      chan_550_simple_LO_SLE_user_data_out => chan_550_simple_LO_SLE_user_data_out,
      chan_550_simple_SER_DI_user_data_out => chan_550_simple_SER_DI_user_data_out,
      chan_550_simple_SWAT_LE_user_data_out => chan_550_simple_SWAT_LE_user_data_out,
      chan_550_simple_adc_mkid_user_data_i0 => chan_550_simple_adc_mkid_user_data_i0,
      chan_550_simple_adc_mkid_user_data_i1 => chan_550_simple_adc_mkid_user_data_i1,
      chan_550_simple_adc_mkid_user_data_q0 => chan_550_simple_adc_mkid_user_data_q0,
      chan_550_simple_adc_mkid_user_data_q1 => chan_550_simple_adc_mkid_user_data_q1,
      chan_550_simple_adc_mkid_user_sync => chan_550_simple_adc_mkid_user_sync,
      chan_550_simple_avgIQ_addr_user_data_in => chan_550_simple_avgIQ_addr_user_data_in,
      chan_550_simple_avgIQ_bram_data_out => chan_550_simple_avgIQ_bram_data_out,
      chan_550_simple_avgIQ_bram_addr => chan_550_simple_avgIQ_bram_addr,
      chan_550_simple_avgIQ_bram_data_in => chan_550_simple_avgIQ_bram_data_in,
      chan_550_simple_avgIQ_bram_we => chan_550_simple_avgIQ_bram_we,
      chan_550_simple_avgIQ_ctrl_user_data_out => chan_550_simple_avgIQ_ctrl_user_data_out,
      chan_550_simple_bins_user_data_out => chan_550_simple_bins_user_data_out,
      chan_550_simple_capture_load_thresh_user_data_out => chan_550_simple_capture_load_thresh_user_data_out,
      chan_550_simple_capture_threshold_user_data_out => chan_550_simple_capture_threshold_user_data_out,
      chan_550_simple_ch_we_user_data_out => chan_550_simple_ch_we_user_data_out,
      chan_550_simple_conv_phase_centers_user_data_out => chan_550_simple_conv_phase_centers_user_data_out,
      chan_550_simple_conv_phase_load_centers_user_data_out => chan_550_simple_conv_phase_load_centers_user_data_out,
      chan_550_simple_dac_mkid_dac_data_i0 => chan_550_simple_dac_mkid_dac_data_i0,
      chan_550_simple_dac_mkid_dac_data_i1 => chan_550_simple_dac_mkid_dac_data_i1,
      chan_550_simple_dac_mkid_dac_data_q0 => chan_550_simple_dac_mkid_dac_data_q0,
      chan_550_simple_dac_mkid_dac_data_q1 => chan_550_simple_dac_mkid_dac_data_q1,
      chan_550_simple_dac_mkid_dac_sync_i => chan_550_simple_dac_mkid_dac_sync_i,
      chan_550_simple_dac_mkid_dac_sync_q => chan_550_simple_dac_mkid_dac_sync_q,
      chan_550_simple_dac_mkid_not_reset => chan_550_simple_dac_mkid_not_reset,
      chan_550_simple_dac_mkid_not_sdenb_i => chan_550_simple_dac_mkid_not_sdenb_i,
      chan_550_simple_dac_mkid_not_sdenb_q => chan_550_simple_dac_mkid_not_sdenb_q,
      chan_550_simple_dac_mkid_sclk => chan_550_simple_dac_mkid_sclk,
      chan_550_simple_dac_mkid_sdi => chan_550_simple_dac_mkid_sdi,
      chan_550_simple_gpio_a0_gateway => chan_550_simple_gpio_a0_gateway,
      chan_550_simple_gpio_a1_gateway => chan_550_simple_gpio_a1_gateway,
      chan_550_simple_gpio_a2_gateway => chan_550_simple_gpio_a2_gateway,
      chan_550_simple_gpio_a3_gateway => chan_550_simple_gpio_a3_gateway,
      chan_550_simple_gpio_a5_gateway => chan_550_simple_gpio_a5_gateway,
      chan_550_simple_if_switch_user_data_out => chan_550_simple_if_switch_user_data_out,
      chan_550_simple_load_bins_user_data_out => chan_550_simple_load_bins_user_data_out,
      chan_550_simple_pulses_addr_user_data_in => chan_550_simple_pulses_addr_user_data_in,
      chan_550_simple_pulses_bram0_data_out => chan_550_simple_pulses_bram0_data_out,
      chan_550_simple_pulses_bram0_addr => chan_550_simple_pulses_bram0_addr,
      chan_550_simple_pulses_bram0_data_in => chan_550_simple_pulses_bram0_data_in,
      chan_550_simple_pulses_bram0_we => chan_550_simple_pulses_bram0_we,
      chan_550_simple_pulses_bram1_data_out => chan_550_simple_pulses_bram1_data_out,
      chan_550_simple_pulses_bram1_addr => chan_550_simple_pulses_bram1_addr,
      chan_550_simple_pulses_bram1_data_in => chan_550_simple_pulses_bram1_data_in,
      chan_550_simple_pulses_bram1_we => chan_550_simple_pulses_bram1_we,
      chan_550_simple_regs_user_data_out => chan_550_simple_regs_user_data_out,
      chan_550_simple_seconds_user_data_in => chan_550_simple_seconds_user_data_in,
      chan_550_simple_snapPhase_addr_user_data_in => chan_550_simple_snapPhase_addr_user_data_in,
      chan_550_simple_snapPhase_bram_data_out => chan_550_simple_snapPhase_bram_data_out,
      chan_550_simple_snapPhase_bram_addr => chan_550_simple_snapPhase_bram_addr,
      chan_550_simple_snapPhase_bram_data_in => chan_550_simple_snapPhase_bram_data_in,
      chan_550_simple_snapPhase_bram_we => chan_550_simple_snapPhase_bram_we,
      chan_550_simple_snapPhase_ctrl_user_data_out => chan_550_simple_snapPhase_ctrl_user_data_out,
      chan_550_simple_start_user_data_out => chan_550_simple_start_user_data_out,
      chan_550_simple_startAccumulator_user_data_out => chan_550_simple_startAccumulator_user_data_out,
      chan_550_simple_startBuffer_user_data_out => chan_550_simple_startBuffer_user_data_out,
      chan_550_simple_startDAC_user_data_out => chan_550_simple_startDAC_user_data_out,
      chan_550_simple_startSnap_user_data_out => chan_550_simple_startSnap_user_data_out,
      chan_550_simple_stb_en_user_data_out => chan_550_simple_stb_en_user_data_out
    );

end architecture STRUCTURE;

