library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity poissonpulse is
	generic(
		rng_length : integer := 32
	);
	port(
		clock : in std_logic;
		trigger : out std_logic
	);
	-- declare constants which are being used by other entities
	constant rate : integer range 0 to 31 := 15; -- random chosen value for the trigger rate
end entity;

architecture behavior of poissonpulse is
	-- declare Bernoulli-Trial trigger as a component
	component bernoullitrial is
		generic(
			num_length : integer := 32;
			rate : integer range 0 to 31
		);
		port(
			clock : in std_logic;
			rng : in std_logic_vector(num_length-1 downto 0);
			trig : out std_logic
		);
	end component;

	-- declare the RNG as a component
	component barrelshifter is
		generic(
			reg_length : integer := 95;
			rng_length : integer := 32
		);
		port(
			clock : in std_logic;
			rng_out : out std_logic_vector(rng_length-1 downto 0)
		);
	end component;

-- declare signals only available within the architecture
	signal rng : std_logic_vector(rng_length-1 downto 0);
begin
	-- create an instance of the barrel shifter
	bs1 : barrelshifter port map(
		clock => clock, -- connect clock of barrel shifter to clock of top level entity
		rng_out => rng -- make rng output available
	);

	-- create an instance of the bernoullitrial trigger
	bt1: bernoullitrial
		generic map(
			rate => rate
		)
		port map(
			clock => clock,
			rng => rng,
			trig => trigger
		);
end architecture;
