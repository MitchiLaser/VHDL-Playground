library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rippleadder is
	generic(
		Size : integer := 5
	);
	port(
		a, b : in std_logic_vector(Size-1 downto 0);
		segment1, segment2 : out std_logic_vector(6 downto 0);
		cin : in std_logic;
		cout : out std_logic
	);
end;

architecture bhv of rippleadder is
	component fulladder is
		port(
			a, b, c_in : in std_logic;
			s, c_out : out std_logic
		);
	end component;
	
	signal c : std_logic_vector(Size downto 0);
	signal sum : std_logic_vector(Size-1 downto 0);
	signal sum_seg2 : std_logic_vector(3 downto 0) := (others => '0');
	
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

	gen: for i in 0 to Size-1 generate
		adder: fulladder port map(
				a => a(i),
				b => b(i),
				c_in => c(i),
				s => sum(i),
				c_out => c(i+1)
			);
	end generate;
	c(0) <= not(cin);
	cout <= c(Size);
	
	sum_seg2 <= (0 => sum(4), others => '0');
	
	segment1 <= not(bin2hex(sum(3 downto 0)));
	segment2 <= not(bin2hex( sum_seg2 ));
end;