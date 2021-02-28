----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:17:24 10/02/2019 
-- Design Name: 
-- Module Name:    state_machine - Behavioral 
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

--	component state_machine
--		port (
--			CLK						: in std_logic;
--			-- 受信用FIFOへの信号
--			REC_EMPTY				: in std_logic;
--			REC_VALID				: in std_logic;
--			REC_AC					: in ascii;
--			REC_RD_EN				: out std_logic;
--			
--			-- 測定モジュールとの通信用
--			MSR_FINISH				: in std_logic;
--			MSR_START				: out std_logic;
--			
--			-- 文字列送信モジュール用
--			STR_FINISH				: in std_logic;
--			STR_START				: out std_logic;
--			STR						: out ascii_vector(0 to MAX_LEN-1);
--			STR_LEN					: out integer;
--			
--			-- リセット要求信号
--			RST_OP					: out std_logic
--		);
--	end component;
--	-- state machine
--	st_machine : state_machine
--		port map (
--			CLK => clk100,
--			REC_EMPTY => ,
--			REC_VALID => ,
--			REC_AC => ,
--			REC_RD_EN => ,
--			MSR_FINISH => ,
--			MSR_START => ,
--			STR_FINISH => ,
--			STR_START => ,
--			STR => ,
--			STR_LEN => ,
--			RST => 
--	);

entity state_machine is
	generic (
		MAX_LEN					: positive := 64 -- CRLFを含め、1度に受信可能な文字数
	);
	port (
		CLK						: in std_logic;
		-- 受信用FIFOとの接続
		REC_EMPTY				: in std_logic;
		REC_ALMOST_EMPTY		: in std_logic;
		REC_VALID				: in std_logic;
		REC_AC					: in ascii;
		REC_RD_EN				: out std_logic;
		
		-- 文字列送信モジュール用
		STR_FINISH				: in std_logic;
		STR_START				: out std_logic;
		STR						: out ascii_vector(0 to MAX_LEN-1);
		STR_LEN					: out integer;
		
		-- 実行モジュール用
		EXE_FINISH				: in std_logic;
		EXE_START				: out std_logic;
		EXE_CMD					: out cmd_t;
		EXE_ADDR					: out std_logic_vector(20-1 downto 0);
		EXE_ADDR_FINISH		: out std_logic_vector(20-1 downto 0);
		EXE_DATA					: out std_logic_vector(64-1 downto 0);
		EXE_RESULT				: in ascii_vector(0 to 64-1);
		EXE_RESULT_LEN			: in integer
	);
end state_machine;

architecture Behavioral of state_machine is
	--** component
	
	-- CRLFの入力を監視するモジュール
	component crlf_observer
		port (
			CLK		: in	std_logic;
			REC_RQ	: in	std_logic;
			AC			: in	ascii;
			CRLF		: out	std_logic
		);
	end component;

	--** type def
	
	-- 状態の型
	type state_t is (require, fetch, decode, address, data, execute_start, execute_wait);
	type addr_status_t is (uncompleted, completed);
	
	--** signal

	-- for recieve signal
	signal rd_en			: std_logic;
	signal acv_recieve	: ascii_vector(0 to MAX_LEN-1); -- 受信アスキーデータ(最大長MAX_LEN文字)
	signal recieve_cnt	: integer := 0; -- 受信文字数
	
	-- for crlf observer
	signal obs_rec_rq		: std_logic;
	signal obs_crlf		: std_logic;
	
	-- for state
	signal state			: state_t := execute_wait;
	signal transit_en		: std_logic; -- 遷移可能信号
	
	-- for str
	signal str_start_inner	: std_logic := '0';
	
	-- for execute
	signal cmd					: cmd_t := none;
	signal addr_cnt			: integer := 0;
	signal addr					: std_logic_vector(20-1 downto 0);
	signal start_addr			: std_logic_vector(20-1 downto 0);
	signal finish_addr		: std_logic_vector(20-1 downto 0);
	signal exe_data_inner	: std_logic_vector(64-1 downto 0);
	signal exe_data_cnt		: integer := 0;
	
	-- for address control
	signal start_addr_status	: addr_status_t := uncompleted; -- 開始アドレス代入状況（初期値：未完了）
	
begin
	--** port map
	crlf_obs : crlf_observer
		port map (
			CLK => CLK,
			REC_RQ => REC_VALID,
			AC => REC_AC,
			CRLF => obs_crlf
	);
	--** signal assignment
	REC_RD_EN <= rd_en;
	STR_START <= str_start_inner;
	EXE_DATA <= exe_data_inner;
	EXE_CMD <= cmd;

	--** process
	-- クロックに同期した処理
	process(CLK)
	begin
		if rising_edge(CLK) then
			-- 状態遷移
			case state is
				-- コマンド要求
				when require =>
					str_start_inner <= '0';
					if STR_FINISH = '1' then
						recieve_cnt <= 0;
						STR(0) <= '>';
						STR_LEN <= 1;
						str_start_inner <= '1';
						state <= fetch;
					end if;
				-- コマンドフェッチ
				when fetch =>
					str_start_inner <= '0';
					if transit_en = '1' then -- CRLFが検知されたら
						transit_en <= '0';
						rd_en <= '0';
						state <= decode;
					end if;
					
					if recieve_cnt > MAX_LEN-1 then -- 受信文字数が最大値を超えていたら
						transit_en <= '0';
						state <= decode;
					end if;
					
					if REC_EMPTY = '0' then -- FIFOが空でなければ
						if STR_FINISH = '1' then -- 文字列送信可能だったら
							rd_en <= '1';
						else
							rd_en <= '0';
						end if;
					end if;

					if (REC_VALID = '1') and (REC_ALMOST_EMPTY = '1') then -- 文字が出力され、ALMOST_EMPTY信号が1なら
						transit_en <= obs_crlf; -- CRLFの監視を開始する
						-- エコーバック
						if STR_FINISH = '1' then
							acv_recieve(recieve_cnt) <= REC_AC; -- コマンド文字列に代入
							STR(0) <= REC_AC;
							STR_LEN <= 1;
							str_start_inner <= '1';
						end if;
						
						recieve_cnt <= recieve_cnt + 1; -- 文字数のカウントを増加させる
					end if;
				-- コマンドを判別し、遷移先を指定
				when decode =>
					start_addr_status <= uncompleted;
					addr_cnt <= 0;
					exe_data_cnt <= 0;
					str_start_inner <= '0';
					if recieve_cnt = 4+2 then -- コマンド4文字+CR+LF
						case acv_recieve(0 to 3) is
							when "srst" =>
								cmd <= srst;
								state <= execute_start;
							when "cmdl" =>
								cmd <= cmdl;
								state <= execute_start;
							when "sdw1" =>
								cmd <= sdw1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "sdr1" =>
								cmd <= sdr1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "dds1" =>
								cmd <= dds1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "dds2" =>
								cmd <= dds2;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "dac1" =>
								cmd <= dac1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "adcr" =>
								cmd <= adcr;
								if STR_FINISH = '1' then
									STR(0 to 6) <= "start @";
									STR_LEN <= 7;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "serr" =>
								cmd <= serr;
								if STR_FINISH = '1' then
									STR(0 to 6) <= "start @";
									STR_LEN <= 7;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "reqr" =>
								cmd <= reqr;
								if STR_FINISH = '1' then
									STR(0 to 6) <= "start @";
									STR_LEN <= 7;
									str_start_inner <= '1';
									state <= address;
								end if;
							when others =>
								cmd <= none;
								STR(0 to 16) <= "command not found";
								STR(17) <= cr;
								STR(18) <= lf;
								STR_LEN <= 19;
								str_start_inner <= '1';
								state <= require;
						end case;
					else
						if STR_FINISH = '1' then
							STR(0 to 23) <= "command length must be 4";
							STR(24) <= cr;
							STR(25) <= lf;
							STR_LEN <= 26;
							str_start_inner <= '1';
							state <= require;
						end if;
					end if;
				-- アドレス要求
				when address =>
					str_start_inner <= '0';
					if REC_EMPTY = '0' then -- FIFOが空でなければ
						if STR_FINISH = '1' then
							rd_en <= '1';
						else
							rd_en <= '0';
						end if;
					end if;
					if (REC_VALID = '1') and (REC_ALMOST_EMPTY = '1') then
						if STR_FINISH = '1' then
							-- コマンドによって必要なアドレス線が違うので、アドレスの接続先を変更する
							case cmd is
								when reqr =>
									if start_addr_status = completed then
										finish_addr(19-addr_cnt downto 19-addr_cnt-3) <= hex2vec(REC_AC);
									else
										start_addr(19-addr_cnt downto 19-addr_cnt-3) <= hex2vec(REC_AC);
									end if;
								when others =>
									addr(19-addr_cnt downto 19-addr_cnt-3) <= hex2vec(REC_AC);
							end case;
							addr_cnt <= addr_cnt + 4;
							STR(0) <= REC_AC;
							STR_LEN <= 1;
							str_start_inner <= '1';
							if addr_cnt = 20-4 then -- 1クロック前のカウントが16だったら最後の入力がこのクロックで完了する
								STR(1) <= cr;
								STR(2) <= lf;
								STR_LEN <= 3;
								case cmd is 
									when sdw1 =>
										STR(3) <= '#';
										STR_LEN <= 4;
										state <= data;
									when reqr => 
										if start_addr_status = completed then
											state <= execute_start;
										else
											STR(3 to 8) <= "end  @";
											STR_LEN <= 9;
											str_start_inner <= '1';
											state <= address;
											addr_cnt <= 0; -- 終了アドレスの取得を開始するためにカウント値を初期化
											start_addr_status <= completed;
										end if;
									when others => state <= execute_start;
								end case;
							end if;
						end if;
					end if;
				-- データ要求
				when data =>
					str_start_inner <= '0';
					if REC_EMPTY = '0' then
						if STR_FINISH = '1' then
							rd_en <= '1';
						else
							rd_en <= '0';
						end if;
					end if;
					
					if (REC_VALID = '1') and (REC_ALMOST_EMPTY = '1') then
						if STR_FINISH = '1' then
							exe_data_inner(63-exe_data_cnt downto 63-exe_data_cnt-3) <= hex2vec(REC_AC);
							exe_data_cnt <= exe_data_cnt + 4;
							STR(0) <= REC_AC;
							STR_LEN <= 1;
							str_start_inner <= '1';
							if exe_data_cnt = 64-4 then -- 1クロック前のカウントが16なら最後の入力がこのクロックで完了
								STR(1) <= cr;
								STR(2) <= lf;
								STR_LEN <= 3;
								state <= execute_start;
							end if;
						end if;
					end if;
				-- 実行
				when execute_start =>
					str_start_inner <= '0';
					EXE_START <= '1';
					case cmd is
						when reqr =>
							EXE_ADDR <= start_addr;
							EXE_ADDR_FINISH <= finish_addr;
						when others =>
							EXE_ADDR <= addr;
					end case;
					EXE_ADDR <= addr;
					state <= execute_wait;
				when execute_wait =>
					EXE_START <= '0';
					if STR_FINISH = '1' then
						if EXE_FINISH = '1' then
							if cmd /= none then
								if EXE_RESULT_LEN /= 0 then
									STR <= EXE_RESULT;
									STR_LEN <= EXE_RESULT_LEN;
									str_start_inner <= '1';
								end if;
							end if;
							state <= require;
						end if;
					end if;
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;

