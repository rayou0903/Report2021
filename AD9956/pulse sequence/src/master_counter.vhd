 ----------------------------------------------------------------------------------
 -- Company: 
 -- Engineer: 
 -- 
 -- Create Date:    18:33:32 12/05/2019 
 -- Design Name: 
 -- Module Name:    master_counter - count_time 
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

 library work;
 use work.data_types.all;

 -- Uncomment the following library declaration if instantiating
 -- any Xilinx primitives in this code.
 --library UNISIM;
 --use UNISIM.VComponents.all;

 --kopipeyou
 --component master_counter is
 --	port( clk : in std_logic;
 --			rst : in std_logic;
 --
 --			d_fin : in std_logic; 
 --			d_type : in std_logic_vector(3 downto 0); 
 --			rd_comp : out std_logic;
 --			data_full : out std_logic; 
 --			data : in std_logic_vector(31 downto 0); 
 --
 --			output_rf : out std_logic;
 --			output_dds : out std_logic;
 --			output_ad : out std_logic);
 --end component;
 --
 --count_time : master_counter 
 --	port map( clk => ,
 --				 rst => ,
 --
 --				 d_fin => , 
 --				 d_type => ,
 --				 rd_comp => ,
 --				 data_full => ,
 --				 data => , 
 --
 --				 output_rf => ,
 --				 output_dds => ,
 --				 output_ad => );


 entity master_counter is
 	port( clk : in std_logic;
 			rst : in std_logic;
 			msr_fin : in std_logic; --計測終了したらこの回路の動作を停止
 			msr_allcomp : out std_logic; --完全な計測終了を伝える
			
 			d_fin : in std_logic; --デコードが終わったかどうかみる
 			d_type : in std_logic_vector(3 downto 0); --どのタイプのでーたが来るのかを確認
 			rd_comp : out std_logic; --データの読み取りが終わったかどうか見る
 			data_full : out std_logic; --データが満タンなのを知らせる
 			data : in std_logic_vector(63 downto 0); 
			
 			output_rf : out std_logic_vector(2 downto 0); --出力
 			output_dds_1 : out std_logic_vector(7 downto 0);
 			output_dds_2 : out std_logic_vector(7 downto 0);
 			dds_start : out std_logic; --DDS開始
 			dds_fin : out std_logic; --DDS終了
 			output_ad : out std_logic_vector(2 downto 0));
 end master_counter;

 architecture count_time of master_counter is

 	type reg is record
 		t_1 : std_logic_vector(63 downto 0);		--カウント上限
 		t_2 : std_logic_vector(63 downto 0);		--カウント上限
 		t_3 : std_logic_vector(63 downto 0);		--カウント上限
 		t_4 : std_logic_vector(63 downto 0);		--カウント上限
 		t_5 : std_logic_vector(63 downto 0);		--カウント上限
 		t_6 : std_logic_vector(63 downto 0);		--カウント上限
 		t_7 : std_logic_vector(63 downto 0);		--カウント上限
 		t_0 : std_logic_vector(63 downto 0);		--カウント上限
 	end record;	
	
 	signal p : reg;
 	signal n : reg;
	
 	signal count_end : std_logic; --カウンター終了時にhigh
	
 	signal counter : std_logic_vector(31 downto 0):= (others => '0'); 		--カウンター

 	signal preset : std_logic:= '0'; --プリセットしているかどうかチェック
 	signal dst_1 : std_logic:= '0'; --データセットがどの程度進行しているか
 	signal dst_2 : std_logic:= '0'; 
 	signal dst_3 : std_logic:= '0'; 
 	signal dst_4 : std_logic:= '0'; 
 	signal dst_5 : std_logic:= '0';
 	signal dst_6 : std_logic:= '0'; 
 	signal dst_7 : std_logic:= '0'; 
 	signal dst_0 : std_logic:= '0'; 
 	signal full : std_logic:= '0'; --データが満タン状態を知らせる
 	signal comp_rd : std_logic:= '0'; --rd_compに対応
 	signal m_fin : std_logic; --msr_finの変化によってカウンターの終了を制御する
	
 	signal rf_out : std_logic_vector(2 downto 0);	--RFパルス用
 	signal dds_set_1 : std_logic_vector(7 downto 0); --ddsの周波数を変える
 	signal dds_set_2 : std_logic_vector(7 downto 0); --ddsの周波数を変える
 	signal ad_out : std_logic_vector(2 downto 0); --AD用
		
 begin

 	rd_comp <= comp_rd;
 	data_full <= full;
 	msr_allcomp <= count_end;
	
 	output_rf <= rf_out;
 	output_dds_1 <= dds_set_1;
 	output_dds_2 <= dds_set_2;
 	dds_start <= preset;
 	dds_fin <= count_end;
 	output_ad <= ad_out;
		
 	process(clk,rst,data,d_fin,d_type,msr_fin,count_end)
 	begin
	
 		if rst = '1' then
 			counter <= (others => '0');
 			m_fin <= '0';
 			count_end <= '0';
 			preset <= '0';
 			full <= '0';
 			comp_rd <= '0';
 			rf_out <= (others => '0');
 			dds_set_1 <= (others => '0');
 			dds_set_2 <= (others => '0');
 			ad_out <= (others => '0');
 			p.t_1 <= (others => '0'); p.t_2 <= (others => '0'); p.t_3 <= (others => '0'); p.t_4 <= (others => '0'); 
 			p.t_5 <= (others => '0'); p.t_6 <= (others => '0'); p.t_7 <= (others => '0'); 
 			n.t_1 <= (others => '0'); n.t_2 <= (others => '0'); n.t_3 <= (others => '0'); n.t_4 <= (others => '0'); 
 			n.t_5 <= (others => '0'); n.t_6 <= (others => '0'); n.t_7 <= (others => '0'); 
 			dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
 		elsif clk' event and clk = '1' then
 			if preset = '1' then --事前のデータセットが終わらなければカウントは始まらない
 				if counter = p.t_1(31 downto 0) then	--データによって指定された時刻になったらイベントを起こす
 					rf_out <= p.t_1(34 downto 32);
 					dds_set_1 <= p.t_1(45 downto 38);
 					dds_set_2 <= p.t_1(53 downto 46);
					ad_out <= p.t_1(37 downto 35);
					dst_1 <= '0';
					counter <= counter +1;
					full <= '0';
					if p.t_1(63 downto 62) = "10" then
						counter <= (others => '0');
					elsif p.t_1(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					end if;
 				elsif counter = p.t_2(31 downto 0) then		
 					rf_out <= p.t_2(34 downto 32);
 					dds_set_1 <= p.t_2(45 downto 38);
 					dds_set_2 <= p.t_2(53 downto 46);
					ad_out <= p.t_2(37 downto 35);
					dst_2 <= '0';
					counter <= counter +1;
					full <= '0';
					if p.t_2(63 downto 62) = "10" then
						counter <= (others => '0');
					elsif p.t_2(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					end if;
 				elsif counter = p.t_3(31 downto 0) then		
 					 rf_out <= p.t_3(34 downto 32);
 					 dds_set_1 <= p.t_3(45 downto 38);
					 dds_set_2 <= p.t_3(53 downto 46);
					 ad_out <= p.t_3(37 downto 35);
					 dst_3 <= '0';
					 counter <= counter +1;
					 full <= '0';
					 if p.t_3(63 downto 62) = "10" then
						counter <= (others => '0');
					 elsif p.t_3(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					 end if;
 				elsif counter = p.t_4(31 downto 0) then		
 					 rf_out <= p.t_4(34 downto 32);
 					 dds_set_1 <= p.t_4(45 downto 38);
 					 dds_set_2 <= p.t_4(53 downto 46);
					 ad_out <= p.t_4(37 downto 35);
					 dst_4 <= '0';
					 counter <= counter +1;
					 full <= '0';
					 if p.t_4(63 downto 62) = "10" then
						counter <= (others => '0');
					 elsif p.t_4(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					 end if;
 				elsif counter = p.t_5(31 downto 0) then		
 					 rf_out <= p.t_5(34 downto 32);
 					 dds_set_1 <= p.t_5(45 downto 38);
 					 dds_set_2 <= p.t_5(53 downto 46);
					 ad_out <= p.t_5(37 downto 35);
					 dst_5 <= '0';
					 counter <= counter +1;
					 full <= '0';
					 if p.t_5(63 downto 62) = "10" then
						counter <= (others => '0');
					 elsif p.t_5(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					 end if;
 				elsif counter = p.t_6(31 downto 0) then	
 					 rf_out <= p.t_6(34 downto 32);
 				 	 dds_set_1 <= p.t_6(45 downto 38);
 					 dds_set_2 <= p.t_6(53 downto 46);
					 ad_out <= p.t_6(37 downto 35);
					 dst_6 <= '0';
					 counter <= counter +1;
					 full <= '0';
					 if p.t_6(63 downto 62) = "10" then
						counter <= (others => '0');
					 elsif p.t_6(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					 end if;
 				elsif counter = p.t_7(31 downto 0) then
 					rf_out <= p.t_7(34 downto 32);
 					dds_set_1 <= p.t_7(45 downto 38);
 					dds_set_2 <= p.t_7(53 downto 46);
 					ad_out <= p.t_7(37 downto 35);
					dst_7 <= '0';
 					counter <= counter +1;
					full <= '0';
					if p.t_7(63 downto 62) = "10" then
						counter <= (others => '0');
					elsif p.t_7(63 downto 62) = "11" then
						counter <= (others => '0');
						preset <= '0';
						dst_1 <= '0';	dst_2 <= '0';	dst_3 <= '0';	dst_4 <= '0';	dst_5 <= '0';	dst_6 <= '0';	dst_7 <= '0';
					end if;							
 				else	--イベントが起きる時刻以外では、釈然とカウントを続ける
 					counter <= counter +1;
 				end if;
 				if d_fin = '1' then --最初以降のデータセット
					if dst_1 = '0' then
						p.t_1 <= data;
						comp_rd <= '1';
						dst_1 <= '1';
						full <= '1';
					elsif dst_2 = '0' then
						p.t_2 <= data;
						comp_rd <= '1';
						dst_2 <= '1';
						full <= '1';
					elsif dst_3 = '0' then
						p.t_3 <= data;
						comp_rd <= '1';
						dst_3 <= '1';
						full <= '1';
					elsif dst_4 = '0' then
						p.t_4 <= data;
						comp_rd <= '1';
						dst_4 <= '1';
						full <= '1';
					elsif dst_5 = '0' then
						p.t_5 <= data;
						comp_rd <= '1';
						dst_5 <= '1';
						full <= '1';
					elsif dst_6 = '0' then
						p.t_6 <= data;
						comp_rd <= '1';
						dst_6 <= '1';
						full <= '1';
					elsif dst_7 = '0' then
						p.t_7 <= data;
						comp_rd <= '1';
						dst_7 <= '1';
						full <= '1';
					end if;
 				else
 					comp_rd <= '0';
-- 					if dst_7 = '1' and dst_1 = '1' and dst_2 = '1' and dst_3 = '1' and dst_4 = '1' and dst_5 = '1' and dst_6 = '1' then --nのほうまでデータが満タンになったらdecodeを一旦停止
-- 						full <= '1';
-- 					end if;
 				end if;
 			elsif preset = '0' then  --最初のデータセット
 				if d_fin = '1' then --decodeからのデータがavailableならデータをセットする
 					case d_type is
 						when first =>		
 							p.t_1 <= data;	
 							comp_rd <= '1';	
 							dst_1 <= '1';
						
 						when second =>		
 							p.t_2 <= data;	
 							comp_rd <= '1';	
 							dst_2 <= '1';
							
 						when third =>		
 							p.t_3 <= data;	
 							comp_rd <= '1';	
 							dst_3 <= '1';
						
 						when fourth =>		
 							p.t_4 <= data;	
 							comp_rd <= '1';	
 							dst_4 <= '1';
							
 						when fifth =>		
 							p.t_5 <= data;
 							comp_rd <= '1';
 							dst_5 <= '1';
						
 						when sixth =>		
 							p.t_6 <= data;	
 							comp_rd <= '1';	
 							dst_6 <= '1';
							
 						when seventh =>	
 							p.t_7 <= data;	
 							comp_rd <= '1';	
 							dst_7 <= '1';
							
 						when others =>		
 							comp_rd <= '1';
 					end case;
 				else
 					comp_rd <= '0';
 					if dst_7 = '1' and dst_1 = '1' and dst_2 = '1' and dst_3 = '1' and dst_4 = '1' and dst_5 = '1' and dst_6 = '1' then --パルスシーケンスのデータがある程度集まればカウント開始
 						preset <= '1';
						full <= '1';
 					end if;
 				end if;
--			elsif preset = '0' and count_end = '1' then
--				counter <= (others => '0');
--				if d_fin = '1' then
--					count_end <= '0';
--				end if;
 			end if;
 		end if;
			
 	end process;

 end count_time;





