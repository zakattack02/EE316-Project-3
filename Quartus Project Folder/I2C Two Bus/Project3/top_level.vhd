library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity top_level is
	port(
		iClk   	 : in std_logic;
	   BTN0 : in std_logic;
		BTN1 : in std_logic;
		BTN2 : in std_logic;
		
		TESTINGLED: out std_LOGIC;
		
		LCD_I2C_SDA : inout std_LOGIC;
		LCD_I2C_SCL : inout std_LOGIC;
		
		ADC_I2C_SDA : inout std_logic;
		ADC_I2C_SCL : inout std_logic;
		
		FinaloPWM : out std_LOGIC;
		FinaloClk_Gen : out std_LOGIC;
								
		oLed0  : out std_logic;
		oLed1  : out std_logic;
		oLed2  : out std_logic;
		oLed3  : out std_logic;
		HEX4OUT : out std_logic_vector(6 downto 0);
		HEX5OUT : out std_logic_vector(6 downto 0);
		
		HEX6OUT : out std_logic_vector(6 downto 0);
		HEX7OUT : out std_logic_vector(6 downto 0)
	);
end top_level;

architecture Structural of top_level is
------------------------------------------------------------------------------------------------------------------
component LCDI2C_user_logic IS
    Port ( iclk : in STD_LOGIC;
           dataIn : in STD_LOGIC_VECTOR (15 downto 0);
			  FirstLineInput: in std_LOGIC_VECTOR(127 downto 0);
			  SecondLineInput: in std_LOGIC_VECTOR(127 downto 0);
           oLCDSDA : inout STD_LOGIC;
			  oLCDSCL : inout STD_LOGIC
		); 
END component;
------------------------------------------------------------------------------------------------------------------
component Main4State_Machine is 
Port ( clk   : in STD_LOGIC; 
       ValidKeyPressedPulse : in std_logic;
       iKey0 : in std_logic;    
       iKey1 : in std_logic;           
       iKey2 : in std_logic;
       clkEnFiveMS : in std_logic;
       state_value_out : out std_logic_vector(1 downto 0)
    ); 
			  
end component; 
------------------------------------------------------------------------------------------------------------------
component ADC_I2C_user_logic is							
    Port ( iclk : in STD_LOGIC;
	 		  byteSel : in std_LOGIC_VECTOR(1 downto 0);
			  EightBitDataFromADC: out std_LOGIC_VECTOR(7 downto 0);
           oADCSDA : inout STD_LOGIC;
           oADCSCL : inout STD_LOGIC
			  );
end component;
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
PWMState : in integer range 0 to 4;
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
           ValidKeyPressedPulse : in std_logic;
           iKey0 : in std_logic;    
           iKey1 : in std_logic;           
           iKey2 : in std_logic;
           clkEnFiveMS : in std_logic;
           state_value_out : out std_logic_vector(1 downto 0)
        ); 
end component; 
------------------------------------------------------------------------------------------------------------------
component ClockGeneration is
    Port ( iClk : in STD_LOGIC;
           Adjustvar : in STD_LOGIC_VECTOR(7 downto  0);
           CLOCK_OUT : buffer STD_LOGIC  -- Change to buffer
			  );
end component;
------------------------------------------------------------------------------------------------------------------
   type PWMState is (PModule1,PModule2,PModule3,PModule4); 
   signal current_PWMState,next_pwmstate : PWMState;
	
	type ClkGenState is (Module1,Module2,Module4); 
   signal current_ClkGenState,next_clkgenstate : ClkGenState;
	
	signal Rst 	: std_logic;
	
	signal PWM_state_value_out_sig : integer range 0 to 4;
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
	signal ADC_Mode: integer range 0 to 3:= 0;
	signal PWN_module: std_lOGIC_VECTOR(1 downto 0):="00";
	signal BTN1_DB_pulse: std_LOGIC;
	
	
	signal PWMmode: integer range 0 to 4;
	signal DataFromADC: std_LOGIC_VECTOR(7 downto 0);
	
------------------------------------------------------------------------------------------------------------------

begin
BigReset <= (BTN0_DB) or (reset);				--BIG SYSTEM RESET
TESTINGLED <= kp;
kp <= (BTN0_DB or BTN1_DB or BTN2_DB);				--Check for keypress


--------------------------------------------------------------------------------------------------------------------
process (PWN_module) is 
begin
	case PWN_module is
		when "00" => HEX5OUT <= "1000000"; HEX4OUT <= "1000000"; 
		when "01" => HEX5OUT <= "1000000"; HEX4OUT <= "1111001"; 
		when "11" => HEX5OUT <= "1000000"; HEX4OUT <= "0100100"; 
		when "10" => HEX5OUT <= "1000000"; HEX4OUT <= "0110000";
	end case;
end process;
-------------------------------------------------------------------------------------------------------------------
process (CurrentState) is 
begin
	case CurrentState is
		when "00" => HEX7OUT <= "1000000"; HEX6OUT <= "1000000"; 
		when "01" => HEX7OUT <= "1000000"; HEX6OUT <= "1111001"; 
		when "10" => HEX7OUT <= "1000000"; HEX6OUT <= "0100100"; 
		when "11" => HEX7OUT <= "1000000"; HEX6OUT <= "0110000";
	end case;
end process;
------------------------------------------------------------------------------------------------------------------
process(iclk, BigReset,clock_en5ms) 
begin 
    if rising_edge(iclk) and clock_en5ms = '1' then 

        Current_PWMState <= next_pwmstate; 
		  Current_ClkGenState <= next_clkgenstate;

    end if; 

end process; 

-------------------------------------------------------------------------------------------------------------------

process(CurrentState,BTN1_DB_pulse,Current_PWMState,Current_ClkGenState)
begin 

	if CurrentState = "00" then		--INIT/RESET state
		oLed0 <= '0';
		oLed1 <= '0';
		oLed2 <= '0';
		oLed3 <= '0';
		PWN_module <= "00";	--LDR
		FirstLine <=  X"2020202020245F28C2295F2F20202020";
		SecondLine <= X"2020202020245F28C2295F2F20202020";
		FinaloPWM <= '0';
		next_pwmstate <= Pmodule1;
		next_clkgenstate <= module1;
		
	elsif CurrentState = "01" then -- PWM mode
		FinaloPWM <= oPwm0;
		case Current_PWMState is
			when Pmodule1 =>
				oLed0 <= '1';
				oLed1 <= '0';
				oLed2 <= '0';
				oLed3 <= '0';
				PWN_module <= "00";	--LDR
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"20202020204C69676874212020202020";
				if BTN1_DB_pulse = '1' then
					next_pwmstate <= Pmodule2;
				end if;

			when Pmodule2 =>
				oLed0 <= '0';
				oLed1 <= '1';
				oLed2 <= '0';
				oLed3 <= '0';
				PWN_module <= "01";	--THERMIS
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"20202020204865617421212020202020";
				if BTN1_DB_pulse = '1' then
					next_pwmstate <= Pmodule3;
				end if;

			when Pmodule3 =>
				oLed0 <= '0';
				oLed1 <= '0';
				oLed2 <= '1';
				oLed3 <= '0';
				PWN_module <= "10";	--AIN2 -> Blue BALLs
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"49444C2D3830302046756E635F47656E";
				if BTN1_DB_pulse = '1' then
					next_pwmstate <= Pmodule4;
				end if;
			

			when Pmodule4 =>
				oLed0 <= '0';
				oLed1 <= '0';
				oLed2 <= '0';
				oLed3 <= '1';
				PWN_module <= "11";	--POT
				FirstLine <=  X"2020202050574D204D6F646520202020";
				SecondLine <= X"20506F74656E74696F6D657465722120";
				if BTN1_DB_pulse = '1' then
					next_pwmstate <= Pmodule1;
				end if;
		end case;
		
	elsif CurrentState = "10" then
		FinaloPWM <= '0';
		
		case Current_ClkGenState is
		when module1 =>
			oLed0 <= '1';
			oLed1 <= '0';
			oLed2 <= '0';
			oLed3 <= '0';
			PWN_module	<= "00"; --LDR
			FirstLine <=  X"20202020434C4B5F47656E7E20202020";
			SecondLine <= X"20202020204C69676874212020202020";
			if BTN1_DB_pulse = '1' then
					next_clkgenstate <= module2;
			end if;	
	
		when module2 =>
			oLed0 <= '0';
			oLed1 <= '1';
			oLed2 <= '0';
			oLed3 <= '0';
			PWN_module	<= "01"; --THER
			FirstLine <=  X"20202020434C4B5F47656E7E20202020";
			SecondLine <= X"20202020204865617421212020202020";
			if BTN1_DB_pulse = '1' then
					next_clkgenstate <= module4;
			end if;	
			
		when module4=>
			oLed0 <= '0';
			oLed1 <= '0';
			oLed2 <= '0';
			oLed3 <= '1';
			PWN_module	<= "11"; --POT
			FirstLine <=  X"20202020434C4B5F47656E7E20202020";
			SecondLine <= X"20506F74656E74696F6D657465722120";
			if BTN1_DB_pulse = '1' then
					next_clkgenstate <= module1;
			end if;
		end case;
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
    Port map ( clk => iclk,
           ValidKeyPressedPulse => kpPulse20ns,
           iKey0 => BTN0_DB,  
           iKey1 => BTN1_DB,       
           iKey2 => BTN2_DB,
           clkEnFiveMS => clock_en5ms,
           state_value_out => CurrentState
        ); 

--------------------------------------------------------------------------------------------------------------------
INST_ADC_I2C_USRLOGIC: ADC_I2C_user_logic 							-- Modified from SPI usr logic from last year
    Port map( iclk => iClk,
	 			  byteSel =>PWN_module,
			  EightBitDataFromADC => dataFromADC,
           oADCSDA => ADC_I2C_SDA,
           oADCSCL => ADC_I2C_SCL
			  );
--end component;
--------------------------------------------------------------------------------------------------------------------
INST_LCD_I2C_UsrLogic: LCDI2C_user_logic
    Port map( iclk => iClk,
           dataIn => I2CandLCDData,
			  FirstLineInput => FirstLine,
			  SecondLineInput => SecondLine,
           oLCDSDA => LCD_I2C_SDA,
			  oLCDSCL => LCD_I2C_SCL
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
INST_BTN1Pulse:btn_debounce_toggle
GENERIC map (
	CNTR_MAX => X"FFFF")  
	Port map (
		BTN_I => BTN1,
	  	CLK => iClk,
	 	BTN_O => open,
	 	TOGGLE_O => open,
		PULSE_O   => BTN1_DB_pulse
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
    Port map( iClk       => iClk,
           Adjustvar  => DataFromADC,
           CLOCK_OUT  => FinaloClk_Gen
	);
------------------------------------------------------------------------------------------------------------------

end Structural;