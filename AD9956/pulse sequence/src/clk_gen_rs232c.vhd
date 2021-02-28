----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:06:43 09/11/2019 
-- Design Name: 
-- Module Name:    clk_gen_rs232c - Behavioral 
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
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity clk_gen_rs232c is
    Port ( CLK_IN : in  STD_LOGIC;
           CLK9600 : out  STD_LOGIC;
           CLK115200 : out  STD_LOGIC);
end clk_gen_rs232c;

architecture Behavioral of clk_gen_rs232c is

begin
	process(clk_in)
		variable cnt9600		: std_logic_vector(12-1 downto 0);
		variable cnt115200	: std_logic_vector(12-1 downto 0);
	begin
		if rising_edge(clk_in) then
			-- ボーレート11520用のクロック
			cnt115200 := cnt115200 + '1';
			if cnt115200 = 64 then
				cnt115200 := X"000";
				CLK115200 <= '1';
			else
				CLK115200 <= '0';
			end if;
			
			-- 　ボーレート9600用のクロック
			cnt9600 := cnt9600 + '1';
			if cnt9600 = 768 then
				cnt9600 := X"000";
				CLK9600 <= '1';
			else
				CLK9600 <= '0';
			end if;
		end if;
	end process;
end Behavioral;

