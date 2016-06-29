library IEEE;
use IEEE.std_logic_1164.all;

entity dark_pfb_core10 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data0: in std_logic_vector(23 downto 0); 
    data1: in std_logic_vector(23 downto 0); 
    data2: in std_logic_vector(23 downto 0); 
    data3: in std_logic_vector(23 downto 0); 
    data4: in std_logic_vector(23 downto 0); 
    data5: in std_logic_vector(23 downto 0); 
    data6: in std_logic_vector(23 downto 0); 
    data7: in std_logic_vector(23 downto 0); 
    skip_pfb: in std_logic; 
    sync_in: in std_logic; 
    bin0_t0: out std_logic_vector(35 downto 0); 
    bin0_t1: out std_logic_vector(35 downto 0); 
    bin1_t0: out std_logic_vector(35 downto 0); 
    bin1_t1: out std_logic_vector(35 downto 0); 
    bin2_t0: out std_logic_vector(35 downto 0); 
    bin2_t1: out std_logic_vector(35 downto 0); 
    bin3_t0: out std_logic_vector(35 downto 0); 
    bin3_t1: out std_logic_vector(35 downto 0); 
    bin4_t0: out std_logic_vector(35 downto 0); 
    bin4_t1: out std_logic_vector(35 downto 0); 
    bin5_t0: out std_logic_vector(35 downto 0); 
    bin5_t1: out std_logic_vector(35 downto 0); 
    bin6_t0: out std_logic_vector(35 downto 0); 
    bin6_t1: out std_logic_vector(35 downto 0); 
    bin7_t0: out std_logic_vector(35 downto 0); 
    bin7_t1: out std_logic_vector(35 downto 0); 
    bin_ctr: out std_logic_vector(7 downto 0); 
    fft_rdy: out std_logic; 
    overflow: out std_logic_vector(3 downto 0)
  );
end dark_pfb_core10;

architecture structural of dark_pfb_core10 is
begin
end structural;

