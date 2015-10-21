library IEEE;
use IEEE.std_logic_1164.all;

entity dark_pfb_core3 is
  port (
    ce_1: in std_logic; 
    clk_1: in std_logic; 
    data_i0: in std_logic_vector(11 downto 0); 
    data_i1: in std_logic_vector(11 downto 0); 
    data_i2: in std_logic_vector(11 downto 0); 
    data_i3: in std_logic_vector(11 downto 0); 
    data_i4: in std_logic_vector(11 downto 0); 
    data_i5: in std_logic_vector(11 downto 0); 
    data_i6: in std_logic_vector(11 downto 0); 
    data_i7: in std_logic_vector(11 downto 0); 
    data_q0: in std_logic_vector(11 downto 0); 
    data_q1: in std_logic_vector(11 downto 0); 
    data_q2: in std_logic_vector(11 downto 0); 
    data_q3: in std_logic_vector(11 downto 0); 
    data_q4: in std_logic_vector(11 downto 0); 
    data_q5: in std_logic_vector(11 downto 0); 
    data_q6: in std_logic_vector(11 downto 0); 
    data_q7: in std_logic_vector(11 downto 0); 
    sync_in: in std_logic; 
    fft_out: out std_logic_vector(575 downto 0); 
    fft_rdy: out std_logic
  );
end dark_pfb_core3;

architecture structural of dark_pfb_core3 is
begin
end structural;

