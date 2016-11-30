--tube_encoder
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tube_encoder is
port(
    key:in std_logic_vector(3 downto 0);
    display:out std_logic_vector(6 downto 0));
end entity;

architecture bhv of tube_encoder is
begin

process(key)
begin
    case key is							     
    --decoding Table
    --key(6 downto 0) -> a~g 逆时针，最上为 a, 中间为 g.
        when "0000" => display <= "1111110";	--0
        when "0001" => display <= "0110000";	--1
        when "0010" => display <= "1101101";	--2
        when "0011" => display <= "1111001";	--3
        when "0100" => display <= "0110011";	--4
        when "0101" => display <= "1011011";	--5
        when "0110" => display <= "0011111";	--6
        when "0111" => display <= "1110000";	--7
        when "1000" => display <= "1111111";	--8
        when "1001" => display <= "1110011";	--9
        when "1010" => display <= "1110111";	--a
        when "1011" => display <= "0011111";	--b
        when "1100" => display <= "1001110";	--c
        when "1101" => display <= "0111101";	--d
        when "1110" => display <= "1001111";	--e
        when "1111" => display <= "1000111";	--f
        when others => display <= "0000000";	--ERROE
    end case;
end process;

end architecture bhv;