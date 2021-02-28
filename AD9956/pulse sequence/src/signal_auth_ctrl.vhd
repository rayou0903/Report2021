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
--		port (		SEL				: in cmd_t; -- 選択用信号
--			-- 状態遷移モジュールからの信号(0でアクティブ)
--			EXE_ADDR		: in std_logic_vector(20-1 downto 0);
--			EXE_RD_REQ	: in std_logic;
--			EXE_RD_FIN	: out std_logic;
--			EXE_DATA		: out std_logic_vector(64-1 downto 0);
--			-- 測定モジュールからの信号(1でアクティブ)
--			MSR_ADDR			: in std_logic_vector(20-1 downto 0);
--			MSR_RD_REQ		: in std_logic;
--			MSR_RD_FIN		: out std_logic;
--			MSR_DATA			: out std_logic_vector(64-1 downto 0);
--			-- SDRAMから受け取る信号
--			RD_FIN			: in std_logic;
--			RD_DATA			: in std_logic_vector(64-1 downto 0);
--			-- SDRAM読み出しモジュールに渡すアドレス、データ、リクエスト信号
--			RD_REQ			: out std_logic;
--			RD_ADDR			: out std_logic_vector(20-1 downto 0)
--		);
--	end component;
--	sig_auth_ctrl : signal_auth_ctrl
--		port map (
--			SEL => exe_cmd,
--			-- 状態遷移モジュールからの信号(0でアクティブ)
--			EXE_ADDR => exe_addr,
--			EXE_RD_REQ => '0', -- 要編集
--			EXE_RD_FIN => open, -- 要編集
--			EXE_DATA => exe_data,
--			-- 測定モジュールからの信号(1でアクティブ)
--			MSR_ADDR => (others => '0'), -- 要編集
--			MSR_RD_REQ => '0', -- 要編集
--			MSR_RD_FIN => open, -- 要編集
--			MSR_DATA => open, -- 要編集
--			-- SDRAMから受け取る信号
--			RD_FIN => '1', -- 要編集
--			RD_DATA => (others => '0'), -- 要編集
--			-- SDRAM読み出しモジュールに渡すアドレス、データ、リクエスト信号
--			RD_REQ => open, -- 要編集
--			RD_ADDR => open -- 要編集
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
		SEL				: in cmd_t; -- 選択用信号
		-- コマンド実行モジュールからの信号(0でアクティブ)
		EXE_ADDR			: in std_logic_vector(20-1 downto 0);
		EXE_RD_REQ		: in std_logic;
		EXE_RD_FIN		: out std_logic;
		EXE_DATA			: out std_logic_vector(64-1 downto 0);
		-- 測定モジュールからの信号(1でアクティブ)
		MSR_ADDR			: in std_logic_vector(20-1 downto 0);
		MSR_RD_REQ		: in std_logic;
		MSR_RD_FIN		: out std_logic;
		MSR_DATA			: out std_logic_vector(64-1 downto 0);
		-- SDRAMから受け取る信号
		RD_FIN			: in std_logic;
		RD_DATA			: in std_logic_vector(64-1 downto 0);
		-- SDRAM読み出しモジュールに渡すアドレス、データ、リクエスト信号
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
