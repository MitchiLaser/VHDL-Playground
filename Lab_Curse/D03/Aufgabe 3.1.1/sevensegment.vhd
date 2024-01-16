library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevensegment is
	port(
		switches : in std_logic_vector(7 downto 0);
		led : out std_logic_vector(7 downto 0);
		segment1, segment2 : out std_logic_vector(6 downto 0)
	);
end;

architecture behavior of sevensegment is
	
	pure function bin2hex(signal bin: in std_logic_vector(3 downto 0)) return std_logic_vector is
		variable hex_out: std_logic_vector(6 downto 0) := (others => '0');
	begin
		case bin is
			when x"0" => hex_out := (6 => '0', others => '1');
			when x"1" => hex_out := "0000110";
			when x"2" => hex_out := "1011011";
			when x"3" => hex_out := "1001111";
			when x"4" => hex_out := "1100110";
			when x"5" => hex_out := "1101101";
			when x"6" => hex_out := (1 => '0', others => '1');
			when x"7" => hex_out := "0000111";
			when x"8" => hex_out := (others => '1');
			when x"9" => hex_out := (4 => '0', others => '1');
			when x"A" => hex_out := (3 => '0', others => '1');
			when x"B" => hex_out := "1111100";
			when x"C" => hex_out := "0111001";
			when x"D" => hex_out := "1011110";
			when x"E" => hex_out := "1111001";
			when x"F" => hex_out := "1110001";
		end case;
		return hex_out;
	end bin2hex;
	
begin
	led <= switches;
	segment1 <= not(bin2hex(switches(3 downto 0)));
	segment2 <= not(bin2hex(switches(7 downto 4)));
end;