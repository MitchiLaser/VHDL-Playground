library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library halfadder;
use halfadder.halfadder;

entity fulladder is
	port(
		a, b, c_in : in std_logic;
		s, c_out : out std_logic
	);
end;

architecture bhv of fulladder is
	component halfadder is
		port(
			a, b: in std_logic;
			s, c_out : out std_logic
		);
	end component;
	
	signal first_adder_sum, first_adder_carry, second_adder_carry : std_logic;
begin
	H1 : halfadder
	port map(
		a => a,
		b => b,
		s => first_adder_sum,
		c_out => first_adder_carry
	);
	
	H2 : halfadder
	port map(
		a => first_adder_sum,
		b => c_in,
		s => s,
		c_out => second_adder_carry
	);
	
	c_out <= first_adder_carry or second_adder_carry;
end;