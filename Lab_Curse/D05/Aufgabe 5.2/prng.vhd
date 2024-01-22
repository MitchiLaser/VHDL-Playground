library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity prng is
	generic(
		Size : integer := 3
	);
	port(
		segment1, segment2 : out std_logic_vector(6	downto 0);
		button : in std_logic;
		clock_in : in std_logic
	);
end entity;


architecture bhv of prng is
	type T_State is (S0, S1, S2, S3, S4);
	signal current_state : T_State := S0;
	signal next_state : T_State;
	
	signal rand_values : std_logic_vector(2 downto 0);
	signal w0, w1 : std_logic_vector(3 downto 0) := (others => '0');
	
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
	
	component lfsr is
		generic(
			size : integer := 3
		);
		port(
			clock_in : in std_logic;
			parallel_out : out std_logic_vector(size-1 downto 0)
		);
	end component;

begin
	-- instantiate lfsr
	lfsr1: lfsr
	port map(
		clock_in => clock_in,
		parallel_out => rand_values
	);
	
	-- state machine
	process (clock_in) is
	begin
		if rising_edge(clock_in) then
			case current_state is
				when S0 =>
					w0 <= (others => '0');
					w1 <= (others => '0');
					next_state <= S1;
					
				when S1 =>
					w0 <= w0;
					w1 <= w1;
					if button = '0' then
						next_state <= S2;
					else
						next_state <= current_state;
					end if;
					
				when S2 =>
					w1 <= w1;
					if (rand_values /= "000") and (rand_values /= "111") then
						w0(2 downto 0) <= rand_values;
						w0(3) <= '0';
						next_state <= S3;
					else
						w0 <= w0;
						next_state <= current_state;
					end if;					
					
				when S3 =>
					w0 <= w0;
					w1 <= w1;
					if button = '1' then
						next_state <= S4;
					else
						next_state <= current_state;
					end if;
					
				when S4 =>
					w0 <= w0;
					if (rand_values /= "000") and (rand_values /= "111") then
						w1(2 downto 0) <= rand_values;
						w1(3) <= '0';
						next_state <= S1;
					else
						w1 <= w1;
						next_state <= current_state;
					end if;		
			end case;
		end if;
	end process;
	
	current_state <= next_state;
	segment1 <= not(bin2hex(w0));
	segment2 <= not(bin2hex(w1));
	
end architecture;