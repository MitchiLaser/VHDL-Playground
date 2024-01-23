library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity trafficlight is
	generic(
		clk_ticks_S1_S4 : integer := 400;
		clk_ticks_S2_S5 : integer := 200;
		clk_ticks_S3_S6 : integer := 200
	);
	port(
		clock_in : in std_logic;
		light1, light2, light3, light4 : out std_logic_vector(2 downto 0)
	);
end trafficlight;


architecture bhv of trafficlight is

	-- frequency divider component
	component fdiv is
		port(
			clock_in : in std_logic;
			clock_out : out std_logic
		);
	end component;
	-- signal for the reduced clock
	signal clock_100Hz : std_logic;

	-- the states of the traffic lights
	type T_Lights is (RED, RED_YELLOW, YELLOW, GREEN);
	signal light_1_3, light_2_4 : T_Lights;

	-- convert traffic light state to output signal
	pure function led_out(signal light: in T_Lights) return std_logic_vector is
		variable result: std_logic_vector(2 downto 0) := (others => '0');
	begin
		case light is
			when RED 				=> result := "001";
			when RED_YELLOW => result := "011";
			when YELLOW 		=> result := "010";
			when GREEN 			=> result := "100";
		end case;
		return result;
	end led_out;

	-- state machine
	type T_State is (S1, S2, S3, S4, S5, S6);
	signal state : T_State := S1;
	signal state_next : T_State;

	-- counter size preprocessor
	pure function max(constant in1, in2, in3: in integer) return integer is
		variable result : integer := 0;
	begin
		if (in1 >= in2) and (in1 >= in3) then
			result := in1;
		elsif (in2 >= in1) and (in2 >= in3) then
			result := in2;
		elsif (in3 >= in1) and (in3 >= in2) then
			result := in3;
		end if;
		return result;
	end max;
	-- counter
	signal counter : integer range 0 to (max(clk_ticks_S1_S4, clk_ticks_S2_S5, clk_ticks_S3_S6) - 1) := 0;

begin
	-- instantiate the clock divider
	fdiv1: fdiv
	port map(
		clock_in => clock_in,
		clock_out => clock_100Hz
	);

	-- the state machine
	process (clock_100Hz) is
	begin
		if rising_edge(clock_100Hz) then
			case state is
				when S1 =>
					light_1_3 <= RED;
					light_2_4 <= GREEN;
					if counter = (clk_ticks_S1_S4-1) then
						counter <= 0;
						state_next <= S2;
					else
						counter <= counter + 1;
						state_next <= state;
					end if;

				when S2 =>
					light_1_3 <= RED;
					light_2_4 <= YELLOW;
					if counter = (clk_ticks_S2_S5-1) then
						counter <= 0;
						state_next <= S3;
					else
						counter <= counter + 1;
						state_next <= state;
					end if;

				when S3 =>
					light_1_3 <= RED_YELLOW;
					light_2_4 <= RED;
					if counter = (clk_ticks_S3_S6-1) then
						counter <= 0;
						state_next <= S4;
					else
						counter <= counter + 1;
						state_next <= state;
					end if;

				when S4 =>
					light_1_3 <= GREEN;
					light_2_4 <= RED;
					if counter = (clk_ticks_S1_S4-1) then
						counter <= 0;
						state_next <= S5;
					else
						counter <= counter + 1;
						state_next <= state;
					end if;

				when S5 =>
					light_1_3 <= YELLOW;
					light_2_4 <= RED;
					if counter = (clk_ticks_S2_S5-1) then
						counter <= 0;
						state_next <= S6;
					else
						counter <= counter + 1;
						state_next <= state;
					end if;

				when S6 =>
					light_1_3 <= RED;
					light_2_4 <= RED_YELLOW;
					if counter = (clk_ticks_S3_S6-1) then
						counter <= 0;
						state_next <= S1;
					else
						counter <= counter + 1;
						state_next <= state;
					end if;

			end case;
		end if;
	end process;
	-- next state
	state <= state_next;
	-- drive the output pins based on the assignments of the state machine
	light1 <= led_out(light_1_3);
	light3 <= led_out(light_1_3);
	light2 <= led_out(light_2_4);
	light4 <= led_out(light_2_4);
end architecture;
