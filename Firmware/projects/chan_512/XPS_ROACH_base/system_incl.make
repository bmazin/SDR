#################################################################
# Makefile generated by Xilinx Platform Studio 
# Project:/home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/system.xmp
#
# WARNING : This file will be re-generated every time a command
# to run a make target is invoked. So, any changes made to this  
# file manually, will be lost when make is invoked next. 
#################################################################

XILINX_EDK_DIR = /opt/Xilinx/11.1/EDK
NON_CYG_XILINX_EDK_DIR = /opt/Xilinx/11.1/EDK

SYSTEM = system

MHSFILE = system.mhs

MSSFILE = system.mss

FPGA_ARCH = virtex5

DEVICE = xc5vsx95tff1136-1

LANGUAGE = vhdl

SEARCHPATHOPT = 
GLOBAL_SEARCHPATHOPT = 

SUBMODULE_OPT = 

PLATGEN_OPTIONS = -p $(DEVICE) -lang $(LANGUAGE) $(SEARCHPATHOPT) $(SUBMODULE_OPT) -msg __xps/ise/xmsgprops.lst

LIBGEN_OPTIONS = -mhs $(MHSFILE) -p $(DEVICE) $(SEARCHPATHOPT) -msg __xps/ise/xmsgprops.lst

OBSERVE_PAR_OPTIONS = -error yes

MICROBLAZE_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/microblaze/mb_bootloop.elf
PPC405_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc405/ppc_bootloop.elf
PPC440_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc440/ppc440_bootloop.elf
BOOTLOOP_DIR = bootloops

EPB_OPB_BRIDGE_INST_BOOTLOOP = $(BOOTLOOP_DIR)/epb_opb_bridge_inst.elf

BRAMINIT_ELF_FILES =  
BRAMINIT_ELF_FILE_ARGS =  

ALL_USER_ELF_FILES = 

SIM_CMD = vsim

BEHAVIORAL_SIM_SCRIPT = simulation/behavioral/$(SYSTEM)_setup.do

STRUCTURAL_SIM_SCRIPT = simulation/structural/$(SYSTEM)_setup.do

TIMING_SIM_SCRIPT = simulation/timing/$(SYSTEM)_setup.do

DEFAULT_SIM_SCRIPT = $(BEHAVIORAL_SIM_SCRIPT)

MIX_LANG_SIM_OPT = -mixed yes

SIMGEN_OPTIONS = -p $(DEVICE) -lang $(LANGUAGE) $(SEARCHPATHOPT) $(BRAMINIT_ELF_FILE_ARGS) $(MIX_LANG_SIM_OPT) -msg __xps/ise/xmsgprops.lst -s mti


LIBRARIES =  \
       epb_opb_bridge_inst/lib/libxil.a 

LIBSCLEAN_TARGETS = epb_opb_bridge_inst_libsclean 

PROGRAMCLEAN_TARGETS = 

CORE_STATE_DEVELOPMENT_FILES = /home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/pcores/opb_dram_sniffer_v1_00_a/netlist/read_history_fifo.ngc \
/home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/pcores/async_dram_v1_00_a/netlist/rd_fifo_bram.ngc \
/home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/pcores/async_dram_v1_00_a/netlist/rd_fifo_dist.ngc \
/home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/pcores/async_dram_v1_00_a/netlist/data_fifo_dist.ngc \
/home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/pcores/async_dram_v1_00_a/netlist/transaction_fifo_dist.ngc \
/home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/pcores/adc_mkid_interface_v1_00_a/netlist/async_fifo_24x128.ngc \
pcores/roach_infrastructure_v1_00_a/hdl/verilog/roach_infrastructure.v \
pcores/reset_block_v1_00_a/hdl/verilog/reset_block.v \
pcores/epb_opb_bridge_v1_00_a/hdl/verilog/epb_opb_bridge.v \
pcores/epb_infrastructure_v1_00_a/hdl/verilog/epb_infrastructure.v \
pcores/sys_block_v1_00_a/hdl/verilog/sys_block.v \
pcores/opb_dram_sniffer_v1_00_a/hdl/verilog/opb_dram_sniffer.v \
pcores/opb_dram_sniffer_v1_00_a/hdl/verilog/ctrl_opb_attach.v \
pcores/opb_dram_sniffer_v1_00_a/hdl/verilog/mem_opb_attach.v \
pcores/opb_dram_sniffer_v1_00_a/hdl/verilog/read_history_fifo.v \
pcores/opb_dram_sniffer_v1_00_a/hdl/verilog/dram_arbiter.v \
pcores/async_dram_v1_00_a/hdl/verilog/async_dram.v \
pcores/async_dram_v1_00_a/hdl/verilog/rd_fifo_bram.v \
pcores/async_dram_v1_00_a/hdl/verilog/rd_fifo_dist.v \
pcores/async_dram_v1_00_a/hdl/verilog/data_fifo_dist.v \
pcores/async_dram_v1_00_a/hdl/verilog/transaction_fifo_dist.v \
pcores/opb_register_ppc2simulink_v1_00_a/hdl/verilog/opb_register_ppc2simulink.v \
pcores/opb_register_simulink2ppc_v1_00_a/hdl/verilog/opb_register_simulink2ppc.v \
pcores/adc_mkid_interface_v1_00_a/hdl/vhdl/adc_mkid_interface.vhd \
pcores/adc_mkid_interface_v1_00_a/hdl/vhdl/async_fifo_24x128.vhd \
pcores/bram_if_v1_00_a/hdl/vhdl/bram_if.vhd \
pcores/gpio_simulink2ext_v1_00_a/hdl/vhdl/gpio_simulink2ext.vhd

WRAPPER_NGC_FILES = implementation/infrastructure_inst_wrapper.ngc \
implementation/reset_block_inst_wrapper.ngc \
implementation/opb0_wrapper.ngc \
implementation/epb_opb_bridge_inst_wrapper.ngc \
implementation/epb_infrastructure_inst_wrapper.ngc \
implementation/sys_block_inst_wrapper.ngc \
implementation/dram_infrastructure_inst_wrapper.ngc \
implementation/dram_controller_inst_wrapper.ngc \
implementation/opb_dram_sniffer_inst_wrapper.ngc \
implementation/async_dram_1_wrapper.ngc \
implementation/chan_512_dram_lut_lut_size_wrapper.ngc \
implementation/chan_512_dram_lut_rd_valid_wrapper.ngc \
implementation/chan_512_fir_b0b1_wrapper.ngc \
implementation/chan_512_fir_b10b11_wrapper.ngc \
implementation/chan_512_fir_b12b13_wrapper.ngc \
implementation/chan_512_fir_b14b15_wrapper.ngc \
implementation/chan_512_fir_b16b17_wrapper.ngc \
implementation/chan_512_fir_b18b19_wrapper.ngc \
implementation/chan_512_fir_b20b21_wrapper.ngc \
implementation/chan_512_fir_b22b23_wrapper.ngc \
implementation/chan_512_fir_b24b25_wrapper.ngc \
implementation/chan_512_fir_b2b3_wrapper.ngc \
implementation/chan_512_fir_b4b5_wrapper.ngc \
implementation/chan_512_fir_b6b7_wrapper.ngc \
implementation/chan_512_fir_b8b9_wrapper.ngc \
implementation/chan_512_fir_load_coeff_wrapper.ngc \
implementation/chan_512_lo_sle_wrapper.ngc \
implementation/chan_512_ser_di_wrapper.ngc \
implementation/chan_512_swat_le_wrapper.ngc \
implementation/chan_512_adc_mkid_wrapper.ngc \
implementation/chan_512_avgiq_addr_wrapper.ngc \
implementation/chan_512_avgiq_bram_ramif_wrapper.ngc \
implementation/chan_512_avgiq_bram_ramblk_wrapper.ngc \
implementation/chan_512_avgiq_bram_wrapper.ngc \
implementation/chan_512_avgiq_ctrl_wrapper.ngc \
implementation/chan_512_bins_wrapper.ngc \
implementation/chan_512_capture_load_thresh_wrapper.ngc \
implementation/chan_512_capture_threshold_wrapper.ngc \
implementation/chan_512_ch_we_wrapper.ngc \
implementation/chan_512_conv_phase_centers_wrapper.ngc \
implementation/chan_512_conv_phase_load_centers_wrapper.ngc \
implementation/chan_512_dac_mkid_wrapper.ngc \
implementation/chan_512_gpio_a0_wrapper.ngc \
implementation/chan_512_gpio_a1_wrapper.ngc \
implementation/chan_512_gpio_a2_wrapper.ngc \
implementation/chan_512_gpio_a3_wrapper.ngc \
implementation/chan_512_gpio_a5_wrapper.ngc \
implementation/chan_512_if_switch_wrapper.ngc \
implementation/chan_512_load_bins_wrapper.ngc \
implementation/chan_512_pulses_addr_wrapper.ngc \
implementation/chan_512_pulses_bram0_ramif_wrapper.ngc \
implementation/chan_512_pulses_bram0_ramblk_wrapper.ngc \
implementation/chan_512_pulses_bram0_wrapper.ngc \
implementation/chan_512_pulses_bram1_ramif_wrapper.ngc \
implementation/chan_512_pulses_bram1_ramblk_wrapper.ngc \
implementation/chan_512_pulses_bram1_wrapper.ngc \
implementation/chan_512_regs_wrapper.ngc \
implementation/chan_512_seconds_wrapper.ngc \
implementation/chan_512_snapphase_addr_wrapper.ngc \
implementation/chan_512_snapphase_bram_ramif_wrapper.ngc \
implementation/chan_512_snapphase_bram_ramblk_wrapper.ngc \
implementation/chan_512_snapphase_bram_wrapper.ngc \
implementation/chan_512_snapphase_ctrl_wrapper.ngc \
implementation/chan_512_start_wrapper.ngc \
implementation/chan_512_startaccumulator_wrapper.ngc \
implementation/chan_512_startbuffer_wrapper.ngc \
implementation/chan_512_startdac_wrapper.ngc \
implementation/chan_512_startsnap_wrapper.ngc \
implementation/chan_512_stb_en_wrapper.ngc \
implementation/opb1_wrapper.ngc \
implementation/opb2opb_bridge_opb1_wrapper.ngc

POSTSYN_NETLIST = implementation/$(SYSTEM).ngc

SYSTEM_BIT = implementation/$(SYSTEM).bit

DOWNLOAD_BIT = implementation/download.bit

SYSTEM_ACE = implementation/$(SYSTEM).ace

UCF_FILE = data/system.ucf

BMM_FILE = implementation/$(SYSTEM).bmm

BITGEN_UT_FILE = etc/bitgen.ut

XFLOW_OPT_FILE = etc/fast_runtime.opt
XFLOW_DEPENDENCY = __xps/xpsxflow.opt $(XFLOW_OPT_FILE)

XPLORER_DEPENDENCY = __xps/xplorer.opt
XPLORER_OPTIONS = -p $(DEVICE) -uc $(SYSTEM).ucf -bm $(SYSTEM).bmm -max_runs 7

FPGA_IMP_DEPENDENCY = $(BMM_FILE) $(POSTSYN_NETLIST) $(UCF_FILE) $(XFLOW_DEPENDENCY)

SDK_EXPORT_DIR = /home/sean/SDR/Firmware/projects/chan_512/XPS_ROACH_base/SDK/SDK_Export/hw
SYSTEM_HW_HANDOFF = $(SDK_EXPORT_DIR)/$(SYSTEM).xml
SYSTEM_HW_HANDOFF_BIT = $(SDK_EXPORT_DIR)/$(SYSTEM).bit
SYSTEM_HW_HANDOFF_BMM = $(SDK_EXPORT_DIR)/$(SYSTEM)_bd.bmm
SYSTEM_HW_HANDOFF_DEP = $(SYSTEM_HW_HANDOFF) $(SYSTEM_HW_HANDOFF_BIT) $(SYSTEM_HW_HANDOFF_BMM)
