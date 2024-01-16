library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftregister is
	generic(
		Size : integer := 8
	);
	port(
		X : in std_logic_vector(Size-1 downto 0);
		Y : out std_logic_vector(Size-1 downto 0);
		Clock : in std_logic;
		A : in std_logic_vector(1 downto 0);
		serout : out std_logic;
		serin : in std_logic
	);
end;

architecture behavior of shiftregister is
	signal buff: std_logic_vector(Size-1 downto 0) := (others => '0');
	signal buff_out : std_logic := '0';
begin
	process (clock, A, serin, X) is
	begin
		if rising_edge(clock) then
		
			if A = "00" then
				-- do nothing
			elsif A = "01" then -- parallel input
				buff(Size-1 downto 0) <= X;
				buff_out <= buff_out;
			elsif A = "10" then --shift up
				buff_out <= buff(Size-1);
				buff(Size-1 downto 1) <= buff(Size-2 downto 0);
				buff(0) <= serin;
			elsif A = "11" then --shift down
				buff_out <= buff(0);
				buff(Size-2 downto 0) <= buff(Size-1 downto 1);
				buff(Size-1) <= serin;
			end if;
			
		end if;
	end process;
	Y <= buff(Size-1 downto 0);
	serout <= buff_out;
end;