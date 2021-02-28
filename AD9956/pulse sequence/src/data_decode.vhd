
 ----------------------------------------------------------------------------------
 -- Company: 
 -- Engineer: 
 -- 
 -- Create Date:    18:39:39 10/21/2019 
 -- Design Name: 
 -- Module Name:    data_decode - Behavioral 
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


 use IEEE.NUMERIC_STD.ALL;

 library work;
 use work.data_types.all;

 -- Uncomment the following library declaration if instantiating
 -- any Xilinx primitives in this code.
 --library UNISIM;
 --use UNISIM.VComponents.all;

 --component data_decode is
 --	port( clk : in std_logic;
 --			rst : in std_logic;
 --			
 --			data64 : in std_logic_vector(63 downto 0);
 --			fetch_fin : in std_logic;
 --			decode_en : out std_logic;
 --			
 --			cnt_en : out std_logic;
 --			
 --			de_data : out std_logic_vector(63 downto 0));
 --end component;
 --
 --decode : data_decode is
 --	port map( clk => ,
 --				 rst => ,
 --			
 --				 data64 => ,
 --				 fetch_fin => ,
 --				 decode_en => ,
 --			
 --				 cnt_en => ,
 --			
 --				 de_data => );


 entity data_decode is
 	port( clk : in std_logic;
 			rst : in std_logic;
 			msr_fin : in std_logic;
			
 			data64 : in std_logic_vector(63 downto 0);
 			fetch_fin : in std_logic;
 			decode_en : out std_logic;
			
 			decode_fin_m : out std_logic; --master_couterへデコードが終わったことを知らせる
 			decode_fin_d : out std_logic; --DDS_dataへデコードが終わったことを知らせる
 			data_type : out std_logic_vector(3 downto 0); --master_counterへデータがどこのデータだか伝える
 			read_fin : in std_logic; --master_counterがデータの読み込みを終了したことを知らせる
 			decode_wait : in std_logic; --master_counterは現在データが満タンです
 			count_end : out std_logic; --master_counterの動作を終了
			
 			--data_change : in std_logic; --counterのデータかddsのデータか判別する
			
 			d_data_out : out std_logic_vector(63 downto 0); --dds用のデータ
 			c_data_out : out std_logic_vector(63 downto 0)); --マスターカウンタ用のデータ
 end data_decode;

 architecture decode of data_decode is

 	type state_t is (idle, count, dds, cycle_end); --状態名（アイドル、カウンター、処理サイクル終了）
 	constant	DDS_patt:std_logic_vector(3 downto 0):="1111";	--DDSのデータのパターン数（外部入力にしても可）
 
 	type reg is record
 		data : std_logic_vector(63 downto 0);
 		d_type : std_logic_vector(3 downto 0); --data_type
 		d_en : std_logic; --decode_enable
 		d_fin_m : std_logic; --decode_fin(Master_counter)
 		d_fin_d : std_logic; --decode_fin(DDS_data)
 		m_fin : std_logic; --count_endを変化させるために必要な判別用
 		c_end : std_logic; --count_end
 		state : state_t;
 		sequence : std_logic_vector(3 downto 0);
 		d_num : std_logic_vector(1 downto 0); --データの受け取りを小分けにする
 		loading : std_logic; --master_counterがデータを読み込み終わるまで待機
 		change_counter : std_logic_vector(3 downto 0); --data_changeしてから何回目か
 		patt_counter	:	std_logic_vector(3 downto 0); --DDS_dataのパターンをカウントしていく
 	end record;

 	signal p : reg;
 	signal n : reg;
	

 	signal fresh : std_logic; --p.sequenceの値をfirstに最初はなるようにするためのもの
	

 begin

 	decode_en <= p.d_en;

 	c_data_out <= p.data(63 downto 0);
 	d_data_out <= p.data(63 downto 0);
 	decode_fin_m <= p.d_fin_m;
 	decode_fin_d <= p.d_fin_d;
 	data_type <= p.d_type;
 	count_end <= p.m_fin;

 	process(n,p,data64,fetch_fin,read_fin,decode_wait,msr_fin)
 		begin
 			n <= p;
			
 			if msr_fin = '1' then
 				if p.m_fin = '0' then
 					n.m_fin <= '1';
 				end if;
 			end if;
			
 			if fetch_fin = '1'  --フェッチが終了していることがデコード開始の条件
 			and decode_wait = '0'  --master_counterがおなか一杯の時は休憩
 			and p.d_en = '0'  --フェッチとのデータのやり取りがぐちゃぐちゃにならないようにするため
 			and p.loading = '0' then
-- 				case p.sequence is --読み込んだ順で処理
-- 					when first => 
 						if p.d_num = "00" then
 							n.data(15 downto 0) <= data64(15 downto 0);
 							n.d_num <= "01";
 						elsif p.d_num = "01" then
 							n.data(31 downto 16) <= data64(31 downto 16);
 							n.d_num <= "10";
 						elsif p.d_num = "10" then
 							n.data(47 downto 32) <= data64(47 downto 32);
 							n.d_num <= "11";
 						else
--							if p.m_fin = '1' then
--								n.data(62 downto 48) <= data64(62 downto 48);
--								n.data(63) <= '1';
--								n.m_fin <= '0';
--							else
								n.data(63 downto 48) <= data64(63 downto 48);
--							end if;
 							n.d_num <= "00";
							n.loading <= '1';
 							if p.patt_counter = DDS_patt then
 								if p.change_counter = X"0" then
 									n.d_type <= first;
 									n.change_counter <= p.change_counter +1;
 								elsif p.change_counter = X"1" then
 									n.d_type <= second;
 									n.change_counter <= p.change_counter +1;
 								elsif p.change_counter = X"2" then
 									n.d_type <= third;
 									n.change_counter <= p.change_counter +1;
 								elsif p.change_counter = X"3" then
 									n.d_type <= fourth;
 									n.change_counter <= p.change_counter +1;
 								elsif p.change_counter = X"4" then
 									n.d_type <= fifth;
 									n.change_counter <= p.change_counter +1;
 								elsif p.change_counter = X"5" then
 									n.d_type <= sixth;
 									n.change_counter <= p.change_counter +1;
 								else
 									n.d_type <= seventh;
 									n.change_counter <= X"0";
 								end if;
 								n.state <= count;
 							else
 								--n.d_type <= data64(43 downto 40);
 								n.state <= dds;
 								n.patt_counter <= p.patt_counter +1;
 							end if;
 							--n.sequence <= second;
 						end if;
						
 					
 			end if;
			
 			case p.state is
 				when idle =>
					n.d_en <= '0';
					
 				when count =>
 					if read_fin = '0' then --master_counterがデータを獲得するまで待機
 						if p.d_fin_m = '0' then --read_finがクロックと無関係なタイミングで入力されるため
 							n.d_fin_m <= '1'; --master_counterがデータの読み込みを開始
 						end if;
 					else
 						if p.d_fin_m = '1' then
 							n.d_fin_m <= '0';
 							n.loading <= '0';
 							n.d_en <= '1';
 							n.state <= idle;
 						end if;
 					end if;
				
 				when dds =>
 					if read_fin = '0' then --dds_dataがデータを獲得するまで待機
 						if p.d_fin_d = '0' then --read_finがクロックと無関係なタイミングで入力されるため
 							n.d_fin_d <= '1'; --dds_dataがデータの読み込みを開始
 						end if;
 					else
 						if p.d_fin_d = '1' then
 							n.d_fin_d <= '0';
 							n.loading <= '0';
 							n.d_en <= '1';
 							n.state <= idle;
 						end if;
 					end if;
					
 				when others =>
 					n.state <= idle;
 			end case;
		
 		end process;

 	process(clk,rst)
 		begin
 			if rst = '1' then
 				p.data <= (others => '0');
 				p.d_type <= (others => '0');
 				p.d_en <= '0';
 				p.d_fin_d <= '0';
 				p.d_fin_m <= '0';
 				p.m_fin <= '0';
 				p.c_end <= '0';
 				p.state <= idle;
 				p.sequence <= first;
 				p.d_num <= "00";
 				p.loading <= '0';
 				p.change_counter <= (others => '0');
 				p.patt_counter <= (others => '0');
 				fresh <= '0';
 			elsif clk' event and clk = '1' then
 				p <= n;
-- 				if fresh = '0' then --データの順番を初期化
-- 					p.sequence <= first;
-- 					fresh <= '1';
-- 				end if;
 			end if;
 		end process;

 end decode;

