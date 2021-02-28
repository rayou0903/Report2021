library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

--	component SDRAM_ctrl
--		port (
--			clk1	: in std_logic;
--			rst	:	in		std_logic;
--			--SDRAM用信号
--			sdram_addr	:	out	std_logic_vector(11 downto 0);
--			sdram_ba		:	out	std_logic_vector(1 downto 0);
--			sdram_cs		:	out	std_logic;
--			sdram_cke	:	out	std_logic;
--			sdram_clk	:	out	std_logic;
--			sdram_dq		:	inout	std_logic_vector(15 downto 0);
--			sdram_dqm	:	out	std_logic_vector(1 downto 0);
--			sdram_ras	:	out	std_logic;
--			sdram_cas	:	out	std_logic;
--			sdram_we		:	out	std_logic;
--			
--			data_in		:	in	std_logic_vector(63 downto 0);
--			data_out		:	out	std_logic_vector(63 downto 0);
--			req_read		:	in	std_logic;
--			req_write	:	in	std_logic;
--			address		:	in	std_logic_vector(19 downto 0);
--			data_mask	:	in	std_logic_vector(1 downto 0);
--			data_in_valid	: OUT		std_logic; -- 書き込みが完了したら1になる信号
--			data_out_valid : OUT		STD_LOGIC -- 読み出しが完了したら1になる信号
--		);
--	end component;
--
--	sdram : SDRAM_ctrl
--		port map (
--			clk1 => clk100,
--			rst => '0', -- 要修正
--			sdram_addr => DRAM_ADDR,
--			sdram_ba => DRAM_BA,
--			sdram_cs => DRAM_CS_N,
--			sdram_cke => DRAM_CKE,
--			sdram_clk => DRAM_CLK,
--			sdram_dq => DRAM_DQ,
--			sdram_dqm => DRAM_DQM,
--			sdram_ras => DRAM_RAS_N,
--			sdram_cas => DRAM_CAS_N,
--			sdram_we => DRAM_WE_N,
--			data_in => (others => 0), -- 要修正
--			data_out => open, -- 要修正
--			req_read => '0', -- 要修正
--			req_write => '0', -- 要修正
--			address => (others => 0), -- 要修正
--			data_mask => "11", -- 要修正
--			data_in_valid => open, -- 要修正
--			data_out_valid => open -- 要修正
--	);

entity SDRAM_ctrl is

	generic (
    HIGH_BIT: integer := 24;
    MHZ: integer := 96;
    REFRESH_CYCLES: integer := 4096;
    ADDRESS_BITS: integer := 12
	);
	
	port(
		clk1			:	in		std_logic;
		rst			:	in		std_logic;
		
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
end SDRAM_ctrl;

architecture Behavioral of SDRAM_ctrl is
	---SDRAMのコマンド（cs, ras, cas, we） 
	constant cmd_nop	:	std_logic_vector(3 downto 0):="0111";	
	constant cmd_pre	:	std_logic_vector(3 downto 0):="0010";
	constant cmd_ref	:	std_logic_vector(3 downto 0):="0001";
	constant cmd_mrs	:	std_logic_vector(3 downto 0):="0000";
	constant cmd_act	:	std_logic_vector(3 downto 0):="0011";
	constant cmd_read	:	std_logic_vector(3 downto 0):="0101";
	constant cmd_write:	std_logic_vector(3 downto 0):="0100";
	constant addr_set:std_logic_vector(11 downto 0):="000000100001";
	
	
	
	--状態遷移制御用
	constant s_init_nop_id: std_logic_vector(4 downto 0) := "00000";

   constant s_init_nop  : std_logic_vector(8 downto 0) := s_init_nop_id & cmd_nop;
   constant s_init_pre  : std_logic_vector(8 downto 0) := s_init_nop_id  & cmd_pre;
   constant s_init_ref  : std_logic_vector(8 downto 0) := s_init_nop_id  & cmd_ref;
   constant s_init_mrs  : std_logic_vector(8 downto 0) := s_init_nop_id  & cmd_mrs;

   constant s_idle_id: std_logic_vector(4 downto 0) := "00001";
   constant s_idle  : std_logic_vector(8 downto 0) := s_idle_id & cmd_nop;

   constant s_rf0_id: std_logic_vector(4 downto 0) := "00010";
   constant s_rf0   : std_logic_vector(8 downto 0) := s_rf0_id & cmd_ref;

   constant s_rf1_id: std_logic_vector(4 downto 0) := "00011";
   constant s_rf1   : std_logic_vector(8 downto 0) := "00011" & cmd_nop;

   constant s_rf2_id: std_logic_vector(4 downto 0) := "00100";
   constant s_rf2   : std_logic_vector(8 downto 0) := "00100" & cmd_nop;

   constant s_rf3_id: std_logic_vector(4 downto 0) := "00101";
   constant s_rf3   : std_logic_vector(8 downto 0) := "00101" & cmd_nop;

   constant s_rf4_id: std_logic_vector(4 downto 0) := "00110";
   constant s_rf4   : std_logic_vector(8 downto 0) := "00110" & cmd_nop;

   constant s_rf5_id: std_logic_vector(4 downto 0) := "00111";
   constant s_rf5   : std_logic_vector(8 downto 0) := "00111" & cmd_nop;


   constant s_ra0_id: std_logic_vector(4 downto 0) := "01000";
   constant s_ra0   : std_logic_vector(8 downto 0) := "01000" & cmd_act;

   constant s_ra1_id: std_logic_vector(4 downto 0) := "01001";
   constant s_ra1   : std_logic_vector(8 downto 0) := "01001" & cmd_nop;

   constant s_ra2_id: std_logic_vector(4 downto 0) := "01010";
   constant s_ra2   : std_logic_vector(8 downto 0) := "01010" & cmd_nop;


   constant s_dr0_id: std_logic_vector(4 downto 0) := "01011";
   constant s_dr0   : std_logic_vector(8 downto 0) := "01011" & cmd_pre;

   constant s_dr1_id: std_logic_vector(4 downto 0) := "01100";
   constant s_dr1   : std_logic_vector(8 downto 0) := "01100" & cmd_nop;

   constant s_wr0_id: std_logic_vector(4 downto 0) := "01101";
   constant s_wr0   : std_logic_vector(8 downto 0) := "01101" & cmd_write;

   constant s_wr1_id: std_logic_vector(4 downto 0) := "01110";
   constant s_wr1   : std_logic_vector(8 downto 0) := "01110" & cmd_nop;

   constant s_wr2_id: std_logic_vector(4 downto 0) := "01111";
   constant s_wr2   : std_logic_vector(8 downto 0) := "01111" & cmd_nop;

   constant s_wr3_id: std_logic_vector(4 downto 0) := "10000";
   constant s_wr3   : std_logic_vector(8 downto 0) := "10000" & cmd_nop;
	
	constant s_wr4_id: std_logic_vector(4 downto 0) := "11111";
   constant s_wr4   : std_logic_vector(8 downto 0) := "11111" & cmd_nop;


   constant s_rd0_id: std_logic_vector(4 downto 0) := "10001";
   constant s_rd0   : std_logic_vector(8 downto 0) := "10001" & cmd_read;

   constant s_rd1_id: std_logic_vector(4 downto 0) := "10010";
   constant s_rd1   : std_logic_vector(8 downto 0) := "10010" & cmd_nop;

   constant s_rd2_id: std_logic_vector(4 downto 0) := "10011";
   constant s_rd2   : std_logic_vector(8 downto 0) := "10011" & cmd_nop;

   constant s_rd3_id: std_logic_vector(4 downto 0) := "10100";
   constant s_rd3   : std_logic_vector(8 downto 0) := "10100" & cmd_nop;

   constant s_rd4_id: std_logic_vector(4 downto 0) := "10101";
   constant s_rd4   : std_logic_vector(8 downto 0) := "10101" & cmd_nop;

   constant s_rd5_id: std_logic_vector(4 downto 0) := "10110";
   constant s_rd5   : std_logic_vector(8 downto 0) := "10110" & cmd_nop;

   constant s_rd6_id: std_logic_vector(4 downto 0) := "10111";
   constant s_rd6   : std_logic_vector(8 downto 0) := "10111" & cmd_nop;

   constant s_rd7_id: std_logic_vector(4 downto 0) := "11000";
   constant s_rd7   : std_logic_vector(8 downto 0) := "11000" & cmd_nop;

   constant s_rd8_id: std_logic_vector(4 downto 0) := "11001";
   constant s_rd8   : std_logic_vector(8 downto 0) := "11001" & cmd_nop;

   constant s_rd9_id: std_logic_vector(4 downto 0) := "11011";
   constant s_rd9   : std_logic_vector(8 downto 0) := "11011" & cmd_nop;


   constant s_drdr0_id: std_logic_vector(4 downto 0) := "11101";
   constant s_drdr0 : std_logic_vector(8 downto 0) := "11101" & cmd_pre;

   constant s_drdr1_id: std_logic_vector(4 downto 0) := "11110";
   constant s_drdr1 : std_logic_vector(8 downto 0) := "11110" & cmd_nop;
	
	--リフレッシュサイクル
	constant REFRESH	:	integer	:= 2000000;
	
	--遅延
	constant tOPD: time := 2.1 ns;
	constant tHZ: time := 8 ns;
	
	signal n_data_w	:	std_logic_vector(15 downto 0);
	signal p_data_w	:	std_logic_vector(15 downto 0);
	signal state_set	:	std_logic_vector(3 downto 0);
	signal statep		:	std_logic_vector(8 downto 0);
	signal staten		:	std_logic_vector(8 downto 0);
	
	signal captured		:	std_logic_vector(15 downto 0);
	
	signal not_clk	:	std_logic;
	signal	SDRAM_CLK_i	:	std_logic;
	
	--signal i_DRAM_CS_N: std_logic;
	--signal i_DRAM_RAS_N: std_logic;
	--signal i_DRAM_CAS_N: std_logic;
	--signal i_DRAM_WE_N: std_logic;
	--signal i_DRAM_ADDR: std_logic_vector(11 downto 0);
	--signal i_DRAM_BA: std_logic_vector(1 downto 0);
	--signal i_DRAM_DQM: std_logic_vector(1 downto 0);
	--signal i_DRAM_CLK: std_logic;
	
	attribute IOB: string;

  signal i_DRAM_CS_N: std_logic;
  attribute IOB of i_DRAM_CS_N: signal is "true";

  signal i_DRAM_RAS_N: std_logic;
  attribute IOB of i_DRAM_RAS_N: signal is "true";

  signal i_DRAM_CAS_N: std_logic;
  attribute IOB of i_DRAM_CAS_N: signal is "true";

  signal i_DRAM_WE_N: std_logic;
  attribute IOB of i_DRAM_WE_N: signal is "true";

  signal i_DRAM_ADDR: std_logic_vector(ADDRESS_BITS-1 downto 0);
  attribute IOB of i_DRAM_ADDR: signal is "true";

  signal i_DRAM_BA: std_logic_vector(1 downto 0);
  attribute IOB of i_DRAM_BA: signal is "true";

  signal i_DRAM_DQM: std_logic_vector(1 downto 0);
  attribute IOB of i_DRAM_DQM: signal is "true";

  attribute IOB of p_data_w: signal is "true";
  attribute IOB of captured: signal is "true";

  signal i_DRAM_CLK: std_logic;

  attribute fsm_encoding: string;
  attribute fsm_encoding of staten: signal is "user";
  attribute fsm_encoding of statep: signal is "user";
	
	type reg is record
      address       : std_logic_vector(11 downto 0);
      bank          : std_logic_vector(1 downto 0);
      init_counter  : std_logic_vector(14 downto 0);
      rf_counter    : integer;
      rf_pending    : std_logic;
      rd_pending    : std_logic;
      wr_pending    : std_logic;
      act_row       : std_logic_vector(11 downto 0);
      act_ba        : std_logic_vector(1 downto 0);
      data_out_1  : std_logic_vector(15 downto 0);
		data_out_2  : std_logic_vector(15 downto 0);
		data_out_3  : std_logic_vector(15 downto 0);
      req_addr_q    : std_logic_vector(19 downto 0);
      req_data_write: std_logic_vector(63 downto 0);
      req_mask      : std_logic_vector(1 downto 0);
      data_out_valid: std_logic;
		data_in_valid : std_logic;
      dq_masks      : std_logic_vector(1 downto 0);
      tristate      : std_logic;
   end record;
	
	signal r : reg;
	signal n : reg;
	
	signal addr_row : std_logic_vector(11 downto 0);
	signal addr_bank: std_logic_vector(1 downto 0);
	signal addr_col	:	std_logic_vector(7 downto 0);
	
	signal dram_dq_dly	:	std_logic_vector(15 downto 0);
	
begin
	
	not_clk	<= not clk1;
	
	ODDR2_inst : ODDR2
   generic map(
      DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1" 
      INIT => '0', -- Sets initial state of the Q output to '0' or '1'
      SRTYPE => "ASYNC") -- Specifies "SYNC" or "ASYNC" set/reset
   port map (
      Q => i_DRAM_CLK, -- 1-bit output data
      C0 => clk1, -- 1-bit clock input
      C1 => not_clk, -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D0 => '0',   -- 1-bit data input (associated with C0)
      D1 => '1',   -- 1-bit data input (associated with C1)
      R => '0',    -- 1-bit reset input
      S => '0'     -- 1-bit set input
   );

	--sdram_cs			<= statep(3);
	--sdram_ras		<= statep(2);
	--sdram_cas		<= statep(1);
	--sdram_we			<= statep(0);
	
	i_DRAM_CS_N    <= transport statep(3)  after tOPD;
   sdram_cs      <= i_DRAM_CS_N;
	
	i_DRAM_RAS_N    <= transport statep(2)  after tOPD;
   sdram_ras      <= i_DRAM_RAS_N;
	
	i_DRAM_CAS_N    <= transport statep(1)  after tOPD;
   sdram_cas      <= i_DRAM_CAS_N;
	
	i_DRAM_WE_N    <= transport statep(0)  after tOPD;
   sdram_we      <= i_DRAM_we_N;
	
	sdram_cke		<=	'1';
	--i_DRAM_CLK		<= transport clk1 after tOPD;--
	sdram_clk		<= transport i_DRAM_CLK ;--after 10ns;--tOPD;
	i_DRAM_ADDR    <= transport r.address  after tOPD;
	sdram_addr		<=	i_DRAM_ADDR;
	i_DRAM_BA      <= transport r.bank  after tOPD;
	sdram_ba			<= i_DRAM_BA;
	i_DRAM_DQM     <= transport r.dq_masks  after tOPD;
	sdram_dqm		<=	i_DRAM_DQM;
	
	data_out			<= r.data_out_1 &  r.data_out_2 &  r.data_out_3 & captured;
	data_out_valid	<=	r.data_out_valid;
	data_in_valid <= r.data_in_valid;
	sdram_dq			<=	(others => 'Z') after tHZ when r.tristate = '1' else p_data_w;
	
	--アドレス振り分け
	process(r.req_addr_q)
	begin
		addr_bank	<=	r.req_addr_q(19 downto 18);
		addr_row		<=	r.req_addr_q(17 downto 6);
		addr_col  <= (others => '0');
		addr_col		<= r.req_addr_q(5 downto 0) & "00";
	end process;
	
	process(n,r,req_read,req_write,data_in,data_mask,address,addr_row,addr_bank,addr_col,staten,statep,captured)begin
		n <= r;
		staten <= statep;
		
		if req_read = '1' then
			n.rd_pending <= '1';
			if r.rd_pending='0' and r.wr_pending='0' then
				n.req_addr_q <= address;
			end if;
		end if;
		
		if req_write = '1' then
			n.wr_pending <= '1';
         if r.wr_pending='0' and r.rd_pending='0' then
           n.req_addr_q <= address;
           n.req_data_write <= data_in;
           n.req_mask <= data_mask;
         end if;
      end if;
		
		n.dq_masks	<=	"11";
		
		if r.rf_counter = REFRESH then
			n.rf_counter <= 0;
			n.rf_pending <= '1';
		else
			if not(statep(8 downto 0) = s_init_nop(8 downto 0)) then
				n.rf_counter <= r.rf_counter + 1;
			end if;
		end if;
		
		n.tristate		<= '0';
		
		n.init_counter	<= r.init_counter - 1;
		
		n.data_out_valid	<= '0';
		n.data_in_valid <= '0';
		
		case statep(8 downto 4) is
			when s_init_nop_id =>
				staten			<=	s_init_nop;
				n.address		<=	(others => '0');
				n.bank			<=	(others => '0');
				n.act_ba			<= (others => '0');
				n.rf_counter	<= 0;
			
			if r.init_counter = "000000010000010" then
				staten     <= s_init_pre;
				n.address(10)   <= '1';
          end if;
			 
			 if r.init_counter(14 downto 7) = 0 and r.init_counter(3 downto 0) = 15 then
				staten     <= s_init_ref;
          end if;
			 
			 if r.init_counter = 3 then
				staten     <= s_init_mrs;
                        -- Mode register is as follows:
                        --resvd   wr_b   OpMd   CAS=3  Seq  bust=4
				n.address   <= "00" & "0" & "00" & "011" & "0" & "010";
                        -- resvd
				n.bank      <= "00";
			 end if;
			 
			 if r.init_counter = 1 then
				staten          <= s_idle;
          end if;
			 
			-- The Idle section
			when s_idle_id =>
            staten <= s_idle;
				
				if r.rd_pending = '1' or r.wr_pending = '1' then
               staten        <= s_ra0;
               n.address     <= addr_row;
               n.act_row    <= addr_row;
               n.bank       <= addr_bank;
            end if;
				
				if r.rf_pending = '1' then
               staten        <= s_rf0;
               n.rf_pending <= '0';
            end if;
			--Row activation
			when s_ra0_id =>
				staten        <= s_ra1;
			when s_ra1_id =>
				staten        <= s_ra2;
			when s_ra2_id=>
				staten		<= s_ra2;
				n.tristate	<=	'1';
				n.data_out_valid <= '0';
				n.data_in_valid <= '0';
				
				if r.rf_pending = '1' then
					staten	<=	s_dr0;
					n.address(10)	<=	'1';
				end if;
			
				--to read state
				if r.rd_pending = '1' and r.act_row = addr_row and addr_bank=r.bank then
					staten     <= s_rd0;
					n.address <= (others => '0');
					n.address(7 downto 0) <= addr_col;
					n.bank    <= addr_bank;
					n.act_ba    <= addr_bank;
					n.dq_masks <= "00";
					n.rd_pending <= '0';
            end if;
				--to write state
				if r.wr_pending = '1' and r.act_row = addr_row and addr_bank=r.bank then
					staten     <= s_wr0;
					n.address <= (others => '0');
					n.address(7 downto 0) <= addr_col;
					n_data_w <= r.req_data_write(63 downto 48);
					n.bank    <= addr_bank;
					n.act_ba    <= addr_bank;
					n.dq_masks	<= not r.req_mask;
					n.wr_pending <= '0';
					n.tristate	<=	'0';
				end if;
			
			
			--Deactivate the current row and return to idle state
			when s_dr0_id =>
            staten <= s_dr1;
         when s_dr1_id =>
            staten <= s_idle;
			
			-- The Refresh section
			when s_rf0_id =>
            staten <= s_rf1;
         when s_rf1_id =>
            staten <= s_rf2;
         when s_rf2_id =>
            staten <= s_rf3;
         when s_rf3_id =>
            staten <= s_rf4;
         when s_rf4_id =>
            staten <= s_rf5;
         when s_rf5_id =>
            staten <= s_idle;
			
			--write section
			when s_wr0_id =>
				staten	<=	s_wr1;
				n_data_w <= r.req_data_write(47 downto 32);
				n.dq_masks	<= not r.req_mask;
				n.tristate	<=	'0';
			when s_wr1_id =>
				staten	<=	s_wr3;
				n_data_w <= r.req_data_write(31 downto 16);
				n.dq_masks	<= not r.req_mask;
				n.tristate	<=	'0';
			when s_wr2_id =>
				staten	<=	s_dr0;
				n.address(10) <= '1';
			when s_wr3_id =>
				staten	<=	s_wr4;
				n_data_w <= r.req_data_write(15 downto 0);
				n.dq_masks	<= not r.req_mask;
				n.tristate	<=	'0';
			when s_wr4_id =>
				staten	<=	s_ra2;
				n.tristate	<=	'1';
				n.dq_masks	<=	"11";
				n.data_in_valid <= '1';
				if r.rf_pending = '1' then
					staten	<=	s_wr2;
				end if;
			
			-- The Read section
			when s_rd0_id =>
            staten <= s_rd1;
            n.tristate<='1';
            n.dq_masks <= "00";
            --n.address(0)<='1';
			when s_rd1_id =>
            staten <= s_rd2;
            n.dq_masks <= "00";
            n.tristate<='1';
			when s_rd2_id =>
            staten <= s_rd3;
            n.dq_masks <= "00";
            n.tristate<='1';
			when s_rd3_id =>
            staten <= s_rd4;
            n.dq_masks <= "00";
            n.tristate<='1';
				n.data_out_1 <= captured;
			when s_rd4_id =>
            staten <= s_rd5;
            n.dq_masks <= "00";
            n.tristate<='1';
				n.data_out_2 <= captured;
			when s_rd5_id =>
            --staten <= s_rd6;
				staten <= s_ra2;
            n.dq_masks <= "00";
            n.tristate<='1';
				n.data_out_3 <= captured;
				n.data_out_valid <= '1';
				--n.rd_pending <= '0';
			--when s_rd6_id =>
				--staten <= s_ra2;
				--n.data_out_valid <= '1';
				--n.tristate<='1';
				--n.dq_masks <= "00";
			
			when s_rd8_id =>
				null;
				--staten <= s_ra2;
				--n.data_out_valid <= '1';
				--n.tristate<='1';
			when s_rd9_id => null;
			when others => null;
		end case;
	end process;

	
	process(clk1,rst,n)begin
		if rst = '1' then
				statep		<=	(others => '0');
				r.address	<=	(others => '0');
				r.bank		<=	(others => '0');
				r.init_counter	<=	"000001000000000";
				r.rf_counter	<=	0;
				r.rf_pending <= '0';
				r.rd_pending <= '0';
				r.wr_pending <= '0';
				r.act_row <= (others => '0');
				r.data_out_1 <= (others => '0');
				r.data_out_2 <= (others => '0');
				r.data_out_3 <= (others => '0');
				r.data_out_valid <= '0';
				r.data_in_valid <= '1';
				r.dq_masks <= "11";
				r.tristate<='1';
		elsif clk1' event and clk1 = '1' then
				r <= n;
				statep	<=	staten; -- 次の状態に遷移
				p_data_w	<=	n_data_w;
		end if;
	end process;
	
	dram_dq_dly <= transport sdram_dq after 1.9 ns;
	
	process (clk1) begin
      if falling_edge(clk1) then
         captured <= dram_dq_dly;
      end if;
   end process;

end Behavioral;

