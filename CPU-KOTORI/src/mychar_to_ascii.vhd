----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:51:41 12/03/2016 
-- Design Name: 
-- Module Name:    mychar_to_ascii - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mychar_to_ascii is 
port(
    mychar_i : in std_logic_vector(7 downto 0);
    ascii_o : out std_logic_vector(7 downto 0));
end mychar_to_ascii;

architecture Behavioral of mychar_to_ascii is

begin

process(mychar_i)
begin

    case mychar_i is

        when "00010000" => ascii_o <= x"30";    -- 0
        when "00010001" => ascii_o <= x"31";    -- 1
        when "00010010" => ascii_o <= x"32";    -- 2
        when "00010011" => ascii_o <= x"33";    -- 3
        when "00010100" => ascii_o <= x"34";    -- 4
        when "00010101" => ascii_o <= x"35";    -- 5
        when "00010110" => ascii_o <= x"36";    -- 6
        when "00010111" => ascii_o <= x"37";    -- 7
        when "00011000" => ascii_o <= x"38";    -- 8
        when "00011001" => ascii_o <= x"39";    -- 9
        when "00100001" => ascii_o <= x"41";    -- A
        when "00100010" => ascii_o <= x"42";    -- B
        when "00100011" => ascii_o <= x"43";    -- C
        when "00100100" => ascii_o <= x"44";    -- D
        when "00100101" => ascii_o <= x"45";    -- E
        when "00100110" => ascii_o <= x"46";    -- F
        when "00100111" => ascii_o <= x"47";    -- G
        when "00101000" => ascii_o <= x"48";    -- H
        when "00101001" => ascii_o <= x"49";    -- I
        when "00101010" => ascii_o <= x"4A";    -- J
        when "00101011" => ascii_o <= x"4B";    -- K
        when "00101100" => ascii_o <= x"4C";    -- L
        when "00101101" => ascii_o <= x"4D";    -- M
        when "00101110" => ascii_o <= x"4E";    -- N
        when "00101111" => ascii_o <= x"4F";    -- O
        when "00110000" => ascii_o <= x"50";    -- P
        when "00110001" => ascii_o <= x"51";    -- Q
        when "00110010" => ascii_o <= x"52";    -- R
        when "00110011" => ascii_o <= x"53";    -- S
        when "00110100" => ascii_o <= x"54";    -- T
        when "00110101" => ascii_o <= x"55";    -- U
        when "00110110" => ascii_o <= x"56";    -- V
        when "00110111" => ascii_o <= x"57";    -- W
        when "00111000" => ascii_o <= x"58";    -- X
        when "00111001" => ascii_o <= x"59";    -- Y
        when "00111010" => ascii_o <= x"5A";    -- Z
        when "00000000" => ascii_o <= x"20";    -- space
        when "00001100" => ascii_o <= x"2C";    -- ,
        when "00111011" => ascii_o <= x"5B";    -- [
        when "00111101" => ascii_o <= x"5D";    -- ]
        when "00011101" => ascii_o <= x"3D";    -- =
        when "00000001" => ascii_o <= x"27";    -- '
        when "00001110" => ascii_o <= x"2E";    -- .
        when "00011011" => ascii_o <= x"3B";    -- ;
        when "11111100" => ascii_o <= x"0A";    -- enter -> LF 换行
        when "11110000" => ascii_o <= x"40";    -- F0 -> @
        when others => ascii_o <= x"23";        -- #
    end case;
    
end process;

end Behavioral;














