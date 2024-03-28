library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ClockGeneration is
port(
		clk : in std_logic; -- 50 MHz frequency (20 ns period)
		adc : in std_logic_vector(7 downto 0);
		reset : in std_logic;
		clock_out : out std_logic
		);
end ClockGeneration;

architecture arch of ClockGeneration is

signal freq_out : integer; -- Frequency of clk_out
signal divisor : integer;
signal total : INTEGER;
signal two  : integer;
constant freq_in : integer := 50000000; -- Frequency of input clk
    signal counter      : integer range 0 to 50000000;
type st is (clock_out_1, clock_out_0);  --, capture
signal states : st;

begin


-- Clock enable with variable frequency output
process(clk,states, adc, reset)
begin

	divisor <= freq_in / freq_out;
	total <= freq_out + divisor;
	two <= total / 2;
	
	if adc = X"FF" then
		freq_out <= 1574;
		else
		freq_out <= (((1750-500)/255)*to_integer(unsigned(adc))) + 503;  
		
		end if;
		
		
		if (reset = '1') then
		clock_out <= '0';
		counter <= 0;
		states <= clock_out_0;
		
		
		
		elsif rising_edge(clk) then
		
		counter <= counter + 1;
		--     adc2 <= adc;
				if (counter = 50000000) then
		counter <= 0;
		states <= clock_out_0;
		end if;
		
		
		case states is
		
		
		when clock_out_0 =>
		clock_out <= '0';
		
				if (two <= counter) then
		clock_out <= '1';
		counter <= 0;
		states <= clock_out_1;
		
			end if;
			
		when clock_out_1 =>
		clock_out <= '1';
		
		if (total <= counter) then
		clock_out <= '0';
		counter <= 0;
		states <= clock_out_0;
		
		end if;
		
		
		end case;
	end if;
end process;

end arch;