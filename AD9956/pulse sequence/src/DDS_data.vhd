----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:53:49 12/20/2019 
-- Design Name: 
-- Module Name:    DDS_data - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.data_types.all;

--componwnt DDS_data is
--	port( clk : in std_logic;
--			rst : in std_logic;
--			msr_fin : in std_logic;
--			
--			d_fin : in std_logic; --デコードが終わったかどうかみる
--			d_type : in std_logic_vector(3 downto 0); --どのタイプのでーたが来るのかを確認
--			rd_comp : out std_logic; --データの読み取りが終わったかどうか見る
--			data : in std_logic_vector(39 downto 0);
--			
--			wr_en_a : out std_logic; --fifoのWR_EN
--			full_a : in std_logic; --fifoのFULL
--			data_out : out std_logic_vector(39 downto 0);
--			data_end : out std_logic);
--end component;
--dds_DATA : DDS_data 
--	port map( clk => ,
--				 rst => ,
--			  	 msr_fin => ,
--			
--				 d_fin => ,
--				 d_type => ,
--				 rd_comp => ,
--				 data => ,
--			
--				 wr_en_a => ,
--				 full_a => ,
--				 data_out => ,
--				 data_end => );


entity DDS_data is
	Generic (DATA_LEN : integer := 64); --40 -> 64
	port( clk : in std_logic;
			rst : in std_logic;
			msr_fin : in std_logic;
			
			d_fin : in std_logic; --デコードが終わったかどうかみる
			d_type : in std_logic_vector(3 downto 0); --どのタイプのでーたが来るのかを確認
			rd_comp : out std_logic; --データの読み取りが終わったかどうか見る
			data : in std_logic_vector(DATA_LEN-1 downto 0);
			
			--wr_en_a
			enable	: out std_logic; --fifoのWR_EN --dataが40ビットそろった合図
			--full_a 
			recieve	: in std_logic; --fifoのFULL --dataを受け取った合図
			data_out : out std_logic_vector(DATA_LEN-1 downto 0));
			--first_data : out std_logic_vector(39 downto 0); --DDS最初のデータ
			--data_end : out std_logic);
end DDS_data;

architecture data_read of DDS_data is
	signal counter : std_logic_vector(15 downto 0):= (others => '0');
	signal count_end : std_logic_vector(15 downto 0):= X"FFFF";
	
	--signal d_end : std_logic:='0'; --data_end
	signal d_num : std_logic_vector(1 downto 0):= "00";  
	signal d_out : std_logic_vector(DATA_LEN-1 downto 0); --data_out
	--signal first_d : std_logic_vector(39 downto 0); --first?data
	
	signal en_sig : std_logic:= '0'; --wr_en_a --enable
	signal comp_rd : std_logic:= '0'; --rd_comp

begin

	rd_comp <= comp_rd;
	--wr_en_a <= tr_pend_a;
	enable <= en_sig;
	data_out <= d_out;
	--first_data <= first_d;


	process(clk,rst,msr_fin,d_fin,recieve)
		begin
			if rst = '1' then
				counter <= (others => '0');
				count_end <= X"FFFF";
				d_num <= "00";
				d_out <= (others => '0');
				en_sig <= '0';
				comp_rd <= '0';
			elsif clk' event and clk = '1' then
				if d_fin = '1' then
					if d_num = "00" then
						d_out(DATA_LEN/2 -1 downto 0) <= data(DATA_LEN/2 -1 downto 0);
						d_num <= "01";
					elsif d_num = "01" then
						d_out(DATA_LEN-1 downto DATA_LEN/2) <= data(DATA_LEN-1 downto DATA_LEN/2);
						en_sig <= '1';
						comp_rd <= '1'; --test	つけたし
						d_num <= "10";
					else
						if recieve = '1' then
							en_sig <= '0';
--							comp_rd <= '1'; 
							d_num <= "00";
						end if;
					end if;
				else
					comp_rd <= '0';
				end if;
			end if;
		end process;


end data_read;

--entity DDS_data is
--	port( clk : in std_logic;
--			rst : in std_logic;
--			msr_fin : in std_logic;
--			
--			d_fin : in std_logic; --デコードが終わったかどうかみる
--			d_type : in std_logic_vector(3 downto 0); --どのタイプのでーたが来るのかを確認
--			rd_comp : out std_logic; --データの読み取りが終わったかどうか見る
--			data : in std_logic_vector(39 downto 0);
--			
--			wr_en_a : out std_logic; --fifoのWR_EN
--			full_a : in std_logic; --fifoのFULL
--			data_out : out std_logic_vector(39 downto 0);
--			first_data : out std_logic_vector(39 downto 0); --DDS最初のデータ
--			data_end : out std_logic);
--end DDS_data;
--
--architecture data_read of DDS_data is
--
--	signal counter : std_logic_vector(15 downto 0):= (others => '0');
--	signal count_end : std_logic_vector(15 downto 0):= X"FFFF";
--	
--	signal d_end : std_logic:='0'; --data_end
--	signal d_num : std_logic_vector(1 downto 0):= "00";  
--	signal d_out : std_logic_vector(39 downto 0); --data_out
--	signal first_d : std_logic_vector(39 downto 0); --first?data
--	
--	signal tr_pend_a : std_logic:= '0'; --wr_en_a
--	signal comp_rd : std_logic:= '0'; --rd_comp
--
--begin
--
--	rd_comp <= comp_rd;
--	wr_en_a <= tr_pend_a;
--	data_out <= d_out;
--	first_data <= first_d;
--	data_end <= d_end;
--
--	process(clk,rst,msr_fin,d_fin,full_a)
--		begin
--			if rst = '1' or msr_fin = '1' then
--				counter <= (others => '0');
--				count_end <= X"FFFF";
--				d_end <= '0';
--				d_num <= "00";
--				d_out <= (others => '0');
--				first_d <= (others => '0');
--				tr_pend_a <= '0';
--				comp_rd <= '0';
--			elsif clk' event and clk = '1' then
--				if counter = X"0000" then
--					if d_fin = '1' then 
--						if comp_rd = '0' then
--							count_end <= data(15 downto 0);
--							comp_rd <= '1';
--						end if;
--					else
--						counter <= counter +1;
--						if comp_rd = '1' then
--							comp_rd <= '0';
--						end if;
--					end if;
--				elsif counter = count_end then
--					d_end <= '1';
--				else
--					if d_fin = '1' and comp_rd = '0' then
--						case d_type is
--							when dds_A =>
--								if d_num = "00" then
--									d_out(19 downto 0) <= data(19 downto 0);
--									d_num <= "01";
--								elsif d_num = "01" then
--									d_out(39 downto 20) <= data(39 downto 20);
--									d_num <= "10";
--								else
----									if counter = count_end then
----										if full_a = '0' then
----											if tr_pend_a <= '0' then 
----												tr_pend_a <= '1';
----											else
----												tr_pend_a <= '0';
----											end if;
----											d_end <= '1';
----											comp_rd <= '1';
----											d_num <= "00";
----										else
----											tr_pend_a <= '0';
----										end if;
--									if counter = X"0001" then --一つ目のデータだけはFIFOを介さず直接DDSコントローラに送る
--										first_d <= d_out;
--										comp_rd <= '1';
--										d_num <= "00";
--										counter <= counter +1;
--									else
--										if full_a = '0' then
----											if tr_pend_a <= '0' then 
--												tr_pend_a <= '1';
----											else
----												tr_pend_a <= '0';
----											end if;
--											comp_rd <= '1';
--											d_num <= "00";
--											counter <= counter +1;
--										else
--											tr_pend_a <= '0';
--										end if;
--									end if;
--								end if;
--								
--							when others =>
--								comp_rd <= '1';
--						end case;
--					elsif d_fin = '0' and comp_rd = '1' then
--						comp_rd <= '0';
--						tr_pend_a <= '0';
--					end if;
--				end if;
--			end if;
--		end process;
--
--
--end data_read;

