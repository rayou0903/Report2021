----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:32:20 09/26/2019 
-- Design Name: 
-- Module Name:    receive - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.ascii_pac.all;

-- ** 使うときのコピペ用
--
--	component receive
--		port (
--			RST			: in std_logic;
--			CLK_RS232C	: in std_logic;
--			RD_CLK		: in std_logic;
--			RD_EN			: in std_logic;
--			RXD			: in std_logic;
--			FULL			: out std_logic;
--			EMPTY			: out std_logic;
--			ALMOST_EMPTY: out std_logic;
--			VALID			: out std_logic;
--			ACOUT			: out ascii
--		);
--	end component;
--	
--	rc : receive
--		port map(
--			RST => RST,
--			CLK_RS232C => CLK_RS232C
--			RD_CLK => RD_CLK,
--			RD_EN => RD_EN,
--			RXD => RXD,
--			FULL => FULL,
--			EMPTY => EMPTY,
--			ALMOST_EMPTY => ALMOST_EMPTY,
--			VALID => VALID,
--			ACOUT => ACOUT
--	);
--
	
entity receive is
	port (
		RST				: in std_logic;
		CLK_RS232C		: in std_logic;
		RD_CLK			: in std_logic;
		RD_EN				: in std_logic;
		RXD				: in std_logic;
		FULL				: out std_logic;
		EMPTY				: out std_logic;
		ALMOST_EMPTY	: out std_logic;
		VALID				: out std_logic;
		ACOUT				: out ascii
	);
end receive;

architecture Behavioral of receive is
	-- ** component
	-- FIFO　memory
 	COMPONENT fifo_receive
		PORT (
			RST : IN STD_LOGIC;
			WR_CLK : IN STD_LOGIC;
			RD_CLK : IN STD_LOGIC;
			DIN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			WR_EN : IN STD_LOGIC;
			RD_EN : IN STD_LOGIC;
			DOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			FULL : OUT STD_LOGIC;
			EMPTY : OUT STD_LOGIC;
			ALMOST_EMPTY : OUT STD_LOGIC;
			VALID	: OUT STD_LOGIC
		);
	END COMPONENT;
	
	-- RS232C receive
	component rs232c_8bit_receive
		port (
			CLK		: in	std_logic;
			RXD		: in	std_logic;
			DREC		: out std_logic_vector(8-1 downto 0);
			GET_EN	: out	std_logic
		);
	end component;
	
	-- ** signal
	signal r_data	: std_logic_vector(8-1 downto 0); -- 受信データ
	
	-- for fifo
	signal fifo_wr_en		: std_logic;
	signal fifo_full		: std_logic;
	signal fifo_rc_data	: std_logic_vector(8-1 downto 0);
	
	-- for receive
	signal rec_get_en	: std_logic;
	signal read_rq		: std_logic := '1';
	
begin
	-- ** port map
	-- fifo
	fifo_rc : fifo_receive
		port map (
			RST => RST,
			WR_CLK => CLK_RS232C,
			RD_CLK => RD_CLK,
			DIN => r_data,
			WR_EN => fifo_wr_en,
			RD_EN => RD_EN,
			DOUT => fifo_rc_data,
			FULL => fifo_full,
			EMPTY => EMPTY,
			ALMOST_EMPTY => ALMOST_EMPTY,
			VALID => VALID
	);

	-- rs232c receive
	rs232c8bit_r : rs232c_8bit_receive
		port map (
			CLK => CLK_RS232C,
			RXD => RXD,
			DREC => r_data,
			GET_EN => rec_get_en
	);
	
	-- ** signal assignment
	FULL <= fifo_full;
	ACOUT <= ascii_encoder(fifo_rc_data);
	
	-- ** process
	process(CLK_RS232C)
	begin
		if rising_edge(CLK_RS232C) then
			-- データを受信可能ならFIFOに追加
			if (rec_get_en = '1') and (read_rq = '1') then
				read_rq <= '0'; -- 1度だけFIFOに格納するためにリクエストを0にする
				fifo_wr_en <= '1';
			-- データ更新中はFIFOへの追加を停止
			elsif (rec_get_en = '0') then
				read_rq <= '1'; -- データが変更されるときにリクエストを1にする
				fifo_wr_en <= '0';
			elsif read_rq = '0' then
				fifo_wr_en <= '0';
			end if;
		end if;
	end process;	
end Behavioral;

