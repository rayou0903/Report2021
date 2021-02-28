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
        SCLK         : in       STD_LOGIC;                         --�V���A���ʐM�p�N���b�N�M��(25MHz)
        RST          : in       STD_LOGIC;                         --���Z�b�g�M��
        RQ           : in       STD_LOGIC;                         --���N�G�X�g�M��(1�Ń��N�G�X�g)
        R_OR_W       : in       STD_LOGIC;                         --�ǂݏ������ʐM��(1�œǂݏo���C0�ŏ�������)
        AC_REG       : in       STD_LOGIC_VECTOR (4 downto 0);     --�A�N�Z�X���W�X�^
        DSEND        : in       STD_LOGIC_VECTOR (63 downto 0);    --���M�f�[�^
        SDIO         : out    STD_LOGIC;                         --�ʐM�M��
        CS           : out      STD_LOGIC;                         --�`�b�v�Z���N�g�M��(0�ŒʐM�\)
        IO_UPDATE    : out      STD_LOGIC;                         --�f�[�^�X�V�M��(1�ōX�V)
        DGET         : out      STD_LOGIC_VECTOR (63 downto 0);    --��M�f�[�^
        BUSY         : out      STD_LOGIC                          --�r�W�[�M��(1�Ńr�W�[���)
    );
end AD9956_com;

architecture Behavioral of AD9956_com is
    -- state transition
    type state_t is (IDLE, INSTRUCTION, SEND, UPDATE);
    signal state : state_t := IDLE;
	
    --innner signal
    signal sdio_inner    : std_logic_vector(63 downto 0) := (others => '0');    --����SDIO
    signal bit_cnt       : integer := 0;                                        --�r�b�g�J�E���^
    signal bit_len       : integer := 32;                                       --���M�r�b�g��(�����l��CFR1)
	
begin
    --SDIO <= sdio_inner(63);
    process(SCLK, RST, RQ) begin
        --������
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
                        BUSY <= '1';    --�r�W�[���
                        --�n�߂�8bit�ȊO�́C0�Ŗ��߂�
                        sdio_inner <= R_OR_W & "00" & AC_REG & (63-8 downto 0 => '0');
                        --�r�b�g���̕ύX
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

                --���߃T�C�N��
                when INSTRUCTION =>
                    CS   <= '0';
                    SDIO <= sdio_inner(63);
                    if(bit_cnt = 7) then
                        bit_cnt <= 0;    --�r�b�g�J�E���^�����Z�b�g
                        --��ԑJ��
                        if(R_OR_W = '0') then
                            sdio_inner <= DSEND;
                            state      <= SEND;
                        else
                            state <= IDLE;
                        end if;
                    else
                        bit_cnt    <= bit_cnt + 1;                      --�r�b�g�J�E���^��1���₷
                        sdio_inner <= sdio_inner(62 downto 0) & '0';    --1�r�b�g���V�t�g
                    end if;
					
                --�f�[�^�]���T�C�N��
                when SEND =>
                    SDIO <= sdio_inner(63);
                    if(bit_cnt = bit_len - 1) then
                        bit_cnt <= 0;    --�r�b�g�J�E���^�����Z�b�g
                        state   <= UPDATE;
                    else
                        bit_cnt    <= bit_cnt + 1;                      --�r�b�g�J�E���^��1���₷
                        sdio_inner <= sdio_inner(62 downto 0) & '0';    --1�r�b�g���V�t�g
                    end if;

                --I/O�o�b�t�@����������W�X�^�Ƀf�[�^��]������
                when UPDATE =>
                    CS        <= '1';    --���M����
                    BUSY      <= '0';    --�r�W�[��Ԃ��畜�A
                    IO_UPDATE <= '1';    --�X�V
                    state     <= IDLE;

                when others => null;
            end case;
        end if;
    end process;
end Behavioral;