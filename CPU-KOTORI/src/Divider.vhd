--Divider
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library WORK;
use WORK.util.ALL;

entity Divider is
    port(clkin : in std_logic;
         clkout : out std_logic;
         key_in : in std_logic_vector(3 downto 0)
         );
end entity;

architecture bhv of Divider is

signal data:integer range 0 to 1000000;
signal q : std_logic;

begin
process(clkin)						--divider

	variable div_rate : integer range 0 to 1000000 := 1;
    
begin


    case key_in(3 downto 0) is
        when "0010" => div_rate := 50;
        when "0011" => div_rate := 1000;
        when "0100" => div_rate := 100000;
        when others => div_rate := 1;
    end case;
    
	if (clkin'event and clkin = '1') then
		if(data = div_rate - 1) then 			--data=0,1,2,3,4.......9的分频比为1,2，3，，,10
			data <= 0;
			q <= not q;
		else
			data <= data + 1;
		end if;
	end if;
	clkout <= q;
end process;

end architecture bhv;