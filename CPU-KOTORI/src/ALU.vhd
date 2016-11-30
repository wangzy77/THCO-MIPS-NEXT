----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:03:28 11/26/2016 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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

entity ALU is

port(
    in1 : in Bus16;
    in2 : in Bus16;
    op : in AluOP;
    
    res : out Bus16 := ZERO_16);
end ALU;

architecture Behavioral of ALU is

begin

process(in1, in2, op)
begin

case op is
    when alu_PLUS => res <= in1 + in2;
    when alu_MINUS => res <= in1 - in2;
    when alu_AND => res <= in1 and in2;
    when alu_OR => res <= in1 or in2;
    when alu_NOT => res <= not in1;
    when alu_SLL => res <= TO_STDLOGICVECTOR(TO_BITVECTOR(in1) sll CONV_INTEGER(in2));
    when alu_SRL => res <= TO_STDLOGICVECTOR(TO_BITVECTOR(in1) srl CONV_INTEGER(in2));
    when alu_SLA => res <= TO_STDLOGICVECTOR(TO_BITVECTOR(in1) sla CONV_INTEGER(in2));
    when alu_SRA => res <= TO_STDLOGICVECTOR(TO_BITVECTOR(in1) sra CONV_INTEGER(in2));
    when alu_CMP =>
        if(in1 = in2) then
            res <= conv_std_logic_vector(0, 16);
        else
            res <= conv_std_logic_vector(1, 16);
        end if;
    when alu_SLT =>
        if(CONV_INTEGER(in1) < CONV_INTEGER(in2)) then
            res <= conv_std_logic_vector(1, 16);
        else
            res <= conv_std_logic_vector(0, 16);
        end if;
    when alu_NULL => res <= in1;
    when others => res <= ZERO_16;
end case;

end process;

end Behavioral;













