library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
	port(
		clock_in : in std_logic;
		button_1, button_2 : in std_logic;
		segment1, segment2 : out std_logic_vector(6 downto 0)
	);
end;

architecture bhv of debounce is
	
	signal counter1 : integer range 0 to 15 := 0;
	signal counter1_value : std_logic_vector(3 downto 0);
	signal counter2 : integer range 0 to 15 := 0;
	signal counter2_value : std_logic_vector(3 downto 0);
	
	signal button_1_prev : std_logic := '0';
	signal button_2_prev : std_logic := '0';
	
	signal button2_db_sig : std_logic;
	
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
	
	component db is
		port(
			clock_in : in std_logic;
			bounce_in : in std_logic;
			debounce_out : out std_logic
		);
	end component;
	
begin

	-- button 1: not debounced
	process (clock_in) is
	begin
		if rising_edge(clock_in) then
			if button_1 /= button_1_prev then
				counter1 <= counter1 + 1;
			end if;
			button_1_prev <= button_1;
		end if;
	end process;
	
	counter1_value <= std_logic_vector(to_unsigned(counter1, 4));
	segment1 <= not(bin2hex(counter1_value));
	
	
	-- button 2: debounced
	
	db_inst : db
	port map(
		clock_in => clock_in,
		bounce_in => button_2,
		debounce_out => button2_db_sig
	);
	
	process (clock_in) is
	begin
		if rising_edge(clock_in) then
			if button2_db_sig /= button_2_prev then
				counter2 <= counter2 + 1;
			end if;
			button_2_prev <= button2_db_sig;
		end if;
	end process;
	
	counter2_value <= std_logic_vector(to_unsigned(counter2, 4));
	segment2 <= not(bin2hex(counter2_value));

end;