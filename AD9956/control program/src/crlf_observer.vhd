----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:56:04 09/17/2019 
-- Design Name: 
-- Module Name:    crlf_observer - Behavioral 
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
-- コピペ用
--	component crlf_observer
--		port (
--			CLK		: in	std_logic;
--			REC_RQ	: in	std_logic;
--			AC			: in	std_logic_vector(8-1 downto 0);
--			CRLF		: out	std_logic
--		);
--	end component;
--
--	crlf_obs : crlf_observer
--		port map (
--			CLK => clk,
--			REC_RQ => rec_rq,
--			AC => data,
--			CRLF => crlf
--	);

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.ascii_pac.all;

entity crlf_observer is
	port (
		CLK		: in	std_logic;
		REC_RQ	: in	std_logic;
		AC			: in	ascii;
		CRLF		: out	std_logic
	);
end crlf_observer;

architecture Behavioral of crlf_observer is
	signal cr_flag	: std_logic;
begin
	process(CLK)
	begin
		if falling_edge(CLK) and (REC_RQ = '1') then
			if AC = cr then
				cr_flag <= '1';
				CRLF <= '0';
			elsif (AC = lf) and (cr_flag = '1') then
				cr_flag <= '0';
				CRLF <= '1';
			else
				cr_flag <= '0';
				CRLF <= '0';
			end if;
		end if;
	end process;

end Behavioral;

