----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:31:40 12/02/2016 
-- Design Name: 
-- Module Name:    divider_10 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divider_10 is --
	generic(N: integer:=20; half: integer:=10; size: integer:=4);
	port(clk: in std_logic;
		 div: out std_logic);
end divider_10;

architecture Behavioral of divider_10 is
	signal result: std_logic:='0';
	signal cnt: std_logic_vector(size downto 0):=(others=>'0');
begin
	process(clk)
	begin
		if (clk'event and clk='1') then
			if (cnt<half-1) then
				cnt<=cnt+1;
			else
				cnt<=(others=>'0');
				result<=not(result);
			end if;
		end if;
		div<=result;
	end process;
end Behavioral;

