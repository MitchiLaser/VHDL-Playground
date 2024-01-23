library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fdiv is
	port(
		clock_in : in std_logic;
		clock_out : out std_logic
	);
end;

architecture behavior of fdiv is
	signal new_clock : std_logic := '0';
	signal counter : integer range 0 to 249999;  -- 50e6 / 200 = 250000
begin
	process (clock_in) is
	begin
		if rising_edge(clock_in) then
			if counter = 249999 then
				counter <= 0;
				new_clock <= not new_clock;  -- new_clock gets toggled with 200Hz -> 100Hz output frequency
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;
	clock_out <= new_clock;
end;
