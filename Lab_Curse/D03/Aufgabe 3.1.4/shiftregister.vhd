library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftregister is
	generic(
		Size : integer
	);
	port(
		X : in std_logic_vector(Size-1 downto 0);
		Y : out std_logic_vector(Size-1 downto 0);
		Clock : in std_logic;
		A : in std_logic_vector(1 downto 0)
	);
end;

architecture behavior of shiftregister is
	signal buff: std_logic_vector(Size-1 downto 0) := (others => '0');
begin
	process (clock, A, X) is
	begin
		if rising_edge(clock) then
		
			if A = "00" then
				-- do nothing
			elsif A = "01" then -- parallel input
				buff(Size-1 downto 0) <= X;
			elsif A = "10" then --shift up
				buff(Size-1 downto 1) <= buff(Size-2 downto 0);
				buff(0) <= buff(Size-1);
			elsif A = "11" then --shift down
				buff(Size-2 downto 0) <= buff(Size-1 downto 1);
				buff(Size-1) <= buff(0);
			end if;
			
		end if;
	end process;
	Y <= buff(Size-1 downto 0);
end;