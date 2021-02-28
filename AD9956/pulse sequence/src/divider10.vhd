----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:25:58 02/23/2021 
-- Design Name: 
-- Module Name:    divider10 - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divider10 is
    Port ( 
		CLK_IN : in  STD_LOGIC;
      CLK_OUT : out  STD_LOGIC
	 );
end divider10;

architecture Behavioral of divider10 is
    --inner signal
	 signal cnt : std_logic_vector(3 downto 0) := (others => '0');
	 signal clk_out_inner : std_logic := '0';
begin
    CLK_OUT <= clk_out_inner;
	 
	 process(CLK_IN) begin
	     if rising_edge(CLK_IN) then
		      cnt <= cnt + 1;
				if (cnt = "0100") then
				    clk_out_inner <= not clk_out_inner;
				elsif (cnt = "1001") then
				    cnt <= "0000";
					 clk_out_inner <= not clk_out_inner;
				end if;
		  end if;
	 end process;
end Behavioral;