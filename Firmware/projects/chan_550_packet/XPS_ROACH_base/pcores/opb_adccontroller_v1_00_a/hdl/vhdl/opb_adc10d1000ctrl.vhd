------------------------------------------------------------------------------
-- opb_adccontroller.vhd - entity/architecture pair
------------------------------------------------------------------------------

-- ***************************************************************************
-- ** Copyright (c) 1995-2004 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ** YOU MAY COPY AND MODIFY THESE FILES FOR YOUR OWN INTERNAL USE SOLELY  **
-- ** WITH XILINX PROGRAMMABLE LOGIC DEVICES AND XILINX EDK SYSTEM OR       **
-- ** CREATE IP MODULES SOLELY FOR XILINX PROGRAMMABLE LOGIC DEVICES AND    **
-- ** XILINX EDK SYSTEM. NO RIGHTS ARE GRANTED TO DISTRIBUTE ANY FILES      **
-- ** UNLESS THEY ARE DISTRIBUTED IN XILINX PROGRAMMABLE LOGIC DEVICES.     **
-- **                                                                       **
-- ***************************************************************************
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v2_00_a;
use proc_common_v2_00_a.proc_common_pkg.all;
use proc_common_v2_00_a.ipif_pkg.all;

library opb_ipif_v3_01_a;
use opb_ipif_v3_01_a.all;

library opb_adc10d1000ctrl_v1_00_a;
use opb_adc10d1000ctrl_v1_00_a.all;

--------------------------------------------------------------------------------
-- Entity section
--------------------------------------------------------------------------------

entity opb_adc10d1000ctrl is
  generic
    (
      -- Bus protocol parameters
      C_BASEADDR    : std_logic_vector := X"00000000";
      C_HIGHADDR    : std_logic_vector := X"0000FFFF";
      C_OPB_AWIDTH  : integer          := 32;
      C_OPB_DWIDTH  : integer          := 32;
      C_FAMILY      : string           := "virtex2p";
      AUTOCONFIG_0  : integer          := 0;
      INTERLEAVED_0 : integer          := 0;
      AUTOCONFIG_1  : integer          := 0;
      INTERLEAVED_1 : integer          := 0
      );
  port
    (
      --------------------------------------
      -- configuration signals to LFSW35105
      --------------------------------------
      adc_syns_rst_o       : out std_logic := '0';
      adc_syns_errflag_i   : in std_logic  := '0';
      adc_syns_le_o        : out std_logic := '0';
      adc_syns_mosi_o      : out std_logic := '0';
      adc_syns_sclk_o      : out std_logic := '0';
      adc0_dcm_reset       : out std_logic := '0';
      adc0_psclk           : out std_logic := '0';
      adc0_psen            : out std_logic := '0';
      adc0_psincdec        : out std_logic := '0';
      adc0_psdone          : in  std_logic := '0';
      adc0_clk             : in  std_logic := '0';

      --------------------------------------
      -- configuration signals to ADC10D1000
      --------------------------------------
	adc_scsb_o	   : out std_logic;
	adc_sclk_o	   : out std_logic;
	adc_sdi		   : in  std_logic;
	adc_sdo		   : out std_logic;
	adc_ece_o	   : out std_logic;
	adc_calrun_i       : in  std_logic;

      --------------------------------------
      -- configuration signals to attenuator
      --------------------------------------
	adc_attn_i_le		: out std_logic;
	adc_attn_i_data         : out std_logic;
	adc_attn_i_clk		: out std_logic;
	adc_attn_q_le		: out std_logic;
	adc_attn_q_data         : out std_logic;
	adc_attn_q_clk		: out std_logic;

      --------------------------------------
      -- interface to temperature sensor
      --------------------------------------

	adc_temp_cs		: out std_logic;
	adc_temp_sck		: out std_logic;
	adc_temp_sdo		: in  std_logic;

      --------------------------------------
      -- Bus protocol ports
      --------------------------------------
      OPB_Clk     : in  std_logic;
      OPB_Rst     : in  std_logic;
      Sl_DBus     : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sl_errAck   : out std_logic;
      Sl_retry    : out std_logic;
      Sl_toutSup  : out std_logic;
      Sl_xferAck  : out std_logic;
      OPB_ABus    : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE      : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_DBus    : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW     : in  std_logic;
      OPB_select  : in  std_logic;
      OPB_seqAddr : in  std_logic
      );

  attribute MIN_SIZE               : string;
  attribute MIN_SIZE of C_BASEADDR : constant is "0x100";

  attribute SIGIS            : string;
  attribute SIGIS of OPB_Clk : signal is "Clk";
  attribute SIGIS of OPB_Rst : signal is "Rst";

end entity opb_adc10d1000ctrl;

--------------------------------------------------------------------------------
-- Architecture section
--------------------------------------------------------------------------------

architecture IMP of opb_adc10d1000ctrl is

  ----------------------------------------
  -- Constant: array of address range identifiers
  ----------------------------------------
  constant ARD_ID_ARRAY : INTEGER_ARRAY_TYPE :=
    (
      0 => USER_00                      -- user logic S/W register address space
      );

  ----------------------------------------
  -- Constant: array of address pairs for each address range
  ----------------------------------------
  constant ZERO_ADDR_PAD : std_logic_vector(0 to 64-C_OPB_AWIDTH-1) := (others => '0');

  constant USER_BASEADDR : std_logic_vector := C_BASEADDR;
  constant USER_HIGHADDR : std_logic_vector := C_HIGHADDR;

  constant ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE :=
    (
      ZERO_ADDR_PAD & USER_BASEADDR,    -- user logic base address
      ZERO_ADDR_PAD & USER_HIGHADDR     -- user logic high address
      );

  ----------------------------------------
  -- Constant: array of data widths for each target address range
  ----------------------------------------
  constant USER_DWIDTH : integer := 32;

  constant ARD_DWIDTH_ARRAY : INTEGER_ARRAY_TYPE :=
    (
      0 => USER_DWIDTH                  -- user logic data width
      );

  ----------------------------------------
  -- Constant: array of desired number of chip enables for each address range
  ----------------------------------------
  constant USER_NUM_CE : integer := 6;

  constant ARD_NUM_CE_ARRAY : INTEGER_ARRAY_TYPE :=
    (
      0 => pad_power2(USER_NUM_CE)      -- user logic number of CEs
      );

  ----------------------------------------
  -- Constant: array of unique properties for each address range
  ----------------------------------------
  constant ARD_DEPENDENT_PROPS_ARRAY : DEPENDENT_PROPS_ARRAY_TYPE :=
    (
      0 => (others => 0)                -- user logic slave space dependent properties (none defined)
      );

  ----------------------------------------
  -- Constant: pipeline mode
  -- 1 = include OPB-In pipeline registers
  -- 2 = include IP pipeline registers
  -- 3 = include OPB-In and IP pipeline registers
  -- 4 = include OPB-Out pipeline registers
  -- 5 = include OPB-In and OPB-Out pipeline registers
  -- 6 = include IP and OPB-Out pipeline registers
  -- 7 = include OPB-In, IP, and OPB-Out pipeline registers
  -- Note:
  -- only mode 4, 5, 7 are supported for this release
  ----------------------------------------
  constant PIPELINE_MODEL : integer := 5;

  ----------------------------------------
  -- Constant: user core ID code
  ----------------------------------------
  constant DEV_BLK_ID : integer := 0;

  ----------------------------------------
  -- Constant: enable MIR/Reset register
  ----------------------------------------
  constant DEV_MIR_ENABLE : integer := 0;

  ----------------------------------------
  -- Constant: array of IP interrupt mode
  -- 1 = Active-high interrupt condition
  -- 2 = Active-low interrupt condition
  -- 3 = Active-high pulse interrupt event
  -- 4 = Active-low pulse interrupt event
  -- 5 = Positive-edge interrupt event
  -- 6 = Negative-edge interrupt event
  ----------------------------------------
  constant IP_INTR_MODE_ARRAY : INTEGER_ARRAY_TYPE :=
    (
      0 => 0                            -- not used
      );

  ----------------------------------------
  -- Constant: enable device burst
  ----------------------------------------
  constant DEV_BURST_ENABLE : integer := 0;

  ----------------------------------------
  -- Constant: include address counter for burst transfers
  ----------------------------------------
  constant INCLUDE_ADDR_CNTR : integer := 0;

  ----------------------------------------
  -- Constant: include write buffer that decouples OPB and IPIC write transactions
  ----------------------------------------
  constant INCLUDE_WR_BUF : integer := 0;

  ----------------------------------------
  -- Constant: index for CS/CE
  ----------------------------------------
  constant USER00_CS_INDEX : integer := get_id_index(ARD_ID_ARRAY, USER_00);

  constant USER00_CE_INDEX : integer := calc_start_ce_index(ARD_NUM_CE_ARRAY, USER00_CS_INDEX);

	component adc_config_mux
		generic(
	    INTERLEAVED     : integer	:= 0
		);
		port (
      clk             : in  std_logic;
      rst             : in  std_logic;
      request         : in  std_logic;
      ddrb_i          : in  std_logic;
      config_start_i  : in  std_logic;
      config_busy_o   : out std_logic;
      config_data_i   : in  std_logic_vector(15 downto 0);
      syns_done_o     : out std_logic;
      ddrb_o          : out std_logic;
      dcm_reset_o     : out std_logic;
      ctrl_clk_o      : out std_logic;
      ctrl_strb_o     : out std_logic;
      ctrl_data_o     : out std_logic
		);
	end component;

	component adc10d1000_ctrl
	port (
		clk		   : in  std_logic;
		rst                : in  std_logic;
		request_i          : in  std_logic;
		syns_done_i	   : in  std_logic;
		adc_start_i	   : in  std_logic;
		adc_rw_i	   : in  std_logic;
		adc_addr_i	   : in  std_logic_vector(0 to 6);
		adc_data_i	   : in  std_logic_vector(0 to 15);
		adc_ece_i	   : in  std_logic;
		adc_busy_o	   : out std_logic;
		adc_data_o         : out std_logic_vector(0 to 15);
		adc_scsb_o	   : out std_logic;
		adc_sclk_o	   : out std_logic;
		adc_sdi		   : in  std_logic;
		adc_sdo		   : out std_logic;
		adc_ece_o	   : out std_logic;
		adc_calrun_i       : in  std_logic
		);
	end component;


	component adc10d1000_attn
	port (
		clk		   : in  std_logic;
		rst                : in  std_logic;
		request_i          : in  std_logic;
		adc_attn_i_start   : in  std_logic;
		adc_attn_i	   : in  std_logic_vector(0 to 4);
		adc_attn_q_start   : in  std_logic;
		adc_attn_q	   : in  std_logic_vector(0 to 4);
		adc_attn_i_le	   : out std_logic;
		adc_attn_i_data	   : out std_logic;
		adc_attn_i_clk     : out std_logic;
		adc_attn_q_le	   : out std_logic;
		adc_attn_q_data	   : out std_logic;
		adc_attn_q_clk	   : out std_logic
		);
	end component;

	component adc10d1000_temp
		port(
		clk		   : in  std_logic;
		rst                : in  std_logic;
		request_i          : in  std_logic;
		adc_temp_start     : in  std_logic;
		adc_temp_cs	   : out std_logic;
		adc_temp_sck       : out std_logic;
		adc_temp_sdo       : in  std_logic;
		adc_temp_data	   : out std_logic_vector(12 downto 0)
		);
	 end component;

  ----------------------------------------
  -- IP Interconnect (IPIC) signal declarations
  ----------------------------------------
  signal iBus2IP_RdCE            : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
  signal iBus2IP_WrCE            : std_logic_vector(0 to calc_num_ce(ARD_NUM_CE_ARRAY)-1);
  signal iBus2IP_Data            : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal iBus2IP_BE              : std_logic_vector(0 to C_OPB_DWIDTH/8-1);
  signal iIP2Bus_Data            : std_logic_vector(0 to C_OPB_DWIDTH-1)              := (others => '0');
  signal iIP2Bus_Ack             : std_logic                                          := '0';
  signal iIP2Bus_Error           : std_logic                                          := '0';
  signal iIP2Bus_Retry           : std_logic                                          := '0';
  signal iIP2Bus_ToutSup         : std_logic                                          := '0';
  signal ZERO_IP2Bus_PostedWrInh : std_logic_vector(0 to ARD_ID_ARRAY'length-1)       := (others => '0');  -- work around for XST not taking (others => '0') in port mapping
  signal ZERO_IP2RFIFO_Data      : std_logic_vector(0 to 31)                          := (others => '0');  -- work around for XST not taking (others => '0') in port mapping
  signal ZERO_WFIFO2IP_Data      : std_logic_vector(0 to 31)                          := (others => '0');  -- work around for XST not taking (others => '0') in port mapping
  signal ZERO_IP2Bus_IntrEvent   : std_logic_vector(0 to IP_INTR_MODE_ARRAY'length-1) := (others => '0');  -- work around for XST not taking (others => '0') in port mapping
  signal iBus2IP_Clk             : std_logic;
  signal iBus2IP_Reset           : std_logic;
  signal uBus2IP_Data            : std_logic_vector(0 to USER_DWIDTH-1);
  signal uBus2IP_BE              : std_logic_vector(0 to USER_DWIDTH/8-1);
  signal uBus2IP_RdCE            : std_logic_vector(0 to USER_NUM_CE-1);
  signal uBus2IP_WrCE            : std_logic_vector(0 to USER_NUM_CE-1);
  signal uIP2Bus_Data            : std_logic_vector(0 to USER_DWIDTH-1);

  ----------------------------------------
  -- Signals for ADC10D1000
  ----------------------------------------
  signal adc_ctrl_request        : std_logic;
  signal adc_syns_start          : std_logic;
  signal adc_syns_data           : std_logic_vector(15 downto 0);
  signal adc_syns_busy           : std_logic;
  signal adc_syns_rst_int        : std_logic;

  signal adc_syns_rst            : std_logic;
  signal adc_syns_errflag        : std_logic;
  signal adc_syns_le             : std_logic;
  signal adc_syns_mosi           : std_logic;
  signal adc_syns_sclk           : std_logic;

  ----------------------------------------
  -- Signals for ADC10D1000
  ----------------------------------------
  signal adc_start		: std_logic;
  signal adc_rw			: std_logic;
  signal adc_addr		: std_logic_vector(0 to 6);
--  signal adc_data		: std_logic_vector(0 to 15);
  signal adc_busy		: std_logic;
  signal adc_data_sdi		: std_logic_vector(0 to 15);
  signal adc_data_sdo		: std_logic_vector(0 to 15);
  signal adc_request		: std_logic;
  signal syns_done		: std_logic;
  signal adc_ece		: std_logic;

  signal adc_attn_i		: std_logic_vector(0 to 4);
  signal adc_attn_i_start	: std_logic;
  signal adc_attn_q		: std_logic_vector(0 to 4);
  signal adc_attn_q_start	: std_logic;

  signal adc_temp_start		: std_logic;
  signal adc_temp		: std_logic_vector(12 downto 0);

begin

  ----------------------------------------
  -- instantiate the OPB IPIF
  ----------------------------------------
  OPB_IPIF_I : entity opb_ipif_v3_01_a.opb_ipif
    generic map
    (
      C_ARD_ID_ARRAY              => ARD_ID_ARRAY,
      C_ARD_ADDR_RANGE_ARRAY      => ARD_ADDR_RANGE_ARRAY,
      C_ARD_DWIDTH_ARRAY          => ARD_DWIDTH_ARRAY,
      C_ARD_NUM_CE_ARRAY          => ARD_NUM_CE_ARRAY,
      C_ARD_DEPENDENT_PROPS_ARRAY => ARD_DEPENDENT_PROPS_ARRAY,
      C_PIPELINE_MODEL            => PIPELINE_MODEL,
      C_DEV_BLK_ID                => DEV_BLK_ID,
      C_DEV_MIR_ENABLE            => DEV_MIR_ENABLE,
      C_OPB_AWIDTH                => C_OPB_AWIDTH,
      C_OPB_DWIDTH                => C_OPB_DWIDTH,
      C_FAMILY                    => C_FAMILY,
      C_IP_INTR_MODE_ARRAY        => IP_INTR_MODE_ARRAY,
      C_DEV_BURST_ENABLE          => DEV_BURST_ENABLE,
      C_INCLUDE_ADDR_CNTR         => INCLUDE_ADDR_CNTR,
      C_INCLUDE_WR_BUF            => INCLUDE_WR_BUF
      )
    port map
    (
      OPB_select                  => OPB_select,
      OPB_DBus                    => OPB_DBus,
      OPB_ABus                    => OPB_ABus,
      OPB_BE                      => OPB_BE,
      OPB_RNW                     => OPB_RNW,
      OPB_seqAddr                 => OPB_seqAddr,
      Sln_DBus                    => Sl_DBus,
      Sln_xferAck                 => Sl_xferAck,
      Sln_errAck                  => Sl_errAck,
      Sln_retry                   => Sl_retry,
      Sln_toutSup                 => Sl_toutSup,
      Bus2IP_CS                   => open,
      Bus2IP_CE                   => open,
      Bus2IP_RdCE                 => iBus2IP_RdCE,
      Bus2IP_WrCE                 => iBus2IP_WrCE,
      Bus2IP_Data                 => iBus2IP_Data,
      Bus2IP_Addr                 => open,
      Bus2IP_AddrValid            => open,
      Bus2IP_BE                   => iBus2IP_BE,
      Bus2IP_RNW                  => open,
      Bus2IP_Burst                => open,
      IP2Bus_Data                 => iIP2Bus_Data,
      IP2Bus_Ack                  => iIP2Bus_Ack,
      IP2Bus_AddrAck              => '0',
      IP2Bus_Error                => iIP2Bus_Error,
      IP2Bus_Retry                => iIP2Bus_Retry,
      IP2Bus_ToutSup              => iIP2Bus_ToutSup,
      IP2Bus_PostedWrInh          => ZERO_IP2Bus_PostedWrInh,
      IP2RFIFO_Data               => ZERO_IP2RFIFO_Data,
      IP2RFIFO_WrMark             => '0',
      IP2RFIFO_WrRelease          => '0',
      IP2RFIFO_WrReq              => '0',
      IP2RFIFO_WrRestore          => '0',
      RFIFO2IP_AlmostFull         => open,
      RFIFO2IP_Full               => open,
      RFIFO2IP_Vacancy            => open,
      RFIFO2IP_WrAck              => open,
      IP2WFIFO_RdMark             => '0',
      IP2WFIFO_RdRelease          => '0',
      IP2WFIFO_RdReq              => '0',
      IP2WFIFO_RdRestore          => '0',
      WFIFO2IP_AlmostEmpty        => open,
      WFIFO2IP_Data               => ZERO_WFIFO2IP_Data,
      WFIFO2IP_Empty              => open,
      WFIFO2IP_Occupancy          => open,
      WFIFO2IP_RdAck              => open,
      IP2Bus_IntrEvent            => ZERO_IP2Bus_IntrEvent,
      IP2INTC_Irpt                => open,
      Freeze                      => '0',
      Bus2IP_Freeze               => open,
      OPB_Clk                     => OPB_Clk,
      Bus2IP_Clk                  => iBus2IP_Clk,
      IP2Bus_Clk                  => '0',
      Reset                       => OPB_Rst,
      Bus2IP_Reset                => iBus2IP_Reset
      );

  ----------------------------------------
  -- instantiate the User Logic
  ----------------------------------------
  USER_LOGIC_I : entity opb_adc10d1000ctrl_v1_00_a.user_logic
    generic map
    (
      C_DWIDTH     => USER_DWIDTH,
      C_NUM_CE     => USER_NUM_CE,
      AUTOCONFIG_0 => AUTOCONFIG_0,
      AUTOCONFIG_1 => AUTOCONFIG_1
      )
    port map
    (
      --------------------------------------
      -- configuration signals to synthersizer and DCM
      --------------------------------------
      adc_ctrl_request_o   => adc_ctrl_request    ,
      adc_syns_start_o     => adc_syns_start      ,
      adc_syns_data_o      => adc_syns_data       ,
      adc_syns_busy_i      => adc_syns_busy       ,
      adc_syns_rst_o       => adc_syns_rst_int    ,
      adc0_psclk           => adc0_psclk          ,
      adc0_psen            => adc0_psen           ,
      adc0_psincdec        => adc0_psincdec       ,
      adc0_psdone          => adc0_psdone         ,
      adc0_clk             => adc0_clk            ,
      adc_syns_errflag	   => adc_syns_errflag    ,

      --------------------------------------
      -- configuration signals to ADC10D1000
      --------------------------------------
      adc_start_o	   => adc_start		,
      adc_rw_o		   => adc_rw		,
      adc_addr_o	   => adc_addr		,
      adc_data_o	   => adc_data_sdo	,
      adc_ece_o		   => adc_ece		,
      adc_busy_i	   => adc_busy		,
      adc_data_i           => adc_data_sdi	,
      adc_calrun_i         => adc_calrun_i	,
      adc_request_o	   => adc_request	,
      adc_attn_i_start	   => adc_attn_i_start  ,
      adc_attn_i	   => adc_attn_i	,
      adc_attn_q_start     => adc_attn_q_start  ,
      adc_attn_q	   => adc_attn_q	,
      adc_temp_start_o     => adc_temp_start    ,
      adc_temp_i	   => adc_temp		,

      -- Bus protocol ports
      Bus2IP_Clk => iBus2IP_Clk,
      Bus2IP_Reset => iBus2IP_Reset,
      Bus2IP_Data => uBus2IP_Data,
      Bus2IP_BE => uBus2IP_BE,
      Bus2IP_RdCE => uBus2IP_RdCE,
      Bus2IP_WrCE => uBus2IP_WrCE,
      IP2Bus_Data => uIP2Bus_Data,
      IP2Bus_Ack => iIP2Bus_Ack,
      IP2Bus_Retry => iIP2Bus_Retry,
      IP2Bus_Error => iIP2Bus_Error,
      IP2Bus_ToutSup => iIP2Bus_ToutSup
      );

  ----------------------------------------
  -- hooking up signal slicing
  ----------------------------------------
  uBus2IP_BE <= iBus2IP_BE(0 to USER_DWIDTH/8-1);
  uBus2IP_Data <= iBus2IP_Data(0 to USER_DWIDTH-1);
  uBus2IP_RdCE <= iBus2IP_RdCE(USER00_CE_INDEX to USER00_CE_INDEX+USER_NUM_CE-1);
  uBus2IP_WrCE <= iBus2IP_WrCE(USER00_CE_INDEX to USER00_CE_INDEX+USER_NUM_CE-1);
  iIP2Bus_Data(0 to USER_DWIDTH-1) <= uIP2Bus_Data;

  --- ADC Configuration Autoconfig/Multiplexors

  adc_syns_rst_o   <= adc_syns_rst;
  adc_syns_errflag <= adc_syns_errflag_i;
  adc_syns_le_o    <= adc_syns_le;
  adc_syns_mosi_o  <= adc_syns_mosi;
  adc_syns_sclk_o  <= adc_syns_sclk;

  adc_config_mux_0 : adc_config_mux
    generic map
    (
      INTERLEAVED => 0
    )
    port map
    (
      clk              => iBus2IP_Clk,
      rst              => iBus2IP_Reset,
      request          => adc_ctrl_request ,
      ddrb_i           => adc_syns_rst_int,

      config_start_i   => adc_syns_start,
      config_busy_o    => adc_syns_busy ,
      config_data_i    => adc_syns_data ,
      syns_done_o      => syns_done, 

      ddrb_o           => adc_syns_rst,
      dcm_reset_o      => adc0_dcm_reset,
      ctrl_clk_o       => adc_syns_sclk,
      ctrl_strb_o      => adc_syns_le,
      ctrl_data_o      => adc_syns_mosi
  );

  adc10d1000_ctrl_0 : adc10d1000_ctrl
	port map(
		clk		   => iBus2IP_Clk,
		rst                => iBus2IP_Reset,
		request_i          => adc_ctrl_request,
		syns_done_i	   => syns_done,
		adc_start_i	   => adc_start,
		adc_rw_i	   => adc_rw,
		adc_addr_i	   => adc_addr,
		adc_data_i	   => adc_data_sdo,
		adc_ece_i	   => adc_ece,
		adc_busy_o	   => adc_busy,
		adc_data_o         => adc_data_sdi,
		adc_scsb_o	   => adc_scsb_o,
		adc_sclk_o	   => adc_sclk_o,
		adc_sdi		   => adc_sdi,
		adc_sdo		   => adc_sdo,
		adc_ece_o	   => adc_ece_o,
		adc_calrun_i       => adc_calrun_i
		);
  adc10d1000_attn_0 : adc10d1000_attn
	port map(
		clk		   => iBus2IP_Clk,
		rst                => iBus2IP_Reset,
		request_i          => adc_ctrl_request,
		adc_attn_i_start   => adc_attn_i_start,
		adc_attn_i	   => adc_attn_i,
		adc_attn_q_start   => adc_attn_q_start,
		adc_attn_q	   => adc_attn_q,
		adc_attn_i_le	   => adc_attn_i_le,
		adc_attn_i_data    => adc_attn_i_data,
		adc_attn_i_clk     => adc_attn_i_clk,
		adc_attn_q_le	   => adc_attn_q_le,
		adc_attn_q_data    => adc_attn_q_data,
		adc_attn_q_clk     => adc_attn_q_clk
		);
 adc10d1000_temp_0 : adc10d1000_temp
   port map
   (
	clk			=> iBus2IP_Clk,
	rst			=> iBus2IP_Reset,
	request_i		=> adc_ctrl_request,
	adc_temp_start   	=> adc_temp_start,
	adc_temp_cs		=> adc_temp_cs,
	adc_temp_sck		=> adc_temp_sck,
	adc_temp_sdo		=> adc_temp_sdo,
	adc_temp_data		=> adc_temp
	);

end IMP;
