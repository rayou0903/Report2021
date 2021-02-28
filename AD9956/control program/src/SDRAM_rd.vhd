----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:02:51 10/09/2019 
-- Design Name: 
-- Module Name:    SDRAM_rd - read_sec 
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
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--kopipeyou
--component SDRAM_rd is
--	port(	clk : in std_logic;
--			rst : in std_logic;
--			
--			rd_req : in std_logic;
--			rd_fin : out std_logic;
--			data_out : out std_logic_vector(63 downto 0);
--
--			adr_in : in std_logic_vector(19 downto 0);
--			
--			sdr_req : out std_logic;
--			sdr_adr : out std_logic_vector(19 downto 0);
--			sdr_fin : in std_logic;
--			sdr_data : in std_logic_vector(63 downto 0));
--end component;

--read_sec : SDRAM_rd 
--	port map(
-- 	clk => ,
--		rst => ,
-- 	rd_req => ,
--		rd_fin => ,
--		data_out => ,
--		adr_in => ,
--		sdr_req => ,
--		sdr_adr => ,
--		sdr_fin => ,
--		sdr_data => 
-- );



entity SDRAM_rd is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
			
		rd_req		: in std_logic;
		rd_fin		: out std_logic;
		data_out		: out std_logic_vector(63 downto 0);
		
		adr_in		: in std_logic_vector(19 downto 0);
		
		sdr_req		: out std_logic;
		sdr_adr		: out std_logic_vector(19 downto 0);
		sdr_fin		: in std_logic;
		sdr_data		: in std_logic_vector(63 downto 0)
	);
end SDRAM_rd;

architecture read_sec of SDRAM_rd is

	type state_t is (idle, sd_request, dt_aquire, cycle_end); --状態名(アイドル、SDRAMリクエスト、データ獲得、1サイクル終了)

	type reg is record
		data : std_logic_vector(63 downto 0); --データ
		adr : std_logic_vector(19 downto 0); --アドレス
		req : std_logic; --読み込み要求信号
		pend : std_logic; --読み込み可能信号
		state : state_t; --状態用
		comp : std_logic; --スイッチを押されるたびにアドレスを返ることを実現
	end record;
	
	signal p : reg; 
	signal n : reg;

begin

	sdr_req <= p.req;
	sdr_adr <= p.adr;
	data_out <= p.data;

	process(n,p,adr_in,rd_req,sdr_fin,n.data,n.adr,n.state)
	begin
		n <= p;
		n.state <= p.state;
		
		if rd_req = '1' then --re_swが押されると読み込み開始
			if p.comp = '0' then --re_swを押すたびにアドレスが切り替わる（押しっぱなしではアドレスが変わらない）
				n.pend <= '1';
				n.comp <= '1'; 
				if p.pend = '0' then
					n.adr <= adr_in; --アドレス変更
					n.state <= sd_request;
				end if;
			end if;
		else
			n.comp <= '0';
		end if;
		
		case p.state is
			when idle =>
				rd_fin <= '0';
				
			when sd_request =>
				n.req <= '1';
				n.state <= dt_aquire;
				
			when dt_aquire =>
				n.req <= '0';
				if sdr_fin = '1' then
					n.data <= sdr_data;
					n.state <= cycle_end;
					
				end if;
				
			when cycle_end =>
				rd_fin <= '1';
				n.pend <= '0';
				n.state <= idle;
				
			when others =>
				n.req <= '0';
				n.pend <= '0';
				n.state <= idle;
		end case;
	
	end process;

	--クロックに同期してｎ信号がp信号に変わる
	process(clk,rst)
	begin
		if rst = '1' then
			p.data <= (others => '0');
			p.adr <= (others => '0');
			p.req <= '0';
			p.pend <= '0';
			p.state <= idle;
			p.comp <= '0';
		elsif clk' event and clk = '1' then
			p <= n;
		end if;
	end process;


end read_sec;

