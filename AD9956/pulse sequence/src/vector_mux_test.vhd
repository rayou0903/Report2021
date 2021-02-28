--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:07:01 12/11/2019
-- Design Name:   
-- Module Name:   G:/lab/integ100/integ100/vector_mux_test.vhd
-- Project Name:  integ100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: vector_mux
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
 
ENTITY vector_mux_test IS
END vector_mux_test;
 
ARCHITECTURE behavior OF vector_mux_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT vector_mux
	 generic(
		SIGNAL_NUM	: positive
	 );
    PORT(
         SEL : IN  std_logic;
         LOW_ACTIVE_SIG : IN  std_logic_vector(SIGNAL_NUM-1 downto 0);
         HIGH_ACTIVE_SIG : IN  std_logic_vector(SIGNAL_NUM-1 downto 0);
         OUT_SIG : OUT  std_logic_vector(SIGNAL_NUM-1 downto 0)
        );
    END COMPONENT;
    
	signal clk : std_logic := '0';
	signal counter : integer := 0;

   --Inputs
   signal SEL : std_logic := '0';
   signal LOW_ACTIVE_SIG : std_logic_vector(64-1 downto 0) := (others => '0');
   signal HIGH_ACTIVE_SIG : std_logic_vector(64-1 downto 0) := (others => '0');

 	--Outputs
   signal OUT_SIG : std_logic_vector(64-1 downto 0);
   -- No clocks detected in port list. Replace clk below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: vector_mux 
		generic map (
			SIGNAL_NUM => 64
		)
		PORT MAP (
          SEL => SEL,
          LOW_ACTIVE_SIG => LOW_ACTIVE_SIG,
          HIGH_ACTIVE_SIG => HIGH_ACTIVE_SIG,
          OUT_SIG => OUT_SIG
   );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
		if counter = 1 then
			SEL <= '1';
		elsif counter = 2 then
			SEL <= '0';
			HIGH_ACTIVE_SIG <= X"0000111122223333";
		elsif counter = 3 then
			LOW_ACTIVE_SIG <= X"4444555566667777";
		end if;
		counter <= counter + 1;
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
