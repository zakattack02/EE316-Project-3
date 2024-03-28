library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
entity top_level_tb is
end top_level_tb;

architecture Structural of top_level_tb is
component top_level is
	port(
		iClk   	 : in std_logic;
		Input_Reset : in std_logic;				-- This is basically Key0
		iKey1 : in std_logic;
		iKey2 : in std_logic;
		iKey3 : in std_logic;
	
		TESTINGLED     : out std_LOGIC;
		LCD_DATA        : out std_logic_vector(7 downto 0);   --(8-bit Data)
		LCD_EN          : out std_logic;  --(1-bit Enable)
		LCD_RS          : out std_logic;   --(1-bit Register_Select)

      SRAM_we_n     : out std_logic;
      SRAM_oe_n     : out std_logic;
      SRAM_ce_n     : out std_logic;
      SRAM_lb_n     : out std_logic;
      SRAM_ub_n     : out std_logic;
      SRAM_io       : inout std_logic_vector(15 downto 0);    
      SRAM_Address  : out std_logic_vector(19 downto 0);
		
		I2C_SDA : inout std_LOGIC;
		I2C_SCL : inout std_LOGIC;
		
		HEX4OUT : out std_logic_vector(6 downto 0);
		HEX5OUT : out std_logic_vector(6 downto 0);
		
		HEX6OUT : out std_logic_vector(6 downto 0);
		HEX7OUT : out std_logic_vector(6 downto 0)
	);
end component;

		signal iClk   	 :      std_logic;
		signal Input_Reset :   std_logic;				-- This is basically Key0
		signal iKey1 :     std_logic;
		signal iKey2 :     std_logic;
		signal iKey3 :     std_logic;
	
		signal TESTINGLED     :    std_LOGIC;
		signal LCD_DATA        :   std_logic_vector(7 downto 0);   --(8-bit Data)
		signal LCD_EN          :   std_logic;  --(1-bit Enable)
		signal LCD_RS          :   std_logic;   --(1-bit Register_Select)

      signal SRAM_we_n     :   std_logic;
      signal SRAM_oe_n     :   std_logic;
      signal SRAM_ce_n     :   std_logic;
      signal SRAM_lb_n     :   std_logic;
      signal SRAM_ub_n     :   std_logic;
      signal SRAM_io       :   std_logic_vector(15 downto 0);    
      signal SRAM_Address  :   std_logic_vector(19 downto 0);
		
		signal I2C_SDA :   std_LOGIC;
		signal I2C_SCL :   std_LOGIC;
		
		signal HEX4OUT :   std_logic_vector(6 downto 0);
		signal HEX5OUT :   std_logic_vector(6 downto 0);
		
		signal HEX6OUT :   std_logic_vector(6 downto 0);
		signal HEX7OUT :   std_logic_vector(6 downto 0);
begin
DUT: top_level
port map(
		 iClk   	 =>      iClk,
		 Input_Reset =>   Input_Reset,				--Input_Reset, This is basically Key0
		 iKey1 =>     iKey1,
		 iKey2 =>     iKey2,
		 iKey3 =>     iKey3,
	
		 TESTINGLED     =>    TESTINGLED,
		 LCD_DATA        =>   LCD_DATA,
		 LCD_EN          =>     LCD_EN,
		 LCD_RS          =>      LCD_RS,

         SRAM_we_n     =>   SRAM_we_n,
         SRAM_oe_n     =>   SRAM_oe_n,
         SRAM_ce_n     =>   SRAM_ce_n,
         SRAM_lb_n     =>   SRAM_lb_n,
         SRAM_ub_n     =>   SRAM_ub_n,
         SRAM_io       =>    SRAM_io,
         SRAM_Address  =>   SRAM_Address,
		
		 I2C_SDA =>   I2C_SDA,
		 I2C_SCL =>   I2C_SCL,
		
		 HEX4OUT =>  HEX4OUT,
		 HEX5OUT =>  HEX5OUT,
		
		 HEX6OUT =>   HEX6OUT,
		 HEX7OUT =>   HEX7OUT
);
iClk <= not ICLK after 10 ns;

end Structural;