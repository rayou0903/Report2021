----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:17:32 09/15/2019 
-- Design Name: 
-- Module Name:    rs232c_8bit_receive - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity rs232c_8bit_receive is
	port (
		CLK		: in	std_logic;
		RXD		: in	std_logic;
		DREC		: out std_logic_vector(8-1 downto 0);
		GET_EN	: out	std_logic
	);
end rs232c_8bit_receive;

architecture Behavioral of rs232c_8bit_receive is
	signal	data_i		: std_logic_vector(8-1 downto 0);
	signal	state			: std_logic_vector(4-1 downto 0) := X"0";
	constant st_standby	: std_logic_vector(4-1 downto 0) := X"0";
	constant st_bit0		: std_logic_vector(4-1 downto 0) := X"1";
	constant st_bit1		: std_logic_vector(4-1 downto 0) := X"2";
	constant st_bit2		: std_logic_vector(4-1 downto 0) := X"3";
	constant st_bit3		: std_logic_vector(4-1 downto 0) := X"4";
	constant st_bit4		: std_logic_vector(4-1 downto 0) := X"5";
	constant st_bit5		: std_logic_vector(4-1 downto 0) := X"6";
	constant st_bit6		: std_logic_vector(4-1 downto 0) := X"7";
	constant st_bit7		: std_logic_vector(4-1 downto 0) := X"8";
begin
	DREC <= data_i;
	process(CLK)
	begin
		if falling_edge(CLK) then
			case state is
				when st_standby =>
					if RXD = '0' then
						state <= st_bit0;
						GET_EN <= '0';
					end if;
				when st_bit0 =>
					data_i(0) <= RXD;
					state <= st_bit1;
				when st_bit1 =>
					data_i(1) <= RXD;
					state <= st_bit2;
				when st_bit2 =>
					data_i(2) <= RXD;
					state <= st_bit3;
				when st_bit3 =>
					data_i(3) <= RXD;
					state <= st_bit4;
				when st_bit4 =>
					data_i(4) <= RXD;
					state <= st_bit5;
				when st_bit5 =>
					data_i(5) <= RXD;
					state <= st_bit6;
				when st_bit6 =>
					data_i(6) <= RXD;
					state <= st_bit7;
				when st_bit7 =>
					data_i(7) <= RXD;
					state <= st_standby;
					GET_EN <= '1';
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;

