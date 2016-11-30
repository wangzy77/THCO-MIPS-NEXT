----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:09:09 11/27/2016 
-- Design Name: 
-- Module Name:    ID_EXE - Behavioral 
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

entity ID_EXE is

port(
----------------------------------------------------------------------------------
    clk : in std_logic;
    rst : in std_logic;
    --
    write_EN_i : in std_logic;
    
----------------------------------------------------------------------------------
--from controller
    inst_i : in Bus16;
    inst_type_i : in InsType;
    alu_op_i : in AluOP;
    rreg1_type_i : in RegType;
    rreg1_data_i : in Bus16;
    rreg2_type_i : in RegType;
    rreg2_data_i : in Bus16;
    exted_imm_i : in Bus16;
    is_wreg_i : in std_logic;
    wreg_type_i : in RegType;
----------------------------------------------------------------------------------
--from IF_ID
    pc_i : in Bus16;
----------------------------------------------------------------------------------
--out
    inst_o : out Bus16;
    inst_type_o : out InsType;
    
    alu_op_o : out AluOP;
    
    rreg1_type_o : out RegType;
    rreg1_data_o : out Bus16;
    rreg2_type_o : out RegType;
    rreg2_data_o : out Bus16;
    
    exted_imm_o : out Bus16;
    is_wreg_o : out std_logic;
    wreg_type_o : out RegType;
    
    pc_o : out Bus16);

end ID_EXE;

architecture Behavioral of ID_EXE is

begin

process(rst, clk)
begin

if(rst = RST_EN) then
    inst_o <= INSTRUCTION_NOP;
    inst_type_o <= ins_NOP;
    
    alu_op_o <= alu_NULL;
    
    rreg1_type_o <= reg_ERR;
    rreg1_data_o <= ZERO_16;
    rreg2_type_o <= reg_ERR;
    rreg2_data_o <= ZERO_16;
    
    exted_imm_o <= ZERO_16;
    is_wreg_o <= WRITE_DIS;
    wreg_type_o <= reg_ERR;
    
    pc_o <= ZERO_16;
elsif(write_EN_i = WRITE_EN) then
    if(clk'event and clk = '0') then
        inst_o <= inst_i;
        inst_type_o <= inst_type_i;

        alu_op_o <= alu_op_i;

        rreg1_type_o <= rreg1_type_i;
        rreg1_data_o <= rreg1_data_i;
        rreg2_type_o <= rreg2_type_i;
        rreg2_data_o <= rreg2_data_i;

        exted_imm_o <= exted_imm_i;
        is_wreg_o <= is_wreg_i;
        wreg_type_o <= wreg_type_i;

        pc_o <= pc_i;
    end if;
end if;

end process;

end Behavioral;
