library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity db is
	port(
		clock_in : in std_logic;
		bounce_in : in std_logic;
		debounce_out : out std_logic
	);
end;

architecture bhv of db is

	type T_State is (PAUSE, TIMER, OUTPUT);
	signal current_state : T_State := PAUSE;
	signal next_state : T_State;
	
	signal bounce_last : std_logic;
	
	signal counter : integer range 0 to 99_999; -- 100.000 cycles
	signal counter_running : std_logic := '0';
	

begin

	process (clock_in, bounce_in) is
	begin
		if rising_edge(clock_in) then
		
			if bounce_in /= bounce_last and counter_running = '0' then
				counter <= 0;
				counter_running <= '1';
			else
				counter <= counter;
				counter_running <= '0';
				
			end if;
			bounce_last <= bounce_in;
			
			if counter_running = '1' then
				if counter = 99_999 then
					counter_running <= '0';
					debounce_out <= bounce_in;
				else
					counter_running <= '1';
					counter <= counter + 1;
				end if;
			end if;
		
		end if;
	end process;
end;