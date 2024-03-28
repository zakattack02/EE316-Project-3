library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ClockGeneration is
    Port ( iClk : in STD_LOGIC;
           Adjustvar : in STD_LOGIC_VECTOR(7 downto  0);
           CLOCK_OUT	 : buffer STD_LOGIC -- Change to buffer
			  );
end ClockGeneration;

architecture Behavioral of ClockGeneration is
    signal clock_enable : STD_LOGIC := '1';
    signal n1, n2, N, n3 : INTEGER :=  0; -- Change to INTEGER type
    signal counter : INTEGER range 0 to 100000;
    signal Adjustvar_signed : UNSIGNED(Adjustvar'range);
    
    -- Your additional constants for the equation
    constant n1_constant : INTEGER :=  50000; -- Change as needed
    constant n2_constant : INTEGER :=  3000;  -- Change as needed

begin
    process(iClk)
    begin
		  
        if rising_edge(iClk) then
		  
		  -- Implement the equation N = n2 + (n1 - n2) /  255 * Adjustvar
        Adjustvar_signed <= UNSIGNED(Adjustvar);
		  
		  n3 <= (50000 - 3000) / 255;
		  
        N <= n2_constant + n3 * to_integer(Adjustvar_signed);
		  
            -- Update clock frequency based on potentiometer, thermistor, and LDR
            if (clock_enable = '1') then
                counter <= counter +  1;

                -- Clock generation logic
                if counter = N then
                    CLOCK_OUT <= not CLOCK_OUT;
                    counter <=  0;
                else
                    CLOCK_OUT <= '0';
                end if;
         else
            CLOCK_OUT <= '0';
            counter <=  0;
            end if;

        end if;
    end process;
end Behavioral;
