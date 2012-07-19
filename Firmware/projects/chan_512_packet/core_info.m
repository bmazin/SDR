% chan_512_packet/XSG core config
chan_512_packet_XSG_core_config_type         = 'xps_xsg';
chan_512_packet_XSG_core_config_param        = '';

% chan_512_packet/DRAM_LUT/dram
chan_512_packet_DRAM_LUT_dram_type         = 'xps_dram';
chan_512_packet_DRAM_LUT_dram_param        = '';
chan_512_packet_DRAM_LUT_dram_ip_name      = 'opb_dram_sniffer';
chan_512_packet_DRAM_LUT_dram_addr_start   = hex2dec('00050000');
chan_512_packet_DRAM_LUT_dram_addr_end     = hex2dec('0005FFFF');

% chan_512_packet/DRAM_LUT/rd_valid
chan_512_packet_DRAM_LUT_rd_valid_type         = 'xps_sw_reg';
chan_512_packet_DRAM_LUT_rd_valid_param        = 'out';
chan_512_packet_DRAM_LUT_rd_valid_ip_name      = 'opb_register_simulink2ppc';
chan_512_packet_DRAM_LUT_rd_valid_addr_start   = hex2dec('01000000');
chan_512_packet_DRAM_LUT_rd_valid_addr_end     = hex2dec('010000FF');

% chan_512_packet/FIR/b0b1
chan_512_packet_FIR_b0b1_type         = 'xps_sw_reg';
chan_512_packet_FIR_b0b1_param        = 'in';
chan_512_packet_FIR_b0b1_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b0b1_addr_start   = hex2dec('01000100');
chan_512_packet_FIR_b0b1_addr_end     = hex2dec('010001FF');

% chan_512_packet/FIR/b10b11
chan_512_packet_FIR_b10b11_type         = 'xps_sw_reg';
chan_512_packet_FIR_b10b11_param        = 'in';
chan_512_packet_FIR_b10b11_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b10b11_addr_start   = hex2dec('01000200');
chan_512_packet_FIR_b10b11_addr_end     = hex2dec('010002FF');

% chan_512_packet/FIR/b12b13
chan_512_packet_FIR_b12b13_type         = 'xps_sw_reg';
chan_512_packet_FIR_b12b13_param        = 'in';
chan_512_packet_FIR_b12b13_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b12b13_addr_start   = hex2dec('01000300');
chan_512_packet_FIR_b12b13_addr_end     = hex2dec('010003FF');

% chan_512_packet/FIR/b14b15
chan_512_packet_FIR_b14b15_type         = 'xps_sw_reg';
chan_512_packet_FIR_b14b15_param        = 'in';
chan_512_packet_FIR_b14b15_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b14b15_addr_start   = hex2dec('01000400');
chan_512_packet_FIR_b14b15_addr_end     = hex2dec('010004FF');

% chan_512_packet/FIR/b16b17
chan_512_packet_FIR_b16b17_type         = 'xps_sw_reg';
chan_512_packet_FIR_b16b17_param        = 'in';
chan_512_packet_FIR_b16b17_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b16b17_addr_start   = hex2dec('01000500');
chan_512_packet_FIR_b16b17_addr_end     = hex2dec('010005FF');

% chan_512_packet/FIR/b18b19
chan_512_packet_FIR_b18b19_type         = 'xps_sw_reg';
chan_512_packet_FIR_b18b19_param        = 'in';
chan_512_packet_FIR_b18b19_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b18b19_addr_start   = hex2dec('01000600');
chan_512_packet_FIR_b18b19_addr_end     = hex2dec('010006FF');

% chan_512_packet/FIR/b20b21
chan_512_packet_FIR_b20b21_type         = 'xps_sw_reg';
chan_512_packet_FIR_b20b21_param        = 'in';
chan_512_packet_FIR_b20b21_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b20b21_addr_start   = hex2dec('01000700');
chan_512_packet_FIR_b20b21_addr_end     = hex2dec('010007FF');

% chan_512_packet/FIR/b22b23
chan_512_packet_FIR_b22b23_type         = 'xps_sw_reg';
chan_512_packet_FIR_b22b23_param        = 'in';
chan_512_packet_FIR_b22b23_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b22b23_addr_start   = hex2dec('01000800');
chan_512_packet_FIR_b22b23_addr_end     = hex2dec('010008FF');

% chan_512_packet/FIR/b24b25
chan_512_packet_FIR_b24b25_type         = 'xps_sw_reg';
chan_512_packet_FIR_b24b25_param        = 'in';
chan_512_packet_FIR_b24b25_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b24b25_addr_start   = hex2dec('01000900');
chan_512_packet_FIR_b24b25_addr_end     = hex2dec('010009FF');

% chan_512_packet/FIR/b2b3
chan_512_packet_FIR_b2b3_type         = 'xps_sw_reg';
chan_512_packet_FIR_b2b3_param        = 'in';
chan_512_packet_FIR_b2b3_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b2b3_addr_start   = hex2dec('01000A00');
chan_512_packet_FIR_b2b3_addr_end     = hex2dec('01000AFF');

% chan_512_packet/FIR/b4b5
chan_512_packet_FIR_b4b5_type         = 'xps_sw_reg';
chan_512_packet_FIR_b4b5_param        = 'in';
chan_512_packet_FIR_b4b5_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b4b5_addr_start   = hex2dec('01000B00');
chan_512_packet_FIR_b4b5_addr_end     = hex2dec('01000BFF');

% chan_512_packet/FIR/b6b7
chan_512_packet_FIR_b6b7_type         = 'xps_sw_reg';
chan_512_packet_FIR_b6b7_param        = 'in';
chan_512_packet_FIR_b6b7_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b6b7_addr_start   = hex2dec('01000C00');
chan_512_packet_FIR_b6b7_addr_end     = hex2dec('01000CFF');

% chan_512_packet/FIR/b8b9
chan_512_packet_FIR_b8b9_type         = 'xps_sw_reg';
chan_512_packet_FIR_b8b9_param        = 'in';
chan_512_packet_FIR_b8b9_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_b8b9_addr_start   = hex2dec('01000D00');
chan_512_packet_FIR_b8b9_addr_end     = hex2dec('01000DFF');

% chan_512_packet/FIR/load_coeff
chan_512_packet_FIR_load_coeff_type         = 'xps_sw_reg';
chan_512_packet_FIR_load_coeff_param        = 'in';
chan_512_packet_FIR_load_coeff_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_FIR_load_coeff_addr_start   = hex2dec('01000E00');
chan_512_packet_FIR_load_coeff_addr_end     = hex2dec('01000EFF');

% chan_512_packet/LO_SLE
chan_512_packet_LO_SLE_type         = 'xps_sw_reg';
chan_512_packet_LO_SLE_param        = 'in';
chan_512_packet_LO_SLE_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_LO_SLE_addr_start   = hex2dec('01000F00');
chan_512_packet_LO_SLE_addr_end     = hex2dec('01000FFF');

% chan_512_packet/SER_DI
chan_512_packet_SER_DI_type         = 'xps_sw_reg';
chan_512_packet_SER_DI_param        = 'in';
chan_512_packet_SER_DI_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_SER_DI_addr_start   = hex2dec('01001000');
chan_512_packet_SER_DI_addr_end     = hex2dec('010010FF');

% chan_512_packet/SWAT_LE
chan_512_packet_SWAT_LE_type         = 'xps_sw_reg';
chan_512_packet_SWAT_LE_param        = 'in';
chan_512_packet_SWAT_LE_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_SWAT_LE_addr_start   = hex2dec('01001100');
chan_512_packet_SWAT_LE_addr_end     = hex2dec('010011FF');

% chan_512_packet/adc_mkid
chan_512_packet_adc_mkid_type         = 'xps_adc_mkid';
chan_512_packet_adc_mkid_param        = '';
chan_512_packet_adc_mkid_ip_name      = 'adc_mkid_interface';

% chan_512_packet/avgIQ/addr
chan_512_packet_avgIQ_addr_type         = 'xps_sw_reg';
chan_512_packet_avgIQ_addr_param        = 'out';
chan_512_packet_avgIQ_addr_ip_name      = 'opb_register_simulink2ppc';
chan_512_packet_avgIQ_addr_addr_start   = hex2dec('01001200');
chan_512_packet_avgIQ_addr_addr_end     = hex2dec('010012FF');

% chan_512_packet/avgIQ/bram
chan_512_packet_avgIQ_bram_type         = 'xps_bram';
chan_512_packet_avgIQ_bram_param        = '1024';
chan_512_packet_avgIQ_bram_ip_name      = 'bram_if';
chan_512_packet_avgIQ_bram_addr_start   = hex2dec('01002000');
chan_512_packet_avgIQ_bram_addr_end     = hex2dec('01002FFF');

% chan_512_packet/avgIQ/ctrl
chan_512_packet_avgIQ_ctrl_type         = 'xps_sw_reg';
chan_512_packet_avgIQ_ctrl_param        = 'in';
chan_512_packet_avgIQ_ctrl_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_avgIQ_ctrl_addr_start   = hex2dec('01003000');
chan_512_packet_avgIQ_ctrl_addr_end     = hex2dec('010030FF');

% chan_512_packet/bins
chan_512_packet_bins_type         = 'xps_sw_reg';
chan_512_packet_bins_param        = 'in';
chan_512_packet_bins_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_bins_addr_start   = hex2dec('01003100');
chan_512_packet_bins_addr_end     = hex2dec('010031FF');

% chan_512_packet/capture/load_thresh
chan_512_packet_capture_load_thresh_type         = 'xps_sw_reg';
chan_512_packet_capture_load_thresh_param        = 'in';
chan_512_packet_capture_load_thresh_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_capture_load_thresh_addr_start   = hex2dec('01003200');
chan_512_packet_capture_load_thresh_addr_end     = hex2dec('010032FF');

% chan_512_packet/capture/threshold
chan_512_packet_capture_threshold_type         = 'xps_sw_reg';
chan_512_packet_capture_threshold_param        = 'in';
chan_512_packet_capture_threshold_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_capture_threshold_addr_start   = hex2dec('01003300');
chan_512_packet_capture_threshold_addr_end     = hex2dec('010033FF');

% chan_512_packet/ch_we
chan_512_packet_ch_we_type         = 'xps_sw_reg';
chan_512_packet_ch_we_param        = 'in';
chan_512_packet_ch_we_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_ch_we_addr_start   = hex2dec('01003400');
chan_512_packet_ch_we_addr_end     = hex2dec('010034FF');

% chan_512_packet/conv_phase/centers
chan_512_packet_conv_phase_centers_type         = 'xps_sw_reg';
chan_512_packet_conv_phase_centers_param        = 'in';
chan_512_packet_conv_phase_centers_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_conv_phase_centers_addr_start   = hex2dec('01003500');
chan_512_packet_conv_phase_centers_addr_end     = hex2dec('010035FF');

% chan_512_packet/conv_phase/load_centers
chan_512_packet_conv_phase_load_centers_type         = 'xps_sw_reg';
chan_512_packet_conv_phase_load_centers_param        = 'in';
chan_512_packet_conv_phase_load_centers_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_conv_phase_load_centers_addr_start   = hex2dec('01003600');
chan_512_packet_conv_phase_load_centers_addr_end     = hex2dec('010036FF');

% chan_512_packet/dac_mkid
chan_512_packet_dac_mkid_type         = 'xps_dac_mkid';
chan_512_packet_dac_mkid_param        = '';
chan_512_packet_dac_mkid_ip_name      = 'dac_mkid_interface';

% chan_512_packet/gpio_a0
chan_512_packet_gpio_a0_type         = 'xps_gpio';
chan_512_packet_gpio_a0_param        = '';
chan_512_packet_gpio_a0_ip_name      = 'gpio_simulink2ext';

% chan_512_packet/gpio_a1
chan_512_packet_gpio_a1_type         = 'xps_gpio';
chan_512_packet_gpio_a1_param        = '';
chan_512_packet_gpio_a1_ip_name      = 'gpio_simulink2ext';

% chan_512_packet/gpio_a2
chan_512_packet_gpio_a2_type         = 'xps_gpio';
chan_512_packet_gpio_a2_param        = '';
chan_512_packet_gpio_a2_ip_name      = 'gpio_simulink2ext';

% chan_512_packet/gpio_a3
chan_512_packet_gpio_a3_type         = 'xps_gpio';
chan_512_packet_gpio_a3_param        = '';
chan_512_packet_gpio_a3_ip_name      = 'gpio_simulink2ext';

% chan_512_packet/gpio_a5
chan_512_packet_gpio_a5_type         = 'xps_gpio';
chan_512_packet_gpio_a5_param        = '';
chan_512_packet_gpio_a5_ip_name      = 'gpio_simulink2ext';

% chan_512_packet/if_switch
chan_512_packet_if_switch_type         = 'xps_sw_reg';
chan_512_packet_if_switch_param        = 'in';
chan_512_packet_if_switch_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_if_switch_addr_start   = hex2dec('01003700');
chan_512_packet_if_switch_addr_end     = hex2dec('010037FF');

% chan_512_packet/load_bins
chan_512_packet_load_bins_type         = 'xps_sw_reg';
chan_512_packet_load_bins_param        = 'in';
chan_512_packet_load_bins_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_load_bins_addr_start   = hex2dec('01003800');
chan_512_packet_load_bins_addr_end     = hex2dec('010038FF');

% chan_512_packet/pulses/addr
chan_512_packet_pulses_addr_type         = 'xps_sw_reg';
chan_512_packet_pulses_addr_param        = 'out';
chan_512_packet_pulses_addr_ip_name      = 'opb_register_simulink2ppc';
chan_512_packet_pulses_addr_addr_start   = hex2dec('01080000');
chan_512_packet_pulses_addr_addr_end     = hex2dec('010800FF');

% chan_512_packet/pulses/bram0
chan_512_packet_pulses_bram0_type         = 'xps_bram';
chan_512_packet_pulses_bram0_param        = '16384';
chan_512_packet_pulses_bram0_ip_name      = 'bram_if';
chan_512_packet_pulses_bram0_addr_start   = hex2dec('01090000');
chan_512_packet_pulses_bram0_addr_end     = hex2dec('0109FFFF');

% chan_512_packet/pulses/bram1
chan_512_packet_pulses_bram1_type         = 'xps_bram';
chan_512_packet_pulses_bram1_param        = '16384';
chan_512_packet_pulses_bram1_ip_name      = 'bram_if';
chan_512_packet_pulses_bram1_addr_start   = hex2dec('010A0000');
chan_512_packet_pulses_bram1_addr_end     = hex2dec('010AFFFF');

% chan_512_packet/regs
chan_512_packet_regs_type         = 'xps_sw_reg';
chan_512_packet_regs_param        = 'in';
chan_512_packet_regs_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_regs_addr_start   = hex2dec('010B0000');
chan_512_packet_regs_addr_end     = hex2dec('010B00FF');

% chan_512_packet/seconds
chan_512_packet_seconds_type         = 'xps_sw_reg';
chan_512_packet_seconds_param        = 'out';
chan_512_packet_seconds_ip_name      = 'opb_register_simulink2ppc';
chan_512_packet_seconds_addr_start   = hex2dec('010B0100');
chan_512_packet_seconds_addr_end     = hex2dec('010B01FF');

% chan_512_packet/snapPhase/addr
chan_512_packet_snapPhase_addr_type         = 'xps_sw_reg';
chan_512_packet_snapPhase_addr_param        = 'out';
chan_512_packet_snapPhase_addr_ip_name      = 'opb_register_simulink2ppc';
chan_512_packet_snapPhase_addr_addr_start   = hex2dec('010B0200');
chan_512_packet_snapPhase_addr_addr_end     = hex2dec('010B02FF');

% chan_512_packet/snapPhase/bram
chan_512_packet_snapPhase_bram_type         = 'xps_bram';
chan_512_packet_snapPhase_bram_param        = '1024';
chan_512_packet_snapPhase_bram_ip_name      = 'bram_if';
chan_512_packet_snapPhase_bram_addr_start   = hex2dec('010B1000');
chan_512_packet_snapPhase_bram_addr_end     = hex2dec('010B1FFF');

% chan_512_packet/snapPhase/ctrl
chan_512_packet_snapPhase_ctrl_type         = 'xps_sw_reg';
chan_512_packet_snapPhase_ctrl_param        = 'in';
chan_512_packet_snapPhase_ctrl_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_snapPhase_ctrl_addr_start   = hex2dec('010B2000');
chan_512_packet_snapPhase_ctrl_addr_end     = hex2dec('010B20FF');

% chan_512_packet/start
chan_512_packet_start_type         = 'xps_sw_reg';
chan_512_packet_start_param        = 'in';
chan_512_packet_start_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_start_addr_start   = hex2dec('010B2100');
chan_512_packet_start_addr_end     = hex2dec('010B21FF');

% chan_512_packet/startAccumulator
chan_512_packet_startAccumulator_type         = 'xps_sw_reg';
chan_512_packet_startAccumulator_param        = 'in';
chan_512_packet_startAccumulator_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_startAccumulator_addr_start   = hex2dec('010B2200');
chan_512_packet_startAccumulator_addr_end     = hex2dec('010B22FF');

% chan_512_packet/startBuffer
chan_512_packet_startBuffer_type         = 'xps_sw_reg';
chan_512_packet_startBuffer_param        = 'in';
chan_512_packet_startBuffer_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_startBuffer_addr_start   = hex2dec('010B2300');
chan_512_packet_startBuffer_addr_end     = hex2dec('010B23FF');

% chan_512_packet/startDAC
chan_512_packet_startDAC_type         = 'xps_sw_reg';
chan_512_packet_startDAC_param        = 'in';
chan_512_packet_startDAC_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_startDAC_addr_start   = hex2dec('010B2400');
chan_512_packet_startDAC_addr_end     = hex2dec('010B24FF');

% chan_512_packet/startSnap
chan_512_packet_startSnap_type         = 'xps_sw_reg';
chan_512_packet_startSnap_param        = 'in';
chan_512_packet_startSnap_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_startSnap_addr_start   = hex2dec('010B2500');
chan_512_packet_startSnap_addr_end     = hex2dec('010B25FF');

% chan_512_packet/stb_en
chan_512_packet_stb_en_type         = 'xps_sw_reg';
chan_512_packet_stb_en_param        = 'in';
chan_512_packet_stb_en_ip_name      = 'opb_register_ppc2simulink';
chan_512_packet_stb_en_addr_start   = hex2dec('010B2600');
chan_512_packet_stb_en_addr_end     = hex2dec('010B26FF');

% OPB to OPB bridge added at 0x1080000
OPB_to_OPB_bridge_added_at_0x1080000_type         = 'xps_opb2opb';
OPB_to_OPB_bridge_added_at_0x1080000_param        = '';

