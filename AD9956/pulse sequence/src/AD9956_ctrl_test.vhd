--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:44:52 11/06/2020
-- Design Name:   
-- Module Name:   C:/Users/rayou/Papilio/ad9956/serial_test.vhd
-- Project Name:  ad9956
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: serial
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
 
ENTITY AD9956_ctrl_test IS
END AD9956_ctrl_test;
 
ARCHITECTURE SIM OF AD9956_ctrl_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AD9956_ctrl
        PORT(
            CLK          : IN       std_logic;    --�N���b�N�M��
				CLK_2        : IN       std_logic;
            RST          : IN       std_logic;    --Papilio���Z�b�g�M��
            REQ_DDS      : IN       std_logic;    --DDS�ǂݏ������N�G�X�g�M��(1�Ń��N�G�X�g)
				DATA64       : IN       std_logic_VECTOR(63 downto 0);
--            R_OR_W       : IN       std_logic;    --�ǂݏ������ʐM��(1�œǂݏo���C0�ŏ�������)
--            IO_RESET     : OUT      std_logic;    --9
            RESET        : OUT      std_logic;    --10
            SDIO         : INOUT    std_logic;    --14
            SCLK         : INOUT    std_logic;    --15
            CS           : OUT      std_logic;    --16
            IO_UPDATE    : OUT      std_logic;    --20
            PSEL         : INOUT    std_logic_vector(2 downto 0);    --Profile Select(21 to 23)
				RECEIVE      : OUT      std_logic    --0�Ńr�W�[���
        );
    END COMPONENT;

    --Inputs
    signal CLK       : std_logic := '0';
	 signal CLK_2     : std_logic := '0';
    signal RST       : std_logic := '0';
    signal REQ_DDS   : std_logic := '0';
	 signal DATA64    : std_logic_vector(63 downto 0) := "0000000000000000011101100110011001100110011001100110011001100110";
--    signal R_OR_W    : std_logic := '1';

    --BiDirs
	 signal SDIO    : std_logic := 'Z';
	 signal SCLK    : std_logic;
    signal PSEL    : std_logic_vector(2 downto 0);

    --Outputs
--    signal IO_RESET     : std_logic;
    signal RESET        : std_logic;
    signal CS           : std_logic;
    signal IO_UPDATE    : std_logic;
	 signal RECEIVE      : std_logic;
 
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: AD9956_ctrl PORT MAP (
        CLK       => CLK,
		  CLK_2     => CLK_2,
        RST       => RST,
        REQ_DDS   => REQ_DDS,
		  DATA64    => DATA64,
--        R_OR_W    => R_OR_W,
--        IO_RESET  => IO_RESET,
        RESET     => RESET,
        SDIO      => SDIO,
        SCLK      => SCLK,
        CS        => CS,
        IO_UPDATE => IO_UPDATE,
        PSEL      => PSEL,
		  RECEIVE   => RECEIVE
    );

    --�N���b�N(10MHz)
    process begin
       CLK <= '0';
       wait for 50 ns;
       CLK <= '1';
       wait for 50 ns;
    end process;

    --RST      <= '1' after 100 us, '0' after 200 us;
    REQ_DDS  <= '1' after 500 us, '0' after 501 us;
--    R_OR_W <= '0' after 3900 ns;
--	SDIO		<= '1' after 4001.875 ns, 
--					'0' after 4041.875 ns,
--					'1' after 4081.875 ns,
--					'0' after 4121.875 ns,
--					'1' after 4161.875 ns,
--					'1' after 4201.875 ns,
--					'0' after 4241.875 ns,
--					'1' after 4281.875 ns,
--					'1' after 4321.875 ns,
--					'0' after 4361.875 ns,
--					'0' after 4401.875 ns,
--					'0' after 4441.875 ns,
--					'1' after 4481.875 ns,
--					'1' after 4521.875 ns,
--					'1' after 4561.875 ns,
--					'1' after 4601.875 ns,
--					'0' after 4641.875 ns,
--					'1' after 4681.875 ns,
--					'1' after 4721.875 ns,
--					'0' after 4761.875 ns,
--					'1' after 4801.875 ns,
--					'1' after 4841.875 ns,
--					'0' after 4881.875 ns,
--					'0' after 4921.875 ns,
--					'0' after 4961.875 ns,
--					'0' after 5001.875 ns,
--					'1' after 5041.875 ns,
--					'0' after 5081.875 ns,
--					'1' after 5121.875 ns,
--					'0' after 5161.875 ns,
--					'1' after 5201.875 ns,
--					'1' after 5241.875 ns,
--					'0' after 5281.875 ns,
--					'1' after 5321.875 ns,
--					'0' after 5361.875 ns,
--					'1' after 5401.875 ns,
--					'0' after 5441.875 ns,
--					'1' after 5481.875 ns,
--					'0' after 5521.875 ns,
--					'1' after 5561.875 ns,
--					'0' after 5601.875 ns,
--					'1' after 5641.875 ns,
--					'0' after 5681.875 ns,
--					'1' after 5721.875 ns,
--					'0' after 5761.875 ns,
--					'1' after 5801.875 ns,
--					'0' after 5841.875 ns,
--					'0' after 5881.875 ns,
--					'1' after 5921.875 ns,
--					'0' after 5961.875 ns,
--					'1' after 6001.875 ns,
--					'0' after 6041.875 ns,
--					'1' after 6081.875 ns,
--					'0' after 6121.875 ns,
--					'1' after 6161.875 ns,
--					'1' after 6201.875 ns;


END;