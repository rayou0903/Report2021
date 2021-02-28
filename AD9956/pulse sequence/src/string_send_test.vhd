--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:18:02 10/18/2019
-- Design Name:   
-- Module Name:   G:/lab/integ100/integ100/string_send_test.vhd
-- Project Name:  integ100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: string_send
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

library work;
use work.ascii_pac.all;

ENTITY string_send_test IS
END string_send_test;
 
ARCHITECTURE behavior OF string_send_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT string_send
    PORT(
         CLK : IN  std_logic;
         STR : IN  ascii_vector(63 downto 0);
         LEN : IN  integer;
         START : IN  std_logic;
         AC_OUT : OUT  ascii;
         WR_REQ : OUT  std_logic;
         FINISH : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal STR : ascii_vector(0 to 63);
   signal LEN : integer := 5;
	signal counter : integer := 0;
   signal START : std_logic := '1';

 	--Outputs
   signal AC_OUT : ascii;
   signal WR_REQ : std_logic;
   signal FINISH : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
	STR(0 to 4) <= "hello";
	STR (5 to 63) <= (others => '0');
	-- Instantiate the Unit Under Test (UUT)
   uut: string_send PORT MAP (
          CLK => CLK,
          STR => STR,
          LEN => LEN,
          START => START,
          AC_OUT => AC_OUT,
          WR_REQ => WR_REQ,
          FINISH => FINISH
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		counter <= counter + 1;
		if counter = 2 then
			START <= '0';
		elsif counter = 4 then
			START <= '1';
			counter <= 0;
		end if;
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
