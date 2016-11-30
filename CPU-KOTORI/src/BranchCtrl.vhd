----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:41:03 11/27/2016 
-- Design Name: 
-- Module Name:    BranchCtrl - Behavioral 
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

entity BranchCtrl is

port(
    inst_i : in Bus16;
    ins_type_i : in InsType;
    pc_i : in Bus16;
    
    --from ALU
    alu_res_i : in Bus16;
    --from Forward
    flag_i : in Bus16;
    
    is_Jump : out std_logic := V_FALSE;
    pc_o : out Bus16 := ZERO_16);


end BranchCtrl;

architecture Behavioral of BranchCtrl is

begin

process(ins_type_i, alu_res_i, flag_i, pc_i)
begin

case ins_type_i is
    when ins_B =>
        is_Jump <= V_TRUE;
        pc_o <= alu_res_i;
    when ins_BEQZ | ins_BTEQZ => 
        if(conv_integer(flag_i) = 0) then
            is_Jump <= V_TRUE;
            pc_o <= alu_res_i;
        else
            is_Jump <= V_FALSE;
            pc_o <= pc_i;
        end if;
    when ins_BNEZ =>
        if(conv_integer(flag_i) /= 0) then
            is_Jump <= V_TRUE;
            pc_o <= alu_res_i;
        else
            is_Jump <= V_FALSE;
            pc_o <= pc_i;
        end if;
    when ins_JALR | ins_JR | ins_JRRA =>
        is_Jump <= V_TRUE;
        pc_o <= alu_res_i;
    when others =>
        is_Jump <= V_FALSE;
        pc_o <= pc_i;
end case;

end process;

end Behavioral;
















