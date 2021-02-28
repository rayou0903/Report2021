----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:32:56 11/02/2019 
-- Design Name: 
-- Module Name:    command_execute - Behavioral 
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
--	component command_execute
--		port (
--			CLK			: in std_logic;
--			-- 実行に必要な信号
--			CMD_IN			: in cmd_t;
--			ADDR_IN			: in std_logic_vector(20-1 downto 0);
--			DATA_IN			: in std_logic_vector(64-1 downto 0);
--			--** 各モジュールとの通信に必要な信号 **
--			-- 読み出しモジュール(sdram_rd)
--			RD_ADDR			: out std_logic_vector(20-1 downto 0);
--			RD_DATA			: in std_logic_vector(64-1 downto 0);
--			RD_START			: out std_logic;
--			RD_FINISH		: in std_logic;
--			-- 書き込みモジュール(sdram_wr)
--			WR_ADDR			: out std_logic_vector(20-1 downto 0);
--			WR_DATA			: out std_logic_vector(64-1 downto 0);
--			WR_START			: out std_logic;
--			WR_FINISH		: in std_logic;
--			-- 測定モジュール()
--			MSR_START		: out std_logic;
--			MSR_FINISH		: in std_logic;
--			--** 結果 **
--			DATA_OUT_EXIST	: out std_logic; -- 実行結果の表示の有無
--			DATA_OUT			: out std_logic_vector(64-1 downto 0);
--			EXE_START		: in std_logic;
--			EXE_FINISH		: out std_logic
--		);
--	end component;
-- -- command execute
--	cmd_exe : command_execute
--		port map (
--			CLK => clk100,
--			-- 実行に必要な信号
--			CMD_IN => exe_cmd,
--			ADDR_IN => exe_addr_in,
--			DATA_IN => exe_data_in,
--			--** 各モジュールとの通信に必要な信号 **
--			-- 読み出しモジュール(sdram_rd)
--			RD_ADDR => exe_rd_addr,
--			RD_DATA => exe_rd_data,
--			RD_START => ,
--			RD_FINISH => ,
--			-- 書き込みモジュール(sdram_wr)
--			WR_ADDR => (others => '0'),
--			WR_DATA => (others => '0'),
--			WR_START => ,
--			WR_FINISH => ,
--			-- 測定モジュール()
--			MSR_START => ,
--			MSR_FINISH => ,
--			--** 結果 **
--			DATA_OUT_EXIST => ,
--			DATA_OUT => ,
--			EXE_START => ,
--			EXE_FINISH => ,
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

entity command_execute is
	port (
		CLK			: in std_logic;
		-- 実行に必要な信号
		CMD_IN			: in cmd_t;
		ADDR_IN			: in std_logic_vector(20-1 downto 0); -- アドレス（兼開始アドレス）
		ADDR_FINISH_IN	: in std_logic_vector(20-1 downto 0); -- 終了アドレス
		DATA_IN			: in std_logic_vector(64-1 downto 0);
		--** 各モジュールとの通信に必要な信号 **
		-- 読み出しモジュール(sdram_rd)
		RD_ADDR			: out std_logic_vector(20-1 downto 0);
		RD_DATA			: in std_logic_vector(64-1 downto 0);
		RD_START			: out std_logic;
		RD_FINISH		: in std_logic;
		-- 書き込みモジュール(sdram_wr)
		WR_ADDR			: out std_logic_vector(20-1 downto 0);
		WR_DATA			: out std_logic_vector(64-1 downto 0);
		WR_START			: out std_logic;
		WR_FINISH		: in std_logic;
		-- 測定モジュール()
		MSR_ADDR_START		: out std_logic_vector(20-1 downto 0);
		MSR_ADDR_FINISH	: out std_logic_vector(20-1 downto 0);
		MSR_DATA				: out std_logic_vector(64-1 downto 0);
		MSR_START			: out std_logic;
		MSR_FINISH			: in std_logic;
		-- リセット信号
		RST_OP			: out std_logic;
		--** 結果 **
		RESULT			: out ascii_vector(0 to 64-1);
		RESULT_LEN		: out integer;
		EXE_START		: in std_logic;
		EXE_FINISH		: out std_logic
	);
end command_execute;

architecture Behavioral of command_execute is
	--** type
	type state_t is (idle, start, exe_wait);
	--** signal
	signal state		: state_t := idle;
begin
	--** signal assignment
	--** port map
	--** process
	process(CLK)
	begin
		if rising_edge(CLK) then
			case(state) is
				when idle =>
					RD_START <= '0';
					WR_START <= '0';
					MSR_START <= '0';
					EXE_FINISH <= '1';
					RESULT_LEN <= 0;
					if EXE_START = '1' then
						state <= start;
					end if;
				when start =>
					EXE_FINISH <= '0';
					state <= exe_wait;
					case(CMD_IN) is
						when sdr1 =>
							RD_START <= '1';
							RD_ADDR <= ADDR_IN;
						when sdw1 =>
							WR_START <= '1';
							WR_ADDR <= ADDR_IN;
							WR_DATA <= DATA_IN;
						when reqr =>
							MSR_START <= '1';
							MSR_ADDR_START <= ADDR_IN;
							MSR_ADDR_FINISH <= ADDR_FINISH_IN;
						when srst =>
							RST_OP <= '1';
						when none => state <= idle;
						when others => null;
					end case;
				when exe_wait =>
					RD_START <= '0';
					WR_START <= '0';
					MSR_START <= '0';
					RST_OP <= '0';
					case (CMD_IN) is
						when srst =>
							RESULT(0 to 11) <= "reset called";
							RESULT_LEN <= 12;
							EXE_FINISH <= '1';
							state <= idle;
						when sdr1 =>
							if RD_FINISH = '1' then
								RESULT(0 to 15) <= vec2datahex(RD_DATA);
--								RESULT(0) <= vec2hex(ADDR_IN(19 downto 16));
--								RESULT(1) <= vec2hex(ADDR_IN(15 downto 12));
--								RESULT(2) <= vec2hex(ADDR_IN(11 downto 8));
--								RESULT(3) <= vec2hex(ADDR_IN(7 downto 4));
--								RESULT(4) <= vec2hex(ADDR_IN(3 downto 0));
								RESULT(16) <= cr;
								RESULT(17) <= lf;
								RESULT_LEN <= 18;
								EXE_FINISH <= '1';
								state <= idle;
							end if;
						when sdw1 =>
							if WR_FINISH = '1' then
								RESULT <= (others => ' ');
								RESULT_LEN <= 0;
								EXE_FINISH <= '1';
								state <= idle;
							end if;
						when reqr =>
							if MSR_FINISH = '1' then
--								RESULT <= (others => ' ');
--								RESULT(0) <= vec2hex(ADDR_IN(19 downto 16));
--								RESULT(1) <= vec2hex(ADDR_IN(15 downto 12));
--								RESULT(2) <= vec2hex(ADDR_IN(11 downto 8));
--								RESULT(3) <= vec2hex(ADDR_IN(7 downto 4));
--								RESULT(4) <= vec2hex(ADDR_IN(3 downto 0));
--								RESULT(0) <= vec2hex(ADDR_FINISH_IN(19 downto 16));
--								RESULT(1) <= vec2hex(ADDR_FINISH_IN(15 downto 12));
--								RESULT(2) <= vec2hex(ADDR_FINISH_IN(11 downto 8));
--								RESULT(3) <= vec2hex(ADDR_FINISH_IN(7 downto 4));
--								RESULT(4) <= vec2hex(ADDR_FINISH_IN(3 downto 0));
--								RESULT_LEN <= 5;
								RESULT <= (others => ' ');
								RESULT_LEN <= 0;
								EXE_FINISH <= '1';
								state <= idle;
							end if;
						when others =>
							RESULT <= (others => ' ');
--							RESULT(0) <= vec2hex(ADDR_IN(19 downto 16));
--							RESULT(1) <= vec2hex(ADDR_IN(15 downto 12));
--							RESULT(2) <= vec2hex(ADDR_IN(11 downto 8));
--							RESULT(3) <= vec2hex(ADDR_IN(7 downto 4));
--							RESULT(4) <= vec2hex(ADDR_IN(3 downto 0));
--							RESULT_LEN <= 5;
							RESULT_LEN <= 0;
							EXE_FINISH <= '1';
							state <= idle;
					end case;
				when others => null;
			end case;
		end if;
	end process;
end Behavioral;

