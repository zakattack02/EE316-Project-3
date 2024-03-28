library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.STD_LOGIC_ARITH.ALL; 

use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Main2State_Machine is 

    Port ( clk : in STD_LOGIC; 
           BTN2Pulse: in std_logic;
           iKey0 : in std_logic;    
 
           clkEnFiveMS : in std_logic;
           state_value_out : out std_logic_vector(1 downto 0)
        ); 
			  
end Main2State_Machine; 


architecture Behavioral of Main2State_Machine is 
------------------------------------------------------------------------------------------------------------------
    type states is (INIT,PWM_mode,CLOCK_GEN_MODE); 
    signal current_state,next_state : states;
	
    signal state_value : STD_LOGIC_VECTOR(1 downto 0);
	signal PWM_state_count : std_LOGIC_VECTOR(1 downto 0);
	signal PWM_state_count_sig : std_LOGIC_VECTOR(1 downto 0);
	signal counter : std_LOGIC_VECTOR(7 downto 0) := X"00";


------------------------------------------------------------------------------------------------------------------
component btn_debounce_toggle is
    GENERIC (
	CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
    Port( 
        BTN_I 		: in  STD_LOGIC;
        CLK 		: in  STD_LOGIC;
        BTN_O 		: out  STD_LOGIC;
        TOGGLE_O 	: out  STD_LOGIC;
		PULSE_O   : out STD_LOGIC);
  end component;
------------------------------------------------------------------------------------------------------------------
begin 
state_value_out <= state_value;
------------------------------------------------------------------------------------------------------------------
process(clk)
begin 
if rising_edge(clk) then
	if counter /= "11111111"then 
		counter <= counter + '1';
	end if;
end if;
end process;
		
	
------------------------------------------------------------------------------------------------------------------
process(clk, iKey0,clkEnFiveMS) 
begin 
    if iKey0 = '1' then 

        current_state <= INIT; 

            
    elsif rising_edge(clk) and clkEnFiveMS = '1' then 

        current_state <= next_state; 

--		  PWM_state_count <= PWM_state_count_sig;

    end if; 

end process; 
------------------------------------------------------------------------------------------------------------------
-- Main 4 states machine

process(current_state,counter,BTN2Pulse,Clk) 
    begin 
	 if rising_edge(clk) then
        case current_state is 			
				
            when INIT => 
					if  counter = "11111111" then
                    next_state <= PWM_mode;
					end if;

            when PWM_mode => 
                if  BTN2Pulse = '1' then
						next_state <= CLOCK_GEN_MODE;
					 end if;
					 

                    

            when CLOCK_GEN_MODE => 
			     if BTN2Pulse = '1' then
			         next_state <= PWM_mode;
              end if;


						
            when others => 
                next_state <= INIT;  -- Reset to INIT state if in an unknown state 
		end case; 
	end if;
end process; 

 

 with current_state select 

    state_value <= "00" when INIT, 				
                   "01" when PWM_mode, 				
                   "10" when CLOCK_GEN_MODE,
						 "11" when others;
					
end Behavioral; 