----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:11:13 11/26/2016 
-- Design Name: 
-- Module Name:    Forward - Behavioral 
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

entity Forward is

port(
--本条指令的信息，从 ID_EXE 获得
    cur_ins_i : in Bus16;
    cur_ins_type_i : in InsType;
    
    --read 寄存器优先顺序：
    --R[x] > R[y] > 参与运算的特殊寄存器 > 作为 flag 的特殊寄存器
    cur_rreg1_type_i : in RegType;
    cur_rreg1_data_i : in Bus16;
    
    cur_rreg2_type_i : in RegType;
    cur_rreg2_data_i : in Bus16;
    
    cur_exted_imm_i : in Bus16;
       
--上条指令信息，从 EXE_MEM 获得
    l_ins_type_i : InsType;
    l_is_wreg_i : in std_logic;
    l_wreg_type_i : in RegType;
    l_wreg_data_i : in Bus16;
    
--上上条指令信息，从 MEM_WB 获得
    ll_ins_type_i : in InsType;
    ll_is_wreg_i : std_logic;
    ll_wreg_type_i : in RegType;
    ll_wreg_data_i : in Bus16;
    
    alu_A_fin_o : out Bus16 := ZERO_16;
    alu_B_fin_o : out Bus16 := ZERO_16;
    
    --用于 SW, SW_SP 指令，仅该指令的计算在赋
    --值号左边，且恰好赋值号右边只有一个变量
    --以及JALR 指令的
    single_value_fin_o : out Bus16 := ZERO_16; 
    
    flag_A_fin_o : out Bus16 := ZERO_16);
    --flag_B_fin_o : out Bus16);

end Forward;

architecture Behavioral of Forward is

begin

process(
    cur_ins_type_i,
    cur_rreg1_type_i, cur_rreg1_data_i,
    cur_rreg2_type_i, cur_rreg2_data_i,
    cur_exted_imm_i,
    
    l_is_wreg_i, l_wreg_type_i, l_wreg_data_i,
    ll_ins_type_i, ll_wreg_type_i, ll_wreg_data_i)

begin
    
-- if((ll_wreg_type_i = cur_rreg1_type_i) or (ll_wreg_type_i = cur_rreg2_type_i or
   -- (l_wreg_type_i = cur_rreg1_type_i) or (l_wreg_type_i = cur_rreg2_type_i)) then
    --对每条指令分别搞
    case cur_ins_type_i is
        when ins_ADDIU | ins_ADDIU3 | ins_ADDSP3 | ins_ADDSP |
             ins_B | ins_LW | ins_LW_SP =>
            if(cur_rreg1_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
            alu_B_fin_o <= cur_exted_imm_i;
        when ins_ADDU | ins_AND | ins_CMP | ins_OR | ins_SLT |
             ins_SUBU =>
            if(cur_rreg1_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
            if(cur_rreg2_type_i = l_wreg_type_i) then
                alu_B_fin_o <= l_wreg_data_i;
            elsif(cur_rreg2_type_i = ll_wreg_type_i) then
                alu_B_fin_o <= ll_wreg_data_i;
            else
                alu_B_fin_o <= cur_rreg1_data_i;
            end if;
            
        when ins_BEQZ | ins_BNEZ =>
        
            if(cur_rreg2_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg2_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
            alu_B_fin_o <= cur_exted_imm_i;
            
            if(cur_rreg1_type_i = l_wreg_type_i) then
                flag_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                flag_A_fin_o <= ll_wreg_data_i;
            else
                flag_A_fin_o <= cur_rreg1_data_i;
            end if;
            
        when ins_BTEQZ =>
        
            if(cur_rreg1_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
            alu_B_fin_o <= cur_exted_imm_i;
            
            if(cur_rreg2_type_i = l_wreg_type_i) then
                flag_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg2_type_i = ll_wreg_type_i) then
                flag_A_fin_o <= ll_wreg_data_i;
            else
                flag_A_fin_o <= cur_rreg1_data_i;
            end if;
            
        when ins_JALR | ins_JR | ins_JRRA |
             ins_MFIH | ins_MFPC | ins_MOVE | ins_MTIH | ins_MTSP =>
            
            if(cur_rreg1_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
        when ins_LI => 
            alu_A_fin_o <= cur_exted_imm_i;
        when ins_NOP => null;
        when ins_SLL | ins_SRA =>
            if(cur_rreg1_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
            if(conv_integer(cur_exted_imm_i) = 0)then
                alu_B_fin_o <= conv_std_logic_vector(8, 16);
            else
                alu_B_fin_o <= cur_exted_imm_i;
            end if;
        when ins_SW =>
        
            if(cur_rreg1_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg1_data_i;
            end if;
            
            alu_B_fin_o <= cur_exted_imm_i;
            
            if(cur_rreg2_type_i = l_wreg_type_i) then
                single_value_fin_o <= l_wreg_data_i;
            elsif(cur_rreg2_type_i = ll_wreg_type_i) then
                single_value_fin_o <= ll_wreg_data_i;
            else
                single_value_fin_o <= cur_rreg2_data_i;
            end if;
            
        when ins_SW_SP =>
        
            if(cur_rreg2_type_i = l_wreg_type_i) then
                alu_A_fin_o <= l_wreg_data_i;
            elsif(cur_rreg2_type_i = ll_wreg_type_i) then
                alu_A_fin_o <= ll_wreg_data_i;
            else
                alu_A_fin_o <= cur_rreg2_data_i;
            end if;
            
            alu_B_fin_o <= cur_exted_imm_i;
            
            if(cur_rreg1_type_i = l_wreg_type_i) then
                single_value_fin_o <= l_wreg_data_i;
            elsif(cur_rreg1_type_i = ll_wreg_type_i) then
                single_value_fin_o <= ll_wreg_data_i;
            else
                single_value_fin_o <= cur_rreg1_data_i;
            end if;
            
        when others => null;
    end case;
-- else
    -- case cur_ins_type_i is
        -- when ins_ADDIU | ins_ADDIU3 | ins_ADDSP3 | ins_ADDSP |
             -- ins_B | ins_LW | ins_LW_SP =>
            -- alu_A_fin_o <= cur_rreg1_data_i;
            -- alu_B_fin_o <= cur_exted_imm_i;
        -- when ins_ADDU | ins_AND | ins_CMP | ins_OR | ins_SLT |
             -- ins_SUBU =>
            -- alu_A_fin_o <= cur_rreg1_data_i;
            -- alu_B_fin_o <= cur_rreg2_data_i;
        -- when ins_BEQZ | ins_BNEZ =>
            -- alu_A_fin_o <= cur_rreg2_data_i;
            -- alu_B_fin_o <= cur_exted_imm_i;
            -- flag_A_fin_o <= cur_rreg1_data_i;
        -- when ins_BTEQZ =>
            -- alu_A_fin_o <= cur_rreg1_data_i;
            -- alu_B_fin_o <= cur_exted_imm_i;
            -- flag_A_fin_o <= cur_rreg2_data_i;
        -- when ins_JALR | ins_JR | ins_JRRA |
             -- ins_MFIH | ins_MFPC | ins_MOVE | ins_MTIH | ins_MTSP =>
            -- alu_A_fin_o <= cur_rreg1_data_i;
        -- when ins_LI =>
            -- alu_A_fin_o <= cur_exted_imm_i;
        -- when ins_NOP => null;
        -- when ins_SLL | ins_SRA =>
            -- alu_A_fin_o <= cur_rreg1_data_i;
            -- if(conv_integer(cur_exted_imm_i) = 0) then
                -- alu_B_fin_o <= conv_std_logic_vector(8, 16);
            -- else
                -- alu_B_fin_o <= cur_exted_imm_i;
            -- end if;
        -- when ins_SW =>
            -- alu_A_fin_o <= cur_rreg1_data_i;
            -- alu_B_fin_o <= cur_exted_imm_i;
            -- single_value_fin_o <= cur_rreg2_data_i;
        -- when ins_SW_SP =>
            -- alu_A_fin_o <= cur_rreg2_data_i;
            -- alu_B_fin_o <= cur_exted_imm_i;
            -- single_value_fin_o <= cur_rreg1_data_i;
        -- when others => null;
    -- end case;       
-- end if;

end process;
    
end Behavioral;
