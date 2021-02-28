----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:36:24 02/12/2021 
-- Design Name: 
-- Module Name:    AD9956_ctrl - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AD9956_ctrl is
    Port ( 
        CLK          : in       STD_LOGIC;    --入力クロック信号
		  CLK_2        : in       STD_LOGIC;
        RST          : in       STD_LOGIC;    --Papilioリセット信号(1でリセット)
        REQ_DDS      : in       STD_LOGIC;    --DDS読み書きリクエスト信号(1でリクエスト)
		  DATA64			: in       STD_LOGIC_VECTOR(63 downto 0);  --書き込みデータ(PCR用，64bit)
--        R_OR_W       : in       STD_LOGIC;    --読み書き識別信号(1で読み出し，0で書き込み，内部信号で扱う)
        IO_RESET     : out      STD_LOGIC;    --9(1でリセット)
        RESET        : out      STD_LOGIC;    --10(1でリセット)
        SDIO         : out    STD_LOGIC;    --14
        SCLK         : out    STD_LOGIC;    --15(シリアル通信用クロック信号 1MHz)
        CS           : out      STD_LOGIC;    --16(0で通信可能)
        IO_UPDATE    : out      STD_LOGIC;    --20(1で更新)
        PSEL         : out    STD_LOGIC_VECTOR(2 downto 0);    --Profile Select(21 to 23)
		  RECEIVE      : out      STD_LOGIC    --0でビジー状態
    );
end AD9956_ctrl;

architecture RTL of AD9956_ctrl is
    --Clock Generator
--    component clk_generator
--        port(
--            CLK_IN    : in  std_logic;    --入力クロック信号(32MHz)
--            SCLK      : out std_logic     --シリアル通信用クロック信号(1MHz)
--        );
--    end component;

    component AD9956_com
        port(
            SCLK         : in       std_logic;                        --シリアル通信用クロック信号(1MHz)
            RST          : in       std_logic;                        --リセット信号
            RQ           : in       std_logic;                        --リクエスト信号(1でリクエスト)
            R_OR_W       : in       std_logic;                        --読み書き識別信号(1で読み出し，0で書き込み，とりあえず使用しない)
            AC_REG       : in       std_logic_vector(4 downto 0);     --アクセスレジスタ
            DSEND        : in       std_logic_vector(63 downto 0);    --送信データ
            SDIO         : out    std_logic;                        --通信信号
            CS           : out      std_logic;                        --チップセレクト信号(0で通信可能)
            IO_UPDATE    : out      std_logic;                        --データ更新信号(1で更新)
            DGET         : out      std_logic_vector(63 downto 0);    --受信データ
            BUSY         : out      std_logic                         --ビジー信号(1でビジー状態)
        );
    end component;
	
	
    -- state transition
    type state_t is (IDLE, REQUEST, STANDBY);
    signal state : state_t := IDLE;
	
    --inner signal
    signal rq_dds      : std_logic := '0';    --DDS読み書きリクエスト信号(serial.vhdとdds_communication.vhdでのリクエスト信号は反転しているので注意)
    signal rq_pc       : std_logic := '0';    --PC送信リクエスト信号
    signal dsend       : std_logic_vector(63 downto 0) := (others => '0');
    signal busy_dds    : std_logic;
	 signal r_or_w      : std_logic := '0';
	
    --send data(後で外部アクセスできるようにするかも)
    signal ac_reg    : std_logic_vector(4 downto 0)     := "00110";
    signal cfr1      : std_logic_vector(31 downto 0)    := "00000000000000000000000000000000";
    --signal cfr2      : std_logic_vector(39 downto 0)    := "0000000000000000011110000000000000000111";  --R=8
	 signal cfr2      : std_logic_vector(39 downto 0)    := "0000000000000000010110000000000000000111";  --R=4
	 --signal cfr2      : std_logic_vector(39 downto 0)    := "0000000000000000001110000000000000000111";  --R=2
	 --signal cfr2      : std_logic_vector(39 downto 0)    := "0000000000000000000110000000000000000111";  --R=1
    signal rdftw     : std_logic_vector(23 downto 0)    := "000000000000000000000000";    --使用しない
    signal fdftw     : std_logic_vector(23 downto 0)    := "000000000000000000000000";    --使用しない
    signal rsrr      : std_logic_vector(15 downto 0)    := "0000000000000000";            --使用しない
    signal fsrr      : std_logic_vector(15 downto 0)    := "0000000000000000";            --使用しない
    signal pcr0      : std_logic_vector(63 downto 0)    := "0000000000000000011101100110011001100110011001100110011001100110";
	 signal pcr1      : std_logic_vector(63 downto 0)    := "0000100000000000000101000111101011100001010001111010111000010100";
    signal pcr2      : std_logic_vector(63 downto 0)    := "0001000000000000000101000111101011100001010001111010111000010100";
    signal pcr3      : std_logic_vector(63 downto 0)    := "0010000000000000000101000111101011100001010001111010111000010100";
    signal pcr4      : std_logic_vector(63 downto 0)    := "0000000000000000000010010100111100100000100101001111001000001001";
    signal pcr5      : std_logic_vector(63 downto 0)    := "0000000000000000000010110010101111000000101100101011110000001011";
    signal pcr6      : std_logic_vector(63 downto 0)    := "0000000000000000000011010000100001100000110100001000011000001101";
    signal pcr7      : std_logic_vector(63 downto 0)    := "0000000000000000000011101110010100000000111011100101000000001110";
	
    --clock
    signal clk_inner_slow    : std_logic;
    signal SCLK_slow         : std_logic;
    signal cnt               : std_logic_vector(21 downto 0) := (others => '0');
    signal cnt1              : std_logic_vector(12 downto 0) := (others => '0');
	
begin
    --Clock Generator
--    clk_gen : clk_generator
--        port map(
--            CLK_IN    => CLK,    --クロック信号(32MHz)
--            SCLK      => SCLK    --シリアルクロック(1MHz)
--        );

    dds_com : AD9956_com
        port map(
            SCLK         => CLK,
            RST          => RST,
            RQ           => REQ_DDS,
            R_OR_W       => r_or_w,  --内部信号で扱う(書き込み固定)
            AC_REG       => ac_reg,
            DSEND        => DATA64,  --dsend -> DATA64に変更
            SDIO         => SDIO,
            CS           => CS,
            IO_UPDATE    => IO_UPDATE,
            DGET         => open,
            BUSY         => busy_dds
		);
	 
	 SCLK    <= CLK;
	 RECEIVE <= not busy_dds;
	
    process(CLK, RST, REQ_DDS) begin
        IO_RESET    <= '0';
        RESET       <= '0';
		
        --初期化(起動時必ず行う)
        if(RST = '1') then
            IO_RESET <= '1';
            RESET    <= '1';
            PSEL     <= "000";
				ac_reg   <= "00110";  --"00000" -> "00110"に変更

        elsif rising_edge(CLK) then
            case state is
                when IDLE =>
                    --dsend <= cfr1 & (63-32 downto 0 => '0');
						  cnt	  <= cnt + 1;
                    if(REQ_DDS = '1') then
                        PSEL   <= "000";
								ac_reg <= "00110";  --"00000" -> "00110"に変更
                        cnt    <= (others => '0');
								rq_dds <= '1';
                        state  <= STANDBY;

                    --レジスタの切り替え(とりあえず使用しない)
--                    elsif(cnt = "1111111111111111111111") then
--                        --if(PSEL = "110") then
--                        if(PSEL = "000") then
--                            PSEL <= "000";
--                        else
--                            PSEL <= PSEL + 1;
--                        end if;
                    end if;
				
--                when REQUEST =>  --省略するかも
--                    --dds_communication.vhdにリクエスト信号を送る
--                    --繰り返し送信するのを防ぐため，タクトスイッチを離した瞬間にリクエストを送るようにしている
--                    if(REQ_DDS = '0') then
--                        rq_dds <= '1';
--                        state  <= STANDBY;
--                    end if;
				
                when STANDBY =>
                    rq_dds <= '0';
                    if (busy_dds = '0' and rq_dds = '0') then					
                        --送信データの更新(次回送信するデータ)
--                        if (ac_reg = "00000") then
--                            dsend <= cfr2 & (63-40 downto 0 => '0');
--                        elsif (ac_reg = "00001") then    --pcr0にジャンプ
--                            --dsend <= fdftw & (63-24 downto 0 => '0');
--                            dsend <= pcr0;
--                        elsif (ac_reg = "00010") then    --使用しない
--                            dsend <= fdftw & (63-24 downto 0 => '0');
--                        elsif (ac_reg = "00011") then    --使用しない
--                            dsend <= rsrr & (63-16 downto 0 => '0');
--                        elsif (ac_reg = "00100") then    --使用しない
--                            dsend <= fsrr & (63-16 downto 0 => '0');
--                        elsif (ac_reg = "00101") then    --使用しない
--                            dsend <= pcr0;
--                        elsif (ac_reg = "00110") then
--                            dsend <= pcr1;
--                        elsif (ac_reg = "00111") then
--                            dsend <= pcr2;
--                        elsif (ac_reg = "01000") then
--                            dsend <= pcr3;
--                        elsif (ac_reg = "01001") then
--                            dsend <= pcr4;
--                        elsif (ac_reg = "01010") then
--                            dsend <= pcr5;
--                        elsif (ac_reg = "01011") then
--                            dsend <= pcr6;
--                        elsif (ac_reg = "01100") then
--                            dsend <= pcr7;
--                        else
--                            dsend <= (others => '0');
--                        end if;

                        --アクセスレジスタの更新(次回アクセスするレジスタ) RDFTW~FSRRは省略
--                        if (ac_reg = "00001") then
--                            ac_reg <= "00110";
--                        else
--                            ac_reg <= ac_reg + 1;
--                        end if;

                        --アクセスレジスタが0x0Eになったら書き込み完了
--                        if (ac_reg = "01101") then
--                            state <= IDLE;
--                        else
--                            state <= REQUEST;
--                        end if;
								state <= IDLE;  --リクエスト一回につき，書き込みは1回だけ有効
                    end if;

                when others => null;
            end case;
        end if;
    end process;
end RTL;