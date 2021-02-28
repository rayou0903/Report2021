--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:39:12 09/11/2019
-- Design Name:   
-- Module Name:   G:/lab/crystal_osc_test/crystal_osc_test/clk_gen_rs232c_test.vhd
-- Project Name:  crystal_osc_test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clk_gen_rs232c
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
 
ENTITY clk_gen_rs232c_test IS
END clk_gen_rs232c_test;
 
ARCHITECTURE behavior OF clk_gen_rs232c_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clk_gen_rs232c
    PORT(
         clk_in : IN  std_logic;
         clk9600bps : OUT  std_logic;
         clk115200bps : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';

 	--Outputs
   signal clk9600bps : std_logic;
   signal clk115200bps : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   constant clk9600bps_period : time := 10 ns;
   constant clk115200bps_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clk_gen_rs232c PORT MAP (
          clk_in => clk_in,
          clk9600bps => clk9600bps,
          clk115200bps => clk115200bps
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_in_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
