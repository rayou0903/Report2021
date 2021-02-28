----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:57:38 06/16/2020 
-- Design Name: 
-- Module Name:    DDS_data_drive - Behavioral 
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

---
--component DDS_data_drive is
--    Port ( clk : in  STD_LOGIC;
--           rst : in  STD_LOGIC;
--           data_in : in  STD_LOGIC_VECTOR (39 downto 0);
--           enable : in  STD_LOGIC;
--           recieve : out  STD_LOGIC;
--           data_out_1 : out  STD_LOGIC_VECTOR (39 downto 0);
--           data_out_2 : out  STD_LOGIC_VECTOR (39 downto 0);
--           dds1_data : in  STD_LOGIC_VECTOR (7 downto 0);
--           dds2_data : in  STD_LOGIC_VECTOR (7 downto 0);
--				 req_dds_1	:	out	std_logic;
--				 req_dds_2	:	out	std_logic;
--			 	 enable_1	:	in	std_logic;
--				 enable_2	:	in	std_logic);
--end component;
--DDS_data_drive : data_save
--    Port map 
--				( clk => ,
--           rst => ,
--           data_in => ,
--           enable => ,
--           recieve => ,
--           data_out_1 => ,
--           data_out_2 => ,
--           dds1_data => ,
--           dds2_data => ,
--				 req_dds_1	=> ,
--				 req_dds_2	=> ,
--			 	 enable_1	=> ,
--				 enable_2	=> );
---

entity DDS_data_drive is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR (39 downto 0);
           enable : in  STD_LOGIC;
           recieve : out  STD_LOGIC;
           data_out_1 : out  STD_LOGIC_VECTOR (39 downto 0);
           data_out_2 : out  STD_LOGIC_VECTOR (39 downto 0);
           dds1_data : in  STD_LOGIC_VECTOR (7 downto 0);
           dds2_data : in  STD_LOGIC_VECTOR (7 downto 0);
			  req_dds_1	:	out	std_logic;
			  req_dds_2	:	out	std_logic;
			  enable_1	:	in	std_logic;
			  enable_2	:	in	std_logic
			  );
end DDS_data_drive;

architecture data_save of DDS_data_drive is
	signal rec	:	std_logic;	--recieveに対応
	signal req_1	:	std_logic;
	signal req_2	:	std_logic;
	signal d_out_1	:	std_logic_vector(39 downto 0); --data_out1に対応
	signal d_out_2	:	std_logic_vector(39 downto 0); --data_out2に対応
	signal d_num	:	std_logic;	--dataを20ビットずつ読み取るための変数
	signal counter	:	std_logic_vector(3 downto 0);	--data数管理用カウンター
	signal d_drive_11	:	std_logic_vector(39 downto 0);	--dataを保存する
	signal d_drive_12	:	std_logic_vector(39 downto 0);
	signal d_drive_13	:	std_logic_vector(39 downto 0);
	signal d_drive_14	:	std_logic_vector(39 downto 0);
	signal d_drive_15	:	std_logic_vector(39 downto 0);
	signal d_drive_16	:	std_logic_vector(39 downto 0);
	signal d_drive_17	:	std_logic_vector(39 downto 0);
	signal d_drive_18	:	std_logic_vector(39 downto 0);
	signal d_drive_21	:	std_logic_vector(39 downto 0);	--dataを保存する
	signal d_drive_22	:	std_logic_vector(39 downto 0);
	signal d_drive_23	:	std_logic_vector(39 downto 0);
	signal d_drive_24	:	std_logic_vector(39 downto 0);
	signal d_drive_25	:	std_logic_vector(39 downto 0);
	signal d_drive_26	:	std_logic_vector(39 downto 0);
	signal d_drive_27	:	std_logic_vector(39 downto 0);
	signal d_drive_28	:	std_logic_vector(39 downto 0);
	
begin

	recieve <= rec;
	req_dds_1 <= req_1;
	req_dds_2 <= req_2;
	data_out_1 <= d_out_1;
	data_out_2 <= d_out_2;
	
process(clk,rst,enable)
begin

	if rst = '1' then
		rec <= '0';
		d_num	<= '0';
		counter <= (others => '0');
--		req_1 <= '0';
--		req_2 <= '0';
	elsif clk' event and clk = '1' then
		if rec = '0' then
			if enable = '1' then
				if counter = X"0" then
					if d_num = '0' then
						d_drive_11(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_11(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"1" then
					if d_num = '0' then
						d_drive_12(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_12(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"2" then
					if d_num = '0' then
						d_drive_13(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_13(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"3" then
					if d_num = '0' then
						d_drive_14(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_14(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"4" then
					if d_num = '0' then
						d_drive_15(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_15(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"5" then
					if d_num = '0' then
						d_drive_16(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_16(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"6" then
					if d_num = '0' then
						d_drive_17(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_17(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"7" then
					if d_num = '0' then
						d_drive_18(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_18(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"8" then
					if d_num = '0' then
						d_drive_21(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_21(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"9" then
					if d_num = '0' then
						d_drive_22(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_22(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"A" then
					if d_num = '0' then
						d_drive_23(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_23(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"B" then
					if d_num = '0' then
						d_drive_24(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_24(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"C" then
					if d_num = '0' then
						d_drive_25(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_25(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"D" then
					if d_num = '0' then
						d_drive_26(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_26(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"E" then
					if d_num = '0' then
						d_drive_27(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_27(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= counter +1;
					end if;
				elsif counter = X"F" then
					if d_num = '0' then
						d_drive_28(19 downto 0) <= data_in(19 downto 0);
						d_num <= '1';
					else
						d_drive_28(39 downto 20) <= data_in(39 downto 20);
						d_num <= '0';
						rec <= '1';
						counter <= (others => '0');
					end if;
				end if;
			end if;
		else
			if enable = '0' then
				rec <= '0';
			end if;
		end if;
	end if;

end process;

process(dds1_data,enable_1)
begin
	
	if enable_1 = '1' then
		req_1 <= '0';
	end if;
--	req_1 <= '1';
	
	if dds1_data = X"80" then
		d_out_1 <= d_drive_18;
		req_1 <= '1';
	elsif dds1_data = X"40" then
		d_out_1 <= d_drive_17;
		req_1 <= '1';
	elsif dds1_data = X"20" then
		d_out_1 <= d_drive_16;
		req_1 <= '1';
	elsif dds1_data = X"10" then
		d_out_1 <= d_drive_15;
		req_1 <= '1';
	elsif dds1_data = X"08" then
		d_out_1 <= d_drive_14;
		req_1 <= '1';
	elsif dds1_data = X"04" then
		d_out_1 <= d_drive_13;
		req_1 <= '1';
	elsif dds1_data = X"02" then
		d_out_1 <= d_drive_12;
		req_1 <= '1';
	elsif dds1_data = X"01" then
		d_out_1 <= d_drive_11;
		req_1 <= '1';	
	end if;
end process;

process(dds2_data,enable_2)
begin

	if enable_2 = '1' then
		req_2 <= '0';
	end if;

--	req_2 <= '1';
	
	if dds2_data = X"80" then
		d_out_2 <= d_drive_28;
		req_2 <= '1';
	elsif dds2_data = X"40" then
		d_out_2 <= d_drive_27;
		req_2 <= '1';
	elsif dds2_data = X"20" then
		d_out_2 <= d_drive_26;
		req_2 <= '1';
	elsif dds2_data = X"10" then
		d_out_2 <= d_drive_25;
		req_2 <= '1';
	elsif dds2_data = X"08" then
		d_out_2 <= d_drive_24;
		req_2 <= '1';
	elsif dds2_data = X"04" then
		d_out_2 <= d_drive_23;
		req_2 <= '1';
	elsif dds2_data = X"02" then
		d_out_2 <= d_drive_22;
		req_2 <= '1';
	elsif dds2_data = X"01" then
		d_out_2 <= d_drive_21;
		req_2 <= '1';		
	end if;
end process;
	

end data_save;

