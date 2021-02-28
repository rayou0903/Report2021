----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:00:51 12/11/2019 
-- Design Name: 
-- Module Name:    vector_mux - Behavioral 
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

entity vector_mux is
	generic (
		SIGNAL_NUM	: positive := 64
	);
	port (
		SEL					: in std_logic;
		LOW_ACTIVE_SIG		: in std_logic_vector(SIGNAL_NUM-1 downto 0);
		HIGH_ACTIVE_SIG	: in std_logic_vector(SIGNAL_NUM-1 downto 0);
		OUT_SIG				: out std_logic_vector(SIGNAL_NUM-1 downto 0)
	);
end vector_mux;

architecture Behavioral of vector_mux is

begin
	process(SEL, LOW_ACTIVE_SIG, HIGH_ACTIVE_SIG)
	begin
		if SEL = '0' then
			OUT_SIG <= LOW_ACTIVE_SIG;
		else
			OUT_SIG <= HIGH_ACTIVE_SIG;
		end if;
	end process;
end Behavioral;

