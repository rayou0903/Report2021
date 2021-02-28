----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:03:16 11/27/2019 
-- Design Name: 
-- Module Name:    counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--kopipeyou
--component counter is
--	port( clk : in std_logic;
--			rst : in std_logic;
--			
--			start : in std_logic;
--			fin_sig : out std_logic	
--	);
--end component;
--
--count_test : counter 
--	port map( clk => ,
--				 rst => ,
--			
--				 start => ,
--				 fin_sig =>	
--	);
--end counter;


entity counter is
	port( clk : in std_logic;
			rst : in std_logic;
			
			start : in std_logic;
			fin_sig : out std_logic	
	);
end counter;

architecture Behavioral of counter is

	signal counter : std_logic_vector(63 downto 0):= (others => '0');
	signal out_sig : std_logic;
	
	constant max : std_logic_vector(63 downto 0):= X"00000000000186A0";
	constant high_time : std_logic_vector(63 downto 0):= X"00000000000186A0";

begin
	
	process(clk,rst,start)
	begin
		if rst = '1' then
			counter <= (others => '0');
			out_sig <= '0';
		elsif clk' event and clk = '1' then
			if start = '1' then
				if out_sig = '0' then
					if counter = max then
						counter <= (others => '0');
						out_sig <= '1';
					else
						counter <= counter +1;
					end if;
				else
					if counter = high_time then
						counter <= (others => '0');
						out_sig <= '0';
					else
						counter <= counter +1;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	fin_sig <= out_sig;

end Behavioral;

