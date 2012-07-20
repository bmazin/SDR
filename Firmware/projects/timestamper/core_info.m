% timestamper/XSG core config
timestamper_XSG_core_config_type         = 'xps_xsg';
timestamper_XSG_core_config_param        = '';

% timestamper/adc_mkid
timestamper_adc_mkid_type         = 'xps_adc_mkid';
timestamper_adc_mkid_param        = '';
timestamper_adc_mkid_ip_name      = 'adc_mkid_interface';

% timestamper/pulses/addr
timestamper_pulses_addr_type         = 'xps_sw_reg';
timestamper_pulses_addr_param        = 'out';
timestamper_pulses_addr_ip_name      = 'opb_register_simulink2ppc';
timestamper_pulses_addr_addr_start   = hex2dec('01000000');
timestamper_pulses_addr_addr_end     = hex2dec('010000FF');

% timestamper/pulses/bram0
timestamper_pulses_bram0_type         = 'xps_bram';
timestamper_pulses_bram0_param        = '16384';
timestamper_pulses_bram0_ip_name      = 'bram_if';
timestamper_pulses_bram0_addr_start   = hex2dec('01010000');
timestamper_pulses_bram0_addr_end     = hex2dec('0101FFFF');

% timestamper/pulses/bram1
timestamper_pulses_bram1_type         = 'xps_bram';
timestamper_pulses_bram1_param        = '16384';
timestamper_pulses_bram1_ip_name      = 'bram_if';
timestamper_pulses_bram1_addr_start   = hex2dec('01020000');
timestamper_pulses_bram1_addr_end     = hex2dec('0102FFFF');

% timestamper/seconds
timestamper_seconds_type         = 'xps_sw_reg';
timestamper_seconds_param        = 'out';
timestamper_seconds_ip_name      = 'opb_register_simulink2ppc';
timestamper_seconds_addr_start   = hex2dec('01030000');
timestamper_seconds_addr_end     = hex2dec('010300FF');

% timestamper/startBuffer
timestamper_startBuffer_type         = 'xps_sw_reg';
timestamper_startBuffer_param        = 'in';
timestamper_startBuffer_ip_name      = 'opb_register_ppc2simulink';
timestamper_startBuffer_addr_start   = hex2dec('01030100');
timestamper_startBuffer_addr_end     = hex2dec('010301FF');

