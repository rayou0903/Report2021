--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:19:25 08/16/2020
-- Design Name:   
-- Module Name:   D:/integ100/src/dds_test.vhd
-- Project Name:  integ100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AD9851_ctrl
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
 
ENTITY dds_test IS
END dds_test;
 
ARCHITECTURE behavior OF dds_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AD9851_ctrl
    PORT(
         clk1 : IN  std_logic;
         clk2 : IN  std_logic;
         rst : IN  std_logic;
         data40 : IN  std_logic_vector(39 downto 0);
         data : OUT  std_logic;
         fqud : OUT  std_logic;
         reset : OUT  std_logic;
         w_clk : OUT  std_logic;
         req_dds : IN  std_logic;
         recieve : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk1 : std_logic := '0';
   signal clk2 : std_logic := '0';
   signal rst : std_logic := '0';
   signal data40 : std_logic_vector(39 downto 0) := (others => '0');
   signal req_dds : std_logic := '0';

 	--Outputs
   signal data : std_logic;
   signal fqud : std_logic;
   signal reset : std_logic;
   signal w_clk : std_logic;
   signal recieve : std_logic;

   -- Clock period definitions
   constant clk1_period : time := 10 ns;
   constant clk2_period : time := 10 ns;
   constant w_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AD9851_ctrl PORT MAP (
          clk1 => clk1,
          clk2 => clk2,
          rst => rst,
          data40 => data40,
          data => data,
          fqud => fqud,
          reset => reset,
          w_clk => w_clk,
          req_dds => req_dds,
          recieve => recieve
        );

   -- Clock process definitions
   clk1_process :process
   begin
		clk1 <= '0';
		wait for clk1_period/2;
		clk1 <= '1';
		wait for clk1_period/2;
   end process;
 
   clk2_process :process
   begin
		clk2 <= '0';
		wait for clk2_period/2;
		clk2 <= '1';
		wait for clk2_period/2;
   end process;
 
   w_clk_process :process
   begin
		w_clk <= '0';
		wait for w_clk_period/2;
		w_clk <= '1';
		wait for w_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk1_period*10;

      -- insert stimulus here 
		data40 <= X"10aaaaaaaa";
		req_dds <= '1';

      wait;
   end process;

END;
