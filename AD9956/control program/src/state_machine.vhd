----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:17:24 10/02/2019 
-- Design Name: 
-- Module Name:    state_machine - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.ascii_pac.all;
use work.types.all;

--	component state_machine
--		port (
--			CLK						: in std_logic;
--			-- ��M�pFIFO�ւ̐M��
--			REC_EMPTY				: in std_logic;
--			REC_VALID				: in std_logic;
--			REC_AC					: in ascii;
--			REC_RD_EN				: out std_logic;
--			
--			-- ���胂�W���[���Ƃ̒ʐM�p
--			MSR_FINISH				: in std_logic;
--			MSR_START				: out std_logic;
--			
--			-- �����񑗐M���W���[���p
--			STR_FINISH				: in std_logic;
--			STR_START				: out std_logic;
--			STR						: out ascii_vector(0 to MAX_LEN-1);
--			STR_LEN					: out integer;
--			
--			-- ���Z�b�g�v���M��
--			RST_OP					: out std_logic
--		);
--	end component;
--	-- state machine
--	st_machine : state_machine
--		port map (
--			CLK => clk100,
--			REC_EMPTY => ,
--			REC_VALID => ,
--			REC_AC => ,
--			REC_RD_EN => ,
--			MSR_FINISH => ,
--			MSR_START => ,
--			STR_FINISH => ,
--			STR_START => ,
--			STR => ,
--			STR_LEN => ,
--			RST => 
--	);

entity state_machine is
	generic (
		MAX_LEN					: positive := 64 -- CRLF���܂߁A1�x�Ɏ�M�\�ȕ�����
	);
	port (
		CLK						: in std_logic;
		-- ��M�pFIFO�Ƃ̐ڑ�
		REC_EMPTY				: in std_logic;
		REC_ALMOST_EMPTY		: in std_logic;
		REC_VALID				: in std_logic;
		REC_AC					: in ascii;
		REC_RD_EN				: out std_logic;
		
		-- �����񑗐M���W���[���p
		STR_FINISH				: in std_logic;
		STR_START				: out std_logic;
		STR						: out ascii_vector(0 to MAX_LEN-1);
		STR_LEN					: out integer;
		
		-- ���s���W���[���p
		EXE_FINISH				: in std_logic;
		EXE_START				: out std_logic;
		EXE_CMD					: out cmd_t;
		EXE_ADDR					: out std_logic_vector(20-1 downto 0);
		EXE_ADDR_FINISH		: out std_logic_vector(20-1 downto 0);
		EXE_DATA					: out std_logic_vector(64-1 downto 0);
		EXE_RESULT				: in ascii_vector(0 to 64-1);
		EXE_RESULT_LEN			: in integer
	);
end state_machine;

architecture Behavioral of state_machine is
	--** component
	
	-- CRLF�̓��͂��Ď����郂�W���[��
	component crlf_observer
		port (
			CLK		: in	std_logic;
			REC_RQ	: in	std_logic;
			AC			: in	ascii;
			CRLF		: out	std_logic
		);
	end component;

	--** type def
	
	-- ��Ԃ̌^
	type state_t is (require, fetch, decode, address, data, execute_start, execute_wait);
	type addr_status_t is (uncompleted, completed);
	
	--** signal

	-- for recieve signal
	signal rd_en			: std_logic;
	signal acv_recieve	: ascii_vector(0 to MAX_LEN-1); -- ��M�A�X�L�[�f�[�^(�ő咷MAX_LEN����)
	signal recieve_cnt	: integer := 0; -- ��M������
	
	-- for crlf observer
	signal obs_rec_rq		: std_logic;
	signal obs_crlf		: std_logic;
	
	-- for state
	signal state			: state_t := execute_wait;
	signal transit_en		: std_logic; -- �J�ډ\�M��
	
	-- for str
	signal str_start_inner	: std_logic := '0';
	
	-- for execute
	signal cmd					: cmd_t := none;
	signal addr_cnt			: integer := 0;
	signal addr					: std_logic_vector(20-1 downto 0);
	signal start_addr			: std_logic_vector(20-1 downto 0);
	signal finish_addr		: std_logic_vector(20-1 downto 0);
	signal exe_data_inner	: std_logic_vector(64-1 downto 0);
	signal exe_data_cnt		: integer := 0;
	
	-- for address control
	signal start_addr_status	: addr_status_t := uncompleted; -- �J�n�A�h���X����󋵁i�����l�F�������j
	
begin
	--** port map
	crlf_obs : crlf_observer
		port map (
			CLK => CLK,
			REC_RQ => REC_VALID,
			AC => REC_AC,
			CRLF => obs_crlf
	);
	--** signal assignment
	REC_RD_EN <= rd_en;
	STR_START <= str_start_inner;
	EXE_DATA <= exe_data_inner;
	EXE_CMD <= cmd;

	--** process
	-- �N���b�N�ɓ�����������
	process(CLK)
	begin
		if rising_edge(CLK) then
			-- ��ԑJ��
			case state is
				-- �R�}���h�v��
				when require =>
					str_start_inner <= '0';
					if STR_FINISH = '1' then
						recieve_cnt <= 0;
						STR(0) <= '>';
						STR_LEN <= 1;
						str_start_inner <= '1';
						state <= fetch;
					end if;
				-- �R�}���h�t�F�b�`
				when fetch =>
					str_start_inner <= '0';
					if transit_en = '1' then -- CRLF�����m���ꂽ��
						transit_en <= '0';
						rd_en <= '0';
						state <= decode;
					end if;
					
					if recieve_cnt > MAX_LEN-1 then -- ��M���������ő�l�𒴂��Ă�����
						transit_en <= '0';
						state <= decode;
					end if;
					
					if REC_EMPTY = '0' then -- FIFO����łȂ����
						if STR_FINISH = '1' then -- �����񑗐M�\��������
							rd_en <= '1';
						else
							rd_en <= '0';
						end if;
					end if;

					if (REC_VALID = '1') and (REC_ALMOST_EMPTY = '1') then -- �������o�͂���AALMOST_EMPTY�M����1�Ȃ�
						transit_en <= obs_crlf; -- CRLF�̊Ď����J�n����
						-- �G�R�[�o�b�N
						if STR_FINISH = '1' then
							acv_recieve(recieve_cnt) <= REC_AC; -- �R�}���h������ɑ��
							STR(0) <= REC_AC;
							STR_LEN <= 1;
							str_start_inner <= '1';
						end if;
						
						recieve_cnt <= recieve_cnt + 1; -- �������̃J�E���g�𑝉�������
					end if;
				-- �R�}���h�𔻕ʂ��A�J�ڐ���w��
				when decode =>
					start_addr_status <= uncompleted;
					addr_cnt <= 0;
					exe_data_cnt <= 0;
					str_start_inner <= '0';
					if recieve_cnt = 4+2 then -- �R�}���h4����+CR+LF
						case acv_recieve(0 to 3) is
							when "srst" =>
								cmd <= srst;
								state <= execute_start;
							when "cmdl" =>
								cmd <= cmdl;
								state <= execute_start;
							when "sdw1" =>
								cmd <= sdw1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "sdr1" =>
								cmd <= sdr1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "dds1" =>
								cmd <= dds1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "dds2" =>
								cmd <= dds2;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "dac1" =>
								cmd <= dac1;
								if STR_FINISH = '1' then
									STR(0) <= '@';
									STR_LEN <= 1;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "adcr" =>
								cmd <= adcr;
								if STR_FINISH = '1' then
									STR(0 to 6) <= "start @";
									STR_LEN <= 7;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "serr" =>
								cmd <= serr;
								if STR_FINISH = '1' then
									STR(0 to 6) <= "start @";
									STR_LEN <= 7;
									str_start_inner <= '1';
									state <= address;
								end if;
							when "reqr" =>
								cmd <= reqr;
								if STR_FINISH = '1' then
									STR(0 to 6) <= "start @";
									STR_LEN <= 7;
									str_start_inner <= '1';
									state <= address;
								end if;
							when others =>
								cmd <= none;
								STR(0 to 16) <= "command not found";
								STR(17) <= cr;
								STR(18) <= lf;
								STR_LEN <= 19;
								str_start_inner <= '1';
								state <= require;
						end case;
					else
						if STR_FINISH = '1' then
							STR(0 to 23) <= "command length must be 4";
							STR(24) <= cr;
							STR(25) <= lf;
							STR_LEN <= 26;
							str_start_inner <= '1';
							state <= require;
						end if;
					end if;
				-- �A�h���X�v��
				when address =>
					str_start_inner <= '0';
					if REC_EMPTY = '0' then -- FIFO����łȂ����
						if STR_FINISH = '1' then
							rd_en <= '1';
						else
							rd_en <= '0';
						end if;
					end if;
					if (REC_VALID = '1') and (REC_ALMOST_EMPTY = '1') then
						if STR_FINISH = '1' then
							-- �R�}���h�ɂ���ĕK�v�ȃA�h���X�����Ⴄ�̂ŁA�A�h���X�̐ڑ����ύX����
							case cmd is
								when reqr =>
									if start_addr_status = completed then
										finish_addr(19-addr_cnt downto 19-addr_cnt-3) <= hex2vec(REC_AC);
									else
										start_addr(19-addr_cnt downto 19-addr_cnt-3) <= hex2vec(REC_AC);
									end if;
								when others =>
									addr(19-addr_cnt downto 19-addr_cnt-3) <= hex2vec(REC_AC);
							end case;
							addr_cnt <= addr_cnt + 4;
							STR(0) <= REC_AC;
							STR_LEN <= 1;
							str_start_inner <= '1';
							if addr_cnt = 20-4 then -- 1�N���b�N�O�̃J�E���g��16��������Ō�̓��͂����̃N���b�N�Ŋ�������
								STR(1) <= cr;
								STR(2) <= lf;
								STR_LEN <= 3;
								case cmd is 
									when sdw1 =>
										STR(3) <= '#';
										STR_LEN <= 4;
										state <= data;
									when reqr => 
										if start_addr_status = completed then
											state <= execute_start;
										else
											STR(3 to 8) <= "end  @";
											STR_LEN <= 9;
											str_start_inner <= '1';
											state <= address;
											addr_cnt <= 0; -- �I���A�h���X�̎擾���J�n���邽�߂ɃJ�E���g�l��������
											start_addr_status <= completed;
										end if;
									when others => state <= execute_start;
								end case;
							end if;
						end if;
					end if;
				-- �f�[�^�v��
				when data =>
					str_start_inner <= '0';
					if REC_EMPTY = '0' then
						if STR_FINISH = '1' then
							rd_en <= '1';
						else
							rd_en <= '0';
						end if;
					end if;
					
					if (REC_VALID = '1') and (REC_ALMOST_EMPTY = '1') then
						if STR_FINISH = '1' then
							exe_data_inner(63-exe_data_cnt downto 63-exe_data_cnt-3) <= hex2vec(REC_AC);
							exe_data_cnt <= exe_data_cnt + 4;
							STR(0) <= REC_AC;
							STR_LEN <= 1;
							str_start_inner <= '1';
							if exe_data_cnt = 64-4 then -- 1�N���b�N�O�̃J�E���g��16�Ȃ�Ō�̓��͂����̃N���b�N�Ŋ���
								STR(1) <= cr;
								STR(2) <= lf;
								STR_LEN <= 3;
								state <= execute_start;
							end if;
						end if;
					end if;
				-- ���s
				when execute_start =>
					str_start_inner <= '0';
					EXE_START <= '1';
					case cmd is
						when reqr =>
							EXE_ADDR <= start_addr;
							EXE_ADDR_FINISH <= finish_addr;
						when others =>
							EXE_ADDR <= addr;
					end case;
					EXE_ADDR <= addr;
					state <= execute_wait;
				when execute_wait =>
					EXE_START <= '0';
					if STR_FINISH = '1' then
						if EXE_FINISH = '1' then
							if cmd /= none then
								if EXE_RESULT_LEN /= 0 then
									STR <= EXE_RESULT;
									STR_LEN <= EXE_RESULT_LEN;
									str_start_inner <= '1';
								end if;
							end if;
							state <= require;
						end if;
					end if;
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;

