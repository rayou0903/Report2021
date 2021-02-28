library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ascii_pac is
	type ascii is ('0','1','2','3','4','5','6','7','8','9',
			'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
			':','?','!','-','(',')',' ',lf,cr,'#','@','<','>');
	type ascii_vector is array (Natural range <>)of ascii;
	
	-- アスキーコードの対応
	constant ac_0 : std_logic_vector(7 downto 0) :=X"30";
	constant ac_1 : std_logic_vector(7 downto 0) :=X"31";
	constant ac_2 : std_logic_vector(7 downto 0) :=X"32";
	constant ac_3 : std_logic_vector(7 downto 0) :=X"33";
	constant ac_4 : std_logic_vector(7 downto 0) :=X"34";
	constant ac_5 : std_logic_vector(7 downto 0) :=X"35";
	constant ac_6 : std_logic_vector(7 downto 0) :=X"36";
	constant ac_7 : std_logic_vector(7 downto 0) :=X"37";
	constant ac_8 : std_logic_vector(7 downto 0) :=X"38";
	constant ac_9 : std_logic_vector(7 downto 0) :=X"39";
	
	constant ac_a : std_logic_vector(7 downto 0) :=X"61";
	constant ac_b : std_logic_vector(7 downto 0) :=X"62";
	constant ac_c : std_logic_vector(7 downto 0) :=X"63";
	constant ac_d : std_logic_vector(7 downto 0) :=X"64";
	constant ac_e : std_logic_vector(7 downto 0) :=X"65";
	constant ac_f : std_logic_vector(7 downto 0) :=X"66";
	constant ac_g : std_logic_vector(7 downto 0) :=X"67";
	constant ac_h : std_logic_vector(7 downto 0) :=X"68";
	constant ac_i : std_logic_vector(7 downto 0) :=X"69";
	constant ac_j : std_logic_vector(7 downto 0) :=X"6a";
	constant ac_k : std_logic_vector(7 downto 0) :=X"6b";
	constant ac_l : std_logic_vector(7 downto 0) :=X"6c";
	constant ac_m : std_logic_vector(7 downto 0) :=X"6d";
	constant ac_n : std_logic_vector(7 downto 0) :=X"6e";
	constant ac_o : std_logic_vector(7 downto 0) :=X"6f";
	constant ac_p : std_logic_vector(7 downto 0) :=X"70";
	constant ac_q : std_logic_vector(7 downto 0) :=X"71";
	constant ac_r : std_logic_vector(7 downto 0) :=X"72";
	constant ac_s : std_logic_vector(7 downto 0) :=X"73";
	constant ac_t : std_logic_vector(7 downto 0) :=X"74";
	constant ac_u : std_logic_vector(7 downto 0) :=X"75";
	constant ac_v : std_logic_vector(7 downto 0) :=X"76";
	constant ac_w : std_logic_vector(7 downto 0) :=X"77";
	constant ac_x : std_logic_vector(7 downto 0) :=X"78";
	constant ac_y : std_logic_vector(7 downto 0) :=X"79";
	constant ac_z : std_logic_vector(7 downto 0) :=X"7a";
	
	constant ac_ex : std_logic_vector(7 downto 0) :=X"21";
	constant ac_qu : std_logic_vector(7 downto 0) :=X"3f";
	constant ac_hy : std_logic_vector(7 downto 0) :=X"2d";
	constant ac_co : std_logic_vector(7 downto 0) :=X"3a";
	constant ac_br1 : std_logic_vector(7 downto 0) :=X"28";
	constant ac_br2 : std_logic_vector(7 downto 0) :=X"29";
	constant ac_sp	:	std_logic_vector(7 downto 0) :=X"20";
	constant ac_lf	:	std_logic_vector(7 downto 0) :=X"0a";
	constant ac_cr	:	std_logic_vector(7 downto 0) :=X"0d";
	constant ac_sharp : std_logic_vector(7 downto 0) := X"23";
	constant ac_at : std_logic_vector(7 downto 0) := X"40";
	constant ac_lt : std_logic_vector(7 downto 0) := X"3c";
	constant ac_gt : std_logic_vector(7 downto 0) := X"3e";
	-- end of アスキーコードの対応
	
	-- サブタイプ
	subtype ac is ascii;
	subtype ac16 is ascii_vector(0 to 16-1);
	subtype logic8 is std_logic_vector(8-1 downto 0);
	subtype logic4 is std_logic_vector(4-1 downto 0);
	subtype logic64 is std_logic_vector(64-1 downto 0);
	
	-- 関数の宣言
	
	-- アスキーコードを8bitデータに変換
	function ascii_decoder (ac : ac) return logic8;
	
	-- 8bitデータをアスキーコードに変換
	function ascii_encoder (bin : logic8) return ac;
	
	-- 16進アスキーコード=>std_logic_vector(3 downto 0)の変換
	function hex2vec (ac : ac) return logic4;

	-- 16進アスキーコード<=std_logic_vectorの変換
	function vec2hex (hex : logic4) return ascii;
	
	-- 16進アスキーコード文字列ascii_vector(0 to 15)=>std_logic_vector(63 downto 0)の変換
	function datahex2vec (acv : ac16) return logic64;

	-- 16進アスキーコード文字列ascii_vector(0 to 15)<=std_logic_vector(63 downto 0)の変換
	function vec2datahex (data : logic64) return ac16;

end ascii_pac;

package body ascii_pac is
	-- デコーダ
	function ascii_decoder (ac : ac) return logic8 is
		variable ret : logic8;
	begin
		case ac is
			when '0' => ret := ac_0;
			when '1' => ret := ac_1;
			when '2' => ret := ac_2;
			when '3' => ret := ac_3;
			when '4' => ret := ac_4;
			when '5' => ret := ac_5;
			when '6' => ret := ac_6;
			when '7' => ret := ac_7;
			when '8' => ret := ac_8;
			when '9' => ret := ac_9;
			when 'a' => ret := ac_a;
			when 'b' => ret := ac_b;
			when 'c' => ret := ac_c;
			when 'd' => ret := ac_d;
			when 'e' => ret := ac_e;
			when 'f' => ret := ac_f;
			when 'g' => ret := ac_g;
			when 'h' => ret := ac_h;
			when 'i' => ret := ac_i;
			when 'j' => ret := ac_j;
			when 'k' => ret := ac_k;
			when 'l' => ret := ac_l;
			when 'm' => ret := ac_m;
			when 'n' => ret := ac_n;
			when 'o' => ret := ac_o;
			when 'p' => ret := ac_p;
			when 'q' => ret := ac_q;
			when 'r' => ret := ac_r;
			when 's' => ret := ac_s;
			when 't' => ret := ac_t;
			when 'u' => ret := ac_u;
			when 'v' => ret := ac_v;
			when 'w' => ret := ac_w;
			when 'x' => ret := ac_x;
			when 'y' => ret := ac_y;
			when 'z' => ret := ac_z;
			when '!' => ret := ac_ex;
			when '?' => ret := ac_qu;
			when '-' => ret := ac_hy;
			when ':' => ret := ac_co;
			when '(' => ret := ac_br1;
			when ')' => ret := ac_br2;
			when ' ' => ret := ac_sp;
			when lf 	=> ret := ac_lf;
			when cr 	=> ret := ac_cr;
			when '#' => ret := ac_sharp;
			when '@' => ret := ac_at;
			when '<' => ret := ac_lt;
			when '>' => ret := ac_gt;
			when others => null;
		end case;
		return ret;
	end ascii_decoder;
	
	-- エンコーダ
	function ascii_encoder (bin : logic8) return ac is
		variable ret : ac;
	begin
		case bin is
			when ac_0 => ret := '0';
			when ac_1 => ret := '1';
			when ac_2 => ret := '2';
			when ac_3 => ret := '3';
			when ac_4 => ret := '4';
			when ac_5 => ret := '5';
			when ac_6 => ret := '6';
			when ac_7 => ret := '7';
			when ac_8 => ret := '8';
			when ac_9 => ret := '9';

			when ac_a => ret := 'a';
			when ac_b => ret := 'b';
			when ac_c => ret := 'c';
			when ac_d => ret := 'd';
			when ac_e => ret := 'e';
			when ac_f => ret := 'f';
			when ac_g => ret := 'g';
			when ac_h => ret := 'h';
			when ac_i => ret := 'i';
			when ac_j => ret := 'j';
			when ac_k => ret := 'k';
			when ac_l => ret := 'l';
			when ac_m => ret := 'm';
			when ac_n => ret := 'n';
			when ac_o => ret := 'o';
			when ac_p => ret := 'p';
			when ac_q => ret := 'q';
			when ac_r => ret := 'r';
			when ac_s => ret := 's';
			when ac_t => ret := 't';
			when ac_u => ret := 'u';
			when ac_v => ret := 'v';
			when ac_w => ret := 'w';
			when ac_x => ret := 'x';
			when ac_y => ret := 'y';
			when ac_z => ret := 'z';

			when ac_ex => ret := '!';
			when ac_qu => ret := '?';
			when ac_hy => ret := '-';
			when ac_co => ret := ':';
			when ac_br1 => ret := '(';
			when ac_br2 => ret := ')';
			when ac_sp => ret := ' ';

			when ac_cr => ret := cr;
			when ac_lf => ret := lf;
			when ac_sharp => ret := '#';
			when ac_at => ret := '@';
			when ac_lt => ret := '<';
			when ac_gt => ret := '>';
			when others => null;
		end case;
		return ret;
	end ascii_encoder;
	
	-- 16進アスキーコード=>std_logic_vector(3 downto 0)の変換
	function hex2vec(ac : ascii) return logic4 is
		variable ret	: logic4;
	begin
		case ac is
			when '0' => ret := "0000";
			when '1' => ret := "0001";
			when '2' => ret := "0010";
			when '3' => ret := "0011";
			when '4' => ret := "0100";
			when '5' => ret := "0101";
			when '6' => ret := "0110";
			when '7' => ret := "0111";
			when '8' => ret := "1000";
			when '9' => ret := "1001";
--			when 'A' => ret := "1010";
			when 'a' => ret := "1010";
--			when 'B' => ret := "1011";
			when 'b' => ret := "1011";
--			when 'C' => ret := "1100";
			when 'c' => ret := "1100";
--			when 'D' => ret := "1101";
			when 'd' => ret := "1101";
--			when 'E' => ret := "1110";
			when 'e' => ret := "1110";
--			when 'F' => ret := "1111";
			when 'f' => ret := "1111";
			when others => ret := "0000";
		end case;
		return ret;
	end hex2vec;
	
	-- 16進アスキーコード<=std_logic_vectorの変換
	function vec2hex(hex : logic4) return ascii is
		variable ret	: ascii;
	begin
		case hex is
			when "0000" => ret := '0';
			when "0001" => ret := '1';
			when "0010" => ret := '2';
			when "0011" => ret := '3';
			when "0100" => ret := '4';
			when "0101" => ret := '5';
			when "0110" => ret := '6';
			when "0111" => ret := '7';
			when "1000" => ret := '8';
			when "1001" => ret := '9';
			when "1010" => ret := 'a';
			when "1011" => ret := 'b';
			when "1100" => ret := 'c';
			when "1101" => ret := 'd';
			when "1110" => ret := 'e';
			when "1111" => ret := 'f';
			when others => ret := '-';
		end case;
		return ret;
	end vec2hex;
	
	-- 16進アスキーコード文字列ascii_vector(0 to 15)=>std_logic_vector(63 downto 0)の変換
	function datahex2vec (acv : ac16) return logic64 is
		variable ret : logic64;
	begin
		ret(63 downto 60) := hex2vec(acv(0));
		ret(59 downto 56) := hex2vec(acv(1));
		ret(55 downto 52) := hex2vec(acv(2));
		ret(51 downto 48) := hex2vec(acv(3));
		ret(47 downto 44) := hex2vec(acv(4));
		ret(43 downto 40) := hex2vec(acv(5));
		ret(39 downto 36) := hex2vec(acv(6));
		ret(35 downto 32) := hex2vec(acv(7));
		ret(31 downto 28) := hex2vec(acv(8));
		ret(27 downto 24) := hex2vec(acv(9));
		ret(23 downto 20) := hex2vec(acv(10));
		ret(19 downto 16) := hex2vec(acv(11));
		ret(15 downto 12) := hex2vec(acv(12));
		ret(11 downto 8) := hex2vec(acv(13));
		ret(7 downto 4) := hex2vec(acv(14));
		ret(3 downto 0) := hex2vec(acv(15));
		return ret;
	end datahex2vec;

	-- 16進アスキーコード文字列ascii_vector(0 to 15)<=std_logic_vector(63 downto 0)の変換
	function vec2datahex (data : logic64) return ac16 is
		variable ret : ac16;
	begin
		ret(0) := vec2hex(data(63 downto 60));
		ret(1) := vec2hex(data(59 downto 56));
		ret(2) := vec2hex(data(55 downto 52));
		ret(3) := vec2hex(data(51 downto 48));
		ret(4) := vec2hex(data(47 downto 44));
		ret(5) := vec2hex(data(43 downto 40));
		ret(6) := vec2hex(data(39 downto 36));
		ret(7) := vec2hex(data(35 downto 32));
		ret(8) := vec2hex(data(31 downto 28));
		ret(9) := vec2hex(data(27 downto 24));
		ret(10) := vec2hex(data(23 downto 20));
		ret(11) := vec2hex(data(19 downto 16));
		ret(12) := vec2hex(data(15 downto 12));
		ret(13) := vec2hex(data(11 downto 8));
		ret(14) := vec2hex(data(7 downto 4));
		ret(15) := vec2hex(data(3 downto 0));
		return ret;
	end vec2datahex;
end ascii_pac;
