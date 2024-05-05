library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bernoullitrial is
	generic(
		num_length : integer := 32;
		rate : integer range 0 to 31
	);
	port(
		-- Clock input
		clock : in std_logic;

		-- random number input
		rng : in std_logic_vector(num_length-1 downto 0);

		-- trigger output
		trig : out std_logic
	);
end entity;

architecture behavior of bernoullitrial is
	-- define mask as internal variable
	signal  mask : std_logic_vector(num_length-1 downto 0) := std_logic_vector(to_unsigned(rate - 1, num_length));

	-- the next state of the trigger is going to be determines within the arch and the output signal is overwritten after evaluation
	signal trig_next : std_logic := '0';
begin
	process (clock) is
	begin
		if rising_edge(clock) then
			if ( rng and mask ) = mask then
				trig_next <= '1';
			else
				trig_next <= '0';
			end if;
			--trig_next <= '1' when ( (rng and mask) =  mask ) else '0'; -- why is this not working?
		end if;
	end process;

	trig <= trig_next;
end architecture;
