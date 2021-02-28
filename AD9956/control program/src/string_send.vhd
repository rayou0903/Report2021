----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:22:42 10/17/2019 
-- Design Name: 
-- Module Name:    string_send - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--	component string_send
--		generic (
--			MAX_LEN : integer := 64
--		);
--		port (
--			CLK		: in std_logic;
--			STR		: in ascii_vector(MAX_LEN-1 downto 0);
--			LEN		: in integer;
--			START		: in std_logic;
--			AC_OUT	: out ascii;
--			WR_REQ	: out std_logic;
--			FINISH	: out std_logic
--		);
--	end component;
--
--	-- string sender
--	str_send : string_send
--		port map (
--			CLK => clk100,
--			STR => str,
--			LEN => str_len,
--			START => str_start,
--			AC_OUT => tr_ac,
--			WR_REQ => tr_wr_en,
--			FINISH => open
--	);
	
library work;
use work.ascii_pac.all;

entity string_send is
	generic (
		MAX_LEN	: integer := 64
	);
	port (
		CLK		: in std_logic;
		STR		: in ascii_vector(0 to MAX_LEN-1);
		LEN		: in integer;
		START		: in std_logic;
		AC_OUT	: out ascii;
		WR_REQ	: out std_logic;
		FINISH	: out std_logic
	);
end string_send;

architecture Behavioral of string_send is
	--** type definition
	type state_t is (idle, run);
	
	--** signal
	signal index	: integer := 0;
	signal state	: state_t := idle;
	signal finish_inner	: std_logic := '1';
begin
	--** signal assignment
	FINISH <= finish_inner;
	
	--** process
	process(CLK)
	begin
		if falling_edge(CLK) then
			if state = run then
				AC_OUT <= STR(index);
				WR_REQ <= '1';
				if index = MAX_LEN then -- 最大長を超えたら終了
					finish_inner <= '1';
					state <= idle;
				elsif index = LEN-1 then -- 指定した長さまで行ったら終了
					finish_inner <= '1';
					state <= idle;
				else
					finish_inner <= '0';
					index <= index + 1;
				end if;
			elsif state = idle then
				index <= 0;
				WR_REQ <= '0';
				if START = '1' then
					finish_inner <= '0';
					state <= run;
				else
					finish_inner <= '1';
				end if;
			end if;
		end if;
	end process;
end Behavioral;

