library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_pwm is
   generic(N: integer := 5; N2: integer := 32; N1: integer := 0);
   port(
			clk, reset					: in std_logic;
			state                   : in integer;
			syn_clr, load, en, up	: in std_logic;
			clk_en 						: in std_logic := '1';
			d								: in std_logic_vector(N2-1 downto 0);
			q								: out std_logic_vector(7 downto 0)		
   );
end counter_pwm;

architecture arch of counter_pwm is
   signal r_reg				 	: unsigned(N2-1 downto 0):=X"00000000";
   signal r_next				 	: unsigned(N2-1 downto 0);
   signal r_1				    	: unsigned(N2-1 downto 0);
   signal r_2				    	: unsigned(N2-1 downto 0);
	constant M_1               : integer:= 5153;
	constant M_2               : integer:= 10307;
	constant M_3               : integer:= 85899;
begin
   -- register
--   process(clk,reset)
--   begin
--      if (reset='1') then
--         r_reg <= (others=>'0');
--      elsif rising_edge(clk)  then  --and clk_en = '1'
--         r_reg <= r_next;
--      end if;
--   end process;
--	
   -- next-state logic
--   r_next <= (others=>'0') when syn_clr='1' else
--             unsigned(d)   when load='1' else
--			 r_1     	   when en ='1' and up='1' else
--             r_2     	   when en ='1' and up='0' else
--             r_reg;
				 
	Process(clk, reset, state, r_reg)
	begin     
	if rising_edge(clk) then
		case state is
			when 0 =>						--60hz
				
						r_reg <= r_reg - M_1;
						q        <= std_logic_vector(r_reg(31 downto 24));
			when 1 =>						--120hz
						r_reg <= r_reg - M_2;
						q        <= std_logic_vector(r_reg(31 downto 24));
			when 2 =>						--1000hz
						r_reg <= r_reg - M_3;
						q        <= std_logic_vector(r_reg(31 downto 24));
			when others =>					--60hz
						r_reg <= r_reg - M_1;
						q        <= std_logic_vector(r_reg(31 downto 24));
			end case;
		end if;
	end process;	
	
--   q        <= std_logic_vector(r_reg(31 downto 24));

end arch;
