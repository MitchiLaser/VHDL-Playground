library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fdiv;
use fdiv.fdiv;
library shiftregister;
use shiftregister.shiftregister;

-- entity of the running light
entity running_light is
	generic(
		Size : integer := 8
	);
	Port(
		clock: in std_logic;
		leds : out std_logic_vector(Size-1 downto 0);
		T : in std_logic_vector(1 downto 0);
		switches : in std_logic_vector(Size-1 downto 0);
		leds_red: out std_logic_vector(Size-1 downto 0)
	);
end;

architecture bhv of running_light is

	type T_State is (INIT, PAUSE, PROGRAMMING, OUTPUT, WAIT_STATE, CALC_NEXT);
	signal current_state : T_State := INIT;
	signal next_state : T_State;
	signal shift_reg_control : std_logic_vector(1 downto 0) := "00";
	signal shift_reg_clock : std_logic := '0';

	signal clock_100hz : std_logic := '0';	
	signal counter : integer range 0 to 49;  -- 2 Hz signal
	
	component fdiv is
		port(
			clock_in : in std_logic;
			clock_out : out std_logic
		);
	end component;
	
	component shiftregister is
		generic(
			Size : integer
		);
		port(
			X : in std_logic_vector(Size-1 downto 0);
			Y : out std_logic_vector(Size-1 downto 0);
			Clock : in std_logic;
			A : in std_logic_vector(1 downto 0)
		);
	end component;
	
begin

	-- instanciate the 100Hz clock inside this architecture
	f_divider : fdiv
	port map(
		clock_in => clock,
		clock_out => clock_100hz
	);
	
	shift_register : shiftregister
	generic map(
		Size => Size
	)
	port map(
		X => switches,
		Y => leds,
		Clock => shift_reg_clock,
		A => shift_reg_control
	);
	
	process (clock_100hz, current_state, T) is
	begin
		if rising_edge(clock_100hz) then
			case current_state is
			
				when INIT =>
					shift_reg_control <= "00";  -- shift register in pause state
					shift_reg_clock <= '0';  -- shift register initialisation
					-- switch state
					if T="01" then
						next_state <= PROGRAMMING;
					else
						next_state <= current_state;
					end if;
					
					
				when PROGRAMMING =>
					shift_reg_control <= "01";  -- load values in shift register
					-- switch state
					if T = "00" then
						next_state <= OUTPUT;
						shift_reg_clock <= '1';  -- clock cycle for shift registers to update values
					else
						next_state <= current_state;
						shift_reg_clock <= shift_reg_clock;  -- stay unchanged
					end if;
					
				when PAUSE =>
					shift_reg_clock <= '0';  -- shift register stays in unchanged mode: clock always at zero
					shift_reg_control <= "00";  -- tell shift register to use pause mode
					-- switch state
					if T(1) = '1' then
						next_state <= OUTPUT;
					elsif T = "01" then
						next_state <= PROGRAMMING;
					else
						next_state <= current_state;
					end if;
				
				when OUTPUT =>
					shift_reg_clock <= '1';  -- clock tick for the shift register
					shift_reg_control <= "00";  -- programming mode to accept the input from the switches
					counter <= 0;  -- reset counter
					-- switch state
					next_state <= WAIT_STATE;
				
				when WAIT_STATE =>
					if counter = 49 then
						next_state <= CALC_NEXT;
						counter <= 0;
						shift_reg_control(1) <= '1';
						shift_reg_control(0) <= T(0);
						shift_reg_clock <= '1';  -- clock tick for the shift register
					else
						next_state <= current_state;
						counter <= counter + 1;
						shift_reg_control <= "00";  -- waiting state
						shift_reg_clock <= '0';
					end if;
					
				when CALC_NEXT =>
					shift_reg_clock <= '0';  -- turn clock off again
					shift_reg_control <= "00";
					-- switch state
					if T(1) = '0' then
						next_state <= PAUSE;
					else
						next_state <= OUTPUT;
					end if;
					
					
				when others =>
					-- todo
			end case;
		end if;
	end process;
	-- update to the next state
	current_state <= next_state;
	
	leds_red <= switches;
end;