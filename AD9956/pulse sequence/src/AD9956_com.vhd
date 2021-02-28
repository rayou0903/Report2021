----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:53:53 02/12/2021 
-- Design Name: 
-- Module Name:    AD9956_com - Behavioral 
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

entity AD9956_com is
    Port ( 
        SCLK         : in       STD_LOGIC;                         --シリアル通信用クロック信号(25MHz)
        RST          : in       STD_LOGIC;                         --リセット信号
        RQ           : in       STD_LOGIC;                         --リクエスト信号(1でリクエスト)
        R_OR_W       : in       STD_LOGIC;                         --読み書き識別信号(1で読み出し，0で書き込み)
        AC_REG       : in       STD_LOGIC_VECTOR (4 downto 0);     --アクセスレジスタ
        DSEND        : in       STD_LOGIC_VECTOR (63 downto 0);    --送信データ
        SDIO         : out    STD_LOGIC;                         --通信信号
        CS           : out      STD_LOGIC;                         --チップセレクト信号(0で通信可能)
        IO_UPDATE    : out      STD_LOGIC;                         --データ更新信号(1で更新)
        DGET         : out      STD_LOGIC_VECTOR (63 downto 0);    --受信データ
        BUSY         : out      STD_LOGIC                          --ビジー信号(1でビジー状態)
    );
end AD9956_com;

architecture Behavioral of AD9956_com is
    -- state transition
    type state_t is (IDLE, INSTRUCTION, SEND, UPDATE);
    signal state : state_t := IDLE;
	
    --innner signal
    signal sdio_inner    : std_logic_vector(63 downto 0) := (others => '0');    --内部SDIO
    signal bit_cnt       : integer := 0;                                        --ビットカウンタ
    signal bit_len       : integer := 32;                                       --送信ビット長(初期値はCFR1)
	
begin
    --SDIO <= sdio_inner(63);
    process(SCLK, RST, RQ) begin
        --初期化
        if(RST = '1') then
            CS         <= '1';
            IO_UPDATE  <= '0';
            DGET       <= (others => '0');
            BUSY       <= '0';
            sdio_inner <= (others => '0');
            bit_cnt    <= 0;
            bit_len    <= 32;
            state      <= IDLE;

        elsif rising_edge(SCLK) then
            case state is
                when IDLE =>
                    if(RQ = '1') then
                        BUSY <= '1';    --ビジー状態
                        --始めの8bit以外は，0で埋める
                        sdio_inner <= R_OR_W & "00" & AC_REG & (63-8 downto 0 => '0');
                        --ビット長の変更
                        if(AC_REG = "00000")then
                            bit_len <= 32;
                        elsif(AC_REG = "00001")then
                            bit_len <= 40;
                        elsif(AC_REG = "00010" or AC_REG = "00011")then
                            bit_len <= 24;
                        elsif(AC_REG = "00100" or AC_REG = "00101")then
                            bit_len <= 16;
                        else
                            bit_len <= 64;
                        end if;
                            state <= INSTRUCTION;
                    else
                        CS         <= '1';
                        SDIO       <= 'Z';
                        IO_UPDATE  <= '0';
                        BUSY       <= '0';
                        sdio_inner <= (others => '0');
                    end if;

                --命令サイクル
                when INSTRUCTION =>
                    CS   <= '0';
                    SDIO <= sdio_inner(63);
                    if(bit_cnt = 7) then
                        bit_cnt <= 0;    --ビットカウンタをリセット
                        --状態遷移
                        if(R_OR_W = '0') then
                            sdio_inner <= DSEND;
                            state      <= SEND;
                        else
                            state <= IDLE;
                        end if;
                    else
                        bit_cnt    <= bit_cnt + 1;                      --ビットカウンタを1増やす
                        sdio_inner <= sdio_inner(62 downto 0) & '0';    --1ビット左シフト
                    end if;
					
                --データ転送サイクル
                when SEND =>
                    SDIO <= sdio_inner(63);
                    if(bit_cnt = bit_len - 1) then
                        bit_cnt <= 0;    --ビットカウンタをリセット
                        state   <= UPDATE;
                    else
                        bit_cnt    <= bit_cnt + 1;                      --ビットカウンタを1増やす
                        sdio_inner <= sdio_inner(62 downto 0) & '0';    --1ビット左シフト
                    end if;

                --I/Oバッファから内部レジスタにデータを転送する
                when UPDATE =>
                    CS        <= '1';    --送信完了
                    BUSY      <= '0';    --ビジー状態から復帰
                    IO_UPDATE <= '1';    --更新
                    state     <= IDLE;

                when others => null;
            end case;
        end if;
    end process;
end Behavioral;