----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:52 09/06/2019 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.ascii_pac.all;
use work.types.all;

entity top is
	port (
		CLK			: in		std_logic;
		WING_A		: out		std_logic_vector(16-1 downto 0);
		WING_B		: in		std_logic_vector(16-1 downto 0);
		WING_C		: in		std_logic_vector(16-1 downto 0);
		RXD			: in		std_logic;
		TXD			: out 	std_logic := '1';
		DRAM_ADDR   : OUT		STD_LOGIC_VECTOR (12 downto 0);
		DRAM_BA     : OUT    STD_LOGIC_VECTOR (1 downto 0);
		DRAM_CAS_N  : OUT    STD_LOGIC;
		DRAM_CKE    : OUT    STD_LOGIC;
		DRAM_CLK    : OUT    STD_LOGIC;
		DRAM_CS_N   : OUT    STD_LOGIC;
		DRAM_DQ     : INOUT  STD_LOGIC_VECTOR(15 downto 0);
		DRAM_DQM    : OUT    STD_LOGIC_VECTOR(1 downto 0);
		DRAM_RAS_N  : OUT    STD_LOGIC;
		DRAM_WE_N   : OUT    STD_LOGIC;
		LED		: out		std_logic
	);
end top;

architecture Behavioral of top is
	-- ** component
	
	-- クロックジェネレータ
	component clk_generator
		port (
			-- Clock in ports
			CLK_IN1           : in     std_logic;
			-- Clock out ports
			CLK_OUT2				 : out	 std_logic;
			CLK_OUT3				:	out	std_logic;
			CLK100          : out    std_logic
		);
	end component;
	
	-- RS232C用クロックジェネレータ
	component clk_gen_rs232c
		port (
			CLK_IN : in  STD_LOGIC;
			CLK9600 : out  STD_LOGIC;
			CLK115200 : out  STD_LOGIC);
	end component;
	
	-- 受信モジュール
	component receive
		port (
			RST			: in std_logic;
			CLK_RS232C	: in std_logic;
			RD_CLK		: in std_logic;
			RD_EN			: in std_logic;
			RXD			: in std_logic;
			FULL			: out std_logic;
			EMPTY			: out std_logic;
			ALMOST_EMPTY: out std_logic;
			VALID			: out std_logic;
			ACOUT			: out ascii
		);
	end component;
	
	-- 送信モジュール
	component transfer
		port (
			RST			: in std_logic;
			CLK_RS232C	: in std_logic;
			WR_CLK		: in std_logic;
			WR_EN			: in std_logic;
			AC_TR			: in ascii;
			FULL			: out std_logic;
			EMPTY			: out std_logic;
			TXD			: out std_logic
		);
	end component;
	
	-- SDRAMの制御モジュール
	component SDRAM_ctrl
		port (
			clk1	: in std_logic;
			rst	:	in		std_logic;
			--SDRAM用信号
			sdram_addr	:	out	std_logic_vector(11 downto 0);
			sdram_ba		:	out	std_logic_vector(1 downto 0);
			sdram_cs		:	out	std_logic;
			sdram_cke	:	out	std_logic;
			sdram_clk	:	out	std_logic;
			sdram_dq		:	inout	std_logic_vector(15 downto 0);
			sdram_dqm	:	out	std_logic_vector(1 downto 0);
			sdram_ras	:	out	std_logic;
			sdram_cas	:	out	std_logic;
			sdram_we		:	out	std_logic;
			
			data_in		:	in	std_logic_vector(63 downto 0);
			data_out		:	out	std_logic_vector(63 downto 0);
			req_read		:	in	std_logic;
			req_write	:	in	std_logic;
			address		:	in	std_logic_vector(19 downto 0);
			data_mask	:	in	std_logic_vector(1 downto 0);
			data_in_valid	: OUT		std_logic; -- 書き込みが完了したら1になる信号
			data_out_valid : OUT		STD_LOGIC -- 読み出しが完了したら1になる信号
		);
	end component;
	
	-- sdram読み出しモジュール
	component SDRAM_rd is
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			rd_req : in std_logic;
			rd_fin : out std_logic;
			data_out : out std_logic_vector(63 downto 0);

			adr_in : in std_logic_vector(19 downto 0);
			
			sdr_req : out std_logic;
			sdr_adr : out std_logic_vector(19 downto 0);
			sdr_fin : in std_logic;
			sdr_data : in std_logic_vector(63 downto 0)
		);
	end component;
	
	-- sdram書き込みモジュール
	component SDRAM_wr is
		port(
			clk : in std_logic;
			rst : in std_logic;
			
			wr_req : in std_logic;
			wr_fin	: out std_logic;
			
			data_in	: in std_logic_vector(64-1 downto 0);

			adr_in : in std_logic_vector(19 downto 0);
			
			sdr_req : out std_logic;
			sdr_adr : out std_logic_vector(19 downto 0);
			sdr_data : out std_logic_vector(63 downto 0)
		);
	end component;
	
	-- 状態遷移を行うモジュール
	component state_machine
		generic (
			MAX_LEN					: positive := 64
		);
		port (
			CLK						: in std_logic;
			-- 受信用FIFOへの信号
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
			EXE_RESULT				: in ascii_vector(0 to MAX_LEN-1);
			EXE_RESULT_LEN			: in integer
		);
	end component;
	
	component signal_auth_ctrl
		port (
			CLK				: in std_logic;
			SEL				: in cmd_t; -- 選択用信号
			-- 状態遷移モジュールからの信号(0でアクティブ)
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
	end component;
	
	component command_execute
		port (
			CLK			: in std_logic;
			-- 実行に必要な信号
			CMD_IN			: in cmd_t;
			ADDR_IN			: in std_logic_vector(20-1 downto 0);
			ADDR_FINISH_IN	: in std_logic_vector(20-1 downto 0);
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
			MSR_ADDR_START	: out std_logic_vector(20-1 downto 0);
			MSR_ADDR_FINISH: out std_logic_vector(20-1 downto 0);
			MSR_DATA			: out std_logic_vector(64-1 downto 0);
			MSR_START		: out std_logic;
			MSR_FINISH		: in std_logic;
			-- リセット
			RST_OP			: out std_logic;
			--** 結果 **
			RESULT			: out ascii_vector(64-1 downto 0);
			RESULT_LEN		: out integer; -- 実行結果の文字列長
			EXE_START		: in std_logic;
			EXE_FINISH		: out std_logic
		);
	end component;
	
	-- 測定モジュール
	component just_measurement is
		port(
			clk : in std_logic;
			clk2 : in std_logic;
			rst : in std_logic;
			
			msr_start : in std_logic;
			msr_finish : out std_logic;
			str_adr : in std_logic_vector(19 downto 0);
			end_adr : in std_logic_vector(19 downto 0);
			
			sdr_req : out std_logic;
			sdr_fin : in std_logic;
			ctrl_data : in std_logic_vector(63 downto 0);
			cite_addr : out std_logic_vector(19 downto 0);
			
			test_dout : out std_logic_vector(63 downto 0);
			test_bit : out std_logic; --テスト用1bit信号
			
			measure_output	: out std_logic_vector(15 downto 0);
			rf_pulse : out std_logic_vector(2 downto 0);
			data1 : out std_logic; --DDS・ｽp・ｽM・ｽ・ｽ
			fqud1 : out std_logic;
			reset1 : out std_logic;
			w_clk1 : out std_logic;
			data2 : out std_logic; --DDS・ｽp・ｽM・ｽ・ｽ
			fqud2 : out std_logic;
			reset2 : out std_logic;
			w_clk2 : out std_logic;
			adc_sig : out std_logic_vector(2 downto 0)
		);
	end component;
	
	-- 文字列送信モジュール
	component string_send
		generic (
			MAX_LEN : integer := 64
		);
		port (
			CLK		: in std_logic;
			STR		: in ascii_vector(0 to MAX_LEN-1);
			LEN		: in integer;
			START		: in std_logic;
			AC_OUT	: out ascii;
			WR_REQ	: out std_logic;
			FINISH	: out std_logic
		);
	end component;
	
	component vector_mux
		generic (
			SIGNAL_NUM	: positive	:= 64
		);
		port (
			SEL					: in std_logic;
			LOW_ACTIVE_SIG		: in std_logic_vector(SIGNAL_NUM-1 downto 0);
			HIGH_ACTIVE_SIG	: in std_logic_vector(SIGNAL_NUM-1 downto 0);
			OUT_SIG				: out std_logic_vector(SIGNAL_NUM-1 downto 0)
		);
	end component;

	-- ** signal
	
	-- clk
	signal clk100		: std_logic;
	signal clk100_nb	: std_logic;
	signal clk30		: std_logic;
	signal clk_rs232c	: std_logic; -- RS232C通信に合わせたクロック信号
	
	-- led
	signal led_inner	: std_logic := '0';
	
	-- buf
	signal outer_clk_buf		: std_logic; -- IBUFG, RS232C対応の周波数を入力するためのバッファ
	signal rxd_buf		: std_logic; -- IBUFG
	signal txd_buf		: std_logic := '1'; -- OBUF
	
	-- receive
	signal rc_fifo_rst				: std_logic;
	signal rc_fifo_empty				: std_logic;
	signal rc_fifo_almost_empty	: std_logic;
	signal rc_fifo_full				: std_logic;
	signal rc_fifo_valid				: std_logic;
	signal rc_rd_en					: std_logic;
	signal rc_ac						: ascii; -- 受信用信号
	
	-- transfer
	signal tr_fifo_rst	: std_logic;
	signal tr_fifo_empty	: std_logic;
	signal tr_fifo_full	: std_logic;
	signal tr_wr_en		: std_logic;
	signal tr_ac			: ascii; -- 送信用信号
	
	-- crlfが観測されたら1となる信号
	signal crlf_observed	: std_logic;
	
	-- sdram ctrl
	-- common
	signal sdram_addr		: std_logic_vector(20-1 downto 0);
	signal rw_addr_sel	: std_logic;
	-- read
	signal sdram_r_data	: std_logic_vector(64-1 downto 0);
	signal sdram_r_addr	: std_logic_vector(20-1 downto 0);
	signal sdram_r_req	: std_logic;
	signal sdram_r_fin	: std_logic;
	-- write
	signal sdram_w_data	: std_logic_vector(64-1 downto 0);
	signal sdram_w_addr	: std_logic_vector(20-1 downto 0);
	signal sdram_w_req	: std_logic;
	signal sdram_w_fin	: std_logic;
	
	-- sdram read
	signal rd_fin	: std_logic;
	signal rd_data	: std_logic_vector(64-1 downto 0);
	signal rd_req	: std_logic;
	signal rd_addr	: std_logic_vector(20-1 downto 0);
	
	
	-- state machine
	signal rst_op			: std_logic := '0';
	
	-- execute
	signal exe_cmd					: cmd_t;
	signal exe_start				: std_logic;
	signal exe_finish				: std_logic := '1';
	signal exe_addr_in			: std_logic_vector(20-1 downto 0);
	signal exe_addr_finish_in	: std_logic_vector(20-1 downto 0);
	signal exe_data_in			: std_logic_vector(64-1 downto 0);
	signal exe_rd_addr			: std_logic_vector(20-1 downto 0);
	signal exe_rd_data			: std_logic_vector(64-1 downto 0);
	signal exe_rd_start			: std_logic;
	signal exe_rd_finish			: std_logic;
	-- result
	signal exe_result			: ascii_vector(0 to 64-1);
	signal exe_result_len	: integer;
	-- sdram write
	signal exe_wr_fin		: std_logic;
	signal exe_wr_data	: std_logic_vector(64-1 downto 0);
	signal exe_wr_req		: std_logic;
	signal exe_wr_addr	: std_logic_vector(20-1 downto 0);
	
	-- measure part
	signal msr_addr_start	: std_logic_vector(20-1 downto 0);
	signal msr_addr_finish	: std_logic_vector(20-1 downto 0);
	signal msr_data			: std_logic_vector(64-1 downto 0);
	signal msr_start			: std_logic;
	signal msr_finish			: std_logic;
	signal msr_rd_req	 		: std_logic;
	signal msr_rd_fin			: std_logic;
	signal msr_rd_data		: std_logic_vector(64-1 downto 0);
	signal msr_rd_addr		: std_logic_vector(20-1 downto 0);
	signal msr_rf_pulse		: std_logic_vector(2 downto 0);
	signal msr_adc_sig		: std_logic_vector(2 downto 0);
	signal msr_test_bit		: std_logic;
	signal msr_test_dout		: std_logic_vector(63 downto 0);
	signal msr_wing_a			: std_logic_vector(15 downto 0);
	signal dds_data			: std_logic;
	signal dds_fqud			: std_logic;
   signal dds_wclk1			: std_logic;
	signal dds_reset			: std_logic;
	
	-- string send
	signal str			: ascii_vector(0 to 64-1);
	signal str_len		: integer;
	signal str_start	: std_logic;
	signal str_finish	: std_logic;
	signal str_wr_req	: std_logic;
	
begin
	-- ** port map
	
   -- IBUF: Single-ended Input Buffer
   --       Spartan-6
   -- Xilinx HDL Language Template, version 14.7
   
   IBUF_rs232c_clk : IBUFG
   generic map (
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "LVTTL")
   port map (
      O => outer_clk_buf,-- Buffer output
      I => WING_C(0)      -- Buffer input (connect directly to top-level port)
   );
	
	
	IBUF_rxd : IBUF
   generic map (
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "LVTTL")
   port map (
      O => rxd_buf,     -- Buffer output
      I => RXD      -- Buffer input (connect directly to top-level port)
   );
  
   -- End of IBUF_inst instantiation
	
	-- OBUF: Single-ended Output Buffer
   --       Spartan-6
   -- Xilinx HDL Language Template, version 14.7
   
   OBUF_txd : OBUF
   generic map (
      DRIVE => 8,
      IOSTANDARD => "LVTTL",
      SLEW => "SLOW")
   port map (
      O => TXD,     -- Buffer output (connect directly to top-level port)
      I => txd_buf      -- Buffer input 
   );
  
   -- End of OBUF_inst instantiation
	
	-- BUFG: Global Clock Buffer
   --       Spartan-6
   -- Xilinx HDL Language Template, version 14.7

--   BUFG_inst : BUFG
--   port map (
--      O => WING_A(13), -- 1-bit output: Clock buffer output
--      I => clk30  -- 1-bit input: Clock buffer input
--   );
	
	-- C0からの入力をRS232C用のクロックとして使う
	rs232c_clk_gen : clk_gen_rs232c
		port map (
			CLK_IN => outer_clk_buf,
			CLK9600 => clk_rs232c,
			CLK115200 => open
	);
	
	-- 内部クロック100MHzを生成
	clk_gen : clk_generator
		port map (
			CLK_IN1 => CLK,
			CLK_OUT2 => clk30,
			CLK_OUT3 => clk100_nb,
			CLK100 => clk100
	);
	
	-- receive
	rc : receive
		port map(
			RST => rc_fifo_rst,
			CLK_RS232C => clk_rs232c,
			RD_CLK => clk100,
			RD_EN => rc_rd_en,
			ACOUT => rc_ac,
			FULL => rc_fifo_full,
			EMPTY => rc_fifo_empty,
			ALMOST_EMPTY => rc_fifo_almost_empty,
			VALID => rc_fifo_valid,
			RXD => rxd_buf
	);
	
	-- transfer
	tr : transfer
		port map (
			RST => tr_fifo_rst,
			CLK_RS232C => clk_rs232c,
			WR_CLK => clk100,
			AC_TR => tr_ac,
			WR_EN => tr_wr_en,
			FULL => tr_fifo_full,
			EMPTY => tr_fifo_empty,
			TXD => txd_buf
	);
	
	-- SDRAM制御
	sdram : SDRAM_ctrl
		port map (
			clk1 => clk100,
			rst => rst_op,
			sdram_addr => DRAM_ADDR(11 downto 0),
			sdram_ba => DRAM_BA,
			sdram_cs => DRAM_CS_N,
			sdram_cke => DRAM_CKE,
			sdram_clk => DRAM_CLK,
			sdram_dq => DRAM_DQ,
			sdram_dqm => DRAM_DQM,
			sdram_ras => DRAM_RAS_N,
			sdram_cas => DRAM_CAS_N,
			sdram_we => DRAM_WE_N,
			data_in => sdram_w_data,
			data_out => sdram_r_data,
			req_read => sdram_r_req,
			req_write => sdram_w_req,
			address => sdram_addr,
			data_mask => "11",
			data_in_valid => sdram_w_fin,
			data_out_valid => sdram_r_fin
	);
	
	-- sdram read
	read_sec : sdram_rd
		port map(
			clk => clk100,
			rst => rst_op,
			rd_req => rd_req,
			rd_fin => rd_fin,
			data_out => rd_data,
			adr_in => rd_addr,
			sdr_req => sdram_r_req,
			sdr_adr => sdram_r_addr,
			sdr_fin => sdram_r_fin,
			sdr_data => sdram_r_data
	);
	
	-- sdram write
	write_sec : sdram_wr
		port map(
			clk => clk100,
			rst => rst_op,
			wr_req => exe_wr_req,
			wr_fin => exe_wr_fin,
			data_in => exe_wr_data,
			adr_in => exe_wr_addr,
			sdr_req => sdram_w_req,
			sdr_adr => sdram_w_addr,
			sdr_data => sdram_w_data
	);
	
	-- state machine
	st_machine : state_machine
		port map (
			CLK => clk100,
			REC_EMPTY => rc_fifo_empty,
			REC_ALMOST_EMPTY => rc_fifo_almost_empty,
			REC_VALID => rc_fifo_valid,
			REC_AC => rc_ac,
			REC_RD_EN => rc_rd_en,
			STR_FINISH => str_finish,
			STR_START => str_start,
			STR => str,
			STR_LEN => str_len,
			EXE_FINISH => exe_finish,
			EXE_START => exe_start,
			EXE_CMD => exe_cmd,
			EXE_ADDR => exe_addr_in,
			EXE_ADDR_FINISH => exe_addr_finish_in,
			EXE_DATA => exe_data_in,
			EXE_RESULT => exe_result,
			EXE_RESULT_LEN => exe_result_len
	);
	
	-- 信号の権限を管理するモジュール
	sig_auth_ctrl : signal_auth_ctrl
		port map (
			CLK => clk100,
			SEL => exe_cmd,
			-- 状態遷移モジュールからの信号(0でアクティブ)
			EXE_ADDR => exe_rd_addr,
			EXE_RD_REQ => exe_rd_start,
			EXE_RD_FIN => exe_rd_finish,
			EXE_DATA => exe_rd_data,
			-- 測定モジュールからの信号(1でアクティブ)
			MSR_ADDR => msr_rd_addr,
			MSR_RD_REQ => msr_rd_req,
			MSR_RD_FIN => msr_rd_fin,
			MSR_DATA => msr_rd_data,
			-- SDRAMから受け取る信号
			RD_FIN => rd_fin,
			RD_DATA => rd_data,
			-- SDRAM読み出しモジュールに渡すアドレス、リクエスト信号
			RD_REQ => rd_req,
			RD_ADDR => rd_addr
	);
	
	-- command execute
	cmd_exe : command_execute
		port map (
			CLK => clk100,
			-- 実行に必要な信号
			CMD_IN => exe_cmd,
			ADDR_IN => exe_addr_in,
			ADDR_FINISH_IN => exe_addr_finish_in,
			DATA_IN => exe_data_in,
			--** 各モジュールとの通信に必要な信号 **
			-- 読み出しモジュール(sdram_rd)
			RD_ADDR => exe_rd_addr,
			RD_DATA => exe_rd_data,
			RD_START => exe_rd_start,
			RD_FINISH => exe_rd_finish,
			-- 書き込みモジュール(sdram_wr)
			WR_ADDR => exe_wr_addr,
			WR_DATA => exe_wr_data,
			WR_START => exe_wr_req,
			WR_FINISH => exe_wr_fin,
			-- 測定モジュール()
			MSR_ADDR_START => msr_addr_start,
			MSR_ADDR_FINISH => msr_addr_finish,
			MSR_DATA => msr_data,
			MSR_START => msr_start,
			MSR_FINISH => msr_finish,
			-- リセット
			RST_OP => rst_op,
			--** 結果 **
			RESULT => exe_result,
			RESULT_LEN => exe_result_len,
			EXE_START => exe_start,
			EXE_FINISH => exe_finish
	);
	
	-- measurement module
	measure : just_measurement 
		port map(
			clk => clk100,
			clk2 => clk100_nb,
			rst => rst_op,
			msr_start => msr_start,
			msr_finish => msr_finish,
			str_adr => msr_addr_start,
			end_adr => msr_addr_finish,
			sdr_req => msr_rd_req,
			sdr_fin => msr_rd_fin,
			ctrl_data => msr_rd_data,
			cite_addr => msr_rd_addr,
			test_dout => msr_test_dout,
			test_bit => msr_test_bit,
			measure_output => msr_wing_a,
			rf_pulse => msr_rf_pulse,
			data1 => WING_A(3),
			fqud1=> WING_A(6),
			reset1 => WING_A(0),
			w_clk1 => WING_A(2),
			data2 => WING_A(7),
			fqud2 => WING_A(5),
			reset2 => WING_A(4),
			w_clk2 => WING_A(1),
			adc_sig => msr_adc_sig
	);
	
	-- string sender
	str_send : string_send
		port map (
			CLK => clk100,
			STR => str,
			LEN => str_len,
			START => str_start,
			AC_OUT => tr_ac,
			WR_REQ => tr_wr_en,
			FINISH => str_finish
	);
	
	-- write or read selector
	mux_rw_addr	: vector_mux
		generic map(
			SIGNAL_NUM => 20
		)
		port map (
			SEL => rw_addr_sel,
			LOW_ACTIVE_SIG => sdram_r_addr,
			HIGH_ACTIVE_SIG => sdram_w_addr,
			OUT_SIG => sdram_addr
	);
	
	-- ** signal assignment
	LED <= msr_wing_a(15);
	WING_A(12 downto 8) <= msr_wing_a(4 downto 0);
	WING_A(13) <= clk30;
	WING_A(15 downto 14) <= msr_wing_a(6 downto 5);
--	WING_A(13) <= dds_fqud;
--	WING_A(12) <= dds_reset;
--	WING_A(14) <= dds_wclk1;
--	WING_A <= msr_test_dout(15 downto 0);
--	WING_A(15 downto 0) <= msr_wing_a(15 downto 0);
	DRAM_ADDR(12) <= '0';

	-- ** process
	-- test
--	process(clk100)
--	begin
--		if rising_edge(clk100) then
--			if msr_adc_sig = '1' then
--				led_inner <= not led_inner;
--			end if;
--		end if;
--	end process;
	
	
	-- read and write select signal
	process(exe_cmd)
	begin
		if exe_cmd = sdr1 then
			rw_addr_sel <= '0';
		elsif exe_cmd = sdw1 then
			rw_addr_sel <= '1';
		elsif exe_cmd = reqr then
			rw_addr_sel <= '0';
		else
			rw_addr_sel <= '0';
		end if;
	end process;
	
end Behavioral;