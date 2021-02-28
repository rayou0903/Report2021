--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:19:57 09/09/2019
-- Design Name:   
-- Module Name:   G:/lab/crystal_osc_test/crystal_osc_test/rs232c_8bit_transfer_test.vhd
-- Project Name:  crystal_osc_test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rs232c_8bit_transfer
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
ENTITY rs232c_8bit_transfer_test IS
END rs232c_8bit_transfer_test;
 
ARCHITECTURE behavior OF rs232c_8bit_transfer_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rs232c_8bit_transfer
    PORT(
         CLK : IN  std_logic;
         TXD : OUT  std_logic;
         DATA : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal DATA : std_logic_vector(7 downto 0) := X"04";

 	--Outputs
   signal TXD : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rs232c_8bit_transfer PORT MAP (
          CLK => CLK,
          TXD => TXD,
          DATA => DATA
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
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;
END;
