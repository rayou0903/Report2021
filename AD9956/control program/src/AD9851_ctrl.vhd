------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    15:20:20 12/23/2019 
---- Design Name: 
---- Module Name:    AD9851_ctrl - DDS_ctrl 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity AD9851_ctrl is
	port(
		clk 		: 	in		std_logic;
		clk_2		:	in		std_logic;
		rst		:	in		std_logic;
		data40 	: 	in		std_logic_vector(39 downto 0);
		data	 	:	out	std_logic;
		fqud	 	:	out	std_logic;
		reset	 	:	out	std_logic;
		w_clk	 	:	out	std_logic;
		req_dds 	: 	in		std_logic;
		recieve	:	out	std_logic
	);
end AD9851_ctrl;

architecture Behavioral of AD9851_ctrl is

	--signal data_set	: std_logic:= '0';
	--signal fqud_set	: std_logic:= '0';
	--signal rst_set		: std_logic:= '0';
	--signal w_clk_set	: std_logic:= '0';
	signal state_n		: std_logic_vector(6 downto 0):=(others => '0');
	signal state_p		: std_logic_vector(6 downto 0):=(others => '0');
	--signal c_w			: std_logic:= '0';
	--signal clk5		: std_logic:= '0';
	signal counter3	: std_logic_vector(1 downto 0):=(others => '0');
	signal data32		:	std_logic_vector(39 downto 0);
	signal not_clk		:	std_logic;
	
	signal clk_count	:	std_logic_vector(11 downto 0):=X"000";
	constant M50 : std_logic_vector(11 downto 0):=X"001";
	constant M1 : std_logic_vector(11 downto 0):=X"064";
	constant k500 : std_logic_vector(11 downto 0):=X"1F4";
	
	type reg is record
      rst_pend	   : std_logic;
		dds_pend		:	std_logic;
		data_set		: std_logic;
		fqud_set		: std_logic;
		w_clk_set	: std_logic;
		rst_set		: std_logic;
		c_w			:	std_logic;
		rec			:	std_logic;
   end record;
	
	signal p : reg;
	signal n : reg;
	
	
begin
	--clk5	<= clk_25_o;
	
	--ad9851出力
	data		<= p.data_set;
	fqud		<= p.fqud_set when p.c_w = '1' else
					'0'  when p.c_w = '0';
	reset		<= p.rst_set when p.c_w = '1' else
					'0'  when p.c_w = '0';
	w_clk		<=	p.w_clk_set when p.c_w = '1' else
					clk after 5ns when p.c_w = '0';

	not_clk <= not clk;
					
--	ODDR2_inst : ODDR2
--   generic map(
--      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
--      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
--      SRTYPE => "SYNC") -- Specifies "SYNC" or "ASYNC" set/reset
--   port map (
--      Q => w_clk, -- 1-bit output data
--      C0 => clk, -- 1-bit clock input
--      C1 => not_clk, -- 1-bit clock input
--      CE => '1',  -- 1-bit clock enable input
--      D0 => '1',   -- 1-bit data input (associated with C0)
--      D1 => '0',   -- 1-bit data input (associated with C1)
--      R => '0',    -- 1-bit reset input
--      S => '0'     -- 1-bit set input
--   );
--	
	
	recieve <= p.rec;
	
	process(state_p,data32,req_dds,state_n,data40,rst,req_dds,rst,p) begin

		state_n <= state_p;
		n <= p;
		
		if req_dds = '1' then
			if p.rst_pend = '0' and p.dds_pend = '0' then
				n.dds_pend <= '1';
				data32	<= data40;
			end if;
		else
			n.rec <= '0';
		end if;
		
		
		case state_p is
			--reset
			when "0000001" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '1';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0110001";
				n.dds_pend <= '0';
				n.rst_pend <= '0';
			when "0110001" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '1';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0000010";
			when "0000010" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0110010";
			when "0110010" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0000011";
			when "0000011" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '1';
				n.c_w			<= '1';
				state_n <= "0110011";
			when "0110011" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '1';
				n.c_w			<= '1';
				state_n <= "0000100";
			when "0000100" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0110100";
			when "0110100" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0000101";
			when "0000101" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '1';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0110101";
			when "0110101" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '1';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0000110";
			when "0000110" => 
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0110111";
			when "0110111" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0000000";
			--32bitdata
			when "0000111" =>
				n.data_set		<=	data32(0);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001000";
			when "0001000" =>
				n.data_set		<=	data32(1);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001001";
			when "0001001" =>
				n.data_set		<=	data32(2);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001010";
			when "0001010" =>
				n.data_set		<=	data32(3);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001011";
			when "0001011" =>
				n.data_set		<=	data32(4);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001100";
			when "0001100" =>
				n.data_set		<=	data32(5);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001101";
			when "0001101" =>
				n.data_set		<=	data32(6);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001110";
			when "0001110" =>
				n.data_set		<=	data32(7);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0001111";
			when "0001111" =>
				n.data_set		<=	data32(8);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010000";
			when "0010000" =>
				n.data_set		<=	data32(9);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010001";
			when "0010001" =>
				n.data_set		<=	data32(10);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010010";
			when "0010010" =>
				n.data_set		<=	data32(11);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010011";
			when "0010011" =>
				n.data_set		<=	data32(12);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010100";
			when "0010100" =>
				n.data_set		<=	data32(13);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010101";
			when "0010101" =>
				n.data_set		<=	data32(14);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010110";
			when "0010110" =>
				n.data_set		<=	data32(15);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0010111";
			when "0010111" =>
				n.data_set		<=	data32(16);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011000";
			when "0011000" =>
				n.data_set		<=	data32(17);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011001";
			when "0011001" =>
				n.data_set		<=	data32(18);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011010";
			when "0011010" =>
				n.data_set		<=	data32(19);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011011";
			when "0011011" =>
				n.data_set		<=	data32(20);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011100";
			when "0011100" =>
				n.data_set		<=	data32(21);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011101";
			when "0011101" =>
				n.data_set		<=	data32(22);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011110";
			when "0011110" =>
				n.data_set		<=	data32(23);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0011111";
			when "0011111" =>
				n.data_set		<=	data32(24);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100000";
			when "0100000" =>
				n.data_set		<=	data32(25);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100001";
			when "0100001" =>
				n.data_set		<=	data32(26);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100010";
			when "0100010" =>
				n.data_set		<=	data32(27);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100011";
			when "0100011" =>
				n.data_set		<=	data32(28);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100100";
			when "0100100" =>
				n.data_set		<=	data32(29);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100101";
			when "0100101" =>
				n.data_set		<=	data32(30);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100110";
			when "0100110" =>
				n.data_set		<=	data32(31);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0100111";
			--phase data8
			when "0100111" =>
				n.data_set		<=	data32(32);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101000";
			when "0101000" =>
				n.data_set		<=	data32(33);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101001";
			when "0101001" =>
				n.data_set		<=	data32(34);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101010";
			when "0101010" =>
				n.data_set		<=	data32(35);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101011";
			when "0101011" =>
				n.data_set		<=	data32(36);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101100";
			when "0101100" =>
				n.data_set		<=	data32(37);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101101";
			when "0101101" =>
				n.data_set		<= data32(38);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101110";
			when "0101110" =>
				n.data_set		<=	data32(39);
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '0';
				state_n <= "0101111";
			--end
			when "0101111" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0111111";
			when "0111111" =>
				n.data_set		<=	'0';
				n.fqud_set		<= '1';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				state_n <= "0000000";
				n.dds_pend <= '0';
			--when "0110000" =>
				--data_set		<=	'0';
				--fqud_set		<= '0';
				--rst_set		<= '0';
				--w_clk_set	<= '0';
				--c_w			<= '1';
				--state_n		<= "1110000";
			when others =>	
				n.data_set		<=	'0';
				n.fqud_set		<= '0';
				n.rst_set		<= '0';
				n.w_clk_set	<= '0';
				n.c_w			<= '1';
				if p.dds_pend = '1' then
					state_n <= "0000111";
					n.rec <= '1';
				else
					state_n <= (others => '0');
				end if;
		end case;
	end process;
	
	process(clk,rst) begin
		if rst = '1' then
				state_p <= "0000001";
				p.data_set		<=	'0';
				p.fqud_set		<= '0';
				p.rst_set		<= '0';
				p.w_clk_set	<= '0';
				p.c_w			<= '1';
				p.rec <= '0';
				clk_count <= (others => '0');
		elsif clk' event and clk = '0' then
			state_p <= state_n;
			p	<= n;
--			if clk_count = M50 then
--				state_p <= state_n;
--				p	<= n;
--				clk_count <= (others => '0');
--			else
--				clk_count <= clk_count +1;
--			end if;
		end if;
	end process;
				

end Behavioral;


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--
----component AD9851_ctrl is
----	port(
----		clk 		: 	in		std_logic;
----		rst		:	in		std_logic;
----		first_data 	: 	in		std_logic_vector(39 downto 0); 
----		data40 	: 	in		std_logic_vector(39 downto 0);
----		start		:	in		std_logic;	
----		data_change : 	in 	std_logic; 
----		data	 	:	out	std_logic;
----		fqud	 	:	out	std_logic;
----		reset	 	:	out	std_logic;
----		w_clk	 	:	out	std_logic;
----		msr_fin 	: 	in		std_logic); 
----end component;
----
----DDS : AD9851_ctrl 
----	port map( clk => ,
----				 rst	=> ,
----				 first_data => , 
----				 data40 	=> ,
----				 start	=> ,	
----				 data_change => , 
----				 data	=> ,
----				 fqud	 => ,
----				 reset	=> ,
----				 w_clk	=> ,
----				 msr_fin => ); 
--
--entity AD9851_ctrl is
--	port(
--		clk 		: 	in		std_logic;
--		rst		:	in		std_logic;
--		first_data 	: 	in		std_logic_vector(39 downto 0); --最初にセットするデータ
--		data40 	: 	in		std_logic_vector(39 downto 0);
--		start		:	in		std_logic;	--DDS駆動開始（data_acquireから終了信号を受ける）
--		data_change : 	in 	std_logic; --DDSのデータを変えるeye's
--		data	 	:	out	std_logic;
--		fqud	 	:	out	std_logic;
--		reset	 	:	out	std_logic;
--		w_clk	 	:	out	std_logic;
--		msr_fin 	: 	in		std_logic); --計測終了
--end AD9851_ctrl;
--
--architecture DDS of AD9851_ctrl is
--
--	--signal data_set	: std_logic:= '0';
--	--signal fqud_set	: std_logic:= '0';
--	--signal rst_set		: std_logic:= '0';
--	--signal w_clk_set	: std_logic:= '0';
--	signal state_n		: std_logic_vector(6 downto 0):=(others => '0');
--	signal state_p		: std_logic_vector(6 downto 0):=(others => '0');
--	--signal c_w			: std_logic:= '0';
--	--signal clk5		: std_logic:= '0';
--	signal counter3	: std_logic_vector(1 downto 0):=(others => '0');
--	signal data32		:	std_logic_vector(39 downto 0);
--	signal d_change	:	std_logic; --dataが変わったことに反応
--	
--	type reg is record
--      rst_pend	   : std_logic;
--		dds_pend		:	std_logic;
--		data_set		: std_logic;
--		fqud_set		: std_logic;
--		w_clk_set	: std_logic;
--		rst_set		: std_logic;
--		c_w			:	std_logic;
--		preset 		:	std_logic; --最初のデータセットかどうか判別するため
--   end record;
--	
--	signal p : reg;
--	signal n : reg;
--	
--	
--begin
--	--clk5	<= clk_25_o;
--	
--	--ad9851出力
--	data		<= p.data_set;
--	fqud		<= p.fqud_set when p.c_w = '1' else
--					'0'  when p.c_w = '0';
--	reset		<= p.rst_set when p.c_w = '1' else
--					'0'  when p.c_w = '0';
--	w_clk		<=	p.w_clk_set when p.c_w = '1' else
--					clk after 5ns when p.c_w = '0';
--	
--	
--	process(state_p,data32,state_n,data40,rst,rst,p,start,msr_fin,data_change) begin
--
--		state_n <= state_p;
--		n <= p;
--		
--		if p.preset = '0' then
--			if start = '1' and p.rst_pend = '0' and p.dds_pend = '0' then --master_counter駆動と同時にスタート
--				n.dds_pend <= '1';
--				data32	<= first_data;
--				n.preset <= '1';
--			end if;
--		else
--			if data_change = '1' then
--				d_change <= '1';
--			end if;
--		end if;
--		
--		if d_change = '1' and p.rst_pend = '0' and p.dds_pend = '0' then 
--			n.dds_pend <= '1';
--			data32	<= data40;
--			d_change <= '0';
--		end if;
--		
--		case state_p is
--			--reset
--			when "0000001" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '1';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0110001";
--				n.dds_pend <= '0';
--				n.rst_pend <= '0';
--			when "0110001" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '1';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0000010";
--			when "0000010" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0110010";
--			when "0110010" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0000011";
--			when "0000011" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '1';
--				n.c_w			<= '1';
--				state_n <= "0110011";
--			when "0110011" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '1';
--				n.c_w			<= '1';
--				state_n <= "0000100";
--			when "0000100" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0110100";
--			when "0110100" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0000101";
--			when "0000101" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '1';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0110101";
--			when "0110101" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '1';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0000110";
--			when "0000110" => 
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0110111";
--			when "0110111" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0000000";
--			--32bitdata
--			when "0000111" =>
--				n.data_set		<=	data32(0);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001000";
--			when "0001000" =>
--				n.data_set		<=	data32(1);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001001";
--			when "0001001" =>
--				n.data_set		<=	data32(2);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001010";
--			when "0001010" =>
--				n.data_set		<=	data32(3);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001011";
--			when "0001011" =>
--				n.data_set		<=	data32(4);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001100";
--			when "0001100" =>
--				n.data_set		<=	data32(5);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001101";
--			when "0001101" =>
--				n.data_set		<=	data32(6);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001110";
--			when "0001110" =>
--				n.data_set		<=	data32(7);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0001111";
--			when "0001111" =>
--				n.data_set		<=	data32(8);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010000";
--			when "0010000" =>
--				n.data_set		<=	data32(9);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010001";
--			when "0010001" =>
--				n.data_set		<=	data32(10);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010010";
--			when "0010010" =>
--				n.data_set		<=	data32(11);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010011";
--			when "0010011" =>
--				n.data_set		<=	data32(12);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010100";
--			when "0010100" =>
--				n.data_set		<=	data32(13);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010101";
--			when "0010101" =>
--				n.data_set		<=	data32(14);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010110";
--			when "0010110" =>
--				n.data_set		<=	data32(15);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0010111";
--			when "0010111" =>
--				n.data_set		<=	data32(16);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011000";
--			when "0011000" =>
--				n.data_set		<=	data32(17);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011001";
--			when "0011001" =>
--				n.data_set		<=	data32(18);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011010";
--			when "0011010" =>
--				n.data_set		<=	data32(19);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011011";
--			when "0011011" =>
--				n.data_set		<=	data32(20);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011100";
--			when "0011100" =>
--				n.data_set		<=	data32(21);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011101";
--			when "0011101" =>
--				n.data_set		<=	data32(22);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011110";
--			when "0011110" =>
--				n.data_set		<=	data32(23);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0011111";
--			when "0011111" =>
--				n.data_set		<=	data32(24);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100000";
--			when "0100000" =>
--				n.data_set		<=	data32(25);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100001";
--			when "0100001" =>
--				n.data_set		<=	data32(26);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100010";
--			when "0100010" =>
--				n.data_set		<=	data32(27);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100011";
--			when "0100011" =>
--				n.data_set		<=	data32(28);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100100";
--			when "0100100" =>
--				n.data_set		<=	data32(29);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100101";
--			when "0100101" =>
--				n.data_set		<=	data32(30);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100110";
--			when "0100110" =>
--				n.data_set		<=	data32(31);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0100111";
--			--phase data8
--			when "0100111" =>
--				n.data_set		<=	data32(32);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101000";
--			when "0101000" =>
--				n.data_set		<=	data32(33);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101001";
--			when "0101001" =>
--				n.data_set		<=	data32(34);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101010";
--			when "0101010" =>
--				n.data_set		<=	data32(35);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101011";
--			when "0101011" =>
--				n.data_set		<=	data32(36);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101100";
--			when "0101100" =>
--				n.data_set		<=	data32(37);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101101";
--			when "0101101" =>
--				n.data_set		<= data32(38);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101110";
--			when "0101110" =>
--				n.data_set		<=	data32(39);
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '0';
--				state_n <= "0101111";
--			--end
--			when "0101111" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0111111";
--			when "0111111" =>
--				n.data_set		<=	'0';
--				n.fqud_set		<= '1';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				state_n <= "0000000";
--				n.dds_pend <= '0';
--			--when "0110000" =>
--				--data_set		<=	'0';
--				--fqud_set		<= '0';
--				--rst_set		<= '0';
--				--w_clk_set	<= '0';
--				--c_w			<= '1';
--				--state_n		<= "1110000";
--			when others =>	
--				n.data_set		<=	'0';
--				n.fqud_set		<= '0';
--				n.rst_set		<= '0';
--				n.w_clk_set	<= '0';
--				n.c_w			<= '1';
--				if p.dds_pend = '1' then
--					state_n <= "0000111";	
--				else
--					state_n <= (others => '0');
--				end if;
--		end case;
--	end process;
--	
--	process(clk,rst) begin
--		if rst = '1' or msr_fin = '1' then
--				state_p <= "0000001";
--				p.data_set		<=	'0';
--				p.fqud_set		<= '0';
--				p.rst_set		<= '0';
--				p.w_clk_set	<= '0';
--				p.c_w			<= '1';
--				p.preset <= '0';
--		elsif clk' event and clk = '0' then
--				state_p <= state_n;
--				p	<= n;
--		end if;
--	end process;
--				
--
--end DDS;
