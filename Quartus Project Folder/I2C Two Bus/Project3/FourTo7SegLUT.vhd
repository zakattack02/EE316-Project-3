library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FourTo7SegLUT is
   port(
		iFourBitData : in std_logic_vector(3 downto 0);
		oSevenSegmentData : out std_logic_vector(6 downto 0)
   );
end FourTo7SegLUT;

architecture Behavioral of FourTo7SegLUT is
begin
oSevenSegmentData <= "1000000" when iFourBitData = "0000" else
"1111001" when iFourBitData = "0001" else
"0100100" when iFourBitData = "0010" else
"0110000" when iFourBitData = "0011" else
"0011001" when iFourBitData = "0100" else
"0010010" when iFourBitData = "0101" else
"0000010" when iFourBitData = "0110" else
"1111000" when iFourBitData = "0111" else
"0000000" when iFourBitData = "1000" else
"0010000" when iFourBitData = "1001" else
"0001000" when iFourBitData = "1010" else
"0000011" when iFourBitData = "1011" else
"1000110" when iFourBitData = "1100" else
"0100001" when iFourBitData = "1101" else
"0000110" when iFourBitData = "1110" else
"0001110" when iFourBitData = "1111" else
null;
end Behavioral;
