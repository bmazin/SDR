library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity gpio_ext2simulink is
    Generic (
    		  WIDTH : integer := 4;
    		  DDR : integer := 0;
    		  CLK_PHASE : integer := 0;
              REG_IOB : string := "true"
     );
	 Port (
		gateway   : out std_logic_vector((WIDTH)-1         downto 0);
		io_pad    : in  std_logic_vector((WIDTH/(DDR+1)-1) downto 0);

		clk       : in  std_logic;
		clk90     : in  std_logic
	 );
end gpio_ext2simulink;

architecture Behavioral of gpio_ext2simulink is
	signal sample_clk : std_logic;
	signal not_sample_clk : std_logic;
    attribute IOB: string;
	signal one  : std_logic := '1';
	signal zero : std_logic := '0';
begin

-- clock selection
	PHASE0: if CLK_PHASE = 0 generate
		sample_clk     <=     clk;
		not_sample_clk <= not clk;
	end generate PHASE0;
	PHASE90: if CLK_PHASE = 90 generate
		sample_clk     <=     clk90;
		not_sample_clk <= not clk90;
	end generate PHASE90;
	PHASE180: if CLK_PHASE = 180 generate
		sample_clk     <= not clk;
		not_sample_clk <=     clk;
	end generate PHASE180;
	PHASE270: if CLK_PHASE = 270 generate
		sample_clk     <= not clk90;
		not_sample_clk <=     clk90;
	end generate PHASE270;

-- ddr/sdr selection and register instantiation
	DDR_GEN: if DDR = 1 generate
		REG_DDR_GEN: for i in 0 to (WIDTH/(DDR+1)-1) generate
			attribute IOB of Q_REG_DDR0:label is REG_IOB;
			attribute IOB of Q_REG_DDR1:label is REG_IOB;
		begin
			Q_REG_DDR0: FD
			port map( 
				D => io_pad(i),
				Q => gateway(i*2),
				C => sample_clk
			);
			Q_REG_DDR1: FD
			port map( 
				D => io_pad(i),
				Q => gateway(i*2+1),
				C => not_sample_clk
			);
		end generate REG_DDR_GEN;
	end generate DDR_GEN;
	
	SDR_GEN: if DDR = 0 generate
		REG_SDR_GEN: for i in 0 to (WIDTH/(DDR+1)-1) generate
			attribute IOB of Q_REG_SDR:label is REG_IOB;
		begin
			Q_REG_SDR: FD
			port map( 
				D => io_pad(i),
				Q => gateway(i),
				C => sample_clk
			);
		end generate REG_SDR_GEN;
	end generate SDR_GEN;


end Behavioral;
