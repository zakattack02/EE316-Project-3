library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.STD_LOGIC_ARITH.ALL; 

use IEEE.STD_LOGIC_UNSIGNED.ALL; 

entity Main4State_Machine is 

    Port ( clk : in STD_LOGIC; 
			  counter : in std_LOGIC_VECTOR( 7 downto 0);
           ValidKeyPressedPulse : in std_logic;
           iKey0 : in std_logic;    
           iKey1 : in std_logic;           
           iKey2 : in std_logic;
           iKey3 : in std_logic;
           clkEnFiveMS : in std_logic;
           state_value_out : out std_logic_vector(1 downto 0)
        ); 
			  
end Main4State_Machine; 


architecture Behavioral of Main4State_Machine is 
------------------------------------------------------------------------------------------------------------------
    type states is (INIT,TEST,PAUSE,PWN_GENERATION); 
    signal current_state,next_state : states;
	 
    signal true_address	:std_logic_vector(7 downto 0);
	 signal true2_address :std_logic_vector(7 downto 0);
    signal state_value : STD_LOGIC_VECTOR(1 downto 0); 
	 signal PWM_state_count :std_LOGIC_VECTOR(1 downto 0);
	 signal PWM_state_count_sig :std_LOGIC_VECTOR(1 downto 0);

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
process(clk, iKey0) 
begin 
    if iKey0 = '1' then 

        current_state <= INIT; 

            
    elsif rising_edge(clk) and clkEnFiveMS = '1' then 

        current_state <= next_state; 
--		  PWM_state_count <= PWM_state_count_sig;

    end if; 

end process; 
------------------------------------------------------------------------------------------------------------------		
------------------------------------------------------------------------------------------------------------------
-- Main 4 states machine

process(current_state,counter,ValidKeyPressedPulse) 
    begin 
        next_state <= current_state;

        case current_state is 			
				
            when INIT => 
					PWM_state_count <= "00";
					if  counter = "11111111" then
                    next_state <= TEST;
					end if;

            when TEST => 
                if iKey1 = '0' and ValidKeyPressedPulse = '1' then
						next_state <= PAUSE;
                elsif iKey2 = '0' and ValidKeyPressedPulse = '1' then
						next_state <= PWN_GENERATION;
                end if;

            when PAUSE => 
                if iKey1 = '0' and ValidKeyPressedPulse = '1' then
						next_state <= TEST;
                end if;

            when PWN_GENERATION => 
					 if iKey2 = '0' and ValidKeyPressedPulse = '1' then
						next_state <= TEST;
                end if;
					 
					 if iKey3 = '0' and ValidKeyPressedPulse = '1' then
							PWM_state_count <= PWM_state_count + 1;
							if PWM_state_count > "10" then
								PWM_state_count <= "00";
							end if;
					 end if;
					 
            when others => 
                current_state <= INIT;  -- Reset to INIT state if in an unknown state 
				
		end case; 

end process; 

 

 with current_state select 

    state_value <= "00" when INIT, 				

                   "01" when TEST, 		

                   "10" when PAUSE, 			

                   "11" when PWN_GENERATION; 		




end Behavioral; 