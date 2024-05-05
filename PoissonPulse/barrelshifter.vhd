library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity barrelshifter is
	generic(
		reg_length : integer := 95;
		rng_length : integer := 32
	);
	port(
		clock : in std_logic;
		rng_out : out std_logic_vector(rng_length-1 downto 0)
	);
end entity;

architecture behavior of barrelshifter is
	signal LFSR : std_logic_vector(reg_length downto 0) := std_logic_vector(to_unsigned(1234, reg_length + 1)); -- random chosen start value
begin
	process (clock) is
	begin
		if rising_edge(clock) then
			for i in 0 to rng_length-1 loop
				LFSR(rng_length-1) <= LFSR(reg_length-1-i) xor LFSR(reg_length-2-i) xor LFSR((reg_length/2)) xor LFSR((reg_length/2)-2);
			end loop;
		end if;
	end process;

	rng_out <= LFSR(rng_length-1 downto 0);
end architecture;
