--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:30:36 02/22/2021
-- Design Name:   
-- Module Name:   C:/Users/rayou/Papilio/src/just_measurement_test.vhd
-- Project Name:  integ100
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: just_measurement
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
 
ENTITY just_measurement_test IS
END just_measurement_test;
 
ARCHITECTURE behavior OF just_measurement_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT just_measurement
    PORT(
         clk : IN  std_logic;
         clk2 : IN  std_logic;
         rst : IN  std_logic;
         msr_start : IN  std_logic;
         msr_finish : OUT  std_logic;
         str_adr : IN  std_logic_vector(19 downto 0);
         end_adr : IN  std_logic_vector(19 downto 0);
         sdr_req : OUT  std_logic;
         sdr_fin : IN  std_logic;
         ctrl_data : IN  std_logic_vector(63 downto 0);
         cite_addr : OUT  std_logic_vector(19 downto 0);
         test_dout : OUT  std_logic_vector(63 downto 0);
         test_bit : OUT  std_logic;
         measure_output : OUT  std_logic_vector(15 downto 0);
         rf_pulse : OUT  std_logic_vector(2 downto 0);
         adc_sig : OUT  std_logic_vector(2 downto 0);
         RESET1 : OUT  std_logic;
         SCLK1 : OUT  std_logic;
         SDIO1 : OUT  std_logic;
         CS1 : OUT  std_logic;
         IO_UPDATE1 : OUT  std_logic;
         PSEL1 : OUT  std_logic_vector(2 downto 0);
         RESET2 : OUT  std_logic;
         SCLK2 : OUT  std_logic;
         SDIO2 : OUT  std_logic;
         CS2 : OUT  std_logic;
         IO_UPDATE2 : OUT  std_logic;
         PSEL2 : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal clk2 : std_logic := '0';
   signal rst : std_logic := '0';
   signal msr_start : std_logic := '0';
   signal str_adr : std_logic_vector(19 downto 0) := "00000000000000000000"; --00000
   signal end_adr : std_logic_vector(19 downto 0) := "00000000000000011000"; --00018
   signal sdr_fin : std_logic := '0';
   signal ctrl_data : std_logic_vector(63 downto 0) := (others => '0');

 	--Outputs
   signal msr_finish : std_logic;
   signal sdr_req : std_logic;
   signal cite_addr : std_logic_vector(19 downto 0);
   signal test_dout : std_logic_vector(63 downto 0);
   signal test_bit : std_logic;
   signal measure_output : std_logic_vector(15 downto 0);
   signal rf_pulse : std_logic_vector(2 downto 0);
   signal adc_sig : std_logic_vector(2 downto 0);
   signal RESET1 : std_logic;
   signal SCLK1 : std_logic;
   signal SDIO1 : std_logic;
   signal CS1 : std_logic;
   signal IO_UPDATE1 : std_logic;
   signal PSEL1 : std_logic_vector(2 downto 0);
   signal RESET2 : std_logic;
   signal SCLK2 : std_logic;
   signal SDIO2 : std_logic;
   signal CS2 : std_logic;
   signal IO_UPDATE2 : std_logic;
   signal PSEL2 : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk2_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: just_measurement PORT MAP (
          clk => clk,
          clk2 => clk2,
          rst => rst,
          msr_start => msr_start,
          msr_finish => msr_finish,
          str_adr => str_adr,
          end_adr => end_adr,
          sdr_req => sdr_req,
          sdr_fin => sdr_fin,
          ctrl_data => ctrl_data,
          cite_addr => cite_addr,
          test_dout => test_dout,
          test_bit => test_bit,
          measure_output => measure_output,
          rf_pulse => rf_pulse,
          adc_sig => adc_sig,
          RESET1 => RESET1,
          SCLK1 => SCLK1,
          SDIO1 => SDIO1,
          CS1 => CS1,
          IO_UPDATE1 => IO_UPDATE1,
          PSEL1 => PSEL1,
          RESET2 => RESET2,
          SCLK2 => SCLK2,
          SDIO2 => SDIO2,
          CS2 => CS2,
          IO_UPDATE2 => IO_UPDATE2,
          PSEL2 => PSEL2
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   clk2_process :process
   begin
		clk2 <= '0';
		wait for clk2_period/2;
		clk2 <= '1';
		wait for clk2_period/2;
   end process;
 
	msr_start <= '1' after 200 ns, '0' after 250 ns;
	sdr_fin   <= '1' after 500 ns, '0' after 550 ns;
	ctrl_data <= "0000000000000000000000000000000101110001110001110001110001010000" after 300 ns,
					 "0000000000000000010000000000000000000000000000000000001100101010" after 350 ns,
					 "0000000000000000000000000100000000000000000000000000001110001110" after 400 ns,
					 "0000000100000000000000000000000000000000000000000000000000000000" after 450 ns;

END;
