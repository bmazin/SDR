-------------------------------------------------------------------------------
-- chan_550_simple_gpio_a3_wrapper.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

library gpio_simulink2ext_v1_00_a;
use gpio_simulink2ext_v1_00_a.all;

entity chan_550_simple_gpio_a3_wrapper is
  port (
    gateway : in std_logic_vector(0 to 0);
    io_pad : out std_logic_vector(0 to 0);
    clk : in std_logic;
    clk90 : in std_logic
  );

  attribute x_core_info : STRING;
  attribute x_core_info of chan_550_simple_gpio_a3_wrapper : entity is "gpio_simulink2ext_v1_00_a";

end chan_550_simple_gpio_a3_wrapper;

architecture STRUCTURE of chan_550_simple_gpio_a3_wrapper is

  component gpio_simulink2ext is
    generic (
      WIDTH : INTEGER;
      DDR : INTEGER;
      CLK_PHASE : INTEGER;
      REG_IOB : STRING
    );
    port (
      gateway : in std_logic_vector((WIDTH-1) to 0);
      io_pad : out std_logic_vector((WIDTH/(DDR+1))-1 to 0);
      clk : in std_logic;
      clk90 : in std_logic
    );
  end component;

begin

  chan_550_simple_gpio_a3 : gpio_simulink2ext
    generic map (
      WIDTH => 1,
      DDR => 0,
      CLK_PHASE => 0,
      REG_IOB => "true"
    )
    port map (
      gateway => gateway,
      io_pad => io_pad,
      clk => clk,
      clk90 => clk90
    );

end architecture STRUCTURE;

