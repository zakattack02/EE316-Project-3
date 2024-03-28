library ieee;
use ieee.std_logic_1164.all;

entity EightBitToLCDLUT is
	PORT(
         iFourBit		:	in std_logic_vector(3 downto 0);
			oLCD_Data		:	out std_logic_vector(7 downto 0)
		);

end EightBitToLCDLUT;


architecture Behavioral of EightBitToLCDLUT is


begin
process(iFourBit)
	begin
	case iFourBit is 
	when "0000" =>oLCD_Data <=X"30";
	when "0001" =>oLCD_Data <=X"31";
	when "0010" =>oLCD_Data <=X"32";
	when "0011" =>oLCD_Data <=X"33";
	when "0100" =>oLCD_Data <=X"34";
	when "0101" =>oLCD_Data <=X"35";
	when "0110" =>oLCD_Data <=X"36";
	when "0111" =>oLCD_Data <=X"37";
	when "1000" =>oLCD_Data <=X"38";
	when "1001" =>oLCD_Data <=X"39";
	when "1010" =>oLCD_Data <=X"41";
	when "1011" =>oLCD_Data <=X"42";
	when "1100" =>oLCD_Data <=X"43";
	when "1101" =>oLCD_Data <=X"44";
	when "1110" =>oLCD_Data <=X"45";
	when "1111" =>oLCD_Data <=X"46";


	end case;
	end process;
	end Behavioral;