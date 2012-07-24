-------------------------------------------------------------------------------
-- opb2opb_bridge_opb1_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library opb_opb_lite_v1_00_a;
use opb_opb_lite_v1_00_a.all;

entity opb2opb_bridge_opb1_wrapper is
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

  attribute x_core_info : STRING;
  attribute x_core_info of opb2opb_bridge_opb1_wrapper : entity is "opb_opb_lite_v1_00_a";

end opb2opb_bridge_opb1_wrapper;

architecture STRUCTURE of opb2opb_bridge_opb1_wrapper is

  component opb_opb_lite is
    generic (
      C_OPB_DWIDTH : integer;
      C_OPB_AWIDTH : integer;
      C_NUM_DECODES : integer;
      C_DEC0_BASEADDR : std_logic_vector;
      C_DEC0_HIGHADDR : std_logic_vector;
      C_DEC1_BASEADDR : std_logic_vector;
      C_DEC1_HIGHADDR : std_logic_vector;
      C_DEC2_BASEADDR : std_logic_vector;
      C_DEC2_HIGHADDR : std_logic_vector;
      C_DEC3_BASEADDR : std_logic_vector;
      C_DEC3_HIGHADDR : std_logic_vector
    );
    port (
      MOPB_Clk : in std_logic;
      SOPB_Clk : in std_logic;
      MOPB_Rst : in std_logic;
      SOPB_Rst : in std_logic;
      SOPB_ABus : in std_logic_vector(0 to C_OPB_AWIDTH-1);
      SOPB_BE : in std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      SOPB_DBus : in std_logic_vector(0 to C_OPB_DWIDTH-1);
      SOPB_RNW : in std_logic;
      SOPB_select : in std_logic;
      SOPB_seqAddr : in std_logic;
      Sl_DBus : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sl_errAck : out std_logic;
      Sl_retry : out std_logic;
      Sl_toutSup : out std_logic;
      Sl_xferAck : out std_logic;
      M_ABus : out std_logic_vector(0 to C_OPB_AWIDTH-1);
      M_BE : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      M_busLock : out std_logic;
      M_DBus : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      M_request : out std_logic;
      M_RNW : out std_logic;
      M_select : out std_logic;
      M_seqAddr : out std_logic;
      MOPB_DBus : in std_logic_vector(0 to C_OPB_DWIDTH-1);
      MOPB_errAck : in std_logic;
      MOPB_MGrant : in std_logic;
      MOPB_retry : in std_logic;
      MOPB_timeout : in std_logic;
      MOPB_xferAck : in std_logic
    );
  end component;

begin

  opb2opb_bridge_opb1 : opb_opb_lite
    generic map (
      C_OPB_DWIDTH => 32,
      C_OPB_AWIDTH => 32,
      C_NUM_DECODES => 1,
      C_DEC0_BASEADDR => X"01080000",
      C_DEC0_HIGHADDR => X"010FFFFF",
      C_DEC1_BASEADDR => X"FFFFFFFF",
      C_DEC1_HIGHADDR => X"00000000",
      C_DEC2_BASEADDR => X"FFFFFFFF",
      C_DEC2_HIGHADDR => X"00000000",
      C_DEC3_BASEADDR => X"FFFFFFFF",
      C_DEC3_HIGHADDR => X"00000000"
    )
    port map (
      MOPB_Clk => MOPB_Clk,
      SOPB_Clk => SOPB_Clk,
      MOPB_Rst => MOPB_Rst,
      SOPB_Rst => SOPB_Rst,
      SOPB_ABus => SOPB_ABus,
      SOPB_BE => SOPB_BE,
      SOPB_DBus => SOPB_DBus,
      SOPB_RNW => SOPB_RNW,
      SOPB_select => SOPB_select,
      SOPB_seqAddr => SOPB_seqAddr,
      Sl_DBus => Sl_DBus,
      Sl_errAck => Sl_errAck,
      Sl_retry => Sl_retry,
      Sl_toutSup => Sl_toutSup,
      Sl_xferAck => Sl_xferAck,
      M_ABus => M_ABus,
      M_BE => M_BE,
      M_busLock => M_busLock,
      M_DBus => M_DBus,
      M_request => M_request,
      M_RNW => M_RNW,
      M_select => M_select,
      M_seqAddr => M_seqAddr,
      MOPB_DBus => MOPB_DBus,
      MOPB_errAck => MOPB_errAck,
      MOPB_MGrant => MOPB_MGrant,
      MOPB_retry => MOPB_retry,
      MOPB_timeout => MOPB_timeout,
      MOPB_xferAck => MOPB_xferAck
    );

end architecture STRUCTURE;

