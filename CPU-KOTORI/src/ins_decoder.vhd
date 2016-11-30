----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:13:24 11/24/2016 
-- Design Name: 
-- Module Name:    ins_decoder - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library WORK;
use WORK.util.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ins_decoder is

port(
    ins : in std_logic_vector(15 downto 0);
    ins_type : out InsType);

end ins_decoder;

architecture Behavioral of ins_decoder is

begin

process(ins)
begin
    case ins(15 downto 11) is
        when "00000" => ins_type <= ins_ADDSP3;
        when "00001" => ins_type <= ins_NOP;
        when "00010" => ins_type <= ins_B;
        when "00100" => ins_type <= ins_BEQZ;
        when "00101" => ins_type <= ins_BNEZ;
        when "00110" => 
            case ins(1 downto 0) is
                when "00" => ins_type <= ins_SLL;
                when "11" => ins_type <= ins_SRA;
                when others => ins_type <= ins_NOP;
            end case;
        when "01000" => ins_type <= ins_ADDIU3;
        when "01001" => ins_type <= ins_ADDIU;
        when "01100" => 
            case ins(10 downto 8) is
                when "000" => ins_type <= ins_BTEQZ;
                when "011" => ins_type <= ins_ADDSP;
                when "100" => ins_type <= ins_MTSP;
                when others => ins_type <= ins_NOP;
            end case;
        when "01101" => ins_type <= ins_LI;
        when "01111" => ins_type <= ins_MOVE;
        when "10010" => ins_type <= ins_LW_SP;
        when "10011" => ins_type <= ins_LW;
        when "11010" => ins_type <= ins_SW_SP;
        when "11011" => ins_type <= ins_SW;
        when "11100" => 
            case ins(1 downto 0) is
                when "01" => ins_type <= ins_ADDU;
                when "11" => ins_type <= ins_SUBU;
                when others => ins_type <= ins_NOP;
            end case;
        when "11101" =>
            case ins(4 downto 0) is
                when "00000" =>
                    case ins(7 downto 5) is
                        when "001" => ins_type <= ins_JRRA;
                        when "000" => ins_type <= ins_JR;
                        when "010" => ins_type <= ins_MFPC;
                        when "110" => ins_type <= ins_JALR;
                        when others => ins_type <= ins_NOP;
                    end case;
                when "00010" => ins_type <= ins_SLT;
                when "01010" => ins_type <= ins_CMP;
                when "01100" => ins_type <= ins_AND;
                when "01101" => ins_type <= ins_OR;
                when others => ins_type <= ins_NOP;
            end case;
        when "11110" =>
            case ins(7 downto 0) is
                when "00000000" => ins_type <= ins_MFIH;
                when "00000001" => ins_type <= ins_MTIH;
                when others => ins_type <= ins_NOP;
            end case;
        when others => ins_type <= ins_NOP;
    end case;
end process;


end Behavioral;




















