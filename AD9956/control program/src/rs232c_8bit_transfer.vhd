----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:08:53 09/06/2019 
-- Design Name: 
-- Module Name:    rs232c_transfer - Behavioral 
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
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

entity rs232c_8bit_transfer is
	port (
		CLK		: in		std_logic;							-- �N���b�N�M������
		DSEND		: in		std_logic_vector(7 downto 0);	-- ���M�f�[�^
		SEND_RQ	: in		std_logic;							-- ���M���N�G�X�g
		TXD		: out		std_logic;							-- RS232C��TXD�M��
		SET_EN	: out		std_logic							-- �Z�b�g�\�M��
	);
end rs232c_8bit_transfer;

architecture Behavioral of rs232c_8bit_transfer is
	signal txd_inner		: std_logic := '1'; -- �ҋ@��Ԃ�1�ƂȂ��Ă���K�v������B
	type state_t is (standby, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, stop);
	signal state			: state_t := standby; -- ���݂̏��
begin
	TXD <= txd_inner;
	-- �N���b�N�̃C�x���g�Ŏ��s�����v���Z�X
	process(CLK)
	begin
		if falling_edge(CLK) then
			case state is
				when standby =>
					if SEND_RQ = '1' then
						txd_inner <= '0';		-- �ʐM�̊J�n��m�点��M��
						SET_EN <= '0';
						state <= bit0;
					else
						txd_inner <= '1';
						SET_EN <= '1';
					end if;
				when bit0 =>
					txd_inner <= DSEND(0);
					state <= bit1;
				when bit1 =>
					txd_inner <= DSEND(1);
					state <= bit2;
				when bit2 =>
					txd_inner <= DSEND(2);
					state <= bit3;
				when bit3 =>
					txd_inner <= DSEND(3);
					state <= bit4;
				when bit4 =>
					txd_inner <= DSEND(4);
					state <= bit5;
				when bit5 =>
					txd_inner <= DSEND(5);
					state <= bit6;
				when bit6 =>
					txd_inner <= DSEND(6);
					state <= bit7;
				when bit7 =>
					txd_inner <= DSEND(7);
					state <= stop;
				when stop =>
					txd_inner <= '1';
					SET_EN <= '1';
					state <= standby;
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;

