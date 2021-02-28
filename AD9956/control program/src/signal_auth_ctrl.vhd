----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:42:00 12/04/2019 
-- Design Name: 
-- Module Name:    signal_oath_ctrl - Behavioral 
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

--	component signal_auth_ctrl
--		port (		SEL				: in cmd_t; -- �I��p�M��
--			-- ��ԑJ�ڃ��W���[������̐M��(0�ŃA�N�e�B�u)
--			EXE_ADDR		: in std_logic_vector(20-1 downto 0);
--			EXE_RD_REQ	: in std_logic;
--			EXE_RD_FIN	: out std_logic;
--			EXE_DATA		: out std_logic_vector(64-1 downto 0);
--			-- ���胂�W���[������̐M��(1�ŃA�N�e�B�u)
--			MSR_ADDR			: in std_logic_vector(20-1 downto 0);
--			MSR_RD_REQ		: in std_logic;
--			MSR_RD_FIN		: out std_logic;
--			MSR_DATA			: out std_logic_vector(64-1 downto 0);
--			-- SDRAM����󂯎��M��
--			RD_FIN			: in std_logic;
--			RD_DATA			: in std_logic_vector(64-1 downto 0);
--			-- SDRAM�ǂݏo�����W���[���ɓn���A�h���X�A�f�[�^�A���N�G�X�g�M��
--			RD_REQ			: out std_logic;
--			RD_ADDR			: out std_logic_vector(20-1 downto 0)
--		);
--	end component;
--	sig_auth_ctrl : signal_auth_ctrl
--		port map (
--			SEL => exe_cmd,
--			-- ��ԑJ�ڃ��W���[������̐M��(0�ŃA�N�e�B�u)
--			EXE_ADDR => exe_addr,
--			EXE_RD_REQ => '0', -- �v�ҏW
--			EXE_RD_FIN => open, -- �v�ҏW
--			EXE_DATA => exe_data,
--			-- ���胂�W���[������̐M��(1�ŃA�N�e�B�u)
--			MSR_ADDR => (others => '0'), -- �v�ҏW
--			MSR_RD_REQ => '0', -- �v�ҏW
--			MSR_RD_FIN => open, -- �v�ҏW
--			MSR_DATA => open, -- �v�ҏW
--			-- SDRAM����󂯎��M��
--			RD_FIN => '1', -- �v�ҏW
--			RD_DATA => (others => '0'), -- �v�ҏW
--			-- SDRAM�ǂݏo�����W���[���ɓn���A�h���X�A�f�[�^�A���N�G�X�g�M��
--			RD_REQ => open, -- �v�ҏW
--			RD_ADDR => open -- �v�ҏW
--	);

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.ascii_pac.all;
use work.types.all;

entity signal_auth_ctrl is
	port (
		CLK				: std_logic;
		SEL				: in cmd_t; -- �I��p�M��
		-- �R�}���h���s���W���[������̐M��(0�ŃA�N�e�B�u)
		EXE_ADDR			: in std_logic_vector(20-1 downto 0);
		EXE_RD_REQ		: in std_logic;
		EXE_RD_FIN		: out std_logic;
		EXE_DATA			: out std_logic_vector(64-1 downto 0);
		-- ���胂�W���[������̐M��(1�ŃA�N�e�B�u)
		MSR_ADDR			: in std_logic_vector(20-1 downto 0);
		MSR_RD_REQ		: in std_logic;
		MSR_RD_FIN		: out std_logic;
		MSR_DATA			: out std_logic_vector(64-1 downto 0);
		-- SDRAM����󂯎��M��
		RD_FIN			: in std_logic;
		RD_DATA			: in std_logic_vector(64-1 downto 0);
		-- SDRAM�ǂݏo�����W���[���ɓn���A�h���X�A�f�[�^�A���N�G�X�g�M��
		RD_REQ			: out std_logic;
		RD_ADDR			: out std_logic_vector(20-1 downto 0)
	);
end signal_auth_ctrl;

architecture Behavioral of signal_auth_ctrl is
	--** signal
	
begin
	--** signal assignment
	
	--** process;
	process(CLK)
	begin
		if falling_edge(CLK) then
			if SEL = sdr1 then
				-- to sdram signal
				RD_ADDR <= EXE_ADDR;
				RD_REQ <= EXE_RD_REQ;
				
				-- to exe and msr signal
				EXE_RD_FIN <= RD_FIN;
				MSR_RD_FIN <= '0';
				EXE_DATA <= RD_DATA;
				MSR_DATA <= (others => '0');
			elsif SEL = reqr then
				-- to sdram signal
				RD_ADDR <= MSR_ADDR;
				RD_REQ <= MSR_RD_REQ;
				
				-- to exe and msr signal
				EXE_RD_FIN <= '0';
				MSR_RD_FIN <= RD_FIN;
				EXE_DATA <= (others => '0');
				MSR_DATA <= RD_DATA;
			else
				-- to sdram_signal
				RD_ADDR <= (others => '0');
				RD_REQ <= '0';
				
				-- to exe and msr signal
				EXE_RD_FIN <= '0';
				MSR_RD_FIN <= '0';
				EXE_DATA <= (others => '0');
				MSR_DATA <= (others => '0');
			end if;
		end if;
	end process;
end Behavioral;
