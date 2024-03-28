library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity ADC_I2C_user_logic is							-- Modified from SPI usr logic from last year
    Port ( iclk : in STD_LOGIC;
			  byteSel : in std_LOGIC_VECTOR(1 downto 0);
			  EightBitDataFromADC: out std_LOGIC_VECTOR(7 downto 0);
           oADCSDA : inout STD_LOGIC;
           oADCSCL : inout STD_LOGIC
			  );
end ADC_I2C_user_logic;

architecture Behavioral of ADC_I2C_user_logic is

------------------------------------------------------------------------------------------------------------------
component i2c_master IS
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz (ADC can only run 100khz(slow mode))
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component i2c_master;
------------------------------------------------------------------------------------------------------------------
signal regBusy,sigBusy,reset,enable,rw_sig : std_logic;

signal wData : std_logic_vector(15 downto 0);

signal dataOut : std_logic_vector(7 downto 0):= "00000000";

type state_type is (start,write,read,stop);

signal State : state_type := start;

signal address : std_logic_vector(6 downto 0);

signal Counter : integer range 0 to 16383 := 16383;			-- delay time when a new data transaction occurs

signal ReadData :std_LOGIC_VECTOR(7 downto 0);

signal byteSel_prev: std_LOGIC_VECTOR(1 downto 0);


begin
------------------------------------------------------------------------------------------------------------------
INST_I2C_master: i2c_master
	Generic map(input_clk => 50_000_000, bus_clk=>100_000)
	port map (
		clk       =>  iclk,
		reset_n   =>  reset,
		ena       =>  enable,
		addr      =>  address,						-- For implementation of 2 or more components, link address to a mux to select which component.
		rw        =>  rw_sig,
		data_wr   =>  dataOut,
		busy      =>  sigBusy,
		data_rd   =>  ReadData,
		ack_error =>  open,					--Prof told to leave open :D, not my fault if 7 Seg blows up for somereason |_(ツ)_|	
		sda       =>  oADCSDA,
		scl       =>  oADCSCL
		);
	
------------------------------------------------------------------------------------------------------------------
EightBitDataFromADC <= ReadData;
StateChange: process (iClk)
begin
	if rising_edge(iClk) then

		case State is
		
			when start =>
				if Counter /= 0 then
					Counter<=Counter-1;
					reset<='0';
					State<=start;
					enable<='0';
				else
					reset<='1';					-- Sent to I2C master to start ready transaction
					rw_sig<='0';				-- Sends the write signal
					address<="1001000";		-- Hardcoded to X"48", ADC's default address
					State<=write;
				end if;
			
-- I2C will first write TO the ADC the desired channel(this is controlled by byteSel which will be an input source from a state machine
-- After writing the address and ONE write interaction, this will switch to read mode and start obtaining data through data_rd
-- Will make the I2C go back to writemode when the bytesel changes

			when write=>
				enable<='1';				-- Sent to I2C master to transition to start state.
				regBusy <= sigBusy;

				if regBusy /= sigBusy and sigBusy = '0' then  --Checks if Busy = '0';
					ByteSel_prev <= ByteSel;
						rw_sig<='1';		-- Sends the write signal
						State<=read;		--Guarantees ONE write transaction to the ADC with the necessary Channel setup
				end if;
				
			when read =>
				enable<='1';				-- Sent to I2C master to transition to start state.
				regBusy <= sigBusy;
				
				if regBusy /= sigBusy and sigBusy = '0' then  --Checks if Busy = '0';
					ByteSel_prev <= ByteSel;	
					if ByteSel_prev /= ByteSel then		-- CHECKS IF NEW MODE IS REQUESTED
						rw_sig<='0';		-- Sends the write signal
						counter <= 16383;
						enable<='0';
						State<=start;
					else
						rw_sig<='1';
						State<=read;
					end if;
				end if;
			
			when stop=>
				enable<='0';
				if ByteSel_prev /= ByteSel then		-- CURRENTLY TESTING NO STOP MODE TO SEE IF WORKS 
					State<=start;
				else
					State<=stop;
				end if;
			end case;
	end if;
end process;
------------------------------------------------------------------------------------------------------------------
process(byteSel,iClk)
begin
    case byteSel is
	 -- D7, D6, D5, D4, LED:= '1', EN ,R/W , RS
when "00"  => dataOut <= "00000000";	--Data out will change the ADC to channel 0
when "01"  => dataOut <= "00000001";  --Data out will change the ADC to channel 1 
when "10"  => dataOut <= "00000010";	--Data out will change the ADC to channel 3 
when "11"  => dataOut <= "00000011";	--Data out will change the ADC to channel 2 PWM THING

    end case;
end process;
------------------------------------------------------------------------------------------------------------------
end Behavioral;



--TODO:
-- Fully implement read functionality of I2C(including NACK)