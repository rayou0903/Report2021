----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:07:41 09/26/2019 
-- Design Name: 
-- Module Name:    transfer - Behavioral 
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

library work;
use work.ascii_pac.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- ** 使うときのコピペ用
--
--	component transfer
--		port (
--			RST			: in std_logic;
--			CLK_RS232C	: in std_logic;
--			WR_CLK		: in std_logic;
--			WR_EN			: in std_logic;
--			AC_TR			: in ascii;
--			FULL			: out std_logic;
--			EMPTY			: out std_logic;
--			TXD			: out std_logic
--		);
--	end component;
--
--	tr : transfer
--		port map (
--			RST => rst,
--			CLK_RS232C => clk_rs232c,
--			WR_CLK => wr_clk,
--			WR_EN => wr_en,
--			AC_TR => ac_tr,
--			FULL => full,
--			EMPTY => empty,
--			TXD => txd
--	);
--	
	
entity transfer is
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
end transfer;

architecture Behavioral of transfer is
	-- ** component
	-- FIFO memory
	COMPONENT fifo_trans
		PORT (
			RST	: IN STD_LOGIC;
			WR_CLK : IN STD_LOGIC;
			RD_CLK : IN STD_LOGIC;
			DIN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			WR_EN : IN STD_LOGIC;
			RD_EN : IN STD_LOGIC;
			DOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			FULL : OUT STD_LOGIC;
			EMPTY : OUT STD_LOGIC
		);
	END COMPONENT;
	
	-- RS232C transfer
	component rs232c_8bit_transfer
		port (
			CLK		: in		std_logic;								-- クロック信号入力
			DSEND		: in		std_logic_vector(8-1 downto 0);	-- 送信データ
			SEND_RQ	: in		std_logic;								-- 送信リクエスト
			TXD		: out		std_logic;								-- RS232CのTXD信号
			SET_EN	: out		std_logic								-- セット可能信号
		);
	end component;
	
	-- ** inner signal
	signal t_data		: std_logic_vector(8-1 downto 0);
	signal txd_inner	: std_logic := '1';
	
	-- for fifo
	signal fifo_rd_en 	: std_logic;
	signal fifo_empty 	: std_logic;
	
	-- for transfer
	signal send_rq			: std_logic;
	signal trans_set_en	: std_logic;
	
begin
	-- ** port map
	fifo_tr : fifo_trans
		port map (
			-- in
			RST => RST,
			WR_CLK => WR_CLK,
			RD_CLK => CLK_RS232C,
			DIN => ascii_decoder(AC_TR),
			WR_EN => WR_EN,
			RD_EN => fifo_rd_en,
			-- out
			DOUT => t_data,
			FULL => FULL,
			EMPTY => fifo_empty
	);
	
	
	-- RS232C出力
	rs232c8bit_t : rs232c_8bit_transfer
		port map (
			CLK => CLK_RS232C,
			DSEND => t_data,
			SEND_RQ => send_rq,
			TXD => txd_inner,
			SET_EN => trans_set_en
	);

	-- ** signal assignment
	EMPTY <= fifo_empty;
	TXD <= txd_inner;

	-- ** process
	process(CLK_RS232C)
	begin
		if rising_edge(CLK_RS232C) then
			-- セット可能でなければFIFOからの読み出し中断
			if trans_set_en = '0' then
				fifo_rd_en <= '0';
				send_rq <= '0';
			-- 空になったら送信中断
			elsif fifo_empty = '1' then
				fifo_rd_en <= '0';
				send_rq <= '0';
			-- セット可能で空でなければ読み出しを行い、送信リクエストする
			elsif fifo_empty = '0' then
				fifo_rd_en <= '1';
				send_rq <= '1';
			end if;
		end if;
	end process;

end Behavioral;

