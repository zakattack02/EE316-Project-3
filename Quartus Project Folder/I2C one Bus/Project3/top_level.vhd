library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity top_level is
	port(
		iClk   	 : in std_logic;
	   BTN0 : in std_logic;
		BTN1 : in std_logic;
		BTN2 : in std_logic;
		
		I2C_SDA : inout std_logic;
		I2C_SCL : inout std_logic;
		
		FinaloPWM : out std_LOGIC;
		FinaloClk_Gen : out std_LOGIC;
								
		oLed0  : out std_logic;
		oLed1  : out std_logic;
		oLed2  : out std_logic;
		oLed3  : out std_logic

	);
end top_level;

architecture Structural of top_level is
------------------------------------------------------------------------------------------------------------------
component I2C_user_logic IS
    Port ( iclk : in STD_LOGIC;
           dataIn : in STD_LOGIC_VECTOR (15 downto 0);
		   FirstLineInput: in std_LOGIC_VECTOR(127 downto 0);
		   SecondLineInput: in std_LOGIC_VECTOR(127 downto 0);
		   ADCstate : in std_LOGIC_VECTOR(1 downto 0);
			CurrentBigState: in std_Logic_vector(1 downto 0);
		   EightBitDataFromADC: out std_LOGIC_VECTOR(7 downto 0);
         oSDA : inout STD_LOGIC;
		   oSCL : inout STD_LOGIC
		); 
END component;
------------------------------------------------------------------------------------------------------------------
component Reset_Delay IS
	PORT (
 		SIGNAL iCLK : IN std_logic;
 		SIGNAL oRESET : OUT std_logic
	);
end component;
------------------------------------------------------------------------------------------------------------------
component PWM is
   generic(N: integer := 8);
   port(
clk         : in std_logic;
datain : in std_logic_vector(N-1 downto 0);
BigReset : in std_logic;
PWMState : in std_logic_vector(1 downto 0);
PWM                     : out std_logic
   );
end component;
------------------------------------------------------------------------------------------------------------------
component btn_debounce_toggle is
GENERIC (
	CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
    Port ( BTN_I 	: in  STD_LOGIC;
           CLK 		: in  STD_LOGIC;
           BTN_O 	: out  STD_LOGIC;
           TOGGLE_O : out  STD_LOGIC;
		   PULSE_O  : out STD_LOGIC);
end component;
------------------------------------------------------------------------------------------------------------------
component Main2State_Machine is 
    Port ( clk : in STD_LOGIC; 
           BTN2Pulse: in std_logic;
           iKey0 : in std_logic;    
           clkEnFiveMS : in std_logic;
           state_value_out : out std_logic_vector(1 downto 0)
        ); 
end component; 
------------------------------------------------------------------------------------------------------------------
component ClockGeneration is
    Port ( 	clk : in std_logic; -- 50 MHz frequency (20 ns period)
				adc : in std_logic_vector(7 downto 0);
				reset : in std_logic;
				clock_out : out std_logic
		 );
end component;
------------------------------------------------------------------------------------------------------------------
   type PWMState is (PModule1,PModule2,PModule3,PModule4); 
   signal current_PWMState,next_pwmstate : PWMState;
	
	type ClkGenState is (Module1,Module2,Module4); 
   signal current_ClkGenState,next_clkgenstate : ClkGenState;
	
	signal Rst 	: std_logic;
	
	signal oPwm0: std_LOGIC;
	signal reset: std_LOGIC;

	signal BTN0_DB: std_logic;
	signal BTN1_DB: std_logic;
	signal BTN2_DB: std_logic;
	
	signal BIGReset : std_logic;
	signal kp 		: std_LOGIC;
	signal iKey3_dbPulse : std_logic;
	signal cnt_5MS: integer range 0 to 249999:= 0;
	signal clock_en5ms: std_LOGIC:= '0';
	signal CurrentState: std_logic_vector(1 downto 0);
	signal kpPulse20ns: std_LOGIC;

	signal FirstLine: std_lOGIC_VECTOR(127 downto 0);
	signal SecondLine: std_lOGIC_VECTOR(127 downto 0);
	
	signal I2CandLCDData : std_lOGIC_VECTOR(15 downto 0);
	signal I2CandLCDAddress: std_LOGIC_VECTOR(7 downto 0);
	signal PWN_module: std_lOGIC_VECTOR(1 downto 0):="00";
	signal BTN1_DB_pulse: std_LOGIC;
	
    signal FinaloClk_Gen_sig: std_logic;

	signal BTN2_DB_pulse: std_logic;
	signal PWM_module: std_logic_vector(1 downto 0):= "00";
   signal CLK_gen_module: std_logic_vector(1 downto 0):= "00";
	signal PWMmode: std_lOGIC_VECTOR(1 downto 0);
	signal Clk_genMode: std_lOGIC_VECTOR(1 downto 0);
	signal DataFromADC: std_LOGIC_VECTOR(7 downto 0);
	
------------------------------------------------------------------------------------------------------------------

begin
BigReset <= (BTN0_DB) or (reset);				--BIG SYSTEM RESET
kp <= (BTN0_DB or BTN1_DB or BTN2_DB);				--Check for keypress


------------------------------------------------------------------------------------------------------------------
process(iclk, BigReset,clock_en5ms) 
begin 
    if BigReset = '1' then 

        current_PWMState <= PModule1; 
		  current_ClkGenState <= Module1;

            
    elsif rising_edge(iclk) and clock_en5ms = '1' then 

        current_PWMState <= next_pwmstate; 
		  current_ClkGenState <= next_clkgenstate;
--		  PWM_state_count <= PWM_state_count_sig;

    end if; 

end process; 
-------------------------------------------------------------------------------------------------------------------

process(CurrentState,iClk,BigReset,Clk_genMode,PWMmode)
begin 
	if BigReset = '1' then
		oLed0 <= '0';
		oLed1 <= '0';
		oLed2 <= '0';
		oLed3 <= '0';
		PWN_module <= "00";	--LDR
		FirstLine <=  X"2020202020245F28C2295F2F20202020";
		SecondLine <= X"2020202020245F28C2295F2F20202020";
		FinaloPWM <= '0';
		next_pwmstate <= PModule1;
		next_clkgenstate <= Module1;
	elsif rising_edge(iClk) then
		
	if CurrentState = "01" then -- PWM mode
		FinaloPWM <= oPwm0;
		FinaloClk_Gen <= '0';
		case current_PWMState is
		
		when PModule1 =>
				oLed0 <= '1';
				oLed1 <= '0';
				oLed2 <= '0';
				oLed3 <= '0';
				PWN_module <= "00";	--LDR
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"20202020204C69676874212020202020";
				
				if  BTN1_DB_pulse = '1'  then
					next_pwmstate <= pmodule2;
				end if;
		
  		when PModule2 => 
		
				oLed0 <= '0';
				oLed1 <= '1';
				oLed2 <= '0';
				oLed3 <= '0';
				PWN_module <= "01";	--THERMIS
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"20202020204865617421212020202020";
				
				if  BTN1_DB_pulse = '1'  then
					next_pwmstate <= pmodule3;
				end if;
		
		when PModule3 => 
		
				oLed0 <= '0';
				oLed1 <= '0';
				oLed2 <= '1';
				oLed3 <= '0';
				PWN_module <= "10";	--AIN2 -> Blue BALLs
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"49444C2D3830302046756E635F47656E";
	
				if  BTN1_DB_pulse = '1'  then
					next_pwmstate <= pmodule4;
				end if;
		
		when PModule4 => 
				oLed0 <= '0';
				oLed1 <= '0';
				oLed2 <= '0';
				oLed3 <= '1';
				PWN_module <= "11";	--POT
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"20506F74656E74696F6D657465722120";
				
				if  BTN1_DB_pulse = '1'  then
					next_pwmstate <= pmodule1;
				end if;
		
		end case;

	elsif CurrentState = "10" then --CLK_gen
		FinaloPWM <= '0';
        FinaloClk_Gen <= FinaloClk_Gen_sig;
	case current_ClkGenState is
		
		when Module1 => 
		
			oLed0 <= '1';
			oLed1 <= '0';
			oLed2 <= '0';
			oLed3 <= '0';
			PWN_module	<= "00"; --LDR
			FirstLine <=  X"20202020434C4B5F47656E7E20202020";
			SecondLine <= X"20202020204C69676874212020202020";
			
				if  BTN1_DB_pulse = '1'  then
					next_clkgenstate <= module2;
				end if;
		
  		when Module2 => 
			oLed0 <= '0';
			oLed1 <= '1';
			oLed2 <= '0';
			oLed3 <= '0';
			PWN_module	<= "01"; --THER
			FirstLine <=  X"20202020434C4B5F47656E7E20202020";
			SecondLine <= X"20202020204865617421212020202020";

				if  BTN1_DB_pulse = '1'  then
					next_clkgenstate <= module4;
				end if;
		
		when Module4 => 
			oLed0 <= '0';
			oLed1 <= '0';
			oLed2 <= '0';
			oLed3 <= '1';
			PWN_module	<= "11"; --POT
			FirstLine <=  X"20202020434C4B5F47656E7E20202020";
			SecondLine <= X"20506F74656E74696F6D657465722120";
			
				if  BTN1_DB_pulse = '1'  then
					next_clkgenstate <= module1;
				end if;
		
	end case;

	end if;
	end if;
end process;
-------------------------------------------------------------------------------------------------------------------
process(iClk,BigReset)			-- Simple Clock Enablr running at 5ms 
begin	

	if BigReset = '1' then
	clock_en5ms <= '0';
	cnt_5MS <= 0;
	
 	elsif rising_edge(iClk) then
		if cnt_5MS = 249999 then    -- 249999 is 5ms I DID MATH :D 
 		  	clock_en5ms <= '1';
		  	cnt_5MS <=0;
		else
		  	clock_en5ms <= '0';
		  	cnt_5MS <= cnt_5MS+1;
		end if;
	end if;
end process;
-------------------------------------------------------------------------------------------------------------------
INST_StateMachine: Main2State_Machine 
    Port map( clk => iClk,
           BTN2Pulse => BTN2_DB_pulse,
           iKey0 => BigReset,
 
           clkEnFiveMS => clock_en5ms,
           state_value_out => CurrentState
        ); 
--------------------------------------------------------------------------------------------------------------------
INST_LCD_I2C_UsrLogic: I2C_user_logic
    Port map( iclk => iClk,
           dataIn => I2CandLCDData,
			  FirstLineInput => FirstLine,
			  SecondLineInput => SecondLine,
			  ADCstate => PWN_module,
			  CurrentBigState => CurrentState,
		   EightBitDataFromADC => dataFromADC,
           oSDA => I2C_SDA,
			  oSCL => I2C_SCL
		);  --SPI MOSI data output

------------------------------------------------------------------------------------------------------------------	
Inst_clk_Reset_Delay: Reset_Delay 
	port map(
		iCLK 		 => iCLK,
		oRESET    => reset
	);
------------------------------------------------------------------------------------------------------------------
Inst_Key0: btn_debounce_toggle
GENERIC MAP(CNTR_MAX => X"FFFF")
	Port map (
		BTN_I => BTN0,
		 CLK => iCLk,
		 BTN_O => BTN0_DB,
		 TOGGLE_O => open,
		PULSE_O   => open
	);
------------------------------------------------------------------------------------------------------------------
Inst_Key1: btn_debounce_toggle 
GENERIC MAP(CNTR_MAX => X"FFFF")
	Port map (
		BTN_I => BTN1,
		 CLK => iCLk,
		 BTN_O => BTN1_DB,
		 TOGGLE_O => open,
		PULSE_O   => open
	);
------------------------------------------------------------------------------------------------------------------
Inst_Key2: btn_debounce_toggle
GENERIC MAP(CNTR_MAX => X"FFFF")
	Port map (
		BTN_I => BTN2,
		 CLK => iCLk,
		 BTN_O => BTN2_DB,
		 TOGGLE_O => open,
		PULSE_O   => open
	);
------------------------------------------------------------------------------------------------------------------	
INST_DebouncedKey0:btn_debounce_toggle
GENERIC map (
	CNTR_MAX => X"0001")  
	Port map (
		BTN_I => kp,
	  	CLK => clock_en5ms,
	 	BTN_O => open,
	 	TOGGLE_O => open,
		PULSE_O   => kpPulse20ns
	);
------------------------------------------------------------------------------------------------------------------
INST_BTN1_DB_pulse:btn_debounce_toggle
GENERIC map (
	CNTR_MAX => X"0001")  
	Port map (
		BTN_I => BTN1,
	  	CLK => clock_en5ms,
	 	BTN_O => open,
	 	TOGGLE_O => open,
		PULSE_O   => BTN1_DB_pulse
	);
------------------------------------------------------------------------------------------------------------------
INST_BTN2Pulse:btn_debounce_toggle
GENERIC map (
	CNTR_MAX => X"0001")  
	Port map (
		BTN_I => BTN2,
	  	CLK => clock_en5ms,
	 	BTN_O => open,
	 	TOGGLE_O => open,
		PULSE_O   => BTN2_DB_pulse
	);
------------------------------------------------------------------------------------------------------------------
INST_PWM0:PWM
   generic map(N => 8)--,PWM_counter_max => 256)
   port map(
			clk         				=> iClk,
			datain						=> dataFromADC,
			BigReset						=> BigReset,
			PWMState						=> PWMmode,
			PWM                     => oPwm0
   );
------------------------------------------------------------------------------------------------------------------
INST_CLK_GEN: ClockGeneration
    Port map(	clk => iClk,
					adc =>dataFromADC,
					reset => BigReset,
					clock_out => FinaloClk_Gen_sig
	);
------------------------------------------------------------------------------------------------------------------

end Structural;