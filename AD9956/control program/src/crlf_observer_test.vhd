--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:42:05 09/24/2019
-- Design Name:   
-- Module Name:   G:/lab/integ100/integ100/crlf_observer_test.vhd
-- Project Name:  integ100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: crlf_observer
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
USE ieee.numeric_std.ALL;

library work;
use work.ascii_pac.all;
 
ENTITY crlf_observer_test IS
END crlf_observer_test;
 
ARCHITECTURE behavior OF crlf_observer_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT crlf_observer
    PORT(
         CLK : IN  std_logic;
         REC_RQ : IN  std_logic;
         DATA : IN  std_logic_vector(7 downto 0);
         CRLF : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal REC_RQ : std_logic := '1';
   signal DATA : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal CRLF : std_logic;

   -- Clock period definitions
   constant CLK_period : time :=  20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: crlf_observer PORT MAP (
          CLK => CLK,
          REC_RQ => REC_RQ,
          DATA => DATA,
          CRLF => CRLF
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10 ns;	

		DATA <= ascii_decoder(cr);
      wait for CLK_period*10;
		DATA <= ascii_decoder(lf);
		wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
