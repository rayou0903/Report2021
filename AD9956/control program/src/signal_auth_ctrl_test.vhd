--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:21:38 12/04/2019
-- Design Name:   
-- Module Name:   G:/lab/integ100/integ100/signal_oath_ctrl_test.vhd
-- Project Name:  integ100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: signal_oath_ctrl
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
 
ENTITY signal_oath_ctrl_test IS
END signal_oath_ctrl_test;
 
ARCHITECTURE behavior OF signal_auth_ctrl_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT signal_auth_ctrl
    PORT(
         SEL : IN  std_logic;
         STATE_ADDR : IN  std_logic_vector(19 downto 0);
         STATE_RD_REQ : IN  std_logic;
         STATE_RD_FIN : OUT  std_logic;
         STATE_DATA : OUT  std_logic_vector(63 downto 0);
         MSR_ADDR : IN  std_logic_vector(19 downto 0);
         MSR_RD_REQ : IN  std_logic;
         MSR_RD_FIN : OUT  std_logic;
         MSR_DATA : OUT  std_logic_vector(63 downto 0);
         RD_FIN : IN  std_logic;
         RD_DATA : IN  std_logic_vector(63 downto 0);
         RD_REQ : OUT  std_logic;
         RD_ADDR : OUT  std_logic_vector(19 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal SEL : std_logic := '0';
   signal STATE_ADDR : std_logic_vector(19 downto 0) := (others => '1');
   signal STATE_RD_REQ : std_logic := '1';
   signal MSR_ADDR : std_logic_vector(19 downto 0) := (others => '0');
   signal MSR_RD_REQ : std_logic := '0';
   signal RD_FIN : std_logic := '1';
   signal RD_DATA : std_logic_vector(63 downto 0) := (others => '1');

 	--Outputs
   signal STATE_RD_FIN : std_logic;
   signal STATE_DATA : std_logic_vector(63 downto 0);
   signal MSR_RD_FIN : std_logic;
   signal MSR_DATA : std_logic_vector(63 downto 0);
   signal RD_REQ : std_logic;
   signal RD_ADDR : std_logic_vector(19 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: signal_auth_ctrl PORT MAP (
          SEL => SEL,
          STATE_ADDR => STATE_ADDR,
          STATE_RD_REQ => STATE_RD_REQ,
          STATE_RD_FIN => STATE_RD_FIN,
          STATE_DATA => STATE_DATA,
          MSR_ADDR => MSR_ADDR,
          MSR_RD_REQ => MSR_RD_REQ,
          MSR_RD_FIN => MSR_RD_FIN,
          MSR_DATA => MSR_DATA,
          RD_FIN => RD_FIN,
          RD_DATA => RD_DATA,
          RD_REQ => RD_REQ,
          RD_ADDR => RD_ADDR
        );

   -- Clock process definitions
   clk_process :process
   begin
		SEL <= '0';
		wait for clk_period/2;
		SEL <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
