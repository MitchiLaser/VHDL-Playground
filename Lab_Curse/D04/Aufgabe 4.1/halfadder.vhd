library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity halfadder is
	port(
		a, b: in std_logic;
		s, c_out : out std_logic
	);
end;

architecture bhv of halfadder is
begin
	s <= a xor b;
	c_out <= a and b;
end;